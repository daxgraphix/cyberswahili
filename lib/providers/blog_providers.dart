import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blog_post.dart';
import '../repositories/blog_repository.dart';
import '../services/blogger_api_service.dart';
import '../config/app_config.dart';

final bloggerApiServiceProvider = Provider<BloggerApiService>((ref) {
  final apiKey = AppConfig.bloggerApiKey;
  final blogId = AppConfig.blogId;
  return BloggerApiService(apiKey: apiKey, blogId: blogId);
});

final blogRepositoryProvider = Provider<BlogRepository>((ref) {
  final apiService = ref.watch(bloggerApiServiceProvider);
  return BlogRepository(apiService);
});

class BlogPostsNotifier extends StateNotifier<AsyncValue<List<BlogPost>>> {
  final BlogRepository _repository;
  bool _isRefreshing = false;

  BlogPostsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPosts();
  }

  Future<void> loadPosts({bool forceRefresh = false}) async {
    if (state is! AsyncLoading<List<BlogPost>> || forceRefresh) {
      state = const AsyncValue.loading();
    }

    try {
      final posts = await _repository.getPosts(
        maxResults: BlogRepository.defaultPageSize,
        forceRefresh: forceRefresh,
      );
      state = AsyncValue.data(posts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshPosts() async {
    _isRefreshing = true;
    state = state.when(
      loading: () => const AsyncValue.loading(),
      error: (e, s) => AsyncValue.error(e, s),
      data: (posts) => AsyncValue.data(posts),
    );
    
    try {
      await loadPosts(forceRefresh: true);
      _isRefreshing = false;
    } catch (_) {
      _isRefreshing = false;
    }
  }

  void appendPosts(List<BlogPost> newPosts) {
    state = state.when(
      loading: () => AsyncValue.data(newPosts),
      error: (e, s) => AsyncValue.error(e, s),
      data: (existing) {
        final existingIds = existing.map((p) => p.postId).toSet();
        final uniqueNew = newPosts.where((p) => !existingIds.contains(p.postId)).toList();
        return AsyncValue.data([...existing, ...uniqueNew]);
      },
    );
  }

  bool get isRefreshing => _isRefreshing;
}

final blogPostsProvider = StateNotifierProvider<BlogPostsNotifier, AsyncValue<List<BlogPost>>>((ref) {
  final repository = ref.watch(blogRepositoryProvider);
  return BlogPostsNotifier(repository);
});

class BlogPostNotifier extends StateNotifier<AsyncValue<BlogPost>> {
  final BlogRepository _repository;

  BlogPostNotifier(this._repository, String postId) : super(const AsyncValue.loading()) {
    loadPost(postId);
  }

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

final blogPostProvider = StateNotifierProvider.family<BlogPostNotifier, AsyncValue<BlogPost>, String>((ref, postId) {
  final repository = ref.watch(blogRepositoryProvider);
  return BlogPostNotifier(repository, postId);
});

class CategoryPostsNotifier extends StateNotifier<AsyncValue<List<BlogPost>>> {
  final BlogRepository _repository;
  bool _loading = false;

  CategoryPostsNotifier(this._repository, String label) : super(const AsyncValue.loading()) {
    loadPostsByLabel(label);
  }

  Future<void> loadPostsByLabel(String label) async {
    if (_loading) return;
    _loading = true;
    
    state = const AsyncValue.loading();

    try {
      final posts = await _repository.getPostsByLabel(label);
      state = AsyncValue.data(posts);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
    _loading = false;
  }

  bool get isLoading => _loading;
}

final categoryPostsProvider = StateNotifierProvider.family<CategoryPostsNotifier, AsyncValue<List<BlogPost>>, String>((ref, label) {
  final repository = ref.watch(blogRepositoryProvider);
  return CategoryPostsNotifier(repository, label);
});