import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.onPrimaryLight,
        primaryContainer: AppColors.primaryContainerLight,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.onSecondaryLight,
        secondaryContainer: AppColors.secondaryContainerLight,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.onSurfaceLight,
        onSurfaceVariant: AppColors.onSurfaceVariantLight,
        outline: AppColors.outlineLight,
        outlineVariant: AppColors.outlineVariantLight,
        error: AppColors.error,
        onError: AppColors.onError,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _textTheme(Brightness.light),
      filledButtonTheme: _filledButtonTheme(Brightness.light),
      inputDecorationTheme: _inputDecorationTheme(Brightness.light),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.onPrimaryDark,
        primaryContainer: AppColors.primaryContainerDark,
        secondary: AppColors.secondaryDark,
        onSecondary: AppColors.onSecondaryDark,
        secondaryContainer: AppColors.secondaryContainerDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.onSurfaceDark,
        onSurfaceVariant: AppColors.onSurfaceVariantDark,
        outline: AppColors.outlineDark,
        outlineVariant: AppColors.outlineVariantDark,
        error: AppColors.error,
        onError: AppColors.onError,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _textTheme(Brightness.dark),
      filledButtonTheme: _filledButtonTheme(Brightness.dark),
      inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
    );
  }

  static TextTheme _textTheme(Brightness brightness) {
    final color = brightness == Brightness.light 
        ? AppColors.onSurfaceLight 
        : AppColors.onSurfaceDark;
    
    return TextTheme(
      displayLarge: GoogleFonts.manrope(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02,
        color: color,
      ),
      headlineLarge: GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
        color: color,
      ),
      headlineMedium: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01,
        color: color,
      ),
      headlineSmall: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01,
        color: color,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.02,
        color: brightness == Brightness.light 
            ? AppColors.onSurfaceVariantLight 
            : AppColors.onSurfaceVariantDark,
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(Brightness brightness) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    return InputDecorationTheme(
      filled: true,
      fillColor: isLight ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.2),
      contentPadding: const EdgeInsets.all(AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(
          color: isLight ? AppColors.outlineVariantLight : AppColors.outlineVariantDark,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(
          color: isLight ? AppColors.outlineVariantLight : AppColors.outlineVariantDark,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(
          color: isLight ? AppColors.primaryLight : AppColors.primaryContainerDark,
          width: 2,
        ),
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
      ),
    );
  }
}
