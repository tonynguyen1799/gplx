import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz_practice_status.dart';
import '../services/hive_service.dart';
import '../models/question_progress.dart';
import 'app_data_providers.dart';
import '../models/quiz.dart';
import '../models/topic.dart';

class QuizStatusNotifier extends StateNotifier<Map<String, Map<String, QuizPracticeStatus>>> {
  QuizStatusNotifier() : super({});

  // Load all statuses for all license types at startup
  Future<void> loadAllStatuses(List<String> licenseTypeCodes) async {
    final Map<String, Map<String, QuizPracticeStatus>> allStatuses = {};
    for (final code in licenseTypeCodes) {
      allStatuses[code] = await loadQuizStatus(code);
    }
    state = allStatuses;
  }

  // Get status for a license type
  Map<String, QuizPracticeStatus> getStatus(String licenseTypeCode) {
    return state[licenseTypeCode] ?? {};
  }

  // Update status for a quiz and sync to Hive
  Future<void> updateStatus(String licenseTypeCode, String quizId, QuizPracticeStatus status) async {
    final current = Map<String, QuizPracticeStatus>.from(getStatus(licenseTypeCode));
    current[quizId] = status;
    state = {
      ...state,
      licenseTypeCode: current,
    };
    await saveQuizStatus(licenseTypeCode, current);
  }
}

final quizStatusProvider = StateNotifierProvider<QuizStatusNotifier, Map<String, Map<String, QuizPracticeStatus>>>(
  (ref) => QuizStatusNotifier(),
);

final progressProvider = Provider.family<QuestionProgress, String>((ref, licenseTypeCode) {
  final statusMap = ref.watch(quizStatusProvider)[licenseTypeCode] ?? {};
  int practiced = 0, correct = 0, incorrect = 0;
  List<String> savedQuizIds = [];
  statusMap.forEach((quizId, status) {
    if (status.practiced) {
      practiced++;
      if (status.correct) {
        correct++;
      } else {
        incorrect++;
      }
    }
    if (status.saved) {
      savedQuizIds.add(quizId);
    }
  });
  return QuestionProgress(
    practiced: practiced,
    correct: correct,
    incorrect: incorrect,
    savedQuizIds: savedQuizIds,
  );
});

/// Aggregates per-quiz statuses into per-topic progress for a given licenseTypeCode.
final perTopicProgressProvider = Provider.family<Map<String, TopicProgress>, String>((ref, licenseTypeCode) {
  final statusMap = ref.watch(quizStatusProvider)[licenseTypeCode] ?? {};
  final quizzesMap = ref.watch(quizzesProvider);
  final topicsMap = ref.watch(topicsProvider);
  final quizzes = quizzesMap[licenseTypeCode] ?? [];
  final topics = topicsMap[licenseTypeCode] ?? [];

  // Map of topicId -> TopicProgress
  final Map<String, TopicProgress> topicProgressMap = {
    for (final topic in topics) topic.id: TopicProgress(),
  };

  for (final quiz in quizzes) {
    final status = statusMap[quiz.id];
    for (final topicId in quiz.topicIds) {
      final progress = topicProgressMap[topicId];
      if (progress == null) continue;
      progress.total++;
      if (status != null && status.practiced) {
        progress.practiced++;
        if (status.correct) {
          progress.correct++;
        } else {
          progress.incorrect++;
        }
      }
    }
  }
  return topicProgressMap;
});

class TopicProgress {
  int total = 0;
  int practiced = 0;
  int correct = 0;
  int incorrect = 0;
} 