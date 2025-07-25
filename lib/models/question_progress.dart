class QuestionProgress {
  final int practiced;
  final int correct;
  final int incorrect;
  final List<String> savedQuizIds;

  const QuestionProgress({
    required this.practiced,
    required this.correct,
    required this.incorrect,
    required this.savedQuizIds,
  });

  static QuestionProgress empty() => const QuestionProgress(
    practiced: 0,
    correct: 0,
    incorrect: 0,
    savedQuizIds: [],
  );
} 