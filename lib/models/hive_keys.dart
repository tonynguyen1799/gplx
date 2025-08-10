class HiveBoxes {
  static const String settings = 'settings';
  static const String onboarding = 'onboarding';
  static const String quizStatus = 'quiz_status';
  static const String examProgress = 'examProgressBox';
}

class HiveKeys {
  static const String onboardingCompleted = 'completedOnboarding';
  static const String selectedLicenseType = 'selectedLicenseType';

  static const String reminderEnabled = 'reminderEnabled';
  static const String reminderTime = 'reminderTime';
  static const String themeMode = 'themeMode';

  // Quiz status box keys
  // Use licenseTypeCode as dynamic key per value: box.put(licenseTypeCode, ...)

  // Exam progress box keys
  // Use examId as dynamic key per value: box.put(examId, ...)=
}
