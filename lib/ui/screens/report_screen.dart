import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cyberswahili/providers/app_providers.dart';
import 'package:cyberswahili/providers/blog_providers.dart';
import 'package:cyberswahili/providers/strings_provider.dart';
import 'package:cyberswahili/models/blog_post.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(s.reports),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: cs.primary,
          labelColor: cs.primary,
          unselectedLabelColor: cs.onSurface.withValues(alpha: 0.5),
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: [
            Tab(text: s.readingReport),
            Tab(text: s.interests),
            Tab(text: s.achievements),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(),
          _InterestsTab(),
          _AchievementsTab(),
        ],
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final readArticles = ref.watch(readArticlesProvider);
    final asyncPosts = ref.watch(blogPostsProvider);

    return asyncPosts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        final isOffline = e.toString().contains('SocketException') || 
                         e.toString().contains('host lookup') || 
                         e.toString().contains('Network is unreachable');

        return Center(child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded, size: 48, color: Colors.redAccent.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(isOffline ? s.deviceOffline : s.networkErr, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(isOffline ? s.offlineMessage : e.toString(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ));
      },
      data: (posts) {
        final today = DateTime.now();
        final readToday = readArticles.values.where((d) => 
          d.year == today.year && d.month == today.month && d.day == today.day).length;
        
        const dailyGoal = 3;
        final goalProgress = (readToday / dailyGoal).clamp(0.0, 1.0);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionTitle(s.dailyGoal),
            const SizedBox(height: 12),
            _GoalCard(
              progress: goalProgress,
              current: readToday,
              goal: dailyGoal,
              s: s,
            ),
            const SizedBox(height: 32),
            _SectionTitle(s.activity),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: s.articlesRead,
                    value: readArticles.length.toString(),
                    icon: Icons.auto_stories_rounded,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    label: s.readingStreak,
                    value: s.daysCount(_computeStreak(readArticles.values)),
                    icon: Icons.local_fire_department_rounded,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _SectionTitle(s.weeklyTrend),
            const SizedBox(height: 12),
            _WeeklyChart(readArticles: readArticles, s: s),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () => _showClearConfirm(context, ref, s),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 0.5),
              ),
              child: Text(s.clearReadHistory),
            ),
          ],
        );
      },
    );
  }

  int _computeStreak(Iterable<DateTime> readDates) {
    final days = readDates.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList()
      ..sort((a, b) => b.compareTo(a));
    if (days.isEmpty) return 0;
    
    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  void _showClearConfirm(BuildContext context, WidgetRef ref, S s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.clearReadHistory),
        content: Text(s.clearReadHistorySub),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          ElevatedButton(
            onPressed: () {
              ref.read(readArticlesProvider.notifier).clearAll();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(s.proceed),
          ),
        ],
      ),
    );
  }
}

class _InterestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final readArticles = ref.watch(readArticlesProvider);
    final asyncPosts = ref.watch(blogPostsProvider);

    return asyncPosts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        final isOffline = e.toString().contains('SocketException') || 
                         e.toString().contains('host lookup') || 
                         e.toString().contains('Network is unreachable');

        return Center(child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded, size: 48, color: Colors.redAccent.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(isOffline ? s.deviceOffline : s.networkErr, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(isOffline ? s.offlineMessage : e.toString(), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ));
      },
      data: (posts) {
        final blogPosts = posts.cast<BlogPost>();
        final stats = _computeCategoryStats(blogPosts, readArticles.keys.toSet());
        final sortedKeys = stats.keys.toList()
          ..sort((a, b) => (stats[b]!['read'] ?? 0).compareTo(stats[a]!['read'] ?? 0));

        if (sortedKeys.isEmpty) {
          return Center(child: Text(s.noCategoryData));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: sortedKeys.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _SectionTitle(s.viewByCategory),
              );
            }
            final cat = sortedKeys[index - 1];
            final read = stats[cat]!['read']!;
            final total = stats[cat]!['total']!;
            return _InterestTile(category: cat, read: read, total: total);
          },
        );
      },
    );
  }

  Map<String, Map<String, int>> _computeCategoryStats(List<BlogPost> posts, Set<String> readIds) {
    final stats = <String, Map<String, int>>{};
    for (final post in posts) {
      for (final label in post.labels) {
        stats.putIfAbsent(label, () => {'read': 0, 'total': 0});
        stats[label]!['total'] = stats[label]!['total']! + 1;
        if (readIds.contains(post.postId)) {
          stats[label]!['read'] = stats[label]!['read']! + 1;
        }
      }
    }
    return stats;
  }
}

class _AchievementsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final readCount = ref.watch(readArticlesProvider).length;
    final favCount = ref.watch(favouritesProvider).length;

    final badges = [
      _BadgeData(
        title: s.badgeNewReader,
        desc: s.badgeNewReaderDesc,
        icon: Icons.auto_awesome_rounded,
        unlocked: readCount >= 1,
        color: Colors.amber,
      ),
      _BadgeData(
        title: s.badgeTechLover,
        desc: s.badgeTechLoverDesc,
        icon: Icons.bolt_rounded,
        unlocked: readCount >= 10,
        color: Colors.blue,
      ),
      _BadgeData(
        title: s.badgeCollector,
        desc: s.badgeCollectorDesc,
        icon: Icons.bookmark_rounded,
        unlocked: favCount >= 5,
        color: Colors.teal,
      ),
      _BadgeData(
        title: s.badgePowerReader,
        desc: s.badgePowerReaderDesc,
        icon: Icons.workspace_premium_rounded,
        unlocked: readCount >= 50,
        color: Colors.purple,
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) => _BadgeCard(data: badges[index]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        letterSpacing: 1.2,
      ),
    ),
  );
}

class _GoalCard extends StatelessWidget {
  final double progress;
  final int current, goal;
  final S s;
  const _GoalCard({required this.progress, required this.current, required this.goal, required this.s});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final done = progress >= 1.0;

    return Semantics(
      label: done ? s.goalReached : s.keepReading,
      value: '$current ${s.sw ? 'kati ya' : 'of'} $goal ${s.articles}',
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cs.primary.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ExcludeSemantics(
                  child: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(done ? Icons.emoji_events_rounded : Icons.track_changes_rounded, color: cs.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(done ? s.goalReached : s.keepReading,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      Text('$current / $goal ${s.articles}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: cs.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      value: value,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final Map<String, DateTime> readArticles;
  final S s;
  const _WeeklyChart({required this.readArticles, required this.s});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final counts = List.generate(7, (index) {
      final day = now.subtract(Duration(days: 6 - index));
      return readArticles.values.where((d) => 
        d.year == day.year && d.month == day.month && d.day == day.day).length;
    });

    final maxVal = counts.reduce((a, b) => a > b ? a : b).toDouble();
    final days = s.sw 
      ? ['J3', 'J4', 'JT', 'AL', 'IJ', 'JM', 'JP']
      : ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    final dayNamesFull = s.sw
      ? ['Jumatatu', 'Jumanne', 'Jumatano', 'Alhamisi', 'Ijumaa', 'Jumamosi', 'Jumapili']
      : ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Semantics(
        label: s.sw ? 'Grafu ya mwenendo wa wiki' : 'Weekly reading trend chart',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (i) {
            final h = maxVal > 0 ? (counts[i] / maxVal) : 0.05;
            final dayName = dayNamesFull[i];
            
            return Semantics(
              label: '$dayName: ${counts[i]} ${s.articles}',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(counts[i].toString(), 
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    semanticsLabel: '', // Hide from screen reader as it's in the Column label
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 12,
                    height: 80 * h + 5,
                    decoration: BoxDecoration(
                      color: i == 6 ? cs.primary : cs.primary.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(days[i], 
                    style: const TextStyle(fontSize: 10),
                    semanticsLabel: '', // Hide from screen reader
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _InterestTile extends StatelessWidget {
  final String category;
  final int read, total;
  const _InterestTile({required this.category, required this.read, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pct = total > 0 ? read / total : 0.0;

    return Semantics(
      label: category,
      value: '$read / $total articles read',
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(category, style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text('$read / $total', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 6,
                backgroundColor: cs.outline.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(cs.primary.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final _BadgeData data;
  const _BadgeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: data.title,
      hint: data.desc,
      value: data.unlocked ? 'Unlocked' : 'Locked',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: data.unlocked ? cs.surfaceContainerHighest : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: data.unlocked ? data.color.withValues(alpha: 0.3) : cs.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: data.unlocked ? data.color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  data.icon, 
                  color: data.unlocked ? data.color : Colors.grey.withValues(alpha: 0.5),
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              data.title, 
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700, 
                fontSize: 14,
                color: data.unlocked ? cs.onSurface : cs.onSurface.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: cs.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeData {
  final String title, desc;
  final IconData icon;
  final bool unlocked;
  final Color color;
  _BadgeData({required this.title, required this.desc, required this.icon, required this.unlocked, required this.color});
}
