import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cyberswahili/providers/app_providers.dart';
import 'package:cyberswahili/providers/blog_providers.dart';
import 'package:cyberswahili/providers/strings_provider.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final readArticles = ref.watch(readArticlesProvider);
    final favCount = ref.watch(favouritesProvider).length;
    final asyncPosts = ref.watch(blogPostsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(s.reports),
        elevation: 0,
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Reading'),
                  Tab(text: 'Insights'),
                  Tab(text: 'Analytics'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildReadingTab(context, ref, s, readArticles, favCount, asyncPosts, cs),
                    _buildInsightsTab(context, ref, s, readArticles, asyncPosts, cs),
                    _buildAnalyticsTab(context, ref, s, readArticles, asyncPosts, cs),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingTab(BuildContext context, WidgetRef ref, S s,
      Set<String> readArticles, int favCount, AsyncValue<List> asyncPosts, ColorScheme cs) {
    return asyncPosts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (posts) {
        final totalPosts = posts.length;
        final readCount = readArticles.length;
        final readPercentage = totalPosts > 0 ? (readCount / totalPosts * 100).round() : 0;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
              ),
              child: Column(children: [
                Icon(Icons.analytics_rounded, size: 48, color: cs.primary),
                const SizedBox(height: 12),
                Text(
                  s.readingReport,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.reportSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ]),
            ),
            const SizedBox(height: 24),

            Row(children: [
              _StatCard(
                icon: Icons.article_rounded,
                iconColor: Colors.blue,
                title: s.totalArticles,
                value: totalPosts.toString(),
                subtitle: s.availableArticles,
                onTap: () => _showAllArticles(context, s, posts),
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.visibility_rounded,
                iconColor: Colors.green,
                title: s.articlesRead,
                value: readCount.toString(),
                subtitle: '$readPercentage% ${s.ofTotal}',
                onTap: () => _showReadArticles(context, s, readArticles, posts),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _StatCard(
                icon: Icons.bookmark_rounded,
                iconColor: Colors.orange,
                title: s.favourited,
                value: favCount.toString(),
                subtitle: s.savedForLater,
                onTap: () => _showFavourites(context, s, favCount),
              ),
              const SizedBox(width: 12),
              _StatCard(
                icon: Icons.trending_up_rounded,
                iconColor: Colors.purple,
                title: s.engagement,
                value: readCount > 0 ? '${(favCount / readCount * 100).round()}%' : '0%',
                subtitle: s.favRate,
                onTap: () => _showEngagementDetail(context, s, readCount, favCount),
              ),
            ]),
            const SizedBox(height: 24),

            Text(
              s.insights,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _InsightCard(
              icon: Icons.lightbulb_rounded,
              iconColor: Colors.amber,
              title: readPercentage >= 50 ? s.greatReader : readPercentage >= 25 ? s.goodReader : s.startReading,
              description: readPercentage >= 50
                  ? s.greatReaderDesc
                  : readPercentage >= 25
                      ? s.goodReaderDesc
                      : s.startReadingDesc,
              onTap: () => _showReadingTip(context, s, readPercentage),
            ),
            const SizedBox(height: 12),
            _InsightCard(
              icon: Icons.bookmark_border_rounded,
              iconColor: Colors.teal,
              title: favCount >= 10 ? s.activeSaver : favCount >= 5 ? s.moderateSaver : s.saveMore,
              description: favCount >= 10
                  ? s.activeSaverDesc
                  : favCount >= 5
                      ? s.moderateSaverDesc
                      : s.saveMoreDesc,
              onTap: () => _showSaveTip(context, s, favCount),
            ),
            const SizedBox(height: 12),
            _InsightCard(
              icon: Icons.refresh_rounded,
              iconColor: Colors.indigo,
              title: s.keepUpdated,
              description: s.keepUpdatedDesc,
              onTap: () => _showRefreshTip(context, s),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInsightsTab(BuildContext context, WidgetRef ref, S s,
      Set<String> readArticles, AsyncValue<List> asyncPosts, ColorScheme cs) {
    return asyncPosts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (posts) {
        final categoryStats = _computeCategoryStats(posts, readArticles);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              s.viewByCategory,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            if (categoryStats.isEmpty)
              Center(child: Text(s.noCategoryData)),
            ...categoryStats.entries.map((e) => _CategoryTile(
              category: e.key,
              readCount: e.value['read'] ?? 0,
              totalCount: e.value['total'] ?? 0,
              onTap: () => _showCategoryDetail(context, s, e.key, e.value),
            )),
            const SizedBox(height: 24),
            Text(
              s.readingHabits,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _HabitCard(
              icon: Icons.calendar_today_rounded,
              title: s.readingStreak,
              value: '${_computeStreak(readArticles)} ${s.daysActive}',
              onTap: () => _showStreakDetail(context, s, readArticles),
            ),
            const SizedBox(height: 12),
            _HabitCard(
              icon: Icons.assessment_rounded,
              title: s.assessment,
              value: readArticles.isEmpty ? '--' : '${readArticles.length} ${s.booksRead}',
              onTap: () => _showAssessment(context, s, readArticles.length),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsTab(BuildContext context, WidgetRef ref, S s,
      Set<String> readArticles, AsyncValue<List> asyncPosts, ColorScheme cs) {
    return asyncPosts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (posts) {
        final favCountLocal = ref.watch(favouritesProvider).length;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              s.weeklyTrend,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildSimpleBarChart(posts, readArticles, cs),
            ),
            const SizedBox(height: 24),
            Text(
              s.favVsRead,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildDistributionChart(readArticles.length.toDouble(), favCountLocal.toDouble(), posts.length.toDouble(), cs),
            const SizedBox(height: 24),
            Text(
              s.distribution,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildProgressBars(posts, readArticles, cs, context),
          ],
        );
      },
    );
  }

  Widget _buildSimpleBarChart(List posts, Set<String> readArticles, ColorScheme cs) {
    final weekly = _computeWeeklyData(posts, readArticles);
    final maxVal = weekly.isNotEmpty ? weekly.reduce((a, b) => a > b ? a : b) : 1.0;
    final days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final height = maxVal > 0 ? weekly[i] / maxVal : 0.1;
        return Column(
          children: [
            Container(
              width: 8,
              height: 100 * height,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Text(days[i], style: const TextStyle(fontSize: 10)),
          ],
        );
      }),
    );
  }

  Widget _buildDistributionChart(double readCount, double favCount, double total, ColorScheme cs) {
    final readPct = total > 0 ? readCount / total : 0.0;
    final favPct = readCount > 0 ? favCount / readCount : 0.0;
    
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.outline, width: 2),
                    ),
                  ),
                  Transform.rotate(
                    angle: -math.pi / 2,
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: LinearProgressIndicator(
                        value: readPct,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Read', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.outline, width: 2),
                    ),
                  ),
                  Transform.rotate(
                    angle: -math.pi / 2,
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: LinearProgressIndicator(
                        value: favPct,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Favourited', style: TextStyle(color: Colors.orange)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBars(List posts, Set<String> readArticles, ColorScheme cs, BuildContext context) {
    final categoryStats = _computeCategoryStats(posts, readArticles);
    return Column(
      children: categoryStats.entries.map((e) {
        final read = (e.value['read'] ?? 0).toDouble();
        final total = (e.value['total'] ?? 1).toDouble();
        final pct = total > 0 ? read / total : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${e.key} (${read.toInt()}/${total.toInt()})',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(value: pct, backgroundColor: cs.outline),
            ],
          ),
        );
      }).toList(),
    );
  }

  Map<String, Map<String, int>> _computeCategoryStats(List posts, Set<String> readArticles) {
    final stats = <String, Map<String, int>>{};
    for (final post in posts) {
      final labels = post.labels as List? ?? [];
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

  List<double> _computeWeeklyData(List posts, Set<String> readArticles) {
    final weekly = List.filled(7, 0.0);
    for (final post in posts) {
      if (readArticles.contains(post.postId)) {
        final day = post.published.weekday - 1;
        weekly[day] = weekly[day] + 1;
      }
    }
    return weekly;
  }

  int _computeStreak(Set<String> readArticles) {
    return readArticles.length > 10 ? 7 : readArticles.length > 5 ? 3 : readArticles.length;
  }

  void _showAllArticles(BuildContext context, S s, List posts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.totalArticles, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 16),
            ...posts.map((p) => ListTile(
              title: Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(p.published.toString().split(' ')[0]),
            )),
          ],
        ),
      ),
    );
  }

  void _showReadArticles(BuildContext context, S s, Set<String> readArticles, List posts) {
    final readPosts = posts.where((p) => readArticles.contains(p.postId)).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${s.articlesRead} (${readPosts.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 16),
            if (readPosts.isEmpty)
              Center(child: Text(s.tapArticleToTrack)),
            ...readPosts.map((p) => ListTile(
              title: Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis),
            )),
          ],
        ),
      ),
    );
  }

  void _showFavourites(BuildContext context, S s, int favCount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(s.favourited, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            Text('$favCount ${s.savedForLater}', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  void _showEngagementDetail(BuildContext context, S s, int readCount, int favCount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(s.engagement, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 16),
            _EngagementBar(label: s.articlesRead, value: readCount > 0 ? 1.0 : 0.5),
            const SizedBox(height: 8),
            _EngagementBar(label: s.favourited, value: readCount > 0 ? favCount / readCount : 0),
          ],
        ),
      ),
    );
  }

  void _showReadingTip(BuildContext context, S s, int percentage) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lightbulb_rounded, size: 48, color: Colors.amber),
            const SizedBox(height: 12),
            Text(s.greatReader, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            Text(percentage >= 50 ? s.greatReaderDesc : percentage >= 25 ? s.goodReaderDesc : s.startReadingDesc),
          ],
        ),
      ),
    );
  }

  void _showSaveTip(BuildContext context, S s, int favCount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_rounded, size: 48, color: Colors.orange),
            const SizedBox(height: 12),
            Text(favCount >= 10 ? s.activeSaver : favCount >= 5 ? s.moderateSaver : s.saveMore, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            Text(favCount >= 10 ? s.activeSaverDesc : favCount >= 5 ? s.moderateSaverDesc : s.saveMoreDesc),
          ],
        ),
      ),
    );
  }

  void _showCategoryDetail(BuildContext context, S s, String category, Map data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 12),
            Text('${data['read']} ${s.ofTotal} ${data['total']} ${s.articlesRead}'),
          ],
        ),
      ),
    );
  }

  void _showStreakDetail(BuildContext context, S s, Set<String> readArticles) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, size: 48, color: Colors.blue),
            const SizedBox(height: 12),
            Text(s.readingStreak, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            Text('${_computeStreak(readArticles)} ${s.daysActive}'),
          ],
        ),
      ),
    );
  }

  void _showAssessment(BuildContext context, S s, int readCount) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assessment_rounded, size: 48, color: Colors.purple),
            const SizedBox(height: 12),
            Text(s.assessment, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            Text('$readCount ${s.booksRead}'),
          ],
        ),
      ),
    );
  }

  void _showRefreshTip(BuildContext context, S s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, size: 48, color: Colors.indigo),
            const SizedBox(height: 12),
            Text(s.keepUpdated, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 8),
            Text(s.keepUpdatedDesc),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outline),
          ),
          child: Column(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ]),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _InsightCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ]),
          ),
          Icon(Icons.chevron_right_rounded, color: cs.onSurface.withValues(alpha: 0.5)),
        ]),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _HabitCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cs.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withValues(alpha: 0.7))),
          ]),
        ]),
      ),
    );
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
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      LinearProgressIndicator(value: value.clamp(0, 1), backgroundColor: cs.outline),
    ]);
  }
}

class _CategoryTile extends StatelessWidget {
  final String category;
  final int readCount;
  final int totalCount;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.readCount,
    required this.totalCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percentage = totalCount > 0 ? (readCount / totalCount.toDouble()) : 0.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(category, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('$readCount/$totalCount', style: Theme.of(context).textTheme.bodySmall),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: percentage, backgroundColor: cs.outline),
        ]),
      ),
    );
  }
}