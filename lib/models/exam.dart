class Exam {
  final String id;
  final String name;
  final List<String> quizIds;

  Exam({
    required this.id,
    required this.name,
    required this.quizIds,
  });

  factory Exam.fromJson(Map<String, dynamic> json) => Exam(
        id: json['id'],
        name: json['name'],
        quizIds: List<String>.from(json['quizIds']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quizIds': quizIds,
      };
} 