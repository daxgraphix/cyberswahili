import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Holds the SharedPreferences instance — overridden in main()
final sharedPrefsProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('SharedPreferences not initialized'),
);

// ── Theme ─────────────────────────────────────────────────────────────────────

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const _key = 'theme_mode';

  ThemeNotifier(this._prefs)
      : super(
          _prefs.getString(_key) == 'light' ? ThemeMode.light : ThemeMode.dark,
        );

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_key, mode == ThemeMode.light ? 'light' : 'dark');
  }

  void toggle() =>
      setTheme(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  bool get isDark => state == ThemeMode.dark;
}

final themeModeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref.watch(sharedPrefsProvider));
});

// ── View Modes ────────────────────────────────────────────────────────────────

enum ViewMode { list, grid, cards }

// ── App Settings ──────────────────────────────────────────────────────────────

class AppSettings {
  final double textScale;    // 0.85 | 1.0 | 1.2
  final bool swahiliFirst;
  final bool autoCache;
  final bool notifications;
  final ViewMode viewMode;   // list | grid | cards

  const AppSettings({
    this.textScale = 1.0,
    this.swahiliFirst = true,
    this.autoCache = true,
    this.notifications = true,
    this.viewMode = ViewMode.list,
  });

  AppSettings copyWith({
    double? textScale,
    bool? swahiliFirst,
    bool? autoCache,
    bool? notifications,
    ViewMode? viewMode,
  }) =>
      AppSettings(
        textScale: textScale ?? this.textScale,
        swahiliFirst: swahiliFirst ?? this.swahiliFirst,
        autoCache: autoCache ?? this.autoCache,
        notifications: notifications ?? this.notifications,
        viewMode: viewMode ?? this.viewMode,
      );
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs)
      : super(AppSettings(
          textScale: _prefs.getDouble('text_scale') ?? 1.0,
          swahiliFirst: _prefs.getBool('swahili_first') ?? true,
          autoCache: _prefs.getBool('auto_cache') ?? true,
          notifications: _prefs.getBool('notifications') ?? true,
          viewMode: ViewMode.values[_prefs.getInt('view_mode') ?? 0],
        ));

  Future<void> setTextScale(double scale) async {
    state = state.copyWith(textScale: scale);
    await _prefs.setDouble('text_scale', scale);
  }

  Future<void> setSwahiliFirst(bool v) async {
    state = state.copyWith(swahiliFirst: v);
    await _prefs.setBool('swahili_first', v);
  }

  Future<void> setAutoCache(bool v) async {
    state = state.copyWith(autoCache: v);
    await _prefs.setBool('auto_cache', v);
  }

  Future<void> setNotifications(bool v) async {
    state = state.copyWith(notifications: v);
    await _prefs.setBool('notifications', v);
  }

  Future<void> setViewMode(ViewMode mode) async {
    state = state.copyWith(viewMode: mode);
    await _prefs.setInt('view_mode', mode.index);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.watch(sharedPrefsProvider));
});

// ── Favourites ─────────────────────────────────────────────────────────────

class FavouritesNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences _prefs;
  static const _key = 'favourites';

  FavouritesNotifier(this._prefs)
      : super(Set.from(_prefs.getStringList(_key) ?? []));

  Future<void> toggle(String postId) async {
    final s = Set<String>.from(state);
    if (s.contains(postId)) {
      s.remove(postId);
    } else {
      s.add(postId);
    }
    state = s;
    await _prefs.setStringList(_key, s.toList());
  }

  bool isFav(String postId) => state.contains(postId);
}

final favouritesProvider =
    StateNotifierProvider<FavouritesNotifier, Set<String>>((ref) =>
        FavouritesNotifier(ref.watch(sharedPrefsProvider)));

// ── Read Articles ─────────────────────────────────────────────────────────────

class ReadArticlesNotifier extends StateNotifier<Set<String>> {
  final SharedPreferences _prefs;
  static const _key = 'read_articles';

  ReadArticlesNotifier(this._prefs)
      : super(Set.from(_prefs.getStringList(_key) ?? []));

  Future<void> markAsRead(String postId) async {
    final s = Set<String>.from(state)..add(postId);
    state = s;
    await _prefs.setStringList(_key, s.toList());
  }

  bool isRead(String postId) => state.contains(postId);

  Future<void> clearAll() async {
    state = {};
    await _prefs.remove(_key);
  }
}

final readArticlesProvider =
    StateNotifierProvider<ReadArticlesNotifier, Set<String>>((ref) =>
        ReadArticlesNotifier(ref.watch(sharedPrefsProvider)));

// ── Categories ─────────────────────────────────────────────────────────────

const kAllCategories = [
  'Articles', 'Elimu', 'Opportunities', 'AI resources',
];

class CategoriesNotifier extends StateNotifier<List<String>> {
  final SharedPreferences _prefs;
  static const _key = 'enabled_cats';

  CategoriesNotifier(this._prefs)
      : super(_prefs.getStringList(_key) ?? kAllCategories);

  Future<void> toggle(String cat) async {
    final s = List<String>.from(state);
    if (s.contains(cat)) {
      if (s.length > 1) s.remove(cat); // keep at least one
    } else {
      s.add(cat);
    }
    state = s;
    await _prefs.setStringList(_key, s);
  }

  Future<void> reset() async {
    state = kAllCategories;
    await _prefs.setStringList(_key, kAllCategories);
  }
}

final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, List<String>>((ref) =>
        CategoriesNotifier(ref.watch(sharedPrefsProvider)));
