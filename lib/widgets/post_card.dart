import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cyberswahili/models/blog_post.dart';
import 'package:cyberswahili/ui/theme/app_theme.dart';
import 'package:cyberswahili/providers/app_providers.dart';

class PostCard extends ConsumerWidget {
  final BlogPost post;
  final VoidCallback onTap;
  final bool featured;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    this.featured = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRead = ref.watch(readArticlesProvider).contains(post.postId);
    return featured
        ? _HeroCard(post: post, onTap: onTap, isRead: isRead)
        : _CompactCard(post: post, onTap: onTap, isRead: isRead);
  }
}

// ── Hero Card ─────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final BlogPost post;
  final VoidCallback onTap;
  final bool isRead;
  const _HeroCard({required this.post, required this.onTap, required this.isRead});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outline),
          color: cs.surface,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _Thumbnail(url: post.thumbnailUrl),
              // Gradient overlay
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xDD000000)],
                    stops: [0.3, 1.0],
                  ),
                ),
              ),
              // Content
              Positioned(
                left: 18, right: 18, bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.labels.isNotEmpty)
                      _Label(post.labels.first),
                    const SizedBox(height: 6),
                    Text(
                      post.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(_timeAgo(post.published),
                          style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      if (post.author != null && post.author!.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.person_outline, size: 12, color: Colors.white70),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(post.author!,
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ]),
                  ],
                ),
              ),
              // Featured badge + Fav button row
              Positioned(
                top: 10, left: 12, right: 12,
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.star_rounded, color: Colors.white, size: 11),
                      SizedBox(width: 4),
                      Text('MAARUFU', style: TextStyle(color: Colors.white, fontSize: 10,
                          fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    ]),
                  ),
                  const Spacer(),
                  _FavBtn(postId: post.postId),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Compact Card ──────────────────────────────────────────────────────────────
class _CompactCard extends StatelessWidget {
  final BlogPost post;
  final VoidCallback onTap;
  final bool isRead;
  const _CompactCard({required this.post, required this.onTap, required this.isRead});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline),
        ),
        child: Row(children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: SizedBox(width: 110, height: 108,
                child: _Thumbnail(url: post.thumbnailUrl)),
          ),
          // Text content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.labels.isNotEmpty)
                    Padding(padding: const EdgeInsets.only(bottom: 6),
                        child: _Label(post.labels.first)),
                  Text(post.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 13, height: 1.4, fontWeight: FontWeight.w600),
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                  if (isRead) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.visibility_rounded, size: 10,
                          color: cs.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 4),
                      Text('Imesomwa', style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
                    ]),
                  ],
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(Icons.access_time_rounded, size: 11,
                        color: cs.onSurface.withValues(alpha: 0.4)),
                    const SizedBox(width: 3),
                    Text(_timeAgo(post.published),
                        style: Theme.of(context).textTheme.bodySmall),
                    const Spacer(),
                    _FavBtn(postId: post.postId, mini: true),
                  ]),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────
class _Thumbnail extends StatelessWidget {
  final String? url;
  const _Thumbnail({this.url});

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.cover,
        placeholder: (ctx, url) => Container(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Center(child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary)))),
        errorWidget: (ctx, url, err) => _placeholder(context),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) => Container(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Icon(Icons.article_rounded,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3), size: 30),
  );
}

// Favourite toggle button
class _FavBtn extends ConsumerWidget {
  final String postId;
  final bool mini;
  const _FavBtn({required this.postId, this.mini = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favouritesProvider).contains(postId);
    final color = isFav ? AppTheme.primary : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35);
    return GestureDetector(
      onTap: () => ref.read(favouritesProvider.notifier).toggle(postId),
      child: Container(
        width: mini ? 28 : 36, height: mini ? 28 : 36,
        decoration: mini ? null : BoxDecoration(
          color: Colors.black26, borderRadius: BorderRadius.circular(10)),
        child: Icon(
          isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
          color: color, size: mini ? 18 : 20),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(text.toUpperCase(),
          style: TextStyle(color: color, fontSize: 9,
              fontWeight: FontWeight.w800, letterSpacing: 0.5)),
    );
  }
}

String _timeAgo(DateTime date) {
  final d = DateTime.now().difference(date);
  if (d.inDays > 365) return '${(d.inDays / 365).floor()}y';
  if (d.inDays > 30)  return '${(d.inDays / 30).floor()}mo';
  if (d.inDays > 0)   return '${d.inDays}d';
  if (d.inHours > 0)  return '${d.inHours}h';
  if (d.inMinutes > 0)return '${d.inMinutes}min';
  return 'Sasa';
}
