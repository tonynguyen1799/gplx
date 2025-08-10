import 'package:hive/hive.dart';

part 'quiz_progress.g.dart';

@HiveType(typeId: 2)
class QuizProgress {
  @HiveField(0)
  final bool isPracticed;
  @HiveField(1)
  final bool isCorrect;
  @HiveField(2)
  final bool isSaved;
  @HiveField(3)
  final int? selectedIdx;

  QuizProgress({
    required this.isPracticed,
    required this.isCorrect,
    required this.isSaved,
    this.selectedIdx,
  });
} 