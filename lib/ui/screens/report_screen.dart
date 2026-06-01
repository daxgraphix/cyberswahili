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
    final readCount = ref.watch(readArticlesProvider).length;
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
        child: asyncPosts.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading stats: $e')),
          data: (posts) {
            final totalPosts = posts.length;
            final readPercentage = totalPosts > 0 ? (readCount / totalPosts * 100).round() : 0;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
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

                // Stats Cards
                Row(children: [
                  _StatCard(
                    icon: Icons.article_rounded,
                    iconColor: Colors.blue,
                    title: s.totalArticles,
                    value: totalPosts.toString(),
                    subtitle: s.availableArticles,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.visibility_rounded,
                    iconColor: Colors.green,
                    title: s.articlesRead,
                    value: readCount.toString(),
                    subtitle: '$readPercentage% ${s.ofTotal}',
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
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.trending_up_rounded,
                    iconColor: Colors.purple,
                    title: s.engagement,
                    value: readCount > 0 ? '${(favCount / readCount * 100).round()}%' : '0%',
                    subtitle: s.favRate,
                  ),
                ]),
                const SizedBox(height: 24),

                // Insights
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
                ),
                const SizedBox(height: 12),
                _InsightCard(
                  icon: Icons.refresh_rounded,
                  iconColor: Colors.indigo,
                  title: s.keepUpdated,
                  description: s.keepUpdatedDesc,
                ),
              ],
            );
          },
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

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
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
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _InsightCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
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
      ]),
    );
  }
}