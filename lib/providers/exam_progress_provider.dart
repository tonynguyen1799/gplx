import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exam_progress.dart';
import '../services/hive_service.dart';

class ExamsProgressNotifier extends StateNotifier<Map<String, ExamProgress>> {
  ExamsProgressNotifier() : super({});

  void setProgress(ExamProgress progress) async {
    state = {
      ...state,
      progress.examId: progress,
    };
    await saveExamProgress(progress);
  }

  Future<void> loadAllFromHive() async {
    final all = await loadAllExamProgress();
    state = all;
  }

  ExamProgress? getProgress(String examId) => state[examId];
}

final examsProgressProvider = StateNotifierProvider<ExamsProgressNotifier, Map<String, ExamProgress>>(
  (ref) => ExamsProgressNotifier(),
); 