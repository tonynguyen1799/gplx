import 'package:flutter/material.dart';
import '../../models/riverpod/data/quiz.dart';

import '../../widgets/quiz_shortcut.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_data_providers.dart';
import '../../providers/quizzes_progress_provider.dart';
import '../../providers/license_type_provider.dart';
import '../../constants/quiz_constants.dart';
import '../../constants/route_constants.dart';
import '../../constants/app_colors.dart';
import '../../widgets/error_scaffold.dart';
import 'exam_quiz_screen.dart' show ExamQuizScreenParams;
import '../../constants/ui_constants.dart';

class ExamSummaryScreen extends StatefulWidget {
  final String examId;
  final Map<String, int> selectedAnswers;

  const ExamSummaryScreen({
    Key? key,
    required this.selectedAnswers,
    required this.examId,
  }) : super(key: key);

  @override
  State<ExamSummaryScreen> createState() => _ExamSummaryScreenState();
}

class _ExamSummaryScreenState extends State<ExamSummaryScreen> {
  String _filter = 'all';
  Map<String, int> _examQuizIdToIndex = {};
  
  List<Quiz> _correctQuizzes = [];
  List<Quiz> _incorrectQuizzes = [];
  List<Quiz> _unansweredQuizzes = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(
      builder: (context, ref, _) {
        final licenseTypeAsync = ref.watch(licenseTypeProvider);
        final examQuizzesAsync = ref.watch(examQuizzesProvider(widget.examId));
        final configAsync = ref.watch(configProvider);
        
        if (licenseTypeAsync.isLoading || examQuizzesAsync.isLoading || configAsync.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (configAsync.hasError || licenseTypeAsync.hasError || examQuizzesAsync.hasError) {
          return ErrorScaffold(message: 'Lỗi khi tải dữ liệu.');
        }
        
        final licenseTypeCode = licenseTypeAsync.value;
        final config = configAsync.value!;
        final examQuizzes = examQuizzesAsync.value!;
        
        if (licenseTypeCode == null || licenseTypeCode.isEmpty) {
          return const ErrorScaffold(message: 'Không tìm thấy loại bằng lái.');
        }
        
        _examQuizIdToIndex = {for (int i = 0; i < examQuizzes.length; i++) examQuizzes[i].id: i};
        _populateFilteredQuizzes(examQuizzes);
        
        final quizzesProgress = ref.watch(quizzesProgressProvider)[licenseTypeCode] ?? {};
        
        final String fatalTopicId = licenseTypeCode.toLowerCase() + '-fatal';
        final fatalQuizzes = examQuizzes.where((quiz) => quiz.topicIds.contains(fatalTopicId)).toList();

        final bool isCorrectFatalQuizzes = fatalQuizzes.isEmpty || fatalQuizzes.every((quiz) {
          final selectedAnswer = widget.selectedAnswers[quiz.id];
          return selectedAnswer != null && selectedAnswer == quiz.correctIndex;
        });
        final bool isPassed = isCorrectFatalQuizzes && _correctQuizzes.length >= config.exam.totalRequiredCorrectQuizzes;
        
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.go(RouteConstants.ROUTE_HOME),
            ),
            title: Text(
              'Kết quả bài thi',
              style: const TextStyle(
                fontSize: APP_BAR_FONT_SIZE,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            backgroundColor: theme.APP_BAR_BG,
            foregroundColor: theme.APP_BAR_FG,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                                 const SizedBox(height: SECTION_SPACING),
                 Center(
                   child: Text(
                     isPassed ? 'ĐẬU' : 'RỚT',
                     style: theme.textTheme.headlineMedium?.copyWith(
                       color: isPassed ? theme.SUCCESS_COLOR : theme.ERROR_COLOR,
                     ),
                   ),
                 ),
                const SizedBox(height: 6),
                Text(
                  'Số câu trả lời đúng: ${_correctQuizzes.length}/${examQuizzes.length}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isCorrectFatalQuizzes) ...[
                  Text(
                    'Bạn đã trả lời sai câu điểm liệt.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.ERROR_COLOR,
                    ),
                  ),
                ],
                const SizedBox(height: SECTION_SPACING),
                Row(
                  children: [
                    Expanded(child: _buildFilterButton('Tất cả', 'all')),
                    Expanded(child: _buildFilterButton('Đúng', 'correct')),
                    Expanded(child: _buildFilterButton('Sai', 'incorrect')),
                    Expanded(child: _buildFilterButton('Chưa làm', 'unanswered')),
                  ],
                ),
                const SizedBox(height: 6),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _getFilteredQuizzes(examQuizzes).length,
                  separatorBuilder: (context, index) => SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final quiz = _getFilteredQuizzes(examQuizzes)[index];
                    final selectedAnswer = widget.selectedAnswers[quiz.id];
                    final isCorrect = selectedAnswer != null && selectedAnswer == quiz.correctIndex;
                    final isUnanswered = selectedAnswer == null;
                    Color tileColor;
                    if (isUnanswered) {
                      tileColor = theme.WARNING_COLOR.withValues(alpha: 0.4);
                    } else if (isCorrect) {
                      tileColor = theme.SUCCESS_COLOR.withValues(alpha: 0.4);
                    } else {
                      tileColor = theme.ERROR_COLOR.withValues(alpha: 0.4);
                    }
                    final examQuizIdx = _examQuizIdToIndex[quiz.id] ?? -1;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(BORDER_RADIUS),
                        color: tileColor,
                      ),
                      child: QuizShortcut(
                        quiz: quiz,
                        quizIndex: examQuizIdx,
                        isSelected: false,
                        onTap: () {
                          context.push(RouteConstants.ROUTE_EXAM_QUIZ, extra: ExamQuizScreenParams(
                            examId: widget.examId,
                            examMode: ExamModes.EXAM_REVIEW_MODE,
                            selectedAnswers: widget.selectedAnswers,
                            startIndex: examQuizIdx,
                          ));
                        },
                        tileColor: null,
                        totalQuizzes: examQuizzes.length,
                        isPracticed: quizzesProgress[quiz.id]?.isPracticed ?? false,
                      ),
                    );
                  },
                ),
                const SizedBox(height: SECTION_SPACING),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final theme = Theme.of(context);
    final bool isSelected = _filter == value;
    Color selectedBg;
    Color selectedFg;
    switch (value) {
      case 'correct':
        selectedBg = theme.SUCCESS_COLOR.withValues(alpha: 0.4);
        selectedFg = theme.SUCCESS_COLOR;
        break;
      case 'incorrect':
        selectedBg = theme.ERROR_COLOR.withValues(alpha: 0.4);
        selectedFg = theme.ERROR_COLOR;
        break;
      case 'unanswered':
        selectedBg = theme.WARNING_COLOR.withValues(alpha: 0.4);
        selectedFg = theme.WARNING_COLOR;
        break;
      case 'all':
      default:
        selectedBg = theme.DARK_SURFACE_VARIANT;
        selectedFg = theme.textTheme.bodyMedium!.color!;
        break;
    }
    return TextButton(
      onPressed: () {
        setState(() {
          _filter = value;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? selectedBg : null,
        foregroundColor: selectedFg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        splashFactory: NoSplash.splashFactory,
      ).copyWith(
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _populateFilteredQuizzes(List<Quiz> quizzes) {
    _correctQuizzes = quizzes.where((quiz) {
      final selected = widget.selectedAnswers[quiz.id];
      return selected != null && selected == quiz.correctIndex;
    }).toList();
    
    _incorrectQuizzes = quizzes.where((quiz) {
      final selected = widget.selectedAnswers[quiz.id];
      return selected != null && selected != quiz.correctIndex;
    }).toList();
    
    _unansweredQuizzes = quizzes.where((quiz) {
      final selected = widget.selectedAnswers[quiz.id];
      return selected == null;
    }).toList();
  }

  List<Quiz> _getFilteredQuizzes(List<Quiz> quizzes) {
    switch (_filter) {
      case 'correct':
        return _correctQuizzes;
      case 'incorrect':
        return _incorrectQuizzes;
      case 'unanswered':
        return _unansweredQuizzes;
      case 'all':
      default:
        return quizzes;
    }
  }
} 