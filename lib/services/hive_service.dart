import 'package:hive/hive.dart';
import '../models/hive/quiz_progress.dart';
import '../models/hive/exam_progress.dart';
import 'package:gplx_vn/models/hive_keys.dart';

const quizStatusBox = HiveBoxes.quizStatus;
const onboardingBox = HiveBoxes.onboarding;

// ---------------- Onboarding ----------------
Future<void> setOnboardingComplete(bool completed) async {
  final box = await Hive.openBox(onboardingBox);
  await box.put(HiveKeys.onboardingCompleted, completed);
}

Future<bool> isOnboardingComplete() async {
  final box = await Hive.openBox(onboardingBox);
  return box.get(HiveKeys.onboardingCompleted, defaultValue: false);
}

// Add after isOnboardingComplete
Future<void> setSelectedLicenseType(String code) async {
  final box = await Hive.openBox(onboardingBox);
  await box.put(HiveKeys.selectedLicenseType, code);
}

Future<String?> getSelectedLicenseType() async {
  final box = await Hive.openBox(onboardingBox);
  return box.get(HiveKeys.selectedLicenseType);
}

// ---------------- Reminder Settings ----------------
Future<void> setReminderEnabled(bool enabled) async {
  final box = await Hive.openBox(HiveBoxes.settings);
  await box.put(HiveKeys.reminderEnabled, enabled);
}

Future<bool> getReminderEnabled() async {
  final box = await Hive.openBox(HiveBoxes.settings);
  return box.get(HiveKeys.reminderEnabled, defaultValue: true);
}

Future<void> setReminderTime(String time24h) async {
  final box = await Hive.openBox(HiveBoxes.settings);
  await box.put(HiveKeys.reminderTime, time24h); // e.g., '19:00'
}

Future<String> getReminderTime() async {
  final box = await Hive.openBox(HiveBoxes.settings);
  return box.get(HiveKeys.reminderTime, defaultValue: '21:00');
}

// ---------------- Per-Quiz Status ----------------
Future<Map<String, QuizProgress>> loadQuizStatus(String licenseTypeCode) async {
  final box = await Hive.openBox(quizStatusBox);
  final data = box.get(licenseTypeCode);
  if (data is Map) {
    final Map<String, QuizProgress> status = {};
    data.forEach((key, value) {
      if (value is QuizProgress) {
        status[key as String] = value;
      } else if (value is Map) {
        // legacy map -> adapter migration path (not expected here for QuizProgress as it's typed)
      }
    });
    return status;
  }
  return {};
}

Future<void> saveQuizStatus(String licenseTypeCode, Map<String, QuizProgress> status) async {
  final box = await Hive.openBox(quizStatusBox);
  final data = status.map((key, value) => MapEntry(key, value));
  await box.put(licenseTypeCode, data);
}

Future<void> mergeQuizStatus(String licenseTypeCode, Map<String, QuizProgress> incoming) async {
  final current = await loadQuizStatus(licenseTypeCode);
  current.addAll(incoming);
  await saveQuizStatus(licenseTypeCode, current);
}

Future<void> clearQuizStatusBox() async {
  final box = await Hive.openBox(quizStatusBox);
  await box.clear();
  print('Quiz status box cleared!');
}

Future<void> saveExamProgress(ExamProgress progress) async {
  final box = await Hive.openBox<ExamProgress>(HiveBoxes.examProgress);
  await box.put(progress.examId, progress);
}

Future<Map<String, ExamProgress>> loadAllExamProgress() async {
  final box = await Hive.openBox<ExamProgress>(HiveBoxes.examProgress);
  final Map<String, ExamProgress> result = {};
  for (var key in box.keys) {
    final ExamProgress? value = box.get(key);
    if (value != null) {
      result[key as String] = value;
    }
  }
  return result;
}

Future<void> clearOnboardingBox() async {
  final box = await Hive.openBox(onboardingBox);
  await box.clear();
  print('Onboarding box cleared!');
}

Future<void> clearReminderSettings() async {
  final box = await Hive.openBox(HiveBoxes.settings);
  await box.clear();
  print('Reminder settings cleared!');
}

Future<void> clearExamProgressBox() async {
  final box = await Hive.openBox(HiveBoxes.examProgress);
  await box.clear();
  print('Exam progress box cleared!');
}
