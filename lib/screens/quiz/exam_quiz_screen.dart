import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/quiz.dart';
import '../../providers/app_data_providers.dart';
import '../../models/license_type.dart';
import '../../models/quiz_practice_status.dart';
import '../../models/topic.dart';
import '../../services/hive_service.dart';
import 'package:go_router/go_router.dart';
import '../../utils/quiz_constants.dart';
import '../../models/exam.dart';
import 'dart:async';
import 'quiz_screen.dart' show BookmarkButton;
import '../../widgets/exam_timer.dart';
import '../../widgets/bookmark_button.dart';
import '../../widgets/quiz_content.dart';
import '../../widgets/answer_options.dart';
import '../../providers/learning_progress.provider.dart';
import '../../widgets/exam_quiz_jump_button.dart';
import 'exam_summary_screen.dart';
import '../../models/exam_progress.dart';
import '../../providers/exam_progress_provider.dart';

class ExamQuizScreen extends ConsumerStatefulWidget {
  final Object? extra;
  const ExamQuizScreen({super.key, this.extra});

  @override
  ConsumerState<ExamQuizScreen> createState() => _ExamQuizScreenState();
}

class _ExamQuizScreenState extends ConsumerState<ExamQuizScreen> {
  int currentIndex = 0;
  late final PageController _pageController;
  String? licenseTypeCode;
  String? mode;
  String? examId;
  String? examMode;
  Map<String, int> selectedAnswers = {}; // quizId -> selected index
  static const int examDurationMinutes = 20;
  Timer? _timer;
  bool reviewMode = false;

  // Cache for quizId to index in the full quizzes list
  Map<String, int> _quizIdToIndex = {};

  List<Quiz> get quizzes {
    if (licenseTypeCode == null || mode != QuizModes.EXAM_MODE || examId == null) return <Quiz>[];
    final quizzesMap = ref.read(quizzesProvider);
    final allQuizzes = quizzesMap.containsKey(licenseTypeCode)
        ? List<Quiz>.from(quizzesMap[licenseTypeCode]!)
        : <Quiz>[];
    final examsMap = ref.read(examsProvider);
    final exams = examsMap[licenseTypeCode];
    final exam = exams?.where((e) => e.id == examId).isNotEmpty == true
        ? exams!.firstWhere((e) => e.id == examId)
        : null;
    if (exam != null) {
      // Build the quizId to index map for the full quizzes list
      _buildQuizIdToIndexMap(allQuizzes);
      return allQuizzes.where((q) => exam.quizIds.contains(q.id)).toList();
    }
    return <Quiz>[];
  }

  void _buildQuizIdToIndexMap(List<Quiz> allQuizzes) {
    _quizIdToIndex = {for (int i = 0; i < allQuizzes.length; i++) allQuizzes[i].id: i};
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentIndex);
    final params = widget.extra as Map<String, dynamic>?;
    if (params != null) {
      licenseTypeCode = params['licenseTypeCode'] as String?;
      mode = params['mode'] as String?;
      examId = params['examId'] as String?;
      examMode = params['exam_mode'] as String?;
      reviewMode = params['reviewMode'] == true;
      if (params['selectedAnswers'] != null) {
        selectedAnswers = Map<String, int>.from(params['selectedAnswers'] as Map);
      }
      // Optionally set currentIndex if startIndex is provided
      final startIndex = params['startIndex'] as int?;
      if (startIndex != null) {
        currentIndex = startIndex;
      }
    }
    // Ensure the PageController jumps to the correct page after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(currentIndex);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _selectAnswer(int index) async {
    final currentQuiz = quizzes[currentIndex];
    final quizId = currentQuiz.id;
    setState(() {
      selectedAnswers[quizId] = index;
    });
  }

  void _nextQuestion(int total) async {
    if (currentIndex < total - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void _prevQuestion() async {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  Future<void> _submitExam(BuildContext context, Map<String, dynamic> config, List<Quiz> quizzes, Map<String, int> selectedAnswers, String? licenseTypeCode, String? examId, WidgetRef ref) async {
    int correctCount = 0;
    int incorrectCount = 0;
    for (final quiz in quizzes) {
      final selected = selectedAnswers[quiz.id];
      if (selected != null && selected == quiz.correctIndex) {
        correctCount++;
      } else if (selected != null) {
        incorrectCount++;
      }
    }
    final fatalTopicId = '${licenseTypeCode?.toLowerCase()}-fatal';
    final fatalQuizzes = quizzes.where((quiz) => quiz.topicIds.contains(fatalTopicId)).toList();
    final allFatalCorrect = fatalQuizzes.isEmpty || fatalQuizzes.every((quiz) {
      final selected = selectedAnswers[quiz.id];
      return selected != null && selected == quiz.correctIndex;
    });
    final minCorrect = config['exam']?['numberOfRequiredCorrectQuizzes'] ?? 0;
    final passed = allFatalCorrect && correctCount >= minCorrect;
    ref.read(examsProgressProvider.notifier).setProgress(
      ExamProgress(
        examId: examId!,
        licenseTypeCode: licenseTypeCode!,
        passed: passed,
        correctCount: correctCount,
        incorrectCount: incorrectCount,
        timestamp: DateTime.now(),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.push('/exam-summary', extra: {
        'quizzes': quizzes,
        'selectedAnswers': selectedAnswers,
        'licenseTypeCode': licenseTypeCode!,
        'examId': examId!,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (licenseTypeCode == null) {
      return const Scaffold(body: Center(child: Text('Không tìm thấy loại bằng lái.')));
    }
    final List<Quiz> quizzes = this.quizzes; // Use the filtered getter!
    if (quizzes.isEmpty) {
      return const Scaffold(body: Center(child: Text('Không có câu hỏi nào.', style: TextStyle(fontSize: 15))));
    }
    final quiz = quizzes[currentIndex];
    final fatalTopicId = '${licenseTypeCode?.toLowerCase()}-fatal';
    return Consumer(
      builder: (context, ref, _) {
        final configs = ref.watch(configsProvider);
        final config = configs[licenseTypeCode] ?? {};
        final durationMinutes = config['exam']?['durationInMunites'] ?? 20;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () async {
                if (reviewMode) {
                  Navigator.of(context).pop();
                } else {
            final shouldClose = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Xác nhận thoát'),
                      content: Text(
                        'Bạn có chắc chắn muốn thoát khỏi bài thi? Tiến trình làm bài sẽ bị mất.',
                        style: TextStyle(fontSize: 15, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null),
                      ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer, color: Colors.blue, size: 20),
                        SizedBox(width: 4),
                        Text('Tiếp tục thi'),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, color: Colors.red, size: 20),
                        SizedBox(width: 4),
                        Text('Thoát', style: TextStyle(fontSize: 15, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            );
            if (shouldClose == true) {
                    context.pop();
                  }
            }
          },
        ),
            title: reviewMode
                ? Text('Xem lại bài làm', style: TextStyle(fontSize: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null))
                : ExamTimer(
                    durationSeconds: durationMinutes * 60,
                    onTimeout: () async {
                      await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          title: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.timer_off, color: Colors.red, size: 40),
                              const SizedBox(height: 8),
                              Text('Hết thời gian', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null)),
                            ],
                          ),
                          content: Text('Bài thi đã hết thời gian. Bài làm sẽ được nộp tự động.', style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null)),
        actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Đồng ý'),
                            ),
                          ],
                        ),
                      );
                      await _submitExam(context, config, quizzes, selectedAnswers, licenseTypeCode, examId, ref);
                    },
                  ),
            centerTitle: true,
            actions: reviewMode
                ? null
                : [
          SizedBox(
            width: 80, // Increased width so 'Nộp bài' fits on one line
            child: TextButton(
              onPressed: () async {
                final shouldSubmit = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xác nhận nộp bài'),
                              content: Text(
                                'Bạn có chắc chắn muốn nộp bài? Bạn sẽ không thể thay đổi câu trả lời sau khi nộp.',
                                style: TextStyle(fontSize: 15, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null),
                              ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_rounded, color: Colors.blue, size: 20),
                            SizedBox(width: 4),
                            Text('Tiếp tục thi'),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.red, size: 20),
                            SizedBox(width: 4),
                            Text('Nộp bài', style: TextStyle(fontSize: 15, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
                if (shouldSubmit == true) {
                            await _submitExam(context, config, quizzes, selectedAnswers, licenseTypeCode, examId, ref);
                }
              },
              child: Text('Nộp bài', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
            ),
          ),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 0,
                  runSpacing: 0,
                  children: List.generate(
                    quizzes.length,
                    (idx) {
                      final quizId = quizzes[idx].id;
                      final isAnswered = selectedAnswers.containsKey(quizId);
                      final isQuickExam = mode == QuizModes.EXAM_MODE && examMode == ExamModes.EXAM_QUICK_MODE;
                      final selectedIdx = selectedAnswers[quizId];
                          final isCorrect = isAnswered && selectedIdx == quizzes[idx].correctIndex;
                          final isUnanswered = !isAnswered;
                      return ExamQuizJumpButton(
                        idx: idx,
                        currentIndex: currentIndex,
                        quiz: quizzes[idx],
                        isAnswered: isAnswered,
                        isQuickExam: isQuickExam,
                        selectedIdx: selectedIdx,
                        onTap: () {
                          setState(() {
                            currentIndex = idx;
                          });
                          _pageController.jumpToPage(idx);
                        },
                            reviewMode: reviewMode,
                            isCorrect: isCorrect,
                            isUnanswered: isUnanswered,
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: quizzes.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final quiz = quizzes[index];
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                children: [
                  QuizContent(
                    quiz: quiz,
                              quizIndex: index,
                    totalQuizzes: quizzes.length,
                    licenseTypeCode: licenseTypeCode!,
                    status: null, // Don't show persistent status in exam mode
                    onBookmarkChanged: () => setState(() {}),
                              quizCode: '${licenseTypeCode}.${(_quizIdToIndex[quiz.id] ?? -1) + 1}',
                    mode: mode,
                  ),
                  Divider(thickness: 1, height: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : null),
                  AnswerOptions(
                              key: ValueKey(quiz.id),
                    answers: quiz.answers,
                    correctIndex: quiz.correctIndex,
                              onSelect: reviewMode
                                  ? ((_) async {})
                                  : (mode == QuizModes.EXAM_MODE && examMode == ExamModes.EXAM_QUICK_MODE && selectedAnswers[quiz.id] != null)
                                      ? ((_) async {})
                                      : _selectAnswer,
                              selectedIndex: reviewMode
                                  ? (selectedAnswers.containsKey(quiz.id)
                                      ? selectedAnswers[quiz.id]!
                                      : -1)
                                  : selectedAnswers[quiz.id],
                              showExplanation: reviewMode ||
                                  mode == QuizModes.TRAINING_MODE ||
                                  mode == QuizModes.TRAINING_BY_TOPIC_MODE ||
                                  (mode == QuizModes.EXAM_MODE && examMode == ExamModes.EXAM_QUICK_MODE && selectedAnswers[quiz.id] != null),
                              explanation: reviewMode
                                  ? quiz.explanation
                                  : (mode == QuizModes.TRAINING_MODE ||
                                      mode == QuizModes.TRAINING_BY_TOPIC_MODE ||
                                      (mode == QuizModes.EXAM_MODE && examMode == ExamModes.EXAM_QUICK_MODE && selectedAnswers[quiz.id] != null))
                                      ? quiz.explanation
                                      : null,
                              mode: mode ?? QuizModes.TRAINING_MODE,
                              lockAnswer: reviewMode || (mode == QuizModes.EXAM_MODE && examMode == ExamModes.EXAM_QUICK_MODE && selectedAnswers[quiz.id] != null),
                    isFatalQuiz: quiz.topicIds.contains(fatalTopicId),
                    examMode: examMode ?? '',
                  ),
                ],
                        ),
                      );
                    },
              ),
            ),
                const SizedBox(height: 16),
            SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                          onPressed: (quizzes.isNotEmpty && currentIndex > 0) ? () {
                            _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                          } : null,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade200,
                        disabledForegroundColor: Colors.grey,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Câu trước'),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                          onPressed: (quizzes.isNotEmpty && currentIndex < quizzes.length - 1) ? () {
                            _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                          } : null,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade200,
                        disabledForegroundColor: Colors.grey,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Tiếp theo'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }
} 