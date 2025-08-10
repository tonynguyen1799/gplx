import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hive/exam_progress.dart';
import '../services/hive_service.dart';

class ExamsProgressNotifier extends StateNotifier<Map<String, ExamProgress>> {
  ExamsProgressNotifier() : super({});

  Future<void> loadExamsProgress() async {
    final Map<String, ExamProgress> examIdToExamProgress = await loadAllExamProgress();
    state = examIdToExamProgress;
  }

  Future<void> updateExamProgress(ExamProgress examProgress) async {
    state = {
      ...state,
      examProgress.examId: examProgress,
    };
    await saveExamProgress(examProgress);
  }
}

final examsProgressProvider = StateNotifierProvider<ExamsProgressNotifier, Map<String, ExamProgress>>(
  (ref) => ExamsProgressNotifier(),
); 