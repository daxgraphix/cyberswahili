import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/search_provider.dart';
import '../../providers/blog_providers.dart';
import 'post_detail_screen.dart';

/// Search screen for finding blog posts
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final blogPostsAsync = ref.watch(blogPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Search articles...',
            border: InputBorder.none,
          ),
          autofocus: true,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by title, author, or tags...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (query) {
                ref.read(searchProvider.notifier).updateQuery(query);
                if (query.isNotEmpty) {
                  _performSearch(ref, query);
                }
              },
            ),
          ),
          if (searchState.isSearching)
            const LinearProgressIndicator(),
          if (searchState.results.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: searchState.results.length,
                itemBuilder: (context, index) {
                  final post = searchState.results[index];
                  return ListTile(
                    title: Text(post.title),
                    subtitle: Text(post.author ?? 'Unknown author'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(postId: post.postId),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          if (searchState.query.isEmpty && blogPostsAsync.maybeWhen(data: (_) => true, orElse: () => false))
            Expanded(
              child: Column(
                children: [
                  const ListTile(
                    title: Text('Recent Posts'),
                  ),
                  Expanded(
                    child: ListView(
                      children: blogPostsAsync.maybeWhen(
                        data: (posts) => posts.take(10).map((post) {
                          return ListTile(
                            title: Text(post.title),
                            subtitle: Text(post.author ?? 'Unknown author'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PostDetailScreen(postId: post.postId),
                                ),
                              );
                            },
                          );
                        }).toList(),
                        orElse: () => [],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _performSearch(WidgetRef ref, String query) {
    final blogPostsAsync = ref.watch(blogPostsProvider);
    blogPostsAsync.whenData((posts) {
      final results = posts.where((post) {
        return post.title.toLowerCase().contains(query.toLowerCase()) ||
               post.author?.toLowerCase().contains(query.toLowerCase()) == true ||
               post.labels.any((label) => label.toLowerCase().contains(query.toLowerCase()));
      }).toList();
      ref.read(searchProvider.notifier).setResults(results);
    });
    ref.read(searchProvider.notifier).setSearching(true);
  }
}