class QuizzesProgress {
  final int totalPracticedQuizzes;
  final int totalCorrectQuizzes;
  final int totalIncorrectQuizzes;
  final List<String> savedQuizIds;

  const QuizzesProgress({
    required this.totalPracticedQuizzes,
    required this.totalCorrectQuizzes,
    required this.totalIncorrectQuizzes,
    required this.savedQuizIds,
  });

  static QuizzesProgress empty() => const QuizzesProgress(
    totalPracticedQuizzes: 0,
    totalCorrectQuizzes: 0,
    totalIncorrectQuizzes: 0,
    savedQuizIds: [],
  );
} 