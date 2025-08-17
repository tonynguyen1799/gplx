class QuizzesProgress {
  final int totalPracticedQuizzes;
  final int totalCorrectQuizzes;
  final int totalIncorrectQuizzes;
  final int totalSavedQuizzes;

  const QuizzesProgress({
    required this.totalPracticedQuizzes,
    required this.totalCorrectQuizzes,
    required this.totalIncorrectQuizzes,
    required this.totalSavedQuizzes,
  });

  static QuizzesProgress empty() => const QuizzesProgress(
    totalPracticedQuizzes: 0,
    totalCorrectQuizzes: 0,
    totalIncorrectQuizzes: 0,
    totalSavedQuizzes: 0,
  );
} 