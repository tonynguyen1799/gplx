import 'package:hive/hive.dart';

part 'quiz_practice_status.g.dart';

@HiveType(typeId: 2)
class QuizPracticeStatus {
  @HiveField(0)
  final bool practiced;
  @HiveField(1)
  final bool correct;
  @HiveField(2)
  final bool saved;
  @HiveField(3)
  final int? selectedIndex;

  QuizPracticeStatus({
    required this.practiced,
    required this.correct,
    required this.saved,
    this.selectedIndex,
  });

  QuizPracticeStatus copyWith({
    bool? practiced,
    bool? correct,
    bool? saved,
    int? selectedIndex,
  }) {
    return QuizPracticeStatus(
      practiced: practiced ?? this.practiced,
      correct: correct ?? this.correct,
      saved: saved ?? this.saved,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
} 