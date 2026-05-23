import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class SettingsService {
  static const String _themeModeKey = 'theme_mode';
  static const String _themePresetKey = 'theme_preset';
  static const String _localeKey = 'locale';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  ThemeMode getThemeMode() {
    final mode = _prefs.getString(_themeModeKey);
    if (mode == 'light') return ThemeMode.light;
    if (mode == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.name);
  }

  ThemePreset getThemePreset() {
    final presetName = _prefs.getString(_themePresetKey);
    return ThemePreset.values.firstWhere(
      (e) => e.name == presetName,
      orElse: () => ThemePreset.classic,
    );
  }

  Future<void> setThemePreset(ThemePreset preset) async {
    await _prefs.setString(_themePresetKey, preset.name);
  }

  Locale? getLocale() {
    final localeCode = _prefs.getString(_localeKey);
    if (localeCode == null) return null;
    return Locale(localeCode);
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(_localeKey);
    } else {
      await _prefs.setString(_localeKey, locale.languageCode);
    }
  }
}
