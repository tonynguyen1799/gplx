import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gplx_vn/models/hive/quiz_progress.dart';
import 'package:gplx_vn/models/riverpod/quizzes_progress.dart';
import 'package:gplx_vn/models/riverpod/topic_progress.dart';
import 'package:gplx_vn/services/hive_service.dart' as hive;

import 'app_data_providers.dart';

class QuizzesProgressNotifier extends StateNotifier<Map<String, Map<String, QuizProgress>>> {
  QuizzesProgressNotifier() : super({});

  Future<void> loadQuizzesProgress(List<String> licenseTypeCodes) async {
    final Map<String, Map<String, QuizProgress>> licenseTypeToQuizProgresses = {};
    for (final licenseTypeCode in licenseTypeCodes) {
      licenseTypeToQuizProgresses[licenseTypeCode] = await hive.loadQuizzesProgress(licenseTypeCode);
    }
    state = licenseTypeToQuizProgresses;
  }

  Future<void> updateQuizProgress(String licenseTypeCode, String quizId, QuizProgress quizProgress) async {
    final Map<String, QuizProgress> licenseTypeToQuizProgresses =
        Map<String, QuizProgress>.from(state[licenseTypeCode] ?? {});
    licenseTypeToQuizProgresses[quizId] = quizProgress;
    state = {
      ...state,
      licenseTypeCode: licenseTypeToQuizProgresses,
    };
    await hive.saveQuizzesProgress(licenseTypeCode, licenseTypeToQuizProgresses);
  }
}

final quizzesProgressProvider = StateNotifierProvider<QuizzesProgressNotifier, Map<String, Map<String, QuizProgress>>>(
  (ref) => QuizzesProgressNotifier(),
);

final totalQuizzesProgressProvider = Provider.family<QuizzesProgress, String>((ref, licenseTypeCode) {
  final Map<String, QuizProgress> quizIdToQuizProgresses = ref.watch(quizzesProgressProvider)[licenseTypeCode] ?? {};
  final asyncQuizzes = ref.watch(quizzesProvider);
  
  if (asyncQuizzes.isLoading) return QuizzesProgress.empty();
  if (asyncQuizzes.hasError) return QuizzesProgress.empty();
  
  final quizzes = asyncQuizzes.value ?? [];
  int totalPracticedQuizzes = 0, totalCorrectQuizzes = 0, totalIncorrectQuizzes = 0, totalSavedQuizzes = 0;
  
  for (final quiz in quizzes) {
    final QuizProgress? quizProgress = quizIdToQuizProgresses[quiz.id];
    if (quizProgress != null && quizProgress.isPracticed) {
      totalPracticedQuizzes++;
      if (quizProgress.isCorrect) {
        totalCorrectQuizzes++;
      } else {
        totalIncorrectQuizzes++;
      }
    }
    if (quizProgress != null && quizProgress.isSaved) {
      totalSavedQuizzes++;
    }
  }
  
  return QuizzesProgress(
    totalPracticedQuizzes: totalPracticedQuizzes,
    totalCorrectQuizzes: totalCorrectQuizzes,
    totalIncorrectQuizzes: totalIncorrectQuizzes,
    totalSavedQuizzes: totalSavedQuizzes,
  );
});

final topicQuizzesProgressProvider = Provider.family<Map<String, TopicProgress>, String>((ref, licenseTypeCode) {
  final Map<String, QuizProgress> quizIdToQuizProgresses = ref.watch(quizzesProgressProvider)[licenseTypeCode] ?? {};
  final asyncQuizzes = ref.watch(quizzesProvider);
  final asyncTopics = ref.watch(topicsProvider);
  
  if (asyncQuizzes.isLoading || asyncTopics.isLoading) return <String, TopicProgress>{};
  if (asyncQuizzes.hasError || asyncTopics.hasError) return <String, TopicProgress>{};
  
  final quizzes = asyncQuizzes.value ?? [];
  final topics = asyncTopics.value ?? [];

  final Map<String, TopicProgress> topicIdToTopicProgress = <String, TopicProgress>{
    for (final topic in topics) topic.id: TopicProgress(),
  };

  for (final quiz in quizzes) {
    final QuizProgress? quizProgress = quizIdToQuizProgresses[quiz.id];
    for (final topicId in quiz.topicIds) {
      final TopicProgress? topicProgress = topicIdToTopicProgress[topicId];
      if (topicProgress == null) continue;
      topicProgress.totalQuizzes++;
      if (quizProgress != null && quizProgress.isPracticed) {
        topicProgress.totalPracticedQuizzes++;
        if (quizProgress.isCorrect) {
          topicProgress.totalCorrectQuizzes++;
        } else {
          topicProgress.totalIncorrectQuizzes++;
        }
      }
    }
  }
  return topicIdToTopicProgress;
});

