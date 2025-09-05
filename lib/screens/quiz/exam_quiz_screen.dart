import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/quiz_constants.dart';
import '../../constants/route_constants.dart';
import '../../constants/ui_constants.dart';
import '../../models/hive/exam_progress.dart';
import '../../models/riverpod/data/config.dart';
import '../../models/riverpod/data/quiz.dart';
import '../../providers/app_data_providers.dart';
import '../../providers/exams_progress_provider.dart';
import '../../providers/license_type_provider.dart';
import '../../constants/app_colors.dart';
import '../../widgets/error_scaffold.dart';
import '../../widgets/exam_key_buttons_widget.dart';
import '../../widgets/exam_quiz_jump_buttons_panel.dart';
import '../../widgets/exam_timer.dart';
import '../../widgets/quiz_bottom_navigation.dart';
import '../../widgets/quiz_page.dart';
import '../../widgets/quiz_shortcuts_bottom_sheet.dart';

class ExamQuizScreenParams {
  final String examId;
  final int examMode;
  final Map<String, int>? selectedAnswers;
  final int? startIndex;

  const ExamQuizScreenParams({
    required this.examId,
    required this.examMode,
    this.selectedAnswers,
    this.startIndex,
  });
}

class ExamQuizScreen extends ConsumerStatefulWidget {
  final ExamQuizScreenParams params;
  const ExamQuizScreen({super.key, required this.params});

  @override
  ConsumerState<ExamQuizScreen> createState() => _ExamQuizScreenState();
}

class _ExamQuizScreenState extends ConsumerState<ExamQuizScreen> {
  int _currentIndex = 0;
  Map<String, int> _selectedAnswers = {};
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    if (widget.params.selectedAnswers != null) {
      _selectedAnswers = Map<String, int>.from(widget.params.selectedAnswers!);
    }
    if (widget.params.startIndex != null) {
      _currentIndex = widget.params.startIndex!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.params.examId.isEmpty) {
      return const ErrorScaffold(message: 'Không tìm thấy bài thi.');
    }

    final licenseTypeAsync = ref.watch(licenseTypeProvider);
    final examQuizzesAsync = ref.watch(examQuizzesProvider(widget.params.examId));
    final configAsync = ref.watch(configProvider);
    
    if (licenseTypeAsync.isLoading || examQuizzesAsync.isLoading || configAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (licenseTypeAsync.hasError || examQuizzesAsync.hasError || configAsync.hasError) {
      return ErrorScaffold(message: 'Lỗi khi tải dữ liệu.');
    }
    
    final licenseTypeCode = licenseTypeAsync.value;
    final examQuizzes = examQuizzesAsync.value!;
    final config = configAsync.value!;
    
    if (licenseTypeCode == null || licenseTypeCode.isEmpty) {
      return const ErrorScaffold(message: 'Không tìm thấy loại bằng lái.');
    }
    
    if (examQuizzes.isEmpty) {
      return const ErrorScaffold(message: 'Không có câu hỏi nào.');
    }
    
    final theme = Theme.of(context);
    final durationMinutes = config.exam.durationInMinutes;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _onCancel,
        ),
        title: widget.params.examMode == ExamModes.EXAM_REVIEW_MODE
            ? Text(
                'Xem lại bài làm',
                style: const TextStyle(
                  fontSize: APP_BAR_FONT_SIZE,
                  fontWeight: FontWeight.w600,
                ),
              )
            : ExamTimer(
                durationSeconds: durationMinutes * 60,
                onTimeout: () => _onTimeout(
                  config,
                  examQuizzes,
                  licenseTypeCode!,
                ),
              ),
        centerTitle: true,
        actions:
            widget.params.examMode == ExamModes.EXAM_REVIEW_MODE
            ? null
            : [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SUB_SECTION_SPACING),
                  child: TextButton(
                    onPressed: () => _onSubmit(
                      config,
                      examQuizzes,
                      licenseTypeCode!,
                    ),
                    child: Text(
                      'Nộp bài',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.ERROR_COLOR,
                      ),
                    ),
                  ),
                ),
              ],
        backgroundColor: theme.APP_BAR_BG,
        foregroundColor: theme.APP_BAR_FG,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: SECTION_SPACING),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
            child: ExamQuizJumpButtonsPanel(
              quizzes: examQuizzes,
              selectedAnswers: _selectedAnswers,
              currentIndex: _currentIndex,
              mode: widget.params.examMode,
              onJump: (idx) {
                setState(() {
                  _currentIndex = idx;
                });
                _pageController.jumpToPage(idx);
              },
            ),
          ),
          Expanded(
            child: PageView.builder(
              physics:
                  (widget.params.examMode != ExamModes.EXAM_REVIEW_MODE)
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              controller: _pageController,
              itemCount: examQuizzes.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final quiz = examQuizzes[index];
                final selectedIdx =
                    (widget.params.examMode == ExamModes.EXAM_REVIEW_MODE)
                    ? (_selectedAnswers.containsKey(quiz.id)
                          ? _selectedAnswers[quiz.id]!
                          : -1)
                    : _selectedAnswers[quiz.id];
                final isViewed =
                    (widget.params.examMode == ExamModes.EXAM_REVIEW_MODE) ||
                    (widget.params.examMode == ExamModes.EXAM_QUICK_MODE &&
                        _selectedAnswers[quiz.id] != null);
                final lockAnswer =
                    widget.params.examMode == ExamModes.EXAM_REVIEW_MODE ||
                    widget.params.examMode == ExamModes.EXAM_NORMAL_MODE ||
                    (widget.params.examMode == ExamModes.EXAM_QUICK_MODE &&
                        _selectedAnswers[quiz.id] != null);
                final onAnswer =
                    (widget.params.examMode == ExamModes.EXAM_REVIEW_MODE)
                    ? null
                    : (widget.params.examMode == ExamModes.EXAM_NORMAL_MODE)
                    ? (idx) => _onAnswered(quiz.id, idx)
                    : null;

                return QuizPage(
                  quiz: quiz,
                  progress: null,
                  quizIndex: index,
                  totalQuizzes: examQuizzes.length,
                  selectedIdx: selectedIdx,
                  isViewed: isViewed,
                  lockAnswer: lockAnswer,
                  onAnswer: onAnswer,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          (widget.params.examMode == ExamModes.EXAM_REVIEW_MODE)
          ? QuizBottomNavigation(
              onPrevious:
                  (examQuizzes.isNotEmpty && _currentIndex > 0)
                  ? () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  : null,
              onShowQuizzes: examQuizzes.isNotEmpty
                  ? () async {
                      final selected = await showModalBottomSheet<int>(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => QuizShortcutsBottomSheet(
                          quizzes: examQuizzes,
                          currentIndex: _currentIndex,
                        ),
                      );
                      if (selected != null) {
                        _pageController.jumpToPage(selected);
                      }
                    }
                  : null,
              onNext:
                  (examQuizzes.isNotEmpty && _currentIndex < examQuizzes.length - 1)
                  ? () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  : null,
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ExamKeyButtonsWidget(
                    quiz: examQuizzes[_currentIndex],
                    lockAnswer:
                        (widget.params.examMode == ExamModes.EXAM_REVIEW_MODE) ||
                        (widget.params.examMode == ExamModes.EXAM_QUICK_MODE &&
                            _selectedAnswers[examQuizzes[_currentIndex].id] != null),
                    onAnswer: _onAnswered,
                    onPrevious: _currentIndex > 0
                        ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        : null,
                    onNext: _currentIndex < examQuizzes.length - 1
                        ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        : null,
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _onAnswered(String quizId, int index) async {
    setState(() {
      _selectedAnswers[quizId] = index;
    });
  }

  Future<void> _onCancel() async {
    if (widget.params.examMode == ExamModes.EXAM_REVIEW_MODE) {
      context.pop();
    } else {
      final theme = Theme.of(context);
      final isCancelled = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Xác nhận huỷ',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Bạn có chắc chắn muốn thoát khỏi bài thi? Tiến trình làm bài sẽ bị mất.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
            ),
          ),
          actionsPadding: const EdgeInsets.all(CONTENT_PADDING),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tiếp tục thi',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => context.pop(true),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.close, color: theme.ERROR_COLOR),
                  Text(
                    'Thoát',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.ERROR_COLOR,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
      if (isCancelled == true) {
        context.pop();
        context.pop();
      }
    }
  }

  Future<void> _onTimeout(
    Config config,
    List<Quiz> examQuizzes,
    String licenseTypeCode,
  ) async {
    final theme = Theme.of(context);
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_off, color: theme.ERROR_COLOR, size: 40),
            const SizedBox(height: SUB_SECTION_SPACING),
            Text(
              'Hết thời gian',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Bài thi đã hết thời gian. Bài làm sẽ được nộp tự động.',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
          ),
        ),
        actionsPadding: const EdgeInsets.all(CONTENT_PADDING),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Đồng ý',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
    _doSubmit(
      context,
      config,
      examQuizzes,
      _selectedAnswers,
      licenseTypeCode,
      widget.params.examId,
      ref,
    );
  }

  Future<void> _onSubmit(
    Config config,
    List<Quiz> examQuizzes,
    String licenseTypeCode,
  ) async {
    final theme = Theme.of(context);
    final isSubmitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xác nhận nộp bài',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn nộp bài? Bạn sẽ không thể thay đổi câu trả lời sau khi nộp.',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
          ),
        ),
        actionsPadding: const EdgeInsets.all(CONTENT_PADDING),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(
              'Tiếp tục thi',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: theme.ERROR_COLOR),
                Text(
                  'Nộp bài',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.ERROR_COLOR,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (isSubmitted == true) {
      _doSubmit(
        context,
        config,
        examQuizzes,
        _selectedAnswers,
        licenseTypeCode,
        widget.params.examId,
        ref,
      );
    }
  }

  Future<void> _doSubmit(
    BuildContext context,
    Config config,
    List<Quiz> quizzes,
    Map<String, int> selectedAnswers,
    String? licenseTypeCode,
    String? examId,
    WidgetRef ref,
  ) async {
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
    final fatalQuizzes = quizzes
        .where((quiz) => quiz.topicIds.contains(fatalTopicId))
        .toList();
    final allFatalCorrect =
        fatalQuizzes.isEmpty ||
        fatalQuizzes.every((quiz) {
          final selected = selectedAnswers[quiz.id];
          return selected != null && selected == quiz.correctIndex;
        });
    final isPassed = allFatalCorrect && correctCount >= config.exam.totalRequiredCorrectQuizzes;
    ref
        .read(examsProgressProvider.notifier)
        .updateExamProgress(
          ExamProgress(
            examId: examId!,
            licenseTypeCode: licenseTypeCode!,
            isPassed: isPassed,
            totalCorrectQuizzes: correctCount,
            totalIncorrectQuizzes: incorrectCount,
            completedAt: DateTime.now(),
          ),
        );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.push(
        RouteConstants.ROUTE_EXAM_SUMMARY,
        extra: {
          'selectedAnswers': selectedAnswers,
          'examId': examId!,
        },
      );
    });
  }
}
