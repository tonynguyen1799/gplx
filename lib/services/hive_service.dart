import 'package:hive/hive.dart';
import '../models/hive/quiz_progress.dart';
import '../models/hive/exam_progress.dart';
import 'package:gplx_vn/constants/hive_keys.dart';

const String kDefaultReminderTime = '21:00';
const String kDefaultThemeMode = 'system';

Future<void> setOnboardingComplete(bool completed) async {
  final box = await Hive.openBox(HiveBoxes.ONBOARDING_BOX);
  await box.put(HiveKeys.ONBOARDING_COMPLETED, completed);
}

Future<bool> isOnboardingComplete() async {
  final box = await Hive.openBox(HiveBoxes.ONBOARDING_BOX);
  return box.get(HiveKeys.ONBOARDING_COMPLETED, defaultValue: false);
}

Future<void> setLicenseType(String code) async {
  final box = await Hive.openBox(HiveBoxes.SETTINGS_BOX);
  await box.put(HiveKeys.SETTINGS_LICENSE_TYPE, code);
}

Future<String?> getLicenseType() async {
  final settings = await Hive.openBox(HiveBoxes.SETTINGS_BOX);
  return settings.get(HiveKeys.SETTINGS_LICENSE_TYPE);
}

Future<void> setReminderEnabled(bool enabled) async {
  final box = await Hive.openBox(HiveBoxes.SETTINGS_BOX);
  await box.put(HiveKeys.SETTINGS_REMINDER_ENABLED, enabled);
}

Future<bool> getReminderEnabled() async {
  final box = await Hive.openBox(HiveBoxes.SETTINGS_BOX);
  return box.get(HiveKeys.SETTINGS_REMINDER_ENABLED, defaultValue: true);
}

Future<void> setReminderTime(String time24h) async {
  final box = await Hive.openBox(HiveBoxes.SETTINGS_BOX);
  await box.put(HiveKeys.SETTINGS_REMINDER_TIME, time24h); // e.g., '19:00'
}

Future<String> getReminderTime() async {
  final box = await Hive.openBox(HiveBoxes.SETTINGS_BOX);
  return box.get(HiveKeys.SETTINGS_REMINDER_TIME, defaultValue: kDefaultReminderTime);
}

Future<String> getThemeMode() async {
  final box = await Hive.openBox(HiveBoxes.SETTINGS_BOX);
  return box.get(HiveKeys.SETTINGS_THEME_MODE, defaultValue: kDefaultThemeMode);
}

Future<void> setThemeMode(String modeName) async {
  final box = await Hive.openBox(HiveBoxes.SETTINGS_BOX);
  await box.put(HiveKeys.SETTINGS_THEME_MODE, modeName);
}

Future<Map<String, QuizProgress>> loadQuizzesProgress(String licenseTypeCode) async {
  final box = await Hive.openBox(HiveBoxes.QUIZ_PROGRESS_BOX);
  final data = box.get(licenseTypeCode);
  if (data is Map) {
    final Map<String, QuizProgress> status = {};
    data.forEach((key, value) {
      if (value is QuizProgress) {
        status[key as String] = value;
      }
    });
    return status;
  }
  return {};
}

Future<void> saveQuizzesProgress(String licenseTypeCode, Map<String, QuizProgress> status) async {
  final box = await Hive.openBox(HiveBoxes.QUIZ_PROGRESS_BOX);
  await box.put(licenseTypeCode, status);
}

Future<void> clearQuizProgressBox() async {
  final box = await Hive.openBox(HiveBoxes.QUIZ_PROGRESS_BOX);
  await box.clear();
}

Future<void> saveExamProgress(ExamProgress progress) async {
  final box = await Hive.openBox(HiveBoxes.EXAM_PROGRESS_BOX);
  final String code = progress.licenseTypeCode;
  final dynamic existing = box.get(code);
  Map<String, ExamProgress> examMap = {};
  if (existing is Map) {
    existing.forEach((key, value) {
      if (value is ExamProgress) {
        examMap[key as String] = value;
      }
    });
  }
  examMap[progress.examId] = progress;
  await box.put(code, examMap);
}

Future<Map<String, ExamProgress>> loadExamsProgress(String licenseTypeCode) async {
  final box = await Hive.openBox(HiveBoxes.EXAM_PROGRESS_BOX);
  final dynamic data = box.get(licenseTypeCode);
  if (data is Map) {
    final Map<String, ExamProgress> result = {};
    data.forEach((key, value) {
      if (value is ExamProgress) {
        result[key as String] = value;
      }
    });
    return result;
  }
  return {};
}

Future<void> cleanUp() async {
  final settings = await Hive.openBox(HiveBoxes.SETTINGS_BOX);
  final onboarding = await Hive.openBox(HiveBoxes.ONBOARDING_BOX);
  final quizzes = await Hive.openBox(HiveBoxes.QUIZ_PROGRESS_BOX);
  final exams = await Hive.openBox(HiveBoxes.EXAM_PROGRESS_BOX);
  await Future.wait([
    settings.clear(),
    onboarding.clear(),
    quizzes.clear(),
    exams.clear(),
  ]);
}
