import 'package:flutter/material.dart';

/// CyberSwahili Design System — Red, White, Black
class AppTheme {
  // Brand red — same in both modes
  static const Color primary    = Color(0xFFE53935);
  static const Color primaryDark= Color(0xFFB71C1C);
  static const Color primaryLight= Color(0xFFEF5350);

  // ── Dark palette ────────────────────────────────────────────────────────────
  static const Color dkBg       = Color(0xFF0C0C0C);
  static const Color dkSurface  = Color(0xFF161616);
  static const Color dkElevated = Color(0xFF202020);
  static const Color dkBorder   = Color(0xFF2C2C2C);
  static const Color dkText     = Color(0xFFFFFFFF);
  static const Color dkTextSub  = Color(0xFFABABAB);
  static const Color dkTextMuted= Color(0xFF5C5C5C);

  // ── Light palette ───────────────────────────────────────────────────────────
  static const Color ltBg       = Color(0xFFFFFFFF);
  static const Color ltSurface  = Color(0xFFF5F5F5);
  static const Color ltElevated = Color(0xFFEEEEEE);
  static const Color ltBorder   = Color(0xFFE0E0E0);
  static const Color ltText     = Color(0xFF0C0C0C);
  static const Color ltTextSub  = Color(0xFF4A4A4A);
  static const Color ltTextMuted= Color(0xFF9A9A9A);

  static ThemeData dark() => _build(Brightness.dark);
  static ThemeData light() => _build(Brightness.light);

  static ThemeData _build(Brightness br) {
    final dark = br == Brightness.dark;
    final bg      = dark ? dkBg       : ltBg;
    final surface = dark ? dkSurface  : ltSurface;
    final border  = dark ? dkBorder   : ltBorder;
    final txt     = dark ? dkText     : ltText;
    final txtSub  = dark ? dkTextSub  : ltTextSub;
    final red     = dark ? primary    : primaryDark;

    return ThemeData(
      useMaterial3: true,
      brightness: br,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: br,
        primary: red,
        onPrimary: Colors.white,
        secondary: primaryLight,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: txt,
        error: const Color(0xFFCF6679),
        onError: Colors.white,
        outline: border,
        surfaceContainerHighest: dark ? dkElevated : ltElevated,
      ),
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: txt),
        titleTextStyle: TextStyle(
          color: txt,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: red.withValues(alpha: 0.1),
        labelStyle: TextStyle(color: red, fontSize: 11, fontWeight: FontWeight.w700),
        side: BorderSide(color: red.withValues(alpha: 0.35)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: red,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: txtSub,
          side: BorderSide(color: border),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? dkElevated : ltElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: red, width: 1.5),
        ),
        hintStyle: TextStyle(color: dark ? dkTextMuted : ltTextMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? Colors.white : (dark ? dkTextSub : ltTextMuted),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? red : (dark ? dkElevated : ltElevated),
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? red : border,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: red),
      textTheme: TextTheme(
        displayLarge:  TextStyle(color: txt, fontWeight: FontWeight.w800),
        headlineLarge: TextStyle(color: txt, fontWeight: FontWeight.w700, fontSize: 26),
        headlineMedium:TextStyle(color: txt, fontWeight: FontWeight.w700, fontSize: 22),
        titleLarge:    TextStyle(color: txt, fontWeight: FontWeight.w600, fontSize: 17),
        titleMedium:   TextStyle(color: txt, fontWeight: FontWeight.w600, fontSize: 15),
        bodyLarge:     TextStyle(color: txt, fontSize: 16, height: 1.7),
        bodyMedium:    TextStyle(color: txtSub, fontSize: 14, height: 1.6),
        bodySmall:     TextStyle(color: dark ? dkTextMuted : ltTextMuted, fontSize: 12),
        labelLarge:    TextStyle(color: txt, fontWeight: FontWeight.w600, fontSize: 14),
        labelSmall:    TextStyle(color: dark ? dkTextMuted : ltTextMuted, fontSize: 11),
      ),
    );
  }
}
