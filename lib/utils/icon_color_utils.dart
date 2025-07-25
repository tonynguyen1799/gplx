import 'package:flutter/material.dart';

IconData iconFromString(String? iconName) {
  switch (iconName) {
    case 'warning_amber_rounded':
      return Icons.warning_amber_rounded;
    case 'rule_rounded':
      return Icons.rule_rounded;
    case 'emoji_people_rounded':
      return Icons.emoji_people_rounded;
    case 'directions_car_filled_rounded':
      return Icons.directions_car_filled_rounded;
    case 'traffic_rounded':
      return Icons.traffic_rounded;
    case 'map_rounded':
      return Icons.map_rounded;
    case 'psychology_rounded':
      return Icons.psychology_rounded;
    case 'sports_motorsports_rounded':
      return Icons.sports_motorsports_rounded;
    case 'construction_rounded':
      return Icons.construction_rounded;
    case 'signpost_rounded':
      return Icons.signpost_rounded;
    default:
      return Icons.book;
  }
}

Color colorFromHex(String? hex) {
  if (hex == null || hex.isEmpty) return Colors.blue;
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
} 