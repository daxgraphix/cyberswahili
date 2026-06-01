import '../models/blog_post.dart';
import '../services/blogger_api_service.dart';
import '../services/database_service.dart';

/// Repository for managing blog posts with offline-first caching.
/// Handles fetching from Blogger API, local storage with Isar,
/// and provides methods for posts, categories, and individual articles.
class BlogRepository {
  final BloggerApiService _api;
  BlogRepository(this._api);

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<List<BlogPost>> getPosts(
      {int maxResults = 20, bool forceRefresh = false}) async {
    final isar = await DatabaseService.isar;
    final cached = await isar.blogPosts.buildQuery<BlogPost>().findAll();
    final sortedCache = _sortByDate(cached);

    if (sortedCache.isNotEmpty && !forceRefresh) {
      _refreshInBackground(maxResults); // keep cache fresh silently
      return sortedCache;
    }

    try {
      final fresh = await _api.fetchPosts(maxResults: maxResults);
      await _upsert(fresh);
      return _sortByDate(fresh);
    } catch (e) {
      if (sortedCache.isNotEmpty) return sortedCache; // serve stale on failure
      rethrow;
    }
  }

  Future<BlogPost> getPostById(String postId) async {
    final isar = await DatabaseService.isar;
    final cached = await isar.blogPosts.getByPostId(postId);

    if (cached != null) {
      if (!cached.isContentCached) _fetchContentInBackground(cached);
      return cached;
    }

    // Fallback: fetch from API directly
    final content = await _api.fetchPostContent(postId);
    throw Exception(
        'Post not in cache. Refresh the feed first.\nDetail: $content');
  }

  Future<List<BlogPost>> getPostsByLabel(String label,
      {int maxResults = 50}) async {
    // Fetch all posts (cached or fresh) and filter locally to ensure we get posts even if labels don't match API filter
    final all = await getPosts(forceRefresh: false, maxResults: 100);
    final filtered = _sortByDate(all
        .where(
          (p) => p.labels.any(
            (l) => l.toLowerCase().contains(label.toLowerCase()),
          ),
        )
        .toList());

    if (filtered.isNotEmpty) {
      // Background refresh to keep cache updated
      _refreshByLabelInBackground(label, maxResults);
      return filtered;
    }

    // If still empty after refresh, try fetching more
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

  // ── Private helpers ────────────────────────────────────────────────────────

  List<BlogPost> _sortByDate(List<BlogPost> posts) =>
      posts..sort((a, b) => b.published.compareTo(a.published));

  Future<void> _upsert(List<BlogPost> posts) async {
    final isar = await DatabaseService.isar;
    await isar.writeTxn(() async {
      for (final post in posts) {
        final existing = await isar.blogPosts.getByPostId(post.postId);
        if (existing != null) {
          post.id = existing.id;
          // preserve cached content if we don't have new content
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