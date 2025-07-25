import 'package:hive_flutter/hive_flutter.dart';
import '../models/quiz_practice_status.dart';
import '../models/exam_progress.dart';

const String onboardingBox = 'onboardingBox';
const String quizStatusBox = 'quizStatusBox';

// ---------------- Onboarding ----------------
Future<void> setOnboardingComplete(bool completed) async {
  final box = await Hive.openBox(onboardingBox);
  await box.put('completedOnboarding', completed);
}

Future<bool> isOnboardingComplete() async {
  final box = await Hive.openBox(onboardingBox);
  return box.get('completedOnboarding', defaultValue: false);
}

// Add after isOnboardingComplete
Future<void> setSelectedLicenseType(String code) async {
  final box = await Hive.openBox(onboardingBox);
  await box.put('selectedLicenseType', code);
}

Future<String?> getSelectedLicenseType() async {
  final box = await Hive.openBox(onboardingBox);
  return box.get('selectedLicenseType');
}

// ---------------- Reminder Settings ----------------
Future<void> setReminderEnabled(bool enabled) async {
  final box = await Hive.openBox('settings');
  await box.put('reminderEnabled', enabled);
}

Future<bool> getReminderEnabled() async {
  final box = await Hive.openBox('settings');
  return box.get('reminderEnabled', defaultValue: true);
}

Future<void> setReminderTime(String time24h) async {
  final box = await Hive.openBox('settings');
  await box.put('reminderTime', time24h); // e.g., '19:00'
}

Future<String> getReminderTime() async {
  final box = await Hive.openBox('settings');
  return box.get('reminderTime', defaultValue: '21:00');
}

// ---------------- Per-Quiz Status ----------------
Future<Map<String, QuizPracticeStatus>> loadQuizStatus(String licenseTypeCode) async {
  final box = await Hive.openBox(quizStatusBox);
  final data = box.get(licenseTypeCode);
  if (data is Map) {
    return Map<String, QuizPracticeStatus>.from(data as Map);
  }
  return {};
}

Future<void> saveQuizStatus(String licenseTypeCode, Map<String, QuizPracticeStatus> updatedStatusMap) async {
  final box = await Hive.openBox(quizStatusBox);
  // Load the existing map
  final existing = box.get(licenseTypeCode);
  final merged = <String, QuizPracticeStatus>{};
  if (existing is Map) {
    merged.addAll(Map<String, QuizPracticeStatus>.from(existing));
  }
  merged.addAll(updatedStatusMap);
  await box.put(licenseTypeCode, merged);
}

Future<void> clearQuizStatusBox() async {
  final box = await Hive.openBox(quizStatusBox);
  await box.clear();
  print('Quiz status box cleared!');
}

Future<void> saveExamProgress(ExamProgress progress) async {
  final box = await Hive.openBox('examProgressBox');
  await box.put(progress.examId, progress.toMap());
}

Future<Map<String, ExamProgress>> loadAllExamProgress() async {
  final box = await Hive.openBox('examProgressBox');
  final Map<String, ExamProgress> result = {};
  for (var key in box.keys) {
    final map = box.get(key);
    if (map is Map) {
      result[key as String] = ExamProgress.fromMap(Map<String, dynamic>.from(map));
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
  final box = await Hive.openBox('settings');
  await box.clear();
  print('Reminder settings cleared!');
}

Future<void> clearExamProgressBox() async {
  final box = await Hive.openBox('examProgressBox');
  await box.clear();
  print('Exam progress box cleared!');
}
