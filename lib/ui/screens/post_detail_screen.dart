import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cyberswahili/providers/blog_providers.dart';
import 'package:cyberswahili/providers/app_providers.dart';
import 'package:cyberswahili/ui/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class PostDetailScreen extends ConsumerWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(blogPostProvider(postId));
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: async.when(
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrView(
          msg: e.toString(),
          onRetry: () => ref.read(blogPostProvider(postId).notifier).loadPost(postId),
        ),
        data: (post) {
          // Mark article as read when loaded
          ref.read(readArticlesProvider.notifier).markAsRead(post.postId);
          return _ArticleBody(post: post);
        },
      ),
    );
  }
}

// ── Article body ──────────────────────────────────────────────────────────────
class _ArticleBody extends StatefulWidget {
  final dynamic post;
  const _ArticleBody({required this.post});
  @override
  State<_ArticleBody> createState() => _ArticleBodyState();
}

class _ArticleBodyState extends State<_ArticleBody> {
  final _scroll = ScrollController();
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (max > 0) setState(() => _progress = (_scroll.offset / max).clamp(0.0, 1.0));
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final post = widget.post;
    final hasBg = post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty;

    return Stack(children: [
      CustomScrollView(
        controller: _scroll,
        slivers: [
          // Collapsing header image
          SliverAppBar(
            expandedHeight: hasBg ? 280 : 0,
            pinned: true,
            backgroundColor: cs.surface,
            leading: _CircleBtn(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              _CircleBtn(icon: Icons.share_rounded, onTap: () => _share(post, context)),
              _CircleBtn(icon: Icons.open_in_browser_rounded, onTap: () => _browser(post.url)),
              // Favourite toggle
              Consumer(builder: (context, ref, _) {
                final isFav = ref.watch(favouritesProvider).contains(post.postId as String);
                return _CircleBtn(
                  icon: isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                  onTap: () => ref.read(favouritesProvider.notifier).toggle(post.postId as String),
                  iconColor: isFav ? AppTheme.primary : Colors.white,
                );
              }),
              const SizedBox(width: 8),
            ],
            flexibleSpace: hasBg
                ? FlexibleSpaceBar(
                    background: Stack(fit: StackFit.expand, children: [
                      CachedNetworkImage(
                        imageUrl: post.thumbnailUrl!,
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

          // Article content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Labels
                if ((post.labels as List).isNotEmpty)
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: (post.labels as List).map<Widget>((l) => _Chip(l as String)).toList(),
                  ),
                const SizedBox(height: 16),

                // Title
                Text(post.title,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800, letterSpacing: -0.5, height: 1.3)),
                const SizedBox(height: 18),

                // Meta card
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
                    _ReadTime(content: post.content as String),
                  ]),
                ),
                const SizedBox(height: 24),

                // Red divider
                Container(height: 2, decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0)]),
                )),
                const SizedBox(height: 24),

                // Content
                HtmlWidget(
                  (post.content as String).isNotEmpty
                      ? post.content as String
                      : '<p>Maudhui yanapakiwa... Tafadhali subiri.</p>',
                  textStyle: TextStyle(color: cs.onSurface, fontSize: 16, height: 1.8),
                  customStylesBuilder: (el) {
                    switch (el.localName) {
                      case 'blockquote':
                        return {'border-left': '3px solid #E53935', 'padding-left': '14px',
                          'margin': '16px 0', 'font-style': 'italic'};
                      case 'a': return {'color': '#E53935'};
                      case 'h1': case 'h2': case 'h3':
                        return {'font-weight': 'bold'};
                      case 'code': case 'pre':
                        return {'background': isDark ? '#202020' : '#F0F0F0',
                          'color': '#E53935', 'border-radius': '4px', 'padding': '2px 6px'};
                      default: return null;
                    }
                  },
                ),
                const SizedBox(height: 32),

                // Bottom action buttons
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _browser(post.url),
                      icon: const Icon(Icons.open_in_browser_rounded, size: 16),
                      label: const Text('Kivinjari'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _share(post, context),
                      icon: const Icon(Icons.share_rounded, size: 16),
                      label: const Text('Shiriki'),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ],
      ),

      // Progress bar
      Positioned(top: 0, left: 0, right: 0,
          child: LinearProgressIndicator(
            value: _progress, minHeight: 2,
            backgroundColor: Colors.transparent,
            color: AppTheme.primary,
          )),
    ]);
  }

  void _share(dynamic post, BuildContext context) {
    Share.share('${post.title}\n${post.url}');
    // No snack needed as share opens system dialog
  }

  Future<void> _browser(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  const _CircleBtn({required this.icon, required this.onTap, this.iconColor = Colors.white});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 17),
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

class _ReadTime extends StatelessWidget {
  final String content;
  const _ReadTime({required this.content});
  int get _min => ((content.replaceAll(RegExp(r'<[^>]*>'), ' ').split(' ').length / 200).ceil()).clamp(1, 60);
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.primary.withValues(alpha: 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.menu_book_rounded, size: 12, color: cs.primary),
        const SizedBox(width: 4),
        Text('$_min dk', style: TextStyle(color: cs.primary, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _LoadingView extends StatefulWidget {
  const _LoadingView();
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
        Container(height: 200, decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16))),
        const SizedBox(height: 24),
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

class _ErrView extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  const _ErrView({required this.msg, required this.onRetry});
  @override
  Widget build(BuildContext context) => SafeArea(
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
            child: const Icon(Icons.error_outline_rounded, size: 32, color: Colors.redAccent)),
          const SizedBox(height: 16),
          Text('Makala haijapakiwa', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(msg.replaceAll('Exception: ', ''),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 20),
          ElevatedButton.icon(onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Jaribu Tena')),
        ]),
      ))),
    ]),
  );
}

String _date(DateTime d) {
  const m = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Ago','Sep','Okt','Nov','Des'];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}
