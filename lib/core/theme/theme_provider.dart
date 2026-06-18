import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/data/settings_repository.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final repository = ref.watch(settingsRepositoryProvider);
    return repository.getThemeMode();
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    final repository = ref.read(settingsRepositoryProvider);
    repository.setThemeMode(mode);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
