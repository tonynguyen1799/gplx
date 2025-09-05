import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme_settings.dart';
import '../services/hive_service.dart' as hive;

class ThemeModeNotifier extends StateNotifier<AsyncValue<ThemeSettings>> {
  ThemeModeNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final mode = await hive.getThemeMode();
      state = AsyncValue.data(ThemeSettings.from(mode));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncValue.data(ThemeSettings(mode: mode));
    await hive.setThemeMode(mode.name);
  }

  Future<void> refresh() => _load();
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, AsyncValue<ThemeSettings>>((ref) {
  return ThemeModeNotifier();
});
