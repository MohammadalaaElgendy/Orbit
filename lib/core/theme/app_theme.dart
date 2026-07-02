import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import 'app_colors.dart';

enum ThemePreset {
  classic,
  alexandria,
  forest,
  sunset,
  sunrise,
  lavender,
}

class AppTheme {
  static ThemeData getTheme(ThemePreset preset, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    ColorScheme colorScheme;
    Color scaffoldBg;

    switch (preset) {
      case ThemePreset.alexandria:
        colorScheme = isDark ? ColorScheme.dark(
          primary: AppColors.alexandriaPrimaryDark,
          onPrimary: const Color(0xFF003354),
          primaryContainer: AppColors.alexandriaPrimaryLight,
          onPrimaryContainer: Colors.white,
          surface: AppColors.alexandriaSurfaceDark,
          onSurface: AppColors.alexandriaOnSurfaceDark,
        ) : ColorScheme.light(
          primary: AppColors.alexandriaPrimaryLight,
          onPrimary: Colors.white,
          primaryContainer: AppColors.alexandriaPrimaryContainerLight,
          onPrimaryContainer: AppColors.alexandriaPrimaryLight,
          secondary: const Color(0xFFEDC9AF),
          surface: AppColors.alexandriaSurfaceLight,
          onSurface: AppColors.alexandriaOnSurfaceLight,
        );
        scaffoldBg = isDark ? AppColors.alexandriaBackgroundDark : AppColors.alexandriaBackgroundLight;
        break;

      case ThemePreset.forest:
        colorScheme = isDark ? ColorScheme.dark(
          primary: AppColors.forestPrimaryDark,
          onPrimary: const Color(0xFF00390A),
          primaryContainer: AppColors.forestPrimaryLight,
          onPrimaryContainer: Colors.white,
          surface: AppColors.forestSurfaceDark,
          onSurface: AppColors.forestOnSurfaceDark,
        ) : ColorScheme.light(
          primary: AppColors.forestPrimaryLight,
          onPrimary: Colors.white,
          primaryContainer: AppColors.forestPrimaryContainerLight,
          onPrimaryContainer: AppColors.forestPrimaryLight,
          secondary: const Color(0xFF8B4513),
          surface: AppColors.forestSurfaceLight,
          onSurface: AppColors.forestOnSurfaceLight,
        );
        scaffoldBg = isDark ? AppColors.forestBackgroundDark : AppColors.forestBackgroundLight;
        break;

      case ThemePreset.sunset:
        colorScheme = isDark ? ColorScheme.dark(
          primary: AppColors.sunsetPrimaryDark,
          onPrimary: const Color(0xFF690005),
          primaryContainer: AppColors.sunsetPrimaryLight,
          onPrimaryContainer: Colors.white,
          surface: AppColors.sunsetSurfaceDark,
          onSurface: AppColors.sunsetOnSurfaceDark,
        ) : ColorScheme.light(
          primary: AppColors.sunsetPrimaryLight,
          onPrimary: Colors.white,
          primaryContainer: AppColors.sunsetPrimaryContainerLight,
          onPrimaryContainer: AppColors.sunsetPrimaryLight,
          secondary: const Color(0xFFFC913A),
          surface: AppColors.sunsetSurfaceLight,
          onSurface: AppColors.sunsetOnSurfaceLight,
        );
        scaffoldBg = isDark ? AppColors.sunsetBackgroundDark : AppColors.sunsetBackgroundLight;
        break;

      case ThemePreset.sunrise:
        colorScheme = isDark ? ColorScheme.dark(
          primary: AppColors.sunrisePrimaryDark,
          onPrimary: const Color(0xFF451E1E),
          primaryContainer: AppColors.sunrisePrimaryLight,
          onPrimaryContainer: Colors.white,
          surface: AppColors.sunriseSurfaceDark,
          onSurface: AppColors.sunriseOnSurfaceDark,
        ) : ColorScheme.light(
          primary: AppColors.sunrisePrimaryLight,
          onPrimary: Colors.white,
          primaryContainer: AppColors.sunrisePrimaryContainerLight,
          onPrimaryContainer: AppColors.sunrisePrimaryLight,
          secondary: const Color(0xFF16A085),
          surface: AppColors.sunriseSurfaceLight,
          onSurface: AppColors.sunriseOnSurfaceLight,
        );
        scaffoldBg = isDark ? AppColors.sunriseBackgroundDark : AppColors.sunriseBackgroundLight;
        break;

      case ThemePreset.lavender:
        colorScheme = isDark ? ColorScheme.dark(
          primary: AppColors.lavenderPrimaryDark,
          onPrimary: const Color(0xFF2D0A4E),
          primaryContainer: AppColors.lavenderPrimaryLight,
          onPrimaryContainer: Colors.white,
          surface: AppColors.lavenderSurfaceDark,
          onSurface: AppColors.lavenderOnSurfaceDark,
        ) : ColorScheme.light(
          primary: AppColors.lavenderPrimaryLight,
          onPrimary: Colors.white,
          primaryContainer: AppColors.lavenderPrimaryContainerLight,
          onPrimaryContainer: AppColors.lavenderPrimaryLight,
          secondary: const Color(0xFF636E72),
          surface: AppColors.lavenderSurfaceLight,
          onSurface: AppColors.lavenderOnSurfaceLight,
        );
        scaffoldBg = isDark ? AppColors.lavenderBackgroundDark : AppColors.lavenderBackgroundLight;
        break;

      case ThemePreset.classic:
        colorScheme = isDark ? const ColorScheme.dark(
          primary: AppColors.primaryDark,
          onPrimary: Color(0xFF131E8C),
          primaryContainer: AppColors.primaryLight,
          onPrimaryContainer: Colors.white,
          surface: AppColors.surfaceDark,
          onSurface: AppColors.onSurfaceDark,
          onSurfaceVariant: AppColors.onSurfaceVariantDark,
          outline: AppColors.outlineDark,
          outlineVariant: AppColors.outlineVariantDark,
        ) : const ColorScheme.light(
          primary: AppColors.primaryLight,
          onPrimary: AppColors.onPrimaryLight,
          primaryContainer: AppColors.primaryContainerLight,
          onPrimaryContainer: AppColors.primaryLight,
          surface: AppColors.surfaceLight,
          onSurface: AppColors.onSurfaceLight,
          onSurfaceVariant: AppColors.onSurfaceVariantLight,
          outline: AppColors.outlineLight,
          outlineVariant: AppColors.outlineVariantLight,
        );
        scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
        break;
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
      ),
      textTheme: _textTheme(brightness),
      filledButtonTheme: _filledButtonTheme(brightness),
      inputDecorationTheme: _inputDecorationTheme(brightness),
    );
  }

  static ThemeData get light => getTheme(ThemePreset.classic, Brightness.light);
  static ThemeData get dark => getTheme(ThemePreset.classic, Brightness.dark);

  static TextTheme _textTheme(Brightness brightness) {
    final color = brightness == Brightness.light 
        ? AppColors.onSurfaceLight 
        : AppColors.onSurfaceDark;
    
    return TextTheme(
      displayLarge: TextStyle(fontFamily: 'Manrope', fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: -0.02, color: color),
      headlineLarge: TextStyle(fontFamily: 'Manrope', fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.02, color: color),
      headlineMedium: TextStyle(fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.01, color: color),
      headlineSmall: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.01, color: color),
      bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w400, color: color),
      bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400, color: color),
      labelLarge: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: color),
      labelSmall: TextStyle(
        fontFamily: 'Inter', 
        fontSize: 12, 
        fontWeight: FontWeight.w500, 
        letterSpacing: 0.02, 
        color: brightness == Brightness.light ? AppColors.onSurfaceVariantLight : AppColors.onSurfaceVariantDark,
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme(Brightness brightness) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
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
        borderSide: BorderSide(color: isLight ? AppColors.outlineVariantLight : AppColors.outlineVariantDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: isLight ? AppColors.outlineVariantLight : AppColors.outlineVariantDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        borderSide: BorderSide(color: isLight ? AppColors.primaryLight : AppColors.primaryContainerDark, width: 2),
      ),
      hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14, color: isLight ? AppColors.outlineLight : AppColors.outlineDark),
    );
  }
}
