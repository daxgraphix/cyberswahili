import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cyberswahili/providers/app_providers.dart';
import 'package:cyberswahili/providers/blog_providers.dart';
import 'package:cyberswahili/providers/strings_provider.dart';
import 'package:cyberswahili/ui/theme/app_theme.dart';
import 'package:cyberswahili/ui/screens/report_screen.dart';

class SettingsScreen extends ConsumerWidget {
  final bool embedded;
  const SettingsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final settings  = ref.watch(settingsProvider);
    final s         = ref.watch(stringsProvider);
    final isDark    = themeMode == ThemeMode.dark;
    final cs        = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: embedded ? null : AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(s.settings),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            if (embedded) _header(context, cs),

            // ── MUONEKANO ─────────────────────────────────────────────
            _Sec(s.secAppearance, Icons.palette_rounded),
            _Card([
              _SwRow(
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                iconColor: isDark ? const Color(0xFF7C6FF7) : Colors.orange,
                title: isDark ? s.darkMode : s.lightMode,
                sub: s.modeSub,
                val: isDark,
                onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
              ),
              _Div(),
              _PickRow(
                icon: Icons.format_size_rounded,
                iconColor: cs.primary,
                title: s.textSize,
                current: _scaleLabel(settings.textScale, s),
                opts: [s.small, s.medium, s.large],
                onPick: (o) => ref.read(settingsProvider.notifier)
                    .setTextScale(o == s.small ? 0.85 : o == s.large ? 1.2 : 1.0),
              ),
              _Div(),
              _PickRow(
                icon: Icons.view_list_rounded,
                iconColor: Colors.purple,
                title: s.viewMode,
                current: _viewModeLabel(settings.viewMode, s),
                opts: [s.list, s.grid, s.cards],
                onPick: (o) => ref.read(settingsProvider.notifier).setViewMode(
                  o == s.list ? ViewMode.list : o == s.grid ? ViewMode.grid : ViewMode.cards,
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // ── LUGHA ─────────────────────────────────────────────────
            _Sec(s.secLanguage, Icons.language_rounded),
            _Card([
              _PickRow(
                icon: Icons.translate_rounded,
                iconColor: Colors.teal,
                title: s.appLanguage,
                current: settings.swahiliFirst ? s.kiswahili : s.english,
                opts: [s.kiswahili, s.english],
                onPick: (o) => ref.read(settingsProvider.notifier).setSwahiliFirst(o == s.kiswahili),
              ),
            ]),
            const SizedBox(height: 20),

            // ── MAKALA ────────────────────────────────────────────────
            _Sec(s.secContent, Icons.article_rounded),
            _Card([
              _SwRow(
                icon: Icons.offline_bolt_rounded,
                iconColor: Colors.green,
                title: s.offlineCache,
                sub: s.offlineSub,
                val: settings.autoCache,
                onChanged: (v) => ref.read(settingsProvider.notifier).setAutoCache(v),
              ),
            ]),
            const SizedBox(height: 20),

            // ── ARIFA ─────────────────────────────────────────────────
            _Sec(s.secNotifications, Icons.notifications_rounded),
            _Card([
              _SwRow(
                icon: Icons.notifications_active_rounded,
                iconColor: Colors.orange,
                title: s.notifTitle,
                sub: s.notifSub,
                val: settings.notifications,
                onChanged: (v) => ref.read(settingsProvider.notifier).setNotifications(v),
              ),
            ]),
            const SizedBox(height: 20),

            // ── UAINISHAJI ────────────────────────────────────────────
            _Sec(s.secCategories, Icons.category_rounded),
            _Card([
              _NavRow(
                icon: Icons.tune_rounded,
                iconColor: Colors.deepPurple,
                title: s.chooseCategories,
                sub: s.catSub,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => _CategoriesPage(s: s))),
              ),
            ]),
            const SizedBox(height: 20),

            // ── SHIRIKI ───────────────────────────────────────────────
            _Sec(s.secShare, Icons.share_rounded),
            _Card([
              _NavRow(
                icon: Icons.share_rounded,
                iconColor: Colors.blue,
                title: s.shareApp,
                sub: s.shareSub,
                onTap: () => _shareApp(context, s),
              ),
            ]),
            const SizedBox(height: 20),

            // ── MSAADA ────────────────────────────────────────────────
            _Sec(s.secHelp, Icons.help_rounded),
            _Card([
              _NavRow(
                icon: Icons.quiz_rounded,
                iconColor: Colors.indigo,
                title: s.faqTitle,
                sub: s.faqSub,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => _FaqPage(s: s))),
              ),
            ]),
            const SizedBox(height: 20),

            // ── DATA ──────────────────────────────────────────────────
            _Sec(s.secData, Icons.storage_rounded),
            _Card([
              _NavRow(
                icon: Icons.sync_rounded,
                iconColor: cs.primary,
                title: s.refreshArt,
                sub: s.refreshSub,
                onTap: () {
                  ref.read(blogPostsProvider.notifier).refreshPosts();
                  _snack(context, s.refreshing, cs.primary);
                },
              ),
              _Div(),
              _NavRow(
                icon: Icons.delete_sweep_rounded,
                iconColor: Colors.redAccent,
                title: s.clearCache,
                sub: s.clearCacheSub,
                titleColor: Colors.redAccent,
                onTap: () => _clearCache(context, ref, s),
              ),
            ]),
            const SizedBox(height: 20),

            // ── WEKA UPYA ─────────────────────────────────────────────
            _Sec(s.secReset, Icons.restart_alt_rounded),
            _Card([
              _NavRow(
                icon: Icons.restart_alt_rounded,
                iconColor: Colors.redAccent,
                title: s.resetAll,
                sub: s.resetSub,
                titleColor: Colors.redAccent,
                onTap: () => _resetAll(context, ref, s),
              ),
            ]),
            const SizedBox(height: 20),

            // ── RIPOTI ────────────────────────────────────────────────
            _Sec(s.secReports, Icons.analytics_rounded),
            _Card([
              _NavRow(
                icon: Icons.analytics_rounded,
                iconColor: Colors.cyan,
                title: s.viewReports,
                sub: s.reportsDesc,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ReportScreen())),
              ),
            ]),
            const SizedBox(height: 20),

            // ── KUHUSU ────────────────────────────────────────────────
            _Sec(s.secAbout, Icons.info_rounded),
            _Card([
              _InfoRow(icon: Icons.newspaper_rounded, iconColor: cs.primary,
                  title: 'CyberSwahili', sub: 'Habari za Teknolojia kwa Kiswahili'),
              _Div(),
              _InfoRow(icon: Icons.tag_rounded, iconColor: Colors.grey,
                  title: s.sw ? 'Toleo' : 'Version', sub: 'v1.0.0 · Flutter'),
              _Div(),
              _InfoRow(icon: Icons.code_rounded, iconColor: Colors.blueGrey,
                  title: 'API', sub: 'Google Blogger API v3 · Isar DB'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context, ColorScheme cs) => Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: cs.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
    ),
    child: Row(children: [
      Container(width: 42, height: 42,
        decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Mipangilio', style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(fontWeight: FontWeight.w800)),
        Text('CyberSwahili v1.0.0', style: Theme.of(context).textTheme.bodySmall),
      ]),
    ]),
  );

  String _scaleLabel(double scale, S s) =>
      scale < 0.95 ? s.small : scale > 1.1 ? s.large : s.medium;

  String _viewModeLabel(ViewMode mode, S s) {
    switch (mode) {
      case ViewMode.list: return s.list;
      case ViewMode.grid: return s.grid;
      case ViewMode.cards: return s.cards;
    }
  }

  Future<void> _clearCache(BuildContext ctx, WidgetRef ref, S s) async {
    final ok = await _confirm(ctx, s.clearCacheQ, s.clearCacheBody, s);
    if (ok && ctx.mounted) {
      await ref.read(blogRepositoryProvider).clearCache();
      if (ctx.mounted) _snack(ctx, s.cacheCleared, AppTheme.primary);
    }
  }

  Future<void> _resetAll(BuildContext ctx, WidgetRef ref, S s) async {
    final ok = await _confirm(ctx, s.resetAllQ, s.resetAllBody, s);
    if (ok && ctx.mounted) {
      await ref.read(themeModeProvider.notifier).setTheme(ThemeMode.dark);
      await ref.read(settingsProvider.notifier).setTextScale(1.0);
      await ref.read(settingsProvider.notifier).setSwahiliFirst(true);
      await ref.read(settingsProvider.notifier).setAutoCache(true);
      await ref.read(settingsProvider.notifier).setNotifications(true);
      await ref.read(settingsProvider.notifier).setViewMode(ViewMode.list);
      await ref.read(categoriesProvider.notifier).reset();
      if (ctx.mounted) _snack(ctx, s.resetDone, AppTheme.primary);
    }
  }

  void _shareApp(BuildContext ctx, S s) {
    const text = 'Soma habari za Teknolojia kwa Kiswahili! '
        'Pakua CyberSwahili — programu bora ya habari za Tech. '
        '\nhttps://cyberswahili.blogspot.com';
    Clipboard.setData(const ClipboardData(text: text));
    _snack(ctx, s.shareCopied, AppTheme.primary);
  }

  Future<bool> _confirm(BuildContext ctx, String title, String body, S s) async {
    return await showDialog<bool>(
          context: ctx,
          builder: (d) => AlertDialog(
            backgroundColor: Theme.of(ctx).colorScheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Theme.of(ctx).colorScheme.outline)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            content: Text(body, style: const TextStyle(height: 1.5)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(d, false),
                  child: Text(s.cancel)),
              ElevatedButton(
                onPressed: () => Navigator.pop(d, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: Text(s.proceed),
              ),
            ],
          ),
        ) ??
        false;
  }

  static void _snack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(Icons.check_circle_rounded, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: Theme.of(ctx).colorScheme.surfaceContainerHighest,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }
}

// ── Categories sub-page ────────────────────────────────────────────────────────
class _CategoriesPage extends ConsumerWidget {
  final S s;
  const _CategoriesPage({required this.s});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(categoriesProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(s.chooseCategoriesPageTitle),
        actions: [
          TextButton(
            onPressed: () => ref.read(categoriesProvider.notifier).reset(),
            child: Text(s.selectAll, style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(s.categoriesHint,
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          ...kAllCategories.map((cat) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: enabled.contains(cat)
                  ? cs.primary.withValues(alpha: 0.08)
                  : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled.contains(cat)
                    ? cs.primary.withValues(alpha: 0.4)
                    : cs.outline),
            ),
              child: SwitchListTile(
                value: enabled.contains(cat),
                onChanged: (_) => ref.read(categoriesProvider.notifier).toggle(cat),
                title: Text(cat, style: const TextStyle(fontWeight: FontWeight.w600)),
                activeThumbColor: Colors.white,
                activeTrackColor: cs.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )),
        ],
      ),
    );
  }
}

// ── FAQ sub-page ───────────────────────────────────────────────────────────────
class _FaqPage extends StatelessWidget {
  final S s;
  const _FaqPage({required this.s});

  static const _faqs = [
    ('CyberSwahili ni nini?',
     'CyberSwahili ni programu inayoleta habari za teknolojia kwa lugha ya Kiswahili. '
     'Tunaamini kila Mwafrika anastahili kupata elimu ya kidijitali kwa lugha yake.'),
    ('Ninawezaje kusoma bila mtandao?',
     'Washa "Hifadhi Nje ya Mtandao" kwenye Mipangilio. Makala yatahifadhiwa '
     'kwenye simu yako na unaweza kuyasoma hata bila mtandao.'),
    ('Jinsi ya kuhifadhi makala yanayonipendeza?',
     'Gusa ikoni ya alama ya kitabu (🔖) kwenye makala yoyote. Makala yako '
     'yataorodheshwa kwenye kichupo cha "Vipendwa".'),
    ('Jinsi ya kubadilisha rangi ya programu?',
     'Nenda Mipangilio → Muonekano → Badilisha kati ya "Hali ya Giza" na "Hali ya Mwanga".'),
    ('Makala yanapiganwa kwa njia gani?',
     'Makala hutoka moja kwa moja kupitia Google Blogger API v3. '
     'Yanasasishwa moja kwa moja wakati unafungua programu.'),
    ('Ninawezaje kushiriki makala?',
     'Fungua makala yoyote kisha bonyeza kitufe cha "Shiriki". '
     'Kiungo kitakopwa kwenye ubao wa kunakili (clipboard).'),
    ('Programu haifanyi kazi vizuri. Nifanye nini?',
     'Jaribu: 1) Hakikisha una mtandao. 2) Futa akiba (Mipangilio → Data → Futa Akiba). '
     '3) Funga na ufungue programu upya.'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(s.faqTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
            ),
            child: Row(children: [
              Icon(Icons.quiz_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('Kuna maswali ${_faqs.length} yanayoulizwa mara nyingi.',
                  style: Theme.of(context).textTheme.bodyMedium)),
            ]),
          ),
          ..._faqs.map((faq) => _FaqTile(q: faq.$1, a: faq.$2)),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String q, a;
  const _FaqTile({required this.q, required this.a});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _open ? cs.primary.withValues(alpha: 0.4) : cs.outline),
      ),
      child: Column(children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(width: 28, height: 28,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.help_outline_rounded, size: 16, color: cs.primary)),
              const SizedBox(width: 12),
              Expanded(child: Text(widget.q,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
              Icon(_open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 20, color: cs.onSurface.withValues(alpha: 0.5)),
            ]),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
            child: Text(widget.a,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),
          ),
      ]),
    );
  }
}

// ── Shared components ─────────────────────────────────────────────────────────
class _Sec extends StatelessWidget {
  final String t; final IconData i;
  const _Sec(this.t, this.i);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(i, size: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
      const SizedBox(width: 6),
      Text(t, style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
    ]),
  );
}

class _Card extends StatelessWidget {
  final List<Widget> ch;
  const _Card(this.ch);
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).colorScheme.outline),
    ),
    child: Column(children: ch),
  );
}

class _Div extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 1, margin: const EdgeInsets.only(left: 56),
    color: Theme.of(context).colorScheme.outline);
}

class _IB extends StatelessWidget {
  final IconData ic; final Color c;
  const _IB(this.ic, this.c);
  @override
  Widget build(BuildContext context) => Container(
    width: 36, height: 36,
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: c.withValues(alpha: 0.2))),
    child: Icon(ic, color: c, size: 18),
  );
}

class _SwRow extends StatelessWidget {
  final IconData icon; final Color iconColor;
  final String title, sub; final bool val;
  final ValueChanged<bool> onChanged;
  const _SwRow({required this.icon, required this.iconColor,
      required this.title, required this.sub, required this.val, required this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      _IB(icon, iconColor), const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        Text(sub, style: Theme.of(context).textTheme.bodySmall),
      ])),
      Switch(value: val, onChanged: onChanged),
    ]),
  );
}

class _PickRow extends StatelessWidget {
  final IconData icon; final Color iconColor;
  final String title, current; final List<String> opts;
  final ValueChanged<String> onPick;
  const _PickRow({required this.icon, required this.iconColor,
      required this.title, required this.current, required this.opts, required this.onPick});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        _IB(icon, iconColor), const SizedBox(width: 14),
        Expanded(child: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
        GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: cs.surface,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (_) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 12),
                ...opts.map((o) => ListTile(
                  title: Text(o, style: TextStyle(
                      fontWeight: o == current ? FontWeight.w700 : FontWeight.normal,
                      color: o == current ? cs.primary : cs.onSurface)),
                  trailing: o == current ? Icon(Icons.check_rounded, color: cs.primary) : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () { onPick(o); Navigator.pop(context); },
                )),
              ]),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surface, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outline)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(current, style: TextStyle(color: cs.primary,
                  fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(width: 4),
              Icon(Icons.expand_more_rounded, size: 16,
                  color: cs.onSurface.withValues(alpha: 0.5)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon; final Color iconColor;
  final String title, sub;
  final Color? titleColor;
  final VoidCallback onTap;
  const _NavRow({required this.icon, required this.iconColor,
      required this.title, required this.sub, this.titleColor, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap, borderRadius: BorderRadius.circular(16),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        _IB(icon, iconColor), const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,
              color: titleColor ?? Theme.of(context).colorScheme.onSurface)),
          Text(sub, style: Theme.of(context).textTheme.bodySmall),
        ])),
        Icon(Icons.chevron_right_rounded, size: 18,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35)),
      ]),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final Color iconColor;
  final String title, sub;
  const _InfoRow({required this.icon, required this.iconColor, required this.title, required this.sub});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(children: [
      _IB(icon, iconColor), const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        Text(sub, style: Theme.of(context).textTheme.bodySmall),
      ])),
    ]),
  );
}
