import 'traffic_sign.dart';

class TrafficSignCategory {
  final String key;
  final String name;
  final List<TrafficSign> signs;

  const TrafficSignCategory({
    required this.key,
    required this.name,
    required this.signs,
  });

  factory TrafficSignCategory.fromJson(Map<String, dynamic> json, String key) {
    final name = json['name'] as String? ?? key;
    final signsList = json['signs'] as List? ?? [];
    final signs = signsList.map((e) => TrafficSign.fromJson(e, categoryKey: key, categoryName: name)).toList();
    
    return TrafficSignCategory(
      key: key,
      name: name,
      signs: signs,
    );
  }
} 