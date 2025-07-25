import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../widgets/quiz_shortcut.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/app_data_providers.dart';
import '../../utils/quiz_constants.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
    int correctCount = 0;
        for (final quiz in widget.quizzes) {
          final selected = widget.selectedAnswers[quiz.id];
      if (selected != null && selected == quiz.correctIndex) {
        correctCount++;
      }
    }
        final configs = ref.watch(configsProvider);
        final config = configs[widget.licenseTypeCode] ?? {};
        final minCorrect = config['exam']?['numberOfRequiredCorrectQuizzes'] ?? 0;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả bài thi', style: TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : null,
        foregroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              Text(
                isPassed ? 'ĐẬU' : 'RỚT',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: isPassed
                      ? (Theme.of(context).brightness == Brightness.dark ? Colors.greenAccent : Colors.green)
                      : (Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : Colors.red),
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
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
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
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : Colors.red,
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
                    tileColor = Colors.orangeAccent.withOpacity(0.2);
                  } else if (isCorrect) {
                    tileColor = Theme.of(context).brightness == Brightness.dark
                        ? Colors.greenAccent.withOpacity(0.35)
                        : Colors.greenAccent.withOpacity(0.2);
                  } else {
                    tileColor = Theme.of(context).brightness == Brightness.dark
                        ? Colors.redAccent.withOpacity(0.35)
                        : Colors.redAccent.withOpacity(0.2);
                  }
                  final originalIndex = widget.quizzes.indexWhere((q) => q.id == quiz.id);
                  return QuizShortcut(
                    quiz: quiz,
                    index: originalIndex,
                    originalIndex: originalIndex,
                    selected: false,
                    onTap: () {
                      context.push('/exam-quiz', extra: {
                        'mode': QuizModes.EXAM_MODE,
                        'selectedAnswers': widget.selectedAnswers,
                        'licenseTypeCode': widget.licenseTypeCode,
                        'examId': widget.examId,
                        'startIndex': originalIndex,
                        'reviewMode': true,
                      });
                    },
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    tileColor: tileColor,
                    totalQuizzes: widget.quizzes.length,
                    practiced: selected != null,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
            ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final bool isSelected = _filter == value;
    Color selectedBg;
    Color selectedFg;
    switch (value) {
      case 'correct':
        selectedBg = Theme.of(context).brightness == Brightness.dark ? Colors.green.shade900 : Colors.green.shade50;
        selectedFg = Theme.of(context).brightness == Brightness.dark ? Colors.greenAccent : Colors.green;
        break;
      case 'incorrect':
        selectedBg = Theme.of(context).brightness == Brightness.dark ? Colors.red.shade900 : Colors.red.shade50;
        selectedFg = Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : Colors.red;
        break;
      case 'unanswered':
        selectedBg = Theme.of(context).brightness == Brightness.dark ? Colors.orange.shade900 : Colors.orange.shade50;
        selectedFg = Theme.of(context).brightness == Brightness.dark ? Colors.orangeAccent : Colors.orange;
        break;
      case 'all':
      default:
        selectedBg = Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade900 : Colors.blue.shade50;
        selectedFg = Theme.of(context).brightness == Brightness.dark ? Colors.blueAccent : Colors.blue;
        break;
    }
    return TextButton(
      onPressed: () {
        setState(() {
          _filter = value;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? selectedBg : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white),
        foregroundColor: isSelected ? selectedFg : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
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