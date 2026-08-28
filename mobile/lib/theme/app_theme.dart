import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_palette.dart';

/// Plus Jakarta Sans for headings, Inter for body — same pairing as the web.
TextStyle heading({
  required double size,
  FontWeight weight = FontWeight.w700,
  Color? color,
  double? height,
  double letterSpacing = -0.4,
}) {
  return GoogleFonts.plusJakartaSans(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final palette = isDark ? AppPalette.dark : AppPalette.light;

  final base = GoogleFonts.interTextTheme(
    isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
  ).apply(bodyColor: palette.ink, displayColor: palette.ink);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    extensions: [palette],
    // The gradient backdrop paints behind every screen, so scaffolds
    // themselves stay transparent.
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: palette.surface,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: palette.ink,
      onPrimary: palette.cream,
      secondary: palette.accent,
      onSecondary: palette.inkFixed,
      error: palette.coral,
      onError: palette.inkFixed,
      surface: palette.surface,
      onSurface: palette.ink,
    ),
    textTheme: base.copyWith(
      headlineLarge: heading(size: 34, color: palette.ink),
      headlineMedium: heading(size: 28, color: palette.ink),
      titleLarge: heading(size: 20, color: palette.ink),
      titleMedium: heading(size: 15, weight: FontWeight.w600, color: palette.ink),
      titleSmall: heading(size: 13, weight: FontWeight.w600, color: palette.ink),
    ),
    cardTheme: CardThemeData(
      color: palette.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: palette.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    dividerTheme: DividerThemeData(color: palette.creamSoft, thickness: 1, space: 1),
    iconTheme: IconThemeData(color: palette.inkSoft),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: palette.accent),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surface,
      hintStyle: TextStyle(color: palette.inkSoft.withValues(alpha: 0.6), fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: palette.creamSoft),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: palette.creamSoft),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(color: palette.accent, width: 2),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: palette.ink,
      contentTextStyle: TextStyle(color: palette.cream),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );
}
