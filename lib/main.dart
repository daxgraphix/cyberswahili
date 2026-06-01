import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/generated/app_localizations.dart';
import 'services/database_service.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';
import 'providers/app_providers.dart';

/// Main entry point for the CyberSwahili app.
/// Initializes Flutter, loads environment variables, sets up database,
/// and runs the app with Riverpod provider scope.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Load SharedPreferences before runApp so theme is ready immediately
  final prefs = await SharedPreferences.getInstance();

  try { await dotenv.load(fileName: '.env'); }
  catch (e) { debugPrint('Warning: .env not loaded: $e'); }

  try { await DatabaseService.isar; }
  catch (e) { debugPrint('Warning: DB init failed: $e'); }

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const CyberSwahiliApp(),
    ),
  );
}

/// Root widget for the CyberSwahili app.
/// Manages theme, localization, and text scaling based on user settings.
class CyberSwahiliApp extends ConsumerWidget {
  const CyberSwahiliApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final settings  = ref.watch(settingsProvider);
    final locale = settings.swahiliFirst ? const Locale('sw') : const Locale('en');

    return MaterialApp(
      title: 'CyberSwahili',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: locale,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Apply user's text scale factor from settings
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(settings.textScale),
        ),
        child: child!,
      ),
      home: const HomeScreen(),
    );
  }
}
