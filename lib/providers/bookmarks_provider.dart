import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blog_post.dart';
import '../services/database_service.dart';

/// Provider for bookmarked posts
final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, AsyncValue<List<BlogPost>>>((ref) {
  return BookmarksNotifier();
});

/// Notifier for managing bookmarked posts
class BookmarksNotifier extends StateNotifier<AsyncValue<List<BlogPost>>> {
  BookmarksNotifier() : super(const AsyncValue.data([]));

  Future<void> loadBookmarks() async {
    state = const AsyncValue.loading();
    try {
      final isar = await DatabaseService.isar;
      final allPosts = await isar.blogPosts.getAll([]);
      final bookmarked = allPosts.whereType<BlogPost>().where((p) => p.isContentCached).toList();
      state = AsyncValue.data(bookmarked);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleBookmark(BlogPost post) async {
    final currentPosts = state.maybeWhen(
      data: (posts) => posts,
      orElse: () => [],
    );
    final isBookmarked = currentPosts.any((p) => p.postId == post.postId);

    try {
      final isar = await DatabaseService.isar;
      await isar.writeTxn(() async {
        if (isBookmarked) {
          // Remove bookmark by setting isContentCached to false
          final existingPost = await isar.blogPosts.getByPostId(post.postId);
          if (existingPost != null) {
            existingPost.isContentCached = false;
            await isar.blogPosts.put(existingPost);
          }
        } else {
          // Add bookmark - update the post with bookmark flag
          final existingPost = await isar.blogPosts.getByPostId(post.postId);
          if (existingPost != null) {
            existingPost.isContentCached = true;
            await isar.blogPosts.put(existingPost);
          }
        }
      });

      // Refresh the list
      await loadBookmarks();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  bool isBookmarked(String postId) {
    return state.maybeWhen(
      data: (posts) => posts.any((p) => p.postId == postId),
      orElse: () => false,
    );
  }
}