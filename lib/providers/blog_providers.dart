import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blog_post.dart';
import '../repositories/blog_repository.dart';
import '../services/blogger_api_service.dart';
import '../config/app_config.dart';

// Provider for BloggerApiService instance
// Requires API key and blog ID from secure configuration
final bloggerApiServiceProvider = Provider<BloggerApiService>((ref) {
  final apiKey = AppConfig.bloggerApiKey;
  final blogId = AppConfig.blogId;
  return BloggerApiService(apiKey: apiKey, blogId: blogId);
});

// Provider for BlogRepository instance
// Depends on bloggerApiServiceProvider for API communication
final blogRepositoryProvider = Provider<BlogRepository>((ref) {
  final apiService = ref.watch(bloggerApiServiceProvider);
  return BlogRepository(apiService);
});

/// StateNotifier for managing the main blog posts feed.
/// Automatically loads posts on initialization and handles refresh operations.
class BlogPostsNotifier extends StateNotifier<AsyncValue<List<BlogPost>>> {
  final BlogRepository _repository;

  BlogPostsNotifier(this._repository) : super(const AsyncValue.loading()) {
    // Automatically load posts when provider is initialized
    loadPosts();
  }

  // Load posts with offline-first strategy
  Future<void> loadPosts({bool forceRefresh = false}) async {
    state = const AsyncValue.loading();

    try {
      final posts = await _repository.getPosts(forceRefresh: forceRefresh);
      state = AsyncValue.data(posts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Refresh posts from API, bypassing cache
  Future<void> refreshPosts() async {
    await loadPosts(forceRefresh: true);
  }
}

// Provider for blog posts state management
// UI observes this provider to display the posts feed
final blogPostsProvider = StateNotifierProvider<BlogPostsNotifier, AsyncValue<List<BlogPost>>>((ref) {
  final repository = ref.watch(blogRepositoryProvider);
  return BlogPostsNotifier(repository);
});

// StateNotifier for managing individual blog post state
// Used for article detail view with auto-save functionality
class BlogPostNotifier extends StateNotifier<AsyncValue<BlogPost>> {
  final BlogRepository _repository;

  BlogPostNotifier(this._repository, String postId) : super(const AsyncValue.loading()) {
    loadPost(postId);
  }

  // Load specific post by ID with auto-save
  Future<void> loadPost(String postId) async {
    state = const AsyncValue.loading();

    try {
      final post = await _repository.getPostById(postId);
      state = AsyncValue.data(post);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Family provider for individual blog post by ID
// Creates separate notifier instance for each post ID
final blogPostProvider = StateNotifierProvider.family<BlogPostNotifier, AsyncValue<BlogPost>, String>((ref, postId) {
  final repository = ref.watch(blogRepositoryProvider);
  return BlogPostNotifier(repository, postId);
});

// StateNotifier for managing filtered posts by category
class CategoryPostsNotifier extends StateNotifier<AsyncValue<List<BlogPost>>> {
  final BlogRepository _repository;

  CategoryPostsNotifier(this._repository, String label) : super(const AsyncValue.loading()) {
    loadPostsByLabel(label);
  }

  Future<void> loadPostsByLabel(String label) async {
    state = const AsyncValue.loading();

    try {
      final posts = await _repository.getPostsByLabel(label);
      state = AsyncValue.data(posts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Family provider for posts filtered by category label
final categoryPostsProvider = StateNotifierProvider.family<CategoryPostsNotifier, AsyncValue<List<BlogPost>>, String>((ref, label) {
  final repository = ref.watch(blogRepositoryProvider);
  return CategoryPostsNotifier(repository, label);
});