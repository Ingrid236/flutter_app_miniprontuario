import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/shared_preferences_provider.dart';

class SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  static const String _themeKey = 'theme_mode';

  ThemeMode getThemeMode() {
    final themeStr = _prefs.getString(_themeKey);
    if (themeStr == 'light') return ThemeMode.light;
    if (themeStr == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.name);
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepository(prefs);
});
