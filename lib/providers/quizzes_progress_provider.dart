import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hive/quiz_progress.dart';
import '../services/hive_service.dart';
import 'package:gplx_vn/models/riverpod/quizzes_progress.dart';
import 'app_data_providers.dart';
import '../models/quiz.dart';
import '../models/topic.dart';
import 'package:gplx_vn/models/riverpod/topic_progress.dart';

class QuizzesProgressNotifier extends StateNotifier<Map<String, Map<String, QuizProgress>>> {
  QuizzesProgressNotifier() : super({});

  Future<void> loadQuizzesProgress(List<String> licenseTypeCodes) async {
    final Map<String, Map<String, QuizProgress>> licenseTypeToQuizProgresses = {};
    for (final licenseTypeCode in licenseTypeCodes) {
      licenseTypeToQuizProgresses[licenseTypeCode] = await loadQuizStatus(licenseTypeCode);
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
    await saveQuizStatus(licenseTypeCode, licenseTypeToQuizProgresses);
  }
}

final quizzesProgressProvider = StateNotifierProvider<QuizzesProgressNotifier, Map<String, Map<String, QuizProgress>>>(
  (ref) => QuizzesProgressNotifier(),
);

final totalQuizzesProgressProvider = Provider.family<QuizzesProgress, String>((ref, licenseTypeCode) {
  final Map<String, QuizProgress> quizIdToQuizProgresses = ref.watch(quizzesProgressProvider)[licenseTypeCode] ?? {};
  int totalPracticedQuizzes = 0, totalCorrectQuizzes = 0, totalIncorrectQuizzes = 0;
  List<String> savedQuizIdsForLicense = [];
  quizIdToQuizProgresses.forEach((quizId, quizProgress) {
    if (quizProgress.isPracticed) {
      totalPracticedQuizzes++;
      if (quizProgress.isCorrect) {
        totalCorrectQuizzes++;
      } else {
        totalIncorrectQuizzes++;
      }
    }
    if (quizProgress.isSaved) {
      savedQuizIdsForLicense.add(quizId);
    }
  });
  return QuizzesProgress(
    totalPracticedQuizzes: totalPracticedQuizzes,
    totalCorrectQuizzes: totalCorrectQuizzes,
    totalIncorrectQuizzes: totalIncorrectQuizzes,
    savedQuizIds: savedQuizIdsForLicense,
  );
});

final topicQuizzessProgressProvider = Provider.family<Map<String, TopicProgress>, String>((ref, licenseTypeCode) {
  final Map<String, QuizProgress> quizIdToQuizProgresses = ref.watch(quizzesProgressProvider)[licenseTypeCode] ?? {};
  final Map<String, List<Quiz>> licenseTypeToQuizzes = ref.watch(quizzesProvider);
  final Map<String, List<Topic>> licenseTypeToTopics = ref.watch(topicsProvider);
  final List<Quiz> quizzesForLicenseType = licenseTypeToQuizzes[licenseTypeCode] ?? [];
  final List<Topic> topicsForLicenseType = licenseTypeToTopics[licenseTypeCode] ?? [];

  final Map<String, TopicProgress> topicIdToTopicProgress = {
    for (final topic in topicsForLicenseType) topic.id: TopicProgress(),
  };

  for (final quiz in quizzesForLicenseType) {
    final QuizProgress? quizProgress = quizIdToQuizProgresses[quiz.id];
    for (final topicId in quiz.topicIds) {
      final TopicProgress? topicProgressEntry = topicIdToTopicProgress[topicId];
      if (topicProgressEntry == null) continue;
      topicProgressEntry.totalQuizzes++;
      if (quizProgress != null && quizProgress.isPracticed) {
        topicProgressEntry.totalPracticedQuizzes++;
        if (quizProgress.isCorrect) {
          topicProgressEntry.totalCorrectQuizzes++;
        } else {
          topicProgressEntry.totalIncorrectQuizzes++;
        }
      }
    }
  }
  return topicIdToTopicProgress;
});

 