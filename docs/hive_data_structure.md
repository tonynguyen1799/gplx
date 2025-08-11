# Hive Data Structure

## Boxes and Keys

### ONBOARDING_BOX (`HiveBoxes.ONBOARDING_BOX`)
- `HiveKeys.ONBOARDING_COMPLETED`: bool

### SETTINGS_BOX (`HiveBoxes.SETTINGS_BOX`)
- `HiveKeys.SETTINGS_LICENSE_TYPE`: String
- `HiveKeys.SETTINGS_REMINDER_ENABLED`: bool
- `HiveKeys.SETTINGS_REMINDER_TIME`: String (format HH:mm, default '21:00')
- `HiveKeys.SETTINGS_THEME_MODE`: String ('system' | 'light' | 'dark', default 'system')

### QUIZ_PROGRESS_BOX (`HiveBoxes.QUIZ_PROGRESS_BOX`)
- Key: `licenseTypeCode` (String)
- Value: `Map<String, QuizProgress>` where key is `quizId` and value is a `QuizProgress` object (Hive adapter registered)

### EXAM_PROGRESS_BOX (`HiveBoxes.EXAM_PROGRESS_BOX`)
- Key: `licenseTypeCode` (String)
- Value: `Map<String, ExamProgress>` where key is `examId` and value is an `ExamProgress` object (Hive adapter registered)

## Access Patterns
- Selected license type is read via service: `getSelectedLicenseType()` and written via `setSelectedLicenseType(code)`.
- UI reads selected license through Riverpod: `selectedLicenseTypeProvider` (Future-based). After calling `setSelectedLicenseType(...)`, call `ref.refresh(selectedLicenseTypeProvider)` to update listeners.
- Quizzes/exams progress are loaded/saved per license type using the service helpers.

## Defaults
- Reminder time default: '21:00'
- Theme mode default: 'system'

## Cleanup
- Use `cleanUp()` to clear `SETTINGS_BOX`, `ONBOARDING_BOX`, `QUIZ_PROGRESS_BOX`, and `EXAM_PROGRESS_BOX`. This is used to reset the app and return to splash/onboarding. 