import 'dart:async';
import '../models/blog_post.dart';
import '../services/blogger_api_service.dart';
import '../services/database_service.dart';

class BlogRepository {
  final BloggerApiService _api;
  BlogRepository(this._api);

  static const int defaultPageSize = 20;
  static const int maxCacheSize = 500;

  Future<List<BlogPost>> getPosts({
    int maxResults = defaultPageSize,
    bool forceRefresh = false,
  }) async {
    final isar = await DatabaseService.isar;
    final cached = await isar.blogPosts.buildQuery<BlogPost>().findAll();
    final sortedCache = _sortByDate(cached);

    if (sortedCache.isNotEmpty && !forceRefresh) {
      _refreshInBackground(defaultPageSize);
      return sortedCache.take(maxResults).toList();
    }

    try {
      final fresh = await _api.fetchPosts(maxResults: maxResults * 3);
      await _upsert(fresh);
      return _sortByDate(fresh);
    } catch (e) {
      if (sortedCache.isNotEmpty) return sortedCache.take(maxResults).toList();
      rethrow;
    }
  }

  Future<List<BlogPost>> loadMorePosts({
    int maxResults = defaultPageSize,
    DateTime? afterDate,
  }) async {
    final fresh = await _api.fetchPosts(maxResults: maxResults * 2);
    await _upsert(fresh);
    
    final isar = await DatabaseService.isar;
    final all = await isar.blogPosts.buildQuery<BlogPost>().findAll();
    final sorted = _sortByDate(List.from(all));
    
    if (afterDate != null && sorted.any((p) => p.published.isBefore(afterDate))) {
      return sorted.skipWhile((p) => p.published.isAfter(afterDate)).take(maxResults).toList();
    }
    
    return sorted.take(maxResults).toList();
  }

  Future<BlogPost> getPostById(String postId) async {
    final isar = await DatabaseService.isar;
    final cached = await isar.blogPosts.getByPostId(postId);

    if (cached != null) {
      if (!cached.isContentCached || cached.content.trim().isEmpty) {
        try {
          await _cachePostContent(cached);
          // Return the updated object from DB to ensure content is present
          return await isar.blogPosts.getByPostId(postId) ?? cached;
        } catch (_) {
          return cached;
        }
      }
      return cached;
    }

    try {
      final fresh = await _api.fetchPost(postId);
      fresh.isContentCached = fresh.content.trim().isNotEmpty;
      await _upsert([fresh]);
      return fresh;
    } catch (e) {
      throw Exception('Makala haijapatikana. Tafadhali hakikisha una mtandao.');
    }
  }

  Future<Map<String, dynamic>> getCacheInfo() async {
    final isar = await DatabaseService.isar;
    final all = await isar.blogPosts.buildQuery<BlogPost>().findAll();
    final cachedCount = all.where((p) => p.isContentCached).length;
    
    // Estimate size (very rough: ~10KB per full post, 1KB per metadata)
    final totalBytes = (cachedCount * 10240) + ((all.length - cachedCount) * 1024);
    final mb = totalBytes / (1024 * 1024);
    
    return {
      'count': all.length,
      'cached': cachedCount,
      'size': mb.toStringAsFixed(2),
    };
  }

  Future<List<BlogPost>> getPostsByLabel(String label, {int maxResults = 50}) async {
    final all = await getPosts(forceRefresh: false, maxResults: 100);
    final filtered = _sortByDate(all
        .where(
          (p) => p.labels.any(
            (l) => l.toLowerCase().contains(label.toLowerCase()),
          ),
        )
        .toList());

    if (filtered.isNotEmpty) {
      _refreshByLabelInBackground(label, maxResults);
      return filtered;
    }

    final freshAll = await getPosts(forceRefresh: true, maxResults: 200);
    return _sortByDate(freshAll
        .where(
          (p) => p.labels.any(
            (l) => l.toLowerCase().contains(label.toLowerCase()),
          ),
        )
        .toList());
  }

  Future<void> clearCache() async {
    final isar = await DatabaseService.isar;
    await isar.writeTxn(() => isar.blogPosts.clear());
  }

  Future<List<BlogPost>> getCachedPosts() async {
    final isar = await DatabaseService.isar;
    final all = await isar.blogPosts.buildQuery<BlogPost>().findAll();
    return _sortByDate(all.where((p) => p.isContentCached).toList());
  }

  Future<void> deleteFromCache(String postId) async {
    final isar = await DatabaseService.isar;
    final post = await isar.blogPosts.getByPostId(postId);
    if (post != null) {
      await isar.writeTxn(() async {
        post.content = '';
        post.isContentCached = false;
        await isar.blogPosts.put(post);
      });
    }
  }

  Future<BlogPost> cachePostContent(String postId) async {
    final isar = await DatabaseService.isar;
    final cached = await isar.blogPosts.getByPostId(postId);
    if (cached == null) return getPostById(postId);
    if (cached.isContentCached && cached.content.trim().isNotEmpty) return cached;
    await _cachePostContent(cached);
    return cached;
  }

  List<BlogPost> _sortByDate(List<BlogPost> posts) =>
      posts..sort((a, b) => b.published.compareTo(a.published));

  Future<List<BlogPost>> _upsert(List<BlogPost> posts) async {
    final isar = await DatabaseService.isar;
    final List<BlogPost> newPosts = [];
    
    await isar.writeTxn(() async {
      for (final post in posts) {
        final existing = await isar.blogPosts.getByPostId(post.postId);
        if (existing != null) {
          post.id = existing.id;
          if (!post.isContentCached && existing.isContentCached) {
            post.content = existing.content;
            post.isContentCached = true;
          }
        } else {
          post.isContentCached = post.content.isNotEmpty;
          newPosts.add(post);
        }
        await isar.blogPosts.put(post);
      }
    });
    return newPosts;
  }

  void _refreshInBackground(int maxResults) {
    _api.fetchPosts(maxResults: maxResults).then((posts) async {
      await _upsert(posts);
      // We can hook into a callback or stream here if we want to notify
    }).catchError((_) {});
  }

  void _refreshByLabelInBackground(String label, int maxResults) {
    _api
        .fetchPostsByLabel(label, maxResults: maxResults)
        .then((posts) => _upsert(posts))
        .catchError((_) => <BlogPost>[]);
  }

  Future<void> _cachePostContent(BlogPost post) async {
    final content = await _api.fetchPostContent(post.postId);
    final isar = await DatabaseService.isar;
    await isar.writeTxn(() async {
      post.content = content;
      post.isContentCached = content.trim().isNotEmpty;
      await isar.blogPosts.put(post);
    });
  }
}
