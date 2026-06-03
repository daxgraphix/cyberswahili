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
      if (!cached.isContentCached) _fetchContentInBackground(cached);
      return cached;
    }

    final content = await _api.fetchPostContent(postId);
    throw Exception(
        'Post not in cache. Refresh the feed first.\nDetail: $content');
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

  List<BlogPost> _sortByDate(List<BlogPost> posts) =>
      posts..sort((a, b) => b.published.compareTo(a.published));

  Future<void> _upsert(List<BlogPost> posts) async {
    final isar = await DatabaseService.isar;
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
        }
        await isar.blogPosts.put(post);
      }
    });
  }

  void _refreshInBackground(int maxResults) {
    _api.fetchPosts(maxResults: maxResults).then(_upsert).catchError((_) {});
  }

  void _refreshByLabelInBackground(String label, int maxResults) {
    _api
        .fetchPostsByLabel(label, maxResults: maxResults)
        .then(_upsert)
        .catchError((_) {});
  }

  void _fetchContentInBackground(BlogPost post) {
    _api.fetchPostContent(post.postId).then((content) async {
      final isar = await DatabaseService.isar;
      await isar.writeTxn(() async {
        post.content = content;
        post.isContentCached = true;
        await isar.blogPosts.put(post);
      });
    }).catchError((_) {});
  }
}