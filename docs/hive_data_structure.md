# Hive Data Structure

## onboardingBox
- completedOnboarding: bool
- selectedLicenseType: String  
  _(Accessed directly via service functions, not via a provider)_

## settings
- reminderEnabled: bool
- reminderTime: String

## quizStatusBox
- {licenseTypeCode}: Map<quizId, QuizPracticeStatus> 