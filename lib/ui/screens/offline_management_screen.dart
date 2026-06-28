import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cyberswahili/providers/blog_providers.dart';
import 'package:cyberswahili/providers/strings_provider.dart';
import 'package:cyberswahili/models/blog_post.dart';
import 'package:cyberswahili/ui/screens/post_detail_screen.dart';

class OfflineManagementScreen extends ConsumerStatefulWidget {
  const OfflineManagementScreen({super.key});

  @override
  ConsumerState<OfflineManagementScreen> createState() => _OfflineManagementScreenState();
}

class _OfflineManagementScreenState extends ConsumerState<OfflineManagementScreen> {
  List<BlogPost>? _posts;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    final repo = ref.read(blogRepositoryProvider);
    final posts = await repo.getCachedPosts();
    if (mounted) {
      setState(() {
        _posts = posts;
        _loading = false;
      });
    }
  }

  Future<void> _deletePost(String postId) async {
    final repo = ref.read(blogRepositoryProvider);
    await repo.deleteFromCache(postId);
    await _loadPosts();
    // Refresh cache info in settings
    ref.invalidate(cacheInfoProvider);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.manageOffline),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _posts == null || _posts!.isEmpty
              ? _EmptyState(s: s)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _posts!.length,
                  itemBuilder: (context, index) {
                    final post = _posts![index];
                    return _OfflineTile(
                      post: post,
                      onDelete: () => _deletePost(post.postId),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostDetailScreen(postId: post.postId),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _OfflineTile extends StatelessWidget {
  final BlogPost post;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _OfflineTile({
    required this.post,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final date = DateFormat.yMMMd().format(post.published);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
      ),
      child: Consumer(builder: (context, ref, _) {
        final s = ref.watch(stringsProvider);
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    post.thumbnailUrl ?? '',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 70,
                      height: 70,
                      color: cs.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.article_rounded, color: cs.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  onPressed: () => _showDeleteConfirm(context, s),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showDeleteConfirm(BuildContext context, S s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteOfflineQ),
        content: Text(s.deleteOfflineBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final S s;
  const _EmptyState({required this.s});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.offline_pin_outlined, size: 64, color: cs.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            s.noOfflineArticles,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              s.sw 
                  ? 'Makala unayopakua kwa ajili ya kusoma nje ya mtandao yataonekana hapa.'
                  : 'Articles you download for offline reading will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurface.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }
}
