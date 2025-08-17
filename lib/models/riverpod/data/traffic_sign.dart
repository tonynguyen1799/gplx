class TrafficSign {
  final String id;
  final String name;
  final String shortDescription;
  final String description;
  final String image;
  final String categoryKey;
  final String categoryName;

  TrafficSign({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.image,
    required this.categoryKey,
    required this.categoryName,
  });

  factory TrafficSign.fromJson(Map<String, dynamic> json, {String? categoryKey, String? categoryName}) => TrafficSign(
    id: json['code'] as String,
    name: json['name'] as String,
    shortDescription: json['shortDescription'] as String,
    description: json['description'] as String,
    image: json['filename'] as String,
    categoryKey: categoryKey ?? '',
    categoryName: categoryName ?? categoryKey ?? '',
  );
} 