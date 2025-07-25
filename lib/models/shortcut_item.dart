import 'package:flutter/material.dart';

class ShortcutItem {
  final String title;
  final IconData icon;
  final int? count;
  final Color color;
  final VoidCallback onTap;

  const ShortcutItem({
    required this.title,
    required this.icon,
    this.count,
    required this.color,
    required this.onTap,
  });
}
