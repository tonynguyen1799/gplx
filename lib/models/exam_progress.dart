class ExamProgress {
  final String examId;
  final String licenseTypeCode;
  final bool passed;
  final int correctCount;
  final int incorrectCount;
  final DateTime timestamp;

  ExamProgress({
    required this.examId,
    required this.licenseTypeCode,
    required this.passed,
    required this.correctCount,
    required this.incorrectCount,
    required this.timestamp,
  });

  factory ExamProgress.fromMap(Map<String, dynamic> map) {
    return ExamProgress(
      examId: map['examId'] as String,
      licenseTypeCode: map['licenseTypeCode'] as String,
      passed: map['passed'] as bool,
      correctCount: map['correctCount'] as int,
      incorrectCount: map['incorrectCount'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'examId': examId,
      'licenseTypeCode': licenseTypeCode,
      'passed': passed,
      'correctCount': correctCount,
      'incorrectCount': incorrectCount,
      'timestamp': timestamp.toIso8601String(),
    };
  }
} 