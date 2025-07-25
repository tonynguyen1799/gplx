class LicenseType {
  final String code;
  final String name;
  final String description;
  final bool isDefault;

  LicenseType({
    required this.code,
    required this.name,
    required this.description,
    this.isDefault = false,
  });

  factory LicenseType.fromJson(Map<String, dynamic> json) => LicenseType(
        code: json['code'],
        name: json['name'],
        description: json['description'],
        isDefault: json['isDefault'] == true,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'description': description,
        'isDefault': isDefault,
      };
}
