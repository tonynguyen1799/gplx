import 'package:flutter/material.dart';
import '../../models/riverpod/data/quiz.dart';

import '../../widgets/quiz_shortcut.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_data_providers.dart';
import '../../providers/quizzes_progress_provider.dart';
import '../../constants/quiz_constants.dart';
import '../../constants/route_constants.dart';
import '../../utils/app_colors.dart';
import 'package:gplx_vn/constants/navigation_constants.dart';

class ExamSummaryScreen extends StatefulWidget {
  final List<Quiz> quizzes;
  final Map<String, int> selectedAnswers;
  final String licenseTypeCode;
  final String examId;

  const ExamSummaryScreen({
    Key? key,
    required this.quizzes,
    required this.selectedAnswers,
    required this.licenseTypeCode,
    required this.examId,
  }) : super(key: key);

  @override
  State<ExamSummaryScreen> createState() => _ExamSummaryScreenState();
}

class _ExamSummaryScreenState extends State<ExamSummaryScreen> {
  String _filter = 'all';
  
  // Cache for quizId to index in the full quizzes list
  Map<String, int> _quizIdToIndex = {};
  // Cache for quizId to index within this exam's quizzes (order shown during exam)
  Map<String, int> _examQuizIdToIndex = {};

  List<Quiz> get _filteredQuizzes {
    switch (_filter) {
      case 'correct':
        return widget.quizzes.where((quiz) {
          final selected = widget.selectedAnswers[quiz.id];
          return selected != null && selected == quiz.correctIndex;
        }).toList();
      case 'incorrect':
        return widget.quizzes.where((quiz) {
          final selected = widget.selectedAnswers[quiz.id];
          return selected != null && selected != quiz.correctIndex;
        }).toList();
      case 'unanswered':
        return widget.quizzes.where((quiz) {
          final selected = widget.selectedAnswers[quiz.id];
          return selected == null;
        }).toList();
      case 'all':
      default:
        return widget.quizzes;
    }
  }
  
  void _buildQuizIdToIndexMap(List<Quiz> allQuizzes) {
    _quizIdToIndex = {for (int i = 0; i < allQuizzes.length; i++) allQuizzes[i].id: i};
  }

  void _buildExamQuizIdToIndexMap(List<Quiz> examQuizzes) {
    _examQuizIdToIndex = {for (int i = 0; i < examQuizzes.length; i++) examQuizzes[i].id: i};
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(
      builder: (context, ref, _) {
        final asyncConfig = ref.watch(configProvider);
        
        return asyncConfig.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) => Scaffold(body: Center(child: Text('Lỗi khi tải dữ liệu: $err'))),
                      data: (config) {
              final minCorrect = config.exam.totalRequiredCorrectQuizzes;
            
            int correctCount = 0;
            for (final quiz in widget.quizzes) {
              final selected = widget.selectedAnswers[quiz.id];
              if (selected != null && selected == quiz.correctIndex) {
                correctCount++;
              }
            }
            
            final statusMap = ref.watch(quizzesProgressProvider)[widget.licenseTypeCode] ?? {};
            // Check for fatal quiz answered incorrectly
            final String fatalTopicId = widget.licenseTypeCode.toLowerCase() + '-fatal';
            final fatalQuizzes = widget.quizzes.where((quiz) => quiz.topicIds.contains(fatalTopicId)).toList();
            bool hasFatal = fatalQuizzes.isNotEmpty;
            // Pass if all fatal quizzes are answered correctly and correctCount >= minCorrect
            final bool allFatalCorrect = fatalQuizzes.isEmpty || fatalQuizzes.every((quiz) {
              final selected = widget.selectedAnswers[quiz.id];
              return selected != null && selected == quiz.correctIndex;
            });
            final bool isPassed = allFatalCorrect && correctCount >= minCorrect;
            
            // Build the exam-specific index map so numbering remains correct when filtering
            _buildExamQuizIdToIndexMap(widget.quizzes);
            
            return Scaffold(
              appBar: AppBar(
                title: const Text('Kết quả bài thi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                      context.go('/main', extra: {'initialIndex': MainNav.TAB_HOME});
                    },
                ),
                backgroundColor: theme.appBarBackground,
                foregroundColor: theme.appBarText,
                elevation: 0,
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      Text(
                        isPassed ? 'ĐẬU' : 'RỚT',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: isPassed ? theme.successColor : theme.errorColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Show number of correct quizzes over total
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Số câu trả lời đúng $correctCount/${widget.quizzes.length}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: theme.primaryText,
                          ),
                        ),
                      ),
                      if (hasFatal) ...[
                        const SizedBox(height: 12),
                        if (!allFatalCorrect)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Bạn đã trả lời sai câu điểm liệt',
                              style: TextStyle(
                                color: theme.errorColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                      const SizedBox(height: 12),
                      // Filter bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: _buildFilterButton('Tất cả', 'all')),
                          Expanded(child: _buildFilterButton('Câu đúng', 'correct')),
                          Expanded(child: _buildFilterButton('Câu sai', 'incorrect')),
                          Expanded(child: _buildFilterButton('Chưa làm', 'unanswered')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Quiz shortcut list
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredQuizzes.length,
                        separatorBuilder: (context, idx) => SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final quiz = _filteredQuizzes[idx];
                          final selected = widget.selectedAnswers[quiz.id];
                          final isCorrect = selected != null && selected == quiz.correctIndex;
                          final isUnanswered = selected == null;
                          Color tileColor;
                          if (isUnanswered) {
                            tileColor = theme.warningColor.withOpacity(0.2);
                          } else if (isCorrect) {
                            tileColor = theme.successColor.withOpacity(theme.brightness == Brightness.dark ? 0.35 : 0.2);
                          } else {
                            tileColor = theme.errorColor.withOpacity(theme.brightness == Brightness.dark ? 0.35 : 0.2);
                          }
                          final originalIndex = _quizIdToIndex[quiz.id] ?? -1;
                          final examIndex = _examQuizIdToIndex[quiz.id] ?? -1;
                          return QuizShortcut(
                            quiz: quiz,
                            index: examIndex,
                            originalIndex: originalIndex,
                            selected: false,
                            onTap: () {
                              context.push(RouteConstants.ROUTE_EXAM_QUIZ, extra: {
                                'selectedAnswers': widget.selectedAnswers,
                                'licenseTypeCode': widget.licenseTypeCode,
                                'examId': widget.examId,
                                'startIndex': examIndex,
                                'reviewMode': true,
                              });
                            },
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            tileColor: tileColor,
                            totalQuizzes: widget.quizzes.length,
                            practiced: statusMap[quiz.id]?.isPracticed ?? false,
                          );
                        },
                      ),
                    ],
                    ),
                ),
              ),
            );
          },
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
        selectedBg = theme.brightness == Brightness.dark ? Colors.green.shade900 : Colors.green.shade50;
        selectedFg = theme.successColor;
        break;
      case 'incorrect':
        selectedBg = theme.brightness == Brightness.dark ? Colors.red.shade900 : Colors.red.shade50;
        selectedFg = theme.errorColor;
        break;
      case 'unanswered':
        selectedBg = theme.brightness == Brightness.dark ? Colors.orange.shade900 : Colors.orange.shade50;
        selectedFg = theme.warningColor;
        break;
      case 'all':
      default:
        selectedBg = theme.brightness == Brightness.dark ? Colors.blue.shade900 : Colors.blue.shade50;
        selectedFg = theme.primaryColor;
        break;
    }
    return TextButton(
      onPressed: () {
        setState(() {
          _filter = value;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? selectedBg : theme.cardColor,
        foregroundColor: isSelected ? selectedFg : theme.primaryText,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        splashFactory: NoSplash.splashFactory,
      ).copyWith(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
} 