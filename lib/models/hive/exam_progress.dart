import 'package:hive/hive.dart';

part 'exam_progress.g.dart';

@HiveType(typeId: 3)
class ExamProgress {
  @HiveField(0)
  final String examId;
  @HiveField(1)
  final String licenseTypeCode;
  @HiveField(2)
  final bool isPassed;
  @HiveField(3)
  final int totalCorrectQuizzes;
  @HiveField(4)
  final int totalIncorrectQuizzes;
  @HiveField(5)
  final DateTime completedAt;

  ExamProgress({
    required this.examId,
    required this.licenseTypeCode,
    required this.isPassed,
    required this.totalCorrectQuizzes,
    required this.totalIncorrectQuizzes,
    required this.completedAt,
  });
} 