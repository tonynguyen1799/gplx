import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/riverpod/data/quiz.dart';
import '../../providers/app_data_providers.dart';
import '../../providers/license_type_provider.dart';
import '../../models/riverpod/data/license_type.dart';
import '../../models/hive/quiz_progress.dart';
import '../../models/riverpod/data/topic.dart';
import '../../services/hive_service.dart';
import 'package:go_router/go_router.dart';
import '../../constants/quiz_constants.dart';
import '../../constants/route_constants.dart';
import '../../models/riverpod/data/exam.dart';
import '../../models/riverpod/data/config.dart';
import 'dart:async';
import 'quiz_screen.dart' show BookmarkButton;
import '../../widgets/exam_timer.dart';
import '../../widgets/bookmark_button.dart';
import '../../widgets/quiz_content.dart';
import '../../widgets/answer_options.dart';
import '../../providers/quizzes_progress_provider.dart';
import '../../widgets/exam_quiz_jump_button.dart';
import 'exam_summary_screen.dart';
import '../../models/hive/exam_progress.dart';
import '../../providers/exams_progress_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/image_key_button.dart';
import '../../widgets/quiz_shortcut.dart';

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
  int? mode;
  String? examId;
  String? examMode;
  Map<String, int> selectedAnswers = {}; // quizId -> selected index
  static const int examDurationMinutes = 20;
  Timer? _timer;
  bool reviewMode = false;

  // Cache for quizId to index in the full quizzes list
  Map<String, int> _quizIdToIndex = {};

  List<Quiz> get quizzes {
    if (licenseTypeCode == null || examId == null) {
      print('DEBUG: Missing licenseTypeCode: $licenseTypeCode or examId: $examId');
      return <Quiz>[];
    }
    
    print('DEBUG: Loading quizzes for licenseTypeCode: $licenseTypeCode, examId: $examId');
    
    final quizzesAsync = ref.watch(quizzesProvider);
    final allQuizzes = quizzesAsync.when(
      data: (quizzes) {
        print('DEBUG: Loaded ${quizzes.length} total quizzes');
        return quizzes;
      },
      loading: () {
        print('DEBUG: Quizzes still loading');
        return <Quiz>[];
      },
      error: (err, stack) {
        print('DEBUG: Error loading quizzes: $err');
        return <Quiz>[];
      },
    );
    
    final examsAsync = ref.watch(examsProvider);
    final exams = examsAsync.when(
      data: (exams) {
        print('DEBUG: Loaded ${exams.length} total exams');
        return exams;
      },
      loading: () {
        print('DEBUG: Exams still loading');
        return <Exam>[];
      },
      error: (err, stack) {
        print('DEBUG: Error loading exams: $err');
        return <Exam>[];
      },
    );
    
    final exam = exams.where((e) => e.id == examId).isNotEmpty == true
        ? exams.firstWhere((e) => e.id == examId)
        : null;
    
    if (exam != null) {
      print('DEBUG: Found exam: ${exam.id} with ${exam.quizIds.length} quiz IDs');
      // Build the quizId to index map for the full quizzes list
      _buildQuizIdToIndexMap(allQuizzes);
      final filteredQuizzes = allQuizzes.where((q) => exam.quizIds.contains(q.id)).toList();
      print('DEBUG: Filtered to ${filteredQuizzes.length} quizzes for this exam');
      return filteredQuizzes;
    }
    
    print('DEBUG: No exam found with ID: $examId');
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
      mode = QuizModes.EXAM_MODE; // Always set to exam mode for this screen
      final examIdParam = params['examId'];
      examId = examIdParam?.toString();
      final examModeParam = params['exam_mode'];
      examMode = examModeParam?.toString();
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

  Future<void> _submitExam(BuildContext context, Config config, List<Quiz> quizzes, Map<String, int> selectedAnswers, String? licenseTypeCode, String? examId, WidgetRef ref) async {
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
    final minCorrect = config.exam.totalRequiredCorrectQuizzes;
    final passed = allFatalCorrect && correctCount >= minCorrect;
    ref.read(examsProgressProvider.notifier).updateExamProgress(
      ExamProgress(
        examId: examId!,
        licenseTypeCode: licenseTypeCode!,
        isPassed: passed,
        totalCorrectQuizzes: correctCount,
        totalIncorrectQuizzes: incorrectCount,
        completedAt: DateTime.now(),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.push(RouteConstants.ROUTE_EXAM_SUMMARY, extra: {
        'quizzes': quizzes,
        'selectedAnswers': selectedAnswers,
        'licenseTypeCode': licenseTypeCode!,
        'examId': examId!,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get license type code from provider
    final licenseTypeAsync = ref.watch(licenseTypeProvider);
    licenseTypeAsync.when(
      data: (code) => licenseTypeCode = code,
      loading: () => licenseTypeCode = null,
      error: (err, stack) => licenseTypeCode = null,
    );
    
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
        final theme = Theme.of(context);
        final asyncConfig = ref.watch(configProvider);
        
        return asyncConfig.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) => Scaffold(body: Center(child: Text('Lỗi khi tải dữ liệu: $err'))),
          data: (config) {
            final durationMinutes = config.exam.durationInMinutes;
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.close, size: 24),
                  onPressed: () async {
                    if (reviewMode) {
                      context.pop();
                    } else {
                      final shouldClose = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận thoát'),
                          content: Text(
                            'Bạn có chắc chắn muốn thoát khỏi bài thi? Tiến trình làm bài sẽ bị mất.',
                            style: TextStyle(fontSize: 15, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null),
                          ),
                          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(false),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer, color: Colors.blue, size: 20),
                                  SizedBox(width: 4),
                                  Text('Tiếp tục thi', style: TextStyle(color: Colors.blue)),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.pop(true),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.close, color: Colors.red, size: 20),
                                  SizedBox(width: 4),
                                  Text('Thoát', style: TextStyle(color: Colors.red)),
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
                    ? Text('Xem lại bài làm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null))
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
                              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                              actions: [
                                TextButton(
                                  onPressed: () => context.pop(),
                                  child: Text('Đồng ý', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
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
                                  actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                                  actions: [
                                    TextButton(
                                      onPressed: () => context.pop(false),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.timer_rounded, color: Colors.blue, size: 20),
                                          SizedBox(width: 4),
                                          Text('Tiếp tục thi', style: TextStyle(color: Colors.blue)),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => context.pop(true),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.red, size: 20),
                                          SizedBox(width: 4),
                                          Text('Nộp bài', style: TextStyle(color: Colors.red)),
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
                backgroundColor: theme.appBarBackground,
                foregroundColor: theme.appBarText,
                elevation: 0,
              ),
              backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
              body: Column(
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
                      physics: (mode == QuizModes.EXAM_MODE && !reviewMode)
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
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
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Divider(thickness: 1, height: 1, color: Theme.of(context).dividerColor),
                              ),
                              AnswerOptions(
                                key: ValueKey(quiz.id),
                                answers: quiz.answers,
                                correctIndex: quiz.correctIndex,
                                onSelect: reviewMode
                                    ? ((_) async {})
                                    : (mode == QuizModes.EXAM_MODE)
                                        ? ((_) async {})
                                        : _selectAnswer,
                                selectedIdx: reviewMode
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
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: SafeArea(
                child: reviewMode
                    ? Container(
                        height: 48,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: (quizzes.isNotEmpty && currentIndex > 0)
                                    ? () {
                                        _pageController.previousPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.ease);
                                      }
                                    : null,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey.shade200,
                                  disabledForegroundColor: Colors.grey,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Câu trước'),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: quizzes.isNotEmpty
                                    ? () async {
                                        final selected = await showModalBottomSheet<int>(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) {
                                            final theme = Theme.of(context);
                                            return SafeArea(
                                              child: Container(
                                                color: theme.scaffoldBackgroundColor,
                                                child: SizedBox(
                                                  height: MediaQuery.of(context).size.height * 0.7,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 12),
                                                        child: Text(
                                                          'Chọn câu hỏi',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                            color: theme.quizBottomSheetText,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: ListView.separated(
                                                          itemCount: quizzes.length,
                                                          separatorBuilder: (context, idx) => Divider(
                                                            height: 1,
                                                            color: theme.dividerColor,
                                                          ),
                                                          itemBuilder: (context, idx) {
                                                            final q = quizzes[idx];
                                                            return QuizShortcut(
                                                              quiz: q,
                                                              index: idx,
                                                              originalIndex: (_quizIdToIndex[q.id] ?? -1),
                                                              selected: idx == currentIndex,
                                                              onTap: () => Navigator.pop(context, idx),
                                                              totalQuizzes: quizzes.length,
                                                              practiced: selectedAnswers.containsKey(q.id),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                        if (selected != null) {
                                          _pageController.jumpToPage(selected);
                                        }
                                      }
                                    : null,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.blue,
                                  disabledBackgroundColor: Colors.grey.shade200,
                                  disabledForegroundColor: Colors.grey,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.list,
                                    size: 20,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextButton(
                                onPressed: quizzes.isNotEmpty && currentIndex < quizzes.length - 1
                                    ? () {
                                        _pageController.nextPage(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.ease);
                                      }
                                    : null,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.grey.shade200,
                                  disabledForegroundColor: Colors.grey,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Tiếp theo'),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 0),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double gap = 0;
                            const int totalButtons = 6; // prev, 1,2,3,4, next
                            final double rawSize = (constraints.maxWidth - gap * (totalButtons - 1)) / totalButtons;
                            final double buttonSize = rawSize.clamp(56.0, 110.0);
                            final double arrowIconSize = (buttonSize * 0.20).clamp(16.0, 26.0);
                            final double numberFontSize = (buttonSize * 0.28).clamp(14.0, 22.0);

                            final quiz = quizzes[currentIndex];
                            // Disable direct answer selection by tapping answers in exam modes.
                            // Bottom number keys control selection in exam modes. Training modes remain tappable.
                            final bool isTrainingMode = mode == QuizModes.TRAINING_MODE || mode == QuizModes.TRAINING_BY_TOPIC_MODE;
                            final bool isQuickExamMode = mode == QuizModes.EXAM_MODE && examMode == ExamModes.EXAM_QUICK_MODE;
                            final bool isExamMode = mode == QuizModes.EXAM_MODE;
                            final bool canSelect = quizzes.isNotEmpty && !reviewMode && (
                              isTrainingMode || (isExamMode && (!isQuickExamMode || (isQuickExamMode && selectedAnswers[quiz.id] == null)))
                            );

                            return Row(
                              children: [
                                ...[for (int i = 0; i < 4; i++) ...[
                                  if (i > 0) SizedBox(width: gap),
                                  Builder(
                                    builder: (_) {
                                      final idx = i;
                                      final enabled = canSelect && quiz.answers.length > idx;
                                      return ImageKeyButton(
                                        notPressedAssetPath: 'assets/images/key_not_pressed.png',
                                        pressedAssetPath: 'assets/images/key_pressed.png',
                                        size: buttonSize,
                                        bleedPx: 16,
                                        isEnabled: enabled,
                                        overlayChild: Text('${idx + 1}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: numberFontSize, color: Colors.black87)),
                                        overlayAlignment: const Alignment(0, -0.12),
                                        onTap: () {
                                          if (enabled) {
                                            _selectAnswer(idx);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ]],
                                SizedBox(width: gap),
                                ImageKeyButton(
                                  notPressedAssetPath: 'assets/images/key_not_pressed.png',
                                  pressedAssetPath: 'assets/images/key_pressed.png',
                                  size: buttonSize,
                                  bleedPx: 16,
                                  isEnabled: quizzes.isNotEmpty && currentIndex > 0,
                                  overlayChild: Icon(Icons.arrow_back_ios_new, size: arrowIconSize, color: Colors.black87),
                                  overlayAlignment: const Alignment(0, -0.12),
                                  onTap: () {
                                    if (quizzes.isNotEmpty && currentIndex > 0) {
                                      _pageController.previousPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                    }
                                  },
                                ),
                                SizedBox(width: gap),
                                ImageKeyButton(
                                  notPressedAssetPath: 'assets/images/key_not_pressed.png',
                                  pressedAssetPath: 'assets/images/key_pressed.png',
                                  size: buttonSize,
                                  bleedPx: 16,
                                  isEnabled: quizzes.isNotEmpty && currentIndex < quizzes.length - 1,
                                  overlayChild: Icon(Icons.arrow_forward_ios, size: arrowIconSize, color: Colors.black87),
                                  overlayAlignment: const Alignment(0, -0.12),
                                  onTap: () {
                                    if (quizzes.isNotEmpty && currentIndex < quizzes.length - 1) {
                                      _pageController.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.ease,
                                      );
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }
} 