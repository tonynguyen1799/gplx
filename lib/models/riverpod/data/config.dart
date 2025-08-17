class ExamConfig {
  final int durationInMinutes;
  final int totalOfQuizzes;
  final int totalRequiredCorrectQuizzes;

  const ExamConfig({
    required this.durationInMinutes,
    required this.totalOfQuizzes,
    required this.totalRequiredCorrectQuizzes,
  });

  factory ExamConfig.fromJson(Map<String, dynamic> json) {
    return ExamConfig(
      durationInMinutes: json['durationInMinutes'] ?? json['durationInMunites'] ?? 20,
      totalOfQuizzes: json['totalOfQuizzes'] ?? 25,
      totalRequiredCorrectQuizzes: json['totalRequiredCorrectQuizzes'] ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'durationInMinutes': durationInMinutes,
      'totalOfQuizzes': totalOfQuizzes,
      'totalRequiredCorrectQuizzes': totalRequiredCorrectQuizzes,
    };
  }
}

class Config {
  final ExamConfig exam;

  const Config({required this.exam});

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      exam: ExamConfig.fromJson(json['exam'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exam': exam.toJson(),
    };
  }
} 