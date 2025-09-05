import 'package:flutter/material.dart';

class ThemeSettings {
  final ThemeMode mode;

  const ThemeSettings({
    this.mode = ThemeMode.system,
  });

  factory ThemeSettings.from(String mode) {
    final themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == mode,
      orElse: () => ThemeMode.system,
    );
    return ThemeSettings(mode: themeMode);
  }

  String toStringValue() => mode.name;
}
