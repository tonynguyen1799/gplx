import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hive/exam_progress.dart';
import '../services/hive_service.dart';

class ExamsProgressNotifier extends StateNotifier<Map<String, Map<String, ExamProgress>>> {
  ExamsProgressNotifier() : super({});

  Future<void> loadExamsProgressFor(String licenseTypeCode) async {
    final Map<String, ExamProgress> examIdToExamProgress = await loadExamsProgress(licenseTypeCode);
    state = {
      ...state,
      licenseTypeCode: examIdToExamProgress,
    };
  }

  Future<void> updateExamProgress(ExamProgress examProgress) async {
    final current = Map<String, Map<String, ExamProgress>>.from(state);
    final Map<String, ExamProgress> byExam = Map<String, ExamProgress>.from(current[examProgress.licenseTypeCode] ?? {});
    byExam[examProgress.examId] = examProgress;
    current[examProgress.licenseTypeCode] = byExam;
    state = current;
    await saveExamProgress(examProgress);
  }
}

final examsProgressProvider = StateNotifierProvider<ExamsProgressNotifier, Map<String, Map<String, ExamProgress>>>(
  (ref) => ExamsProgressNotifier(),
); 