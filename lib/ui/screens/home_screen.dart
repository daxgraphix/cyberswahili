import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cyberswahili/providers/blog_providers.dart';
import 'package:cyberswahili/providers/app_providers.dart';
import 'package:cyberswahili/providers/strings_provider.dart';
import 'package:cyberswahili/providers/connectivity_provider.dart';
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

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
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
    final s = ref.watch(stringsProvider);
    final connectivity = ref.watch(connectivityProvider);
    final tabCount = enabledCats.length + 1;
    final tabs = _getTabController(tabCount);

    return Scaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          if (connectivity != ConnectionStatus.online)
            _ConnectivityBanner(status: connectivity, s: s),
          Expanded(
            child: IndexedStack(
              index: _navIdx,
              children: [
                _ArticlesBody(
                  tabs: tabs,
                  enabledCats: enabledCats,
                  searching: _searching,
                  searchCtrl: _searchCtrl,
                  query: _query,
                  s: s,
                  onToggleSearch: () => setState(() {
                    _searching = !_searching;
                    if (!_searching) { _query = ''; _searchCtrl.clear(); }
                  }),
                  onQueryChange: (v) => setState(() => _query = v),
                  onClearQuery: () => setState(() { _query = ''; _searchCtrl.clear(); }),
                  onOpenDetail: _openDetail,
                ),
                _FavsBody(onOpenDetail: _openDetail),
                SettingsScreen(embedded: true),
                const ReportScreen(),
              ],
            ),
          ),
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
            label: s.articles,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_outline_rounded),
            selectedIcon: Icon(Icons.bookmark_rounded, color: cs.primary),
            label: s.favourites,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded, color: cs.primary),
            label: s.settings,
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics_rounded, color: cs.primary),
            label: s.reports,
          ),
        ],
      ),
    );
  }
}

class _ArticlesBody extends ConsumerWidget {
  final TabController tabs;
  final List<String> enabledCats;
  final bool searching;
  final TextEditingController searchCtrl;
  final String query;
  final S s;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onQueryChange;
  final VoidCallback onClearQuery;
  final void Function(BuildContext, String) onOpenDetail;

  const _ArticlesBody({
    required this.tabs, required this.enabledCats,
    required this.searching, required this.searchCtrl,
    required this.query, required this.s,
    required this.onToggleSearch, required this.onQueryChange,
    required this.onClearQuery, required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppTheme.dkBg : AppTheme.ltBg;

    return Column(children: [
      SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 32, height: 32,
              decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 18)),
            const SizedBox(width: 10),
            RichText(text: TextSpan(children: [
              TextSpan(text: 'Cyber', style: TextStyle(color: cs.onSurface, fontSize: 22, fontWeight: FontWeight.w800)),
              TextSpan(text: 'Swahili', style: TextStyle(color: cs.primary, fontSize: 22, fontWeight: FontWeight.w800)),
            ])),
            const Spacer(),
            _IBtn(Icons.search_rounded, onToggleSearch, cs, s.search),
            const SizedBox(width: 6),
            _IBtn(Icons.refresh_rounded,
                () async {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  final snackBg = isDark ? Colors.white : const Color(0xFF161616);
                  final snackFg = isDark ? const Color(0xFF161616) : Colors.white;
                  
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(children: [
                      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: Text(s.refreshing, style: TextStyle(color: snackFg, fontWeight: FontWeight.w600, fontSize: 14))),
                    ]),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: snackBg,
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ));
                  
                  final ok = await ref.read(blogPostsProvider.notifier).refreshPosts();
                  if (!context.mounted) return;
                  
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(children: [
                      Icon(ok ? Icons.check_circle_rounded : Icons.error_rounded, color: ok ? Colors.green : Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(ok ? s.refreshDone : s.refreshFailed, style: TextStyle(color: snackFg, fontWeight: FontWeight.w600, fontSize: 14))),
                    ]),
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: snackBg,
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ));
                }, cs, s.refresh),
          ]),
          if (searching) ...[
            const SizedBox(height: 10),
            TextField(
              controller: searchCtrl, autofocus: true,
              onChanged: onQueryChange,
              decoration: InputDecoration(
                hintText: s.searchHint,
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                isDense: true,
                suffixIcon: query.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close_rounded, size: 16), onPressed: onClearQuery)
                    : null,
              ),
            ),
          ],
        ]),
      )),
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
            Tab(text: s.all),
            ...enabledCats.map((c) => Tab(text: c)),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: tabs,
          children: [
            _Feed(label: null, query: query, onOpenDetail: onOpenDetail),
            ...enabledCats.map((c) => _Feed(key: ValueKey(c), label: c, query: query, onOpenDetail: onOpenDetail)),
          ],
        ),
      ),
    ]);
  }
}

class _FavsBody extends ConsumerWidget {
  final void Function(BuildContext, String) onOpenDetail;
  const _FavsBody({required this.onOpenDetail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favouritesProvider);
    final async = ref.watch(blogPostsProvider);
    final cs = Theme.of(context).colorScheme;
    final s = ref.watch(stringsProvider);

    return SafeArea(bottom: false, child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.bookmark_rounded, color: Colors.white, size: 18)),
        const SizedBox(width: 10),
        Text(s.favourites, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 22)),
        const Spacer(),
        if (favIds.isNotEmpty)
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: cs.primary.withValues(alpha: 0.3))), child: Text('${favIds.length}', style: TextStyle(color: cs.primary, fontSize: 13, fontWeight: FontWeight.w700))),
      ])),
      const SizedBox(height: 8),
      Divider(color: cs.outline, height: 1),
      Expanded(child: async.when(
        loading: () => const _FavsShimmer(),
        error: (e, _) => _ErrView(msg: e.toString(), onRetry: () => ref.read(blogPostsProvider.notifier).loadPosts()),
        data: (posts) {
          final favs = posts.where((p) => favIds.contains(p.postId)).toList();
          if (favs.isEmpty) {
            return Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 72, height: 72, decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(20), border: Border.all(color: cs.outline)), child: Icon(Icons.bookmark_outline_rounded, size: 32, color: cs.onSurface.withValues(alpha: 0.35))),
              const SizedBox(height: 16),
              Text(s.noFavs, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(s.noFavsSub, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
            ])));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: favs.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) => PostCard(post: favs[i], onTap: () => onOpenDetail(ctx, favs[i].postId)),
          );
        },
      )),
    ]));
  }
}

class _FavsShimmer extends StatelessWidget {
  const _FavsShimmer();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.separated(padding: const EdgeInsets.all(16), itemCount: 5, separatorBuilder: (ctx, i) => const SizedBox(height: 12), itemBuilder: (ctx, i) => Container(height: 108, decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(16))));
  }
}

class _Feed extends ConsumerStatefulWidget {
  final String? label;
  final String query;
  final void Function(BuildContext, String) onOpenDetail;

  const _Feed({super.key, this.label, required this.query, required this.onOpenDetail});

  @override
  ConsumerState<_Feed> createState() => _FeedState();
}

class _FeedState extends ConsumerState<_Feed> {
  bool _loadingMore = false;
  static const int _pageSize = 20;

  Future<void> _fetchForLabel() async {
    if (widget.label == null) return;
    setState(() => _loadingMore = true);
    try {
      final posts = await ref.read(blogRepositoryProvider).getPostsByLabel(widget.label!, maxResults: 100);
      ref.read(blogPostsProvider.notifier).appendPosts(posts);
      if (mounted) setState(() => _loadingMore = false);
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _loadMore(List<BlogPost> posts, WidgetRef ref) async {
    if (_loadingMore) return;
    if (widget.label != null) return;
    
    setState(() => _loadingMore = true);
    
    try {
      final oldestDate = posts.isNotEmpty 
          ? posts.reduce((a, b) => a.published.isBefore(b.published) ? a : b).published
          : null;
      
      final more = await ref.read(blogRepositoryProvider).loadMorePosts(
        maxResults: _pageSize,
        afterDate: oldestDate,
      );
      
      if (mounted && more.isNotEmpty) {
        final existingIds = posts.map((p) => p.postId).toSet();
        final newPosts = more.where((p) => !existingIds.contains(p.postId)).toList();
        if (newPosts.isNotEmpty) {
          ref.read(blogPostsProvider.notifier).appendPosts(newPosts);
        }
      }
    } catch (_) {}
    
    if (mounted) setState(() => _loadingMore = false);
  }

  Widget _buildView(ViewMode mode, List<BlogPost> posts) {
    switch (mode) {
      case ViewMode.list:
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) => PostCard(
            post: posts[i],
            featured: i == 0 && widget.label == null && widget.query.isEmpty,
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
            featured: true,
            onTap: () => widget.onOpenDetail(ctx, posts[i].postId),
          ),
        );
    }
  }

  List<BlogPost> _filter(List<BlogPost> all) {
    var posts = widget.label == null
        ? all
        : all.where((p) => p.labels.any((l) => l.toLowerCase().contains(widget.label!.toLowerCase()))).toList();

    if (widget.query.isNotEmpty) {
      final q = widget.query.toLowerCase();
      posts = posts.where((p) => p.title.toLowerCase().contains(q) || (p.author ?? '').toLowerCase().contains(q) || p.labels.any((l) => l.toLowerCase().contains(q))).toList();
    }
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(blogPostsProvider);
    final s = ref.watch(stringsProvider);

    return async.when(
      loading: () => const _FeedShimmer(),
      error: (e, _) => _ErrView(msg: e.toString(), onRetry: () => ref.read(blogPostsProvider.notifier).loadPosts()),
      data: (all) {
        final posts = _filter(all);

        if (posts.isEmpty && widget.label != null) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2),
            const SizedBox(height: 12),
            Text(s.fetching, style: Theme.of(context).textTheme.bodySmall),
          ]));
        }

        if (posts.isEmpty) {
          return _EmptyView(
            isSearch: widget.query.isNotEmpty, 
            s: s, 
            onRefresh: widget.label != null ? () => _fetchForLabel() : () => ref.read(blogPostsProvider.notifier).refreshPosts()
          );
        }

        final viewMode = ref.watch(settingsProvider).viewMode;
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            if (scrollNotification is ScrollEndNotification) {
              final metrics = scrollNotification.metrics;
              if (metrics.extentAfter == 0 && !_loadingMore) {
                _loadMore(posts, ref);
              }
            }
            return false;
          },
          child: RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: () async {
              if (widget.label != null) {
                await _fetchForLabel();
              } else { 
                ref.read(blogPostsProvider.notifier).refreshPosts(); 
              }
            },
            child: _buildView(viewMode, posts),
          ),
        );
      },
    );
  }
}

class _FeedShimmer extends StatelessWidget {
  const _FeedShimmer();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView.separated(padding: const EdgeInsets.all(16), itemCount: 5, separatorBuilder: (ctx, i) => const SizedBox(height: 12), itemBuilder: (ctx, i) => Container(height: i == 0 ? 260 : 108, decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(16))));
  }
}

class _EmptyView extends StatelessWidget {
  final bool isSearch;
  final S s;
  final VoidCallback onRefresh;
  const _EmptyView({required this.isSearch, required this.s, required this.onRefresh});

  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 72, height: 72, decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).colorScheme.outline))), Icon(isSearch ? Icons.search_off_rounded : Icons.article_outlined, size: 32, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
    const SizedBox(height: 16),
    Text(isSearch ? s.noResults : s.noArticles, style: Theme.of(context).textTheme.titleLarge),
    const SizedBox(height: 6),
    Text(isSearch ? s.tryOther : s.tapToLoad, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
    const SizedBox(height: 20),
    ElevatedButton.icon(onPressed: onRefresh, icon: const Icon(Icons.refresh_rounded, size: 16), label: Text(s.showMore)),
  ])));
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
    
    return Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 72, height: 72, decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red.withValues(alpha: 0.3))), child: Icon(isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded, size: 32, color: Colors.redAccent)),
      const SizedBox(height: 16),
      Text(isOffline ? s.deviceOffline : s.networkErr, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10),
      Text(isOffline ? s.offlineMessage : msg.replaceAll('Exception: ', ''), style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center, maxLines: 3, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 20),
      ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded, size: 16), label: Text(s.tryAgain)),
    ])));
  }
}

class _IBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme cs;
  final String label;
  const _IBtn(this.icon, this.onTap, this.cs, this.label);
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      onTap: onTap, 
      child: Container(
        width: 44, height: 44, 
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest, 
          borderRadius: BorderRadius.circular(10), 
          border: Border.all(color: cs.outline)
        ), 
        child: Icon(icon, size: 18, color: cs.onSurface.withValues(alpha: 0.78))
      ),
    ),
  );
}

class _ConnectivityBanner extends StatelessWidget {
  final ConnectionStatus status;
  final S s;

  const _ConnectivityBanner({required this.status, required this.s});

  @override
  Widget build(BuildContext context) {
    final isDeviceOffline = status == ConnectionStatus.offline;
    final color = isDeviceOffline ? Colors.orange : Colors.redAccent;
    final icon = isDeviceOffline ? Icons.wifi_off_rounded : Icons.cloud_off_rounded;
    final text = isDeviceOffline ? s.deviceOffline : s.serverOffline;

    return Container(
      width: double.infinity,
      color: color,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 4,
        bottom: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

