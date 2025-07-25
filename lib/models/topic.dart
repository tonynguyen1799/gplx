class Topic {
  final String id;
  final String name;
  final String description;
  final String? icon; // Icon name as string, e.g. 'warning_amber_rounded'
  final String? color; // Color hex as string, e.g. '#FF5252'

  Topic({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    this.color,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        icon: json['icon'],
        color: json['color'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
      };
} 