import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cyberswahili/providers/blog_providers.dart';
import 'package:cyberswahili/providers/app_providers.dart';
import 'package:cyberswahili/providers/strings_provider.dart';
import 'package:cyberswahili/ui/theme/app_theme.dart';
import 'package:cyberswahili/models/blog_post.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class PostDetailScreen extends ConsumerWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(blogPostProvider(postId));
    final preview = ref.watch(blogPostsProvider).maybeWhen(
          data: (posts) {
            for (final post in posts) {
              if (post.postId == postId) return post;
            }
            return null;
          },
          orElse: () => null,
        );
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: async.when(
        loading: () => _LoadingView(preview: preview),
        error: (e, _) => _ErrView(
          msg: e.toString(),
          onRetry: () => ref.read(blogPostProvider(postId).notifier).loadPost(postId),
        ),
        data: (post) {
          return _ArticleBody(post: post);
        },
      ),
    );
  }
}

class _ArticleBody extends ConsumerStatefulWidget {
  final BlogPost post;
  const _ArticleBody({required this.post});
  @override
  ConsumerState<_ArticleBody> createState() => _ArticleBodyState();
}

class _ArticleBodyState extends ConsumerState<_ArticleBody> {
  final _scroll = ScrollController();
  double _progress = 0;
  Timer? _readTimer;
  bool _markedRead = false;
  bool _savingOffline = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _readTimer = Timer(const Duration(seconds: 12), _markAsRead);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (max > 0) {
      final next = (_scroll.offset / max).clamp(0.0, 1.0);
      setState(() => _progress = next);
      if (next >= 0.35) _markAsRead();
    }
  }

  @override
  void dispose() {
    _readTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  void _markAsRead() {
    if (_markedRead || !mounted) return;
    _markedRead = true;
    ref.read(readArticlesProvider.notifier).markAsRead(widget.post.postId);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final post = widget.post;
    final hasBg = post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty;
    final s = ref.watch(stringsProvider);
    final settings = ref.watch(settingsProvider);
    final contentLoaded = post.content.trim().isNotEmpty;

    return Stack(children: [
      CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            expandedHeight: hasBg ? 280 : 0,
            pinned: true,
            backgroundColor: cs.surface,
            leading: _CircleBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
              label: s.back,
            ),
            actions: [
              _CircleBtn(icon: Icons.share_rounded, onTap: () => _share(post, context), label: s.shareArticle),
              _CircleBtn(icon: Icons.open_in_browser_rounded, onTap: () => _browser(post.url), label: s.openBrowser),
              Consumer(builder: (context, ref, _) {
                final isFav = ref.watch(favouritesProvider).contains(post.postId);
                return _CircleBtn(
                  icon: isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  onTap: () => ref.read(favouritesProvider.notifier).toggle(post.postId),
                  iconColor: isFav ? AppTheme.primary : Colors.white,
                  label: s.favourites,
                );
              }),
              const SizedBox(width: 8),
            ],
            flexibleSpace: hasBg
                ? FlexibleSpaceBar(
                    background: Stack(fit: StackFit.expand, children: [
                      CachedNetworkImage(
                        imageUrl: post.thumbnailUrl ?? '',
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => Container(color: cs.surfaceContainerHighest),
                        errorWidget: (ctx, url, err) => Container(color: cs.surfaceContainerHighest),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, isDark ? AppTheme.dkBg : AppTheme.ltBg],
                          ),
                        ),
                      ),
                    ]),
                  )
                : null,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (post.labels.isNotEmpty)
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: post.labels.map<Widget>((l) => _Chip(l)).toList(),
                  ),
                const SizedBox(height: 16),

                Text(post.title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.3)),
                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Row(children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          (post.author?.isNotEmpty == true) ? post.author![0].toUpperCase() : 'C',
                          style: const TextStyle(color: Colors.white,
                              fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(post.author ?? 'CyberSwahili',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text(_date(post.published),
                          style: Theme.of(context).textTheme.bodySmall),
                    ])),
                    _ReadTime(content: post.content, label: s.readMin),
                  ]),
                ),
                const SizedBox(height: 24),

                Container(height: 2, decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0)]),
                )),
                const SizedBox(height: 24),

                if (!contentLoaded)
                  _ContentLoadFailed(
                    message: s.contentLoadFailed,
                    retryLabel: s.tryAgain,
                    browserLabel: s.openBrowser,
                    onRetry: () => ref.read(blogPostProvider(post.postId).notifier).loadPost(post.postId),
                    onBrowser: () => _browser(post.url),
                  )
                else
                  HtmlWidget(
                    post.content,
                    textStyle: TextStyle(color: cs.onSurface, fontSize: 16 * settings.textScale, height: 1.8),
                    customStylesBuilder: (el) {
                      switch (el.localName) {
                        case 'blockquote':
                          return {'border-left': '3px solid #E53935', 'padding-left': '14px',
                            'margin': '16px 0', 'font-style': 'italic'};
                        case 'a': return {'color': '#E53935'};
                        case 'h1': case 'h2': case 'h3':
                          return {'font-weight': 'bold'};
                        case 'img':
                          return {'max-width': '100%', 'height': 'auto', 'border-radius': '10px'};
                        case 'table':
                          return {'width': '100%'};
                        case 'code': case 'pre':
                          return {'background': isDark ? '#202020' : '#F0F0F0',
                            'color': '#E53935', 'border-radius': '4px', 'padding': '2px 6px'};
                        default: return null;
                      }
                    },
                  ),
                const SizedBox(height: 32),

                _RelatedArticles(current: post),
                const SizedBox(height: 24),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 150,
                      child: OutlinedButton.icon(
                      onPressed: () => _browser(post.url),
                      icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                      label: Text(s.openBrowser),
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: OutlinedButton.icon(
                      onPressed: _savingOffline || post.isContentCached
                          ? null
                          : () => _saveOffline(post, s),
                      icon: Icon(post.isContentCached ? Icons.offline_pin_rounded : Icons.download_rounded, size: 16),
                      label: Text(post.isContentCached ? s.savedOffline : s.readLater),
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: ElevatedButton.icon(
                      onPressed: () => _share(post, context),
                      icon: const Icon(Icons.share_rounded, size: 16),
                      label: Text(s.shareArticle),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),

      Positioned(top: 0, left: 0, right: 0,
          child: LinearProgressIndicator(
            value: _progress, minHeight: 2,
            backgroundColor: Colors.transparent,
            color: AppTheme.primary,
          )),
    ]);
  }

  void _share(BlogPost post, BuildContext context) {
    Share.share('${post.title}\n${post.url}');
  }

  Future<void> _browser(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveOffline(BlogPost post, S s) async {
    setState(() => _savingOffline = true);
    try {
      await ref.read(blogRepositoryProvider).cachePostContent(post.postId);
      ref.invalidate(blogPostProvider(post.postId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(_detailSnackBar(context, s.savedOffline));
      }
    } finally {
      if (mounted) setState(() => _savingOffline = false);
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final String label;
  const _CircleBtn({required this.icon, required this.onTap, this.iconColor = Colors.white, required this.label});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    child: Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 17),
        ),
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _ReadTime extends ConsumerWidget {
  final String content;
  final String label;
  const _ReadTime({required this.content, required this.label});
  int get _min => ((content.replaceAll(RegExp(r'<[^>]*>'), ' ').split(' ').length / 200).ceil()).clamp(1, 60);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final s = ref.watch(stringsProvider);
    return Semantics(
      label: '$_min ${s.readMinSemantic}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.primary.withValues(alpha: 0.35)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.menu_book_rounded, size: 12, color: cs.primary),
          const SizedBox(width: 4),
          Text('$_min $label', style: TextStyle(color: cs.primary, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _ContentLoadFailed extends StatelessWidget {
  final String message;
  final String retryLabel;
  final String browserLabel;
  final VoidCallback onRetry;
  final VoidCallback onBrowser;
  const _ContentLoadFailed({
    required this.message,
    required this.retryLabel,
    required this.browserLabel,
    required this.onRetry,
    required this.onBrowser,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.error.withValues(alpha: 0.35)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.cloud_off_rounded, color: cs.error, size: 24),
        const SizedBox(height: 10),
        Text(message, style: TextStyle(color: cs.onSurface, height: 1.5)),
        const SizedBox(height: 14),
        Wrap(spacing: 10, runSpacing: 10, children: [
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(retryLabel),
          ),
          OutlinedButton.icon(
            onPressed: onBrowser,
            icon: const Icon(Icons.open_in_browser_rounded, size: 16),
            label: Text(browserLabel),
          ),
        ]),
      ]),
    );
  }
}

class _RelatedArticles extends ConsumerWidget {
  final BlogPost current;
  const _RelatedArticles({required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final related = ref.watch(blogPostsProvider).maybeWhen(
          data: (posts) => posts
              .where((post) =>
                  post.postId != current.postId &&
                  post.labels.any((label) => current.labels.contains(label)))
              .take(3)
              .toList(),
          orElse: () => const <BlogPost>[],
        );
    if (related.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(s.relatedArticles,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      ...related.map((post) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outline),
            ),
            child: ListTile(
              title: Text(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: post.labels.isEmpty ? null : Text(post.labels.first),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.postId)),
              ),
            ),
          )),
    ]);
  }
}

class _LoadingView extends StatefulWidget {
  final BlogPost? preview;
  const _LoadingView({this.preview});
  @override
  State<_LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<_LoadingView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _progress = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Container(width: 36, height: 36, decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10))),
        const SizedBox(height: 20),
        if (widget.preview?.thumbnailUrl?.isNotEmpty == true)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: widget.preview!.thumbnailUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        else
          Container(height: 200, decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16))),
        const SizedBox(height: 24),
        if (widget.preview != null) ...[
          Text(widget.preview!.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
        ],
        // Progress indicator
        AnimatedBuilder(
          animation: _progress,
          builder: (context, child) => Column(children: [
            LinearProgressIndicator(
              value: _progress.value,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Inapakua makala... ${(_progress.value * 100).round()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        ...List.generate(3, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(height: 16, width: i == 2 ? 160.0 : double.infinity,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8))),
        )),
        const SizedBox(height: 16),
        Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2)),
      ]),
    ),
  );
}

SnackBar _detailSnackBar(BuildContext context, String message) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bg = isDark ? Colors.white : const Color(0xFF161616);
  final fg = isDark ? const Color(0xFF161616) : Colors.white;
  return SnackBar(
    content: Row(children: [
      Icon(Icons.check_circle_rounded, color: AppTheme.primary, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Text(message, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 14))),
    ]),
    backgroundColor: bg,
    elevation: 8,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
  );
}

class _ErrView extends ConsumerWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrView({required this.msg, required this.onRetry});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final isOffline = msg.contains('SocketException') || 
                     msg.contains('host lookup') || 
                     msg.contains('Network is unreachable');

    return SafeArea(
      child: Column(children: [
        Padding(padding: const EdgeInsets.all(16),
          child: Row(children: [
            IconButton(onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded)),
          ])),
        Expanded(child: Center(child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 72, height: 72,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3))),
              child: Icon(isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded, size: 32, color: Colors.redAccent)),
            const SizedBox(height: 16),
            Text(isOffline ? s.deviceOffline : s.articleNotLoaded, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(isOffline ? s.offlineMessage : msg.replaceAll('Exception: ', ''),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 20),
            ElevatedButton.icon(onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(s.tryAgain)),
          ]),
        ))),
      ]),
    );
  }
}

String _date(DateTime d) {
  const m = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ago','Sep','Okt','Nov','Des'];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}
