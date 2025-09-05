class QuizFilterConstants {
  static const int QUIZ_FILTER_ALL = 0;
  static const int QUIZ_FILTER_PRACTICED = 1;
  static const int QUIZ_FILTER_UNPRACTICED = 2;
  static const int QUIZ_FILTER_SAVED = 3;
  static const int QUIZ_FILTER_CORRECT = 4;
  static const int QUIZ_FILTER_INCORRECT = 5;
  static const int QUIZ_FILTER_DIFFICULT = 6;
  static const int QUIZ_FILTER_FATAL = 7;
}

class QuizModes {
  static const int TRAINING_MODE = 0;
  static const int TRAINING_BY_TOPIC_MODE = 1;
  static const int EXAM_MODE = 2;
}

class ExamModes {
  static const int EXAM_NORMAL_MODE = 0;
  static const int EXAM_QUICK_MODE = 1;
  static const int EXAM_REVIEW_MODE = 2;
}

enum TrainingMode { TOTAL, BY_TOPIC }