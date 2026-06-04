import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cyberswahili/providers/app_providers.dart';
import 'package:cyberswahili/providers/blog_providers.dart';
import 'package:cyberswahili/providers/strings_provider.dart';
import 'package:cyberswahili/models/blog_post.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final s = ref.watch(stringsProvider);
        final readArticles = ref.watch(readArticlesProvider);
        final favCount = ref.watch(favouritesProvider).length;
        final asyncPosts = ref.watch(blogPostsProvider);
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          backgroundColor: cs.surface,
          body: SafeArea(
            child: Column(children: [
              AppBar(
                title: Text(s.reports, style: const TextStyle(fontWeight: FontWeight.w700)),
                elevation: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    color: cs.surface,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        TabBar(
                          controller: _tabController,
                          tabs: [
                            _TabWithBadge(text: s.readingReport, count: readArticles.length),
                            Tab(text: s.insights),
                            Tab(text: s.analytics),
                          ],
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReadingTab(context, ref, s, readArticles, favCount, asyncPosts, cs),
                    _buildInsightsTab(context, ref, s, readArticles, asyncPosts, cs),
                    _buildAnalyticsTab(context, ref, s, readArticles, asyncPosts, cs),
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildReadingTab(BuildContext context, WidgetRef ref, S s,
      Set<String> readArticles, int favCount, AsyncValue<List> asyncPosts, ColorScheme cs) {
    return asyncPosts.when(
      loading: () => const _LoadingState(),
      error: (e, _) => _ErrorState(message: e.toString(), onRetry: () => ref.read(blogPostsProvider.notifier).loadPosts()),
      data: (posts) {
        final blogPosts = posts.cast<BlogPost>();
        final allPosts = blogPosts.length;
        final readCount = readArticles.length;
        final readPercentage = allPosts > 0 ? (readCount / allPosts * 100).round() : 0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeaderCard(
              icon: Icons.analytics_rounded,
              iconColor: cs.primary,
              title: s.readingReport,
              subtitle: s.reportSubtitle,
            ),
            const SizedBox(height: 24),
            Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: _StatCard(icon: Icons.article_rounded, iconColor: Colors.blue, title: s.totalArticles, value: allPosts.toString(), subtitle: s.availableArticles, onTap: () => _showAllArticles(context, blogPosts, s))),
              Expanded(child: _StatCard(icon: Icons.visibility_rounded, iconColor: Colors.green, title: s.articlesRead, value: readCount.toString(), subtitle: '$readPercentage% ${s.ofTotal}', onTap: () => _showReadArticles(context, readArticles, blogPosts, s))),
            ]),
            const SizedBox(height: 12),
            Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: _StatCard(icon: Icons.bookmark_rounded, iconColor: Colors.orange, title: s.favourited, value: favCount.toString(), subtitle: s.savedForLater, onTap: () => _showFavourites(context, favCount, s))),
              Expanded(child: _StatCard(icon: Icons.trending_up_rounded, iconColor: Colors.purple, title: s.engagement, value: readCount > 0 ? '${(favCount / readCount * 100).round()}%' : '0%', subtitle: s.favRate, onTap: () => _showEngagementDetail(context, readCount, favCount, s))),
            ]),
            const SizedBox(height: 24),
            Text(s.insights, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _InsightCard(icon: Icons.lightbulb_rounded, iconColor: Colors.amber, title: readPercentage >= 50 ? s.greatReader : readPercentage >= 25 ? s.goodReader : s.startReading, description: readPercentage >= 50 ? s.greatReaderDesc : readPercentage >= 25 ? s.goodReaderDesc : s.startReadingDesc),
            const SizedBox(height: 12),
            _InsightCard(icon: Icons.bookmark_border_rounded, iconColor: Colors.teal, title: favCount >= 10 ? s.activeSaver : favCount >= 5 ? s.moderateSaver : s.saveMore, description: favCount >= 10 ? s.activeSaverDesc : favCount >= 5 ? s.moderateSaverDesc : s.saveMoreDesc),
            const SizedBox(height: 12),
            _InsightCard(icon: Icons.refresh_rounded, iconColor: Colors.indigo, title: s.keepUpdated, description: s.keepUpdatedDesc),
          ],
        );
      },
    );
  }

  Widget _buildInsightsTab(BuildContext context, WidgetRef ref, S s,
      Set<String> readArticles, AsyncValue<List> asyncPosts, ColorScheme cs) {
    return asyncPosts.when(
      loading: () => const _LoadingState(),
      error: (e, _) => _ErrorState(message: e.toString(), onRetry: () => ref.read(blogPostsProvider.notifier).loadPosts()),
      data: (posts) {
        final blogPosts = posts.cast<BlogPost>();
        final categoryStats = _computeCategoryStats(blogPosts, readArticles);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(s.viewByCategory, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (categoryStats.isEmpty)
              _EmptyState(text: s.noCategoryData),
            ...categoryStats.entries.map((e) => _CategoryTile(category: e.key, readCount: e.value['read'] ?? 0, totalCount: e.value['total'] ?? 0, s: s)),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsTab(BuildContext context, WidgetRef ref, S s,
      Set<String> readArticles, AsyncValue<List> asyncPosts, ColorScheme cs) {
    return asyncPosts.when(
      loading: () => const _LoadingState(),
      error: (e, _) => _ErrorState(message: e.toString(), onRetry: () => ref.read(blogPostsProvider.notifier).loadPosts()),
      data: (posts) {
        final blogPosts = posts.cast<BlogPost>();
        final weekly = _computeWeekly(blogPosts, readArticles);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(s.weeklyTrend, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _WeeklyChart(posts: blogPosts, readArticles: readArticles, weekly: weekly, cs: cs, s: s),
            const SizedBox(height: 24),
            Text(s.distribution, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            ..._computeCategoryStats(blogPosts, readArticles).entries.map((e) => _ProgressBar(label: e.key, value: e.value['total']! > 0 ? (e.value['read']! / e.value['total']!) : 0)),
          ],
        );
      },
    );
  }

  Map<String, Map<String, int>> _computeCategoryStats(List<BlogPost> posts, Set<String> readArticles) {
    final stats = <String, Map<String, int>>{};
    for (final post in posts) {
      final labels = post.labels;
      for (final label in labels) {
        stats.putIfAbsent(label, () => {'read': 0, 'total': 0});
        stats[label]!['total'] = stats[label]!['total']! + 1;
        if (readArticles.contains(post.postId)) {
          stats[label]!['read'] = stats[label]!['read']! + 1;
        }
      }
    }
    return stats;
  }

  List<double> _computeWeekly(List<BlogPost> posts, Set<String> readArticles) {
    final w = List.filled(7, 0.0);
    for (final p in posts) {
      if (readArticles.contains(p.postId)) {
        final d = p.published.weekday - 1;
        w[d] = w[d] + 1;
      }
    }
    return w;
  }
}

class _TabWithBadge extends StatelessWidget {
  final String text;
  final int count;
  const _TabWithBadge({required this.text, required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      if (count > 0) ...[
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(10)), child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
      ],
    ]);
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      CircularProgressIndicator(color: cs.primary),
      const SizedBox(height: 16),
      Text('Inapakia...', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
    ]));
  }
}

class _ErrorState extends ConsumerWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final s = ref.watch(stringsProvider);
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.error_outline, color: cs.error, size: 48),
      const SizedBox(height: 12),
      Text(s.networkErr, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      Text(message, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
      const SizedBox(height: 16),
      ElevatedButton(onPressed: onRetry, child: Text(s.tryAgain)),
    ])));
  }
}

class _HeaderCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  const _HeaderCard({required this.icon, required this.iconColor, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: cs.primary.withValues(alpha: 0.15))), child: Row(children: [
      Container(width: 56, height: 56, decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: iconColor, size: 24)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)), Text(subtitle, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)))])),
    ]));
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback? onTap;
  const _StatCard({required this.icon, required this.iconColor, required this.title, required this.value, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(height: 12),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: cs.primary)),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
        ]),
      ),
    );
  }
}

void _showAllArticles(BuildContext context, List<BlogPost> posts, S s) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(s.totalArticles, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 16),
        ...posts.map((p) => ListTile(title: Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis))),
      ]),
    ),
  );
}

void _showReadArticles(BuildContext context, Set<String> readArticles, List<BlogPost> posts, S s) {
  final readPosts = posts.where((p) => readArticles.contains(p.postId)).toList();
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(s.articlesRead, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 16),
        if (readPosts.isEmpty) Center(child: Text(s.noArticlesRead)),
        ...readPosts.map((p) => ListTile(title: Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis))),
      ]),
    ),
  );
}

void _showFavourites(BuildContext context, int favCount, S s) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.bookmark_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(s.favourited, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 8),
        Text('$favCount ${s.savedForLater}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
      ]),
    ),
  );
}

void _showEngagementDetail(BuildContext context, int readCount, int favCount, S s) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(s.engagement, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        const SizedBox(height: 16),
        _EngagementBar(label: s.articlesRead, value: readCount.toDouble()),
        const SizedBox(height: 8),
        _EngagementBar(label: s.favourited, value: readCount > 0 ? favCount / readCount : 0),
        const SizedBox(height: 8),
        _EngagementBar(label: s.favRate, value: readCount > 0 ? favCount / readCount : 0),
      ]),
    ),
  );
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  const _InsightCard({required this.icon, required this.iconColor, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)), child: Row(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 20)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(description, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7), fontSize: 12))])),
    ]));
  }
}

class _EngagementBar extends StatelessWidget {
  final String label;
  final double value;
  const _EngagementBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [Text(label, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))), Text(' ${(value * 100).toInt()}%', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700))]),
      const SizedBox(height: 4),
      LinearProgressIndicator(value: value.clamp(0, 1), backgroundColor: cs.outline),
    ]);
  }
}

class _CategoryTile extends StatelessWidget {
  final String category;
  final int readCount;
  final int totalCount;
  final S s;
  const _CategoryTile({required this.category, required this.readCount, required this.totalCount, required this.s});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = totalCount > 0 ? readCount / totalCount : 0.0;
    return GestureDetector(onTap: () {}, child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Text(category, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)), const Spacer(), Text('$readCount/$totalCount', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)))]),
      const SizedBox(height: 8),
      LinearProgressIndicator(value: pct, backgroundColor: cs.outline, borderRadius: BorderRadius.circular(4)),
    ])));
  }
}

class _WeeklyChart extends ConsumerWidget {
  final List<BlogPost> posts;
  final Set<String> readArticles;
  final List<double> weekly;
  final ColorScheme cs;
  final S s;
  const _WeeklyChart({required this.posts, required this.readArticles, required this.weekly, required this.cs, required this.s});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxVal = weekly.isNotEmpty ? weekly.reduce((a, b) => a > b ? a : b) : 1.0;
    final swahili = ref.watch(settingsProvider).swahiliFirst;
    final days = swahili ? ['Jumatatu', 'Jumanne', 'Jumatano', 'Alahamisi', 'Ijumaa', 'Jumamosi', 'Jumapili'] : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(7, (i) {
      final h = maxVal > 0 ? weekly[i] / maxVal : 0.1;
      final val = weekly[i];
      return Column(children: [Container(width: 8, height: 80 * h, decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(4))), const SizedBox(height: 4), Text(days[i], style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 10)), Text('${val.toInt()}', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w600))]);
    })));
  }
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final double value;
  const _ProgressBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      LinearProgressIndicator(value: value, backgroundColor: cs.outline, borderRadius: BorderRadius.circular(4)),
    ]));
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.bar_chart, color: cs.onSurface.withValues(alpha: 0.2), size: 48), const SizedBox(height: 12), Text(text, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)))]);
  }
}

