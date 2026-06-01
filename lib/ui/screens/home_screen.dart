import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cyberswahili/providers/blog_providers.dart';
import 'package:cyberswahili/providers/app_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:cyberswahili/widgets/post_card.dart';
import 'package:cyberswahili/ui/screens/post_detail_screen.dart';
import 'package:cyberswahili/ui/screens/settings_screen.dart';
import 'package:cyberswahili/ui/screens/report_screen.dart';
import 'package:cyberswahili/ui/theme/app_theme.dart';
import 'package:cyberswahili/models/blog_post.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  int _navIdx = 0;
  TabController? _catTabs;
  int _lastCatLen = 0;
  final _searchCtrl = TextEditingController();
  bool _searching = false;
  String _query = '';

  @override
  void dispose() {
    _catTabs?.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  TabController _getTabController(int len) {
    if (_catTabs == null || _lastCatLen != len) {
      _catTabs?.dispose();
      _catTabs = TabController(length: len, vsync: this);
      _lastCatLen = len;
    }
    return _catTabs!;
  }

  void _openDetail(BuildContext ctx, String postId) => Navigator.push(
      ctx, MaterialPageRoute(builder: (_) => PostDetailScreen(postId: postId)));

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.dkBg : AppTheme.ltBg;
    final enabledCats = ref.watch(categoriesProvider);
    final l10n = AppLocalizations.of(context)!;
    final tabCount = enabledCats.length + 1;
    final tabs = _getTabController(tabCount);

    return Scaffold(
      backgroundColor: bg,
      body: IndexedStack(
        index: _navIdx,
        children: [
          _ArticlesBody(
            tabs: tabs,
            enabledCats: enabledCats,
            searching: _searching,
            searchCtrl: _searchCtrl,
            query: _query,
            l10n: l10n,
            onToggleSearch: () => setState(() {
              _searching = !_searching;
              if (!_searching) { _query = ''; _searchCtrl.clear(); }
            }),
            onQueryChange: (v) => setState(() => _query = v),
            onClearQuery: () => setState(() { _query = ''; _searchCtrl.clear(); }),
            onOpenDetail: _openDetail,
          ),
          _FavsBody(onOpenDetail: _openDetail, l10n: l10n),
          SettingsScreen(embedded: true),
          const ReportScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIdx,
        onDestinationSelected: (i) => setState(() => _navIdx = i),
        backgroundColor: bg,
        indicatorColor: cs.primary.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper_rounded, color: cs.primary),
            label: l10n.articles,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_outline_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded, color: cs.primary),
            label: l10n.favourites,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded, color: cs.primary),
            label: l10n.settings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded, color: cs.primary),
            label: l10n.reports,
          ),
        ],
      ),
    );
  }
}

// ── Articles Body ─────────────────────────────────────────────────────────────
class _ArticlesBody extends ConsumerWidget {
  final TabController tabs;
  final List<String> enabledCats;
  final bool searching;
  final TextEditingController searchCtrl;
  final String query;
  final AppLocalizations l10n;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onQueryChange;
  final VoidCallback onClearQuery;
  final void Function(BuildContext, String) onOpenDetail;

  const _ArticlesBody({
    required this.tabs, required this.enabledCats,
    required this.searching, required this.searchCtrl,
    required this.query, required this.l10n,
    required this.onToggleSearch, required this.onQueryChange,
    required this.onClearQuery, required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.dkBg : AppTheme.ltBg;
    final l10n = AppLocalizations.of(context)!;

    return Column(children: [
      // App bar
      SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 32, height: 32,
              decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18)),
            const SizedBox(width: 10),
            RichText(text: TextSpan(children: [
              TextSpan(text: 'Cyber', style: TextStyle(color: cs.onSurface,
                  fontSize: 22, fontWeight: FontWeight.w800)),
              TextSpan(text: 'Swahili', style: TextStyle(color: cs.primary,
                  fontSize: 22, fontWeight: FontWeight.w800)),
            ])),
            const Spacer(),
            _IBtn(Icons.search_rounded, onToggleSearch, cs),
            const SizedBox(width: 6),
            _IBtn(Icons.refresh_rounded,
                () {
                  ref.read(blogPostsProvider.notifier).refreshPosts();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(l10n.refreshing),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: cs.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ));
                }, cs),
          ]),
          if (searching) ...[
            const SizedBox(height: 10),
            TextField(
              controller: searchCtrl, autofocus: true,
              onChanged: onQueryChange,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                isDense: true,
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 16),
                        onPressed: onClearQuery)
                    : null,
              ),
            ),
          ],
        ]),
      )),
      // Category tabs - reactive to enabledCats
      Container(
        color: bg,
        child: TabBar(
          controller: tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurface.withValues(alpha: 0.4),
          indicatorColor: cs.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: cs.outline,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: l10n.all),
            ...enabledCats.map((c) => Tab(text: c)),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: tabs,
          children: [
            _Feed(label: null, query: query, onOpenDetail: onOpenDetail, l10n: l10n),
            ...enabledCats.map((c) =>
              _Feed(key: ValueKey(c), label: c, query: query, onOpenDetail: onOpenDetail, l10n: l10n)),
          ],
        ),
      ),
    ]);
  }
}

// ── Favourites Body ───────────────────────────────────────────────────────────
class _FavsBody extends ConsumerWidget {
  final void Function(BuildContext, String) onOpenDetail;
  final AppLocalizations l10n;
  const _FavsBody({required this.onOpenDetail, required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favouritesProvider);
    final async = ref.watch(blogPostsProvider);
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(bottom: false, child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(children: [
          Container(width: 32, height: 32,
            decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.bookmark_rounded, color: Colors.white, size: 18)),
          const SizedBox(width: 10),
          Text(l10n.favourites, style: Theme.of(context).textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.w800, fontSize: 22)),
          const Spacer(),
          if (favIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.primary.withValues(alpha: 0.3))),
              child: Text('${favIds.length}', style: TextStyle(
                  color: cs.primary, fontSize: 13, fontWeight: FontWeight.w700))),
        ]),
      ),
      const SizedBox(height: 8),
      Divider(color: cs.outline, height: 1),
      Expanded(child: async.when(
        loading: () => _Shimmer(),
        error: (e, _) => _ErrView(msg: e.toString(), onRetry: () =>
            ref.read(blogPostsProvider.notifier).loadPosts(), l10n: l10n),
        data: (posts) {
          final favs = posts.where((p) => favIds.contains(p.postId)).toList();
          if (favs.isEmpty) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.outline)),
                  child: Icon(Icons.bookmark_outline_rounded, size: 32,
                      color: cs.onSurface.withValues(alpha: 0.35))),
                const SizedBox(height: 16),
                Text(l10n.noFavs, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(l10n.noFavsSub, style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center),
              ]),
            ));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: favs.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) => PostCard(
              post: favs[i],
              onTap: () => onOpenDetail(ctx, favs[i].postId),
            ),
          );
        },
      )),
    ]));
  }
}

// ── Feed ──────────────────────────────────────────────────────────────────────
class _Feed extends ConsumerStatefulWidget {
  final String? label;
  final String query;
  final AppLocalizations l10n;
  final void Function(BuildContext, String) onOpenDetail;

  const _Feed({super.key, this.label, required this.query,
      required this.onOpenDetail, required this.l10n});

  @override
  ConsumerState<_Feed> createState() => _FeedState();
}

class _FeedState extends ConsumerState<_Feed> {
  bool _fetchingLabel = false;

  @override
  void initState() {
    super.initState();
    // Pre-fetch category-specific posts from API when tab is first opened
    if (widget.label != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchForLabel());
    }
  }

  Future<void> _fetchForLabel() async {
    if (_fetchingLabel || !mounted) return;
    setState(() => _fetchingLabel = true);
    try {
      await ref.read(blogRepositoryProvider).getPostsByLabel(widget.label!, maxResults: 50);
      if (mounted) ref.invalidate(blogPostsProvider);
    } catch (_) {}
    if (mounted) setState(() => _fetchingLabel = false);
  }

  Widget _buildView(ViewMode mode, List<BlogPost> posts) {
    switch (mode) {
      case ViewMode.list:
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          itemCount: posts.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) => PostCard(
            post: posts[i],
            featured: i == 0 && widget.label == null && widget.query.isEmpty,
            onTap: () => widget.onOpenDetail(ctx, posts[i].postId),
          ),
        );
      case ViewMode.grid:
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: posts.length,
          itemBuilder: (ctx, i) => PostCard(
            post: posts[i],
            onTap: () => widget.onOpenDetail(ctx, posts[i].postId),
          ),
        );
      case ViewMode.cards:
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          itemCount: posts.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 16),
          itemBuilder: (ctx, i) => PostCard(
            post: posts[i],
            featured: true, // Make all cards featured for "cards" mode
            onTap: () => widget.onOpenDetail(ctx, posts[i].postId),
          ),
        );
    }
  }

  List<BlogPost> _filter(List<BlogPost> all) {
    var posts = widget.label == null
        ? all
        : all.where((p) => p.labels.any(
            (l) => l.toLowerCase().contains(widget.label!.toLowerCase()))).toList();

    if (widget.query.isNotEmpty) {
      final q = widget.query.toLowerCase();
      posts = posts.where((p) =>
          p.title.toLowerCase().contains(q) ||
          (p.author ?? '').toLowerCase().contains(q) ||
          p.labels.any((l) => l.toLowerCase().contains(q))).toList();
    }
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(blogPostsProvider);
    final l10n = AppLocalizations.of(context)!;

    return async.when(
      loading: () => _Shimmer(),
      error: (e, _) => _ErrView(
          msg: e.toString(),
          onRetry: () => ref.read(blogPostsProvider.notifier).loadPosts(),
          l10n: l10n),
      data: (all) {
        final posts = _filter(all);

        if (posts.isEmpty && _fetchingLabel) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary, strokeWidth: 2),
            const SizedBox(height: 12),
            Text(l10n.fetching, style: Theme.of(context).textTheme.bodySmall),
          ]));
        }

        if (posts.isEmpty) {
          return _EmptyView(
            isSearch: widget.query.isNotEmpty,
            l10n: l10n,
            onRefresh: widget.label != null
                ? _fetchForLabel
                : () => ref.read(blogPostsProvider.notifier).refreshPosts(),
          );
        }

        final viewMode = ref.watch(settingsProvider).viewMode;
        return RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () async {
            if (widget.label != null) {
              await _fetchForLabel();
            } else {
              ref.read(blogPostsProvider.notifier).refreshPosts();
            }
          },
          child: _buildView(viewMode, posts),
        );
      },
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────
class _Shimmer extends StatefulWidget {
  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _a = Tween<double>(begin: 0.3, end: 0.7).animate(_c);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (context, child) => ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => Container(
        height: i == 0 ? 260 : 108,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest
              .withValues(alpha: _a.value + 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}

// ── Empty view ────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final bool isSearch;
  final AppLocalizations l10n;
  final VoidCallback onRefresh;
  const _EmptyView({required this.isSearch, required this.l10n, required this.onRefresh});

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 72, height: 72,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.outline)),
        child: Icon(isSearch ? Icons.search_off_rounded : Icons.article_outlined,
            size: 32, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35))),
      const SizedBox(height: 16),
      Text(isSearch ? l10n.noResults : l10n.noArticles,
          style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 6),
      Text(isSearch ? l10n.tryOther : l10n.tapToLoad,
          style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
      const SizedBox(height: 20),
      ElevatedButton.icon(onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: Text(l10n.showMore)),
    ]),
  ));
}

// ── Error view ────────────────────────────────────────────────────────────────
class _ErrView extends StatelessWidget {
  final String msg;
  final VoidCallback onRetry;
  final AppLocalizations l10n;
  const _ErrView({required this.msg, required this.onRetry, required this.l10n});

  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 72, height: 72,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3))),
        child: const Icon(Icons.wifi_off_rounded, size: 32, color: Colors.redAccent)),
      const SizedBox(height: 16),
      Text(l10n.networkErr, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 6),
      Text(msg.replaceAll('Exception: ', ''),
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 20),
      ElevatedButton.icon(onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: Text(l10n.tryAgain)),
    ]),
  ));
}

// ── Icon button ───────────────────────────────────────────────────────────────
class _IBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme cs;
  const _IBtn(this.icon, this.onTap, this.cs);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outline)),
      child: Icon(icon, size: 17, color: cs.onSurface.withValues(alpha: 0.7)),
    ),
  );
}
