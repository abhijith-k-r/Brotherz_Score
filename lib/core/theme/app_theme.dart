import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.tertiary,
        surface: AppColors.background100,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.oswald(
          fontWeight: FontWeight.bold,
          color: AppColors.neutral,
        ),
        displayMedium: GoogleFonts.oswald(
          fontWeight: FontWeight.bold,
          color: AppColors.neutral,
        ),
        displaySmall: GoogleFonts.oswald(
          fontWeight: FontWeight.bold,
          color: AppColors.neutral,
        ),
        headlineLarge: GoogleFonts.oswald(
          fontWeight: FontWeight.bold,
          color: AppColors.neutral,
        ),
        headlineMedium: GoogleFonts.oswald(
          fontWeight: FontWeight.bold,
          color: AppColors.neutral,
        ),
        headlineSmall: GoogleFonts.oswald(
          fontWeight: FontWeight.bold,
          color: AppColors.neutral,
        ),
        titleLarge: GoogleFonts.oswald(
          fontWeight: FontWeight.bold,
          color: AppColors.neutral,
        ),
        titleMedium: GoogleFonts.oswald(
          fontWeight: FontWeight.w600,
          color: AppColors.neutral,
        ),
        titleSmall: GoogleFonts.oswald(
          fontWeight: FontWeight.w500,
          color: AppColors.neutral,
        ),
        bodyLarge: GoogleFonts.inter(
          fontWeight: FontWeight.normal,
          color: AppColors.neutral100,
        ),
        bodyMedium: GoogleFonts.inter(
          fontWeight: FontWeight.normal,
          color: AppColors.neutral100,
        ),
        bodySmall: GoogleFonts.inter(
          fontWeight: FontWeight.normal,
          color: AppColors.neutral400,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          color: AppColors.neutral,
        ),
        labelSmall: GoogleFonts.inter(
          fontWeight: FontWeight.normal,
          color: AppColors.neutral400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.background,
          textStyle: GoogleFonts.oswald(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 18,
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background100,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.background300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.background300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral400,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
