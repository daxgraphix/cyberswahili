import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for app settings including language preference and theme
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

/// App settings model
class AppSettings {
  final bool swahiliFirst;
  final bool darkMode;
  final double textScale;
  final bool enableNotifications;

  AppSettings({
    this.swahiliFirst = true,
    this.darkMode = false,
    this.textScale = 1.0,
    this.enableNotifications = true,
  });

  AppSettings copyWith({
    bool? swahiliFirst,
    bool? darkMode,
    double? textScale,
    bool? enableNotifications,
  }) {
    return AppSettings(
      swahiliFirst: swahiliFirst ?? this.swahiliFirst,
      darkMode: darkMode ?? this.darkMode,
      textScale: textScale ?? this.textScale,
      enableNotifications: enableNotifications ?? this.enableNotifications,
    );
  }
}

/// Notifier for managing app settings
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(AppSettings());

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      swahiliFirst: prefs.getBool('swahili_first') ?? true,
      darkMode: prefs.getBool('dark_mode') ?? false,
      textScale: prefs.getDouble('text_scale') ?? 1.0,
      enableNotifications: prefs.getBool('enable_notifications') ?? true,
    );
  }

  Future<void> updateSwahiliFirst(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('swahili_first', value);
    state = state.copyWith(swahiliFirst: value);
  }

  Future<void> updateDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    state = state.copyWith(darkMode: value);
  }

  Future<void> updateTextScale(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('text_scale', value);
    state = state.copyWith(textScale: value);
  }

  Future<void> updateNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_notifications', value);
    state = state.copyWith(enableNotifications: value);
  }
}

/// Provider for shared preferences
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Use overrideWithValue in main.dart');
});