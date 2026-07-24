import 'package:isar_db/isar_db.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blog_post.dart';
import '../services/database_service.dart';

/// Provider for posts whose full content is cached for offline reading.
///
/// The active favourites UI uses `favouritesProvider` in `app_providers.dart`.
/// Keep this provider cache-focused so `BlogPost.isContentCached` has one meaning.
final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, AsyncValue<List<BlogPost>>>((ref) {
  return BookmarksNotifier();
});

/// Notifier for reading offline-cached posts.
class BookmarksNotifier extends StateNotifier<AsyncValue<List<BlogPost>>> {
  BookmarksNotifier() : super(const AsyncValue.data([]));

  Future<void> loadBookmarks() async {
    state = const AsyncValue.loading();
    try {
      final isar = await DatabaseService.isar;
      final bookmarked = await isar.blogPosts.where().isContentCachedEqualTo(true).findAllAsync();
      state = AsyncValue.data(bookmarked);
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
