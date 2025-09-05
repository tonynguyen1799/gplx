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

IconData getLicenseTypeIcon(String code) {
  switch (code) {
    case 'A1':
      return Icons.two_wheeler;
    case 'A2':
      return Icons.motorcycle;
    case 'B1':
      return Icons.directions_car;
    case 'B2':
      return Icons.directions_car_filled;
    case 'C':
      return Icons.local_shipping;
    case 'D':
      return Icons.directions_bus;
    case 'E':
      return Icons.airport_shuttle;
    case 'F':
      return Icons.emoji_transportation;
    default:
      return Icons.drive_eta;
  }
}

Color getLicenseTypeColor(String code) {
  switch (code) {
    case 'A1':
      return Colors.orange;
    case 'A2':
      return Colors.deepOrange;
    case 'B1':
      return Colors.blue;
    case 'B2':
      return Colors.indigo;
    case 'C':
      return Colors.green;
    case 'D':
      return Colors.teal;
    case 'E':
      return Colors.purple;
    case 'F':
      return Colors.brown;
    default:
      return Colors.grey;
  }
} 