import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const cream = Color(0xFFF7F3EA);
  static const creamSoft = Color(0xFFEEE8D8);
  static const ink = Color(0xFF1A1A1A);
  static const inkSoft = Color(0xFF4A473F);
  static const accent = Color(0xFFF5C842);
  static const sage = Color(0xFF8FA88A);
  static const sageSoft = Color(0xFFE7EDE5);
  static const coral = Color(0xFFD98C7B);
  static const coralSoft = Color(0xFFF6E6E2);
  static const dustyBlue = Color(0xFF7B96AD);
  static const dustyBlueSoft = Color(0xFFE6ECF1);
}

ThemeData buildAppTheme() {
  final headingFont = GoogleFonts.plusJakartaSansTextTheme();
  final bodyFont = GoogleFonts.interTextTheme();

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.ink,
      secondary: AppColors.accent,
      surface: Colors.white,
    ),
    textTheme: bodyFont.copyWith(
      headlineLarge: headingFont.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      headlineMedium: headingFont.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleLarge: headingFont.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleMedium: headingFont.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cream,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.ink,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
