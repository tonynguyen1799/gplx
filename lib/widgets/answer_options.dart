import 'package:flutter/material.dart';
import '../../utils/quiz_constants.dart';

class AnswerOptions extends StatelessWidget {
  final List<String> answers;
  final int correctIndex;
  final Future<void> Function(int index) onSelect;
  final bool showExplanation;
  final String? explanation;
  final String mode;
  final bool lockAnswer;
  final int? selectedIndex;
  final bool isFatalQuiz;
  final String examMode;

  const AnswerOptions({
    Key? key,
    required this.answers,
    required this.correctIndex,
    required this.onSelect,
    this.showExplanation = false,
    this.explanation,
    required this.mode,
    this.lockAnswer = false,
    this.selectedIndex,
    required this.isFatalQuiz,
    required this.examMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isTrainingMode = mode == QuizModes.TRAINING_MODE || mode == QuizModes.TRAINING_BY_TOPIC_MODE;
    final isQuickExamMode = mode == QuizModes.EXAM_MODE && examMode == ExamModes.EXAM_QUICK_MODE;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < answers.length; i++)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: ((isTrainingMode || isQuickExamMode)
                      ? (selectedIndex == null ? () => onSelect(i) : null)
                      : (!lockAnswer ? () => onSelect(i) : null)),
            child: Container(
                width: double.infinity,
                color: selectedIndex != null
                    ? (isTrainingMode || showExplanation
                        ? (i == correctIndex
                            ? (Theme.of(context).brightness == Brightness.dark ? Colors.green.shade900 : Colors.green.shade100)
                            : selectedIndex == i
                                ? (Theme.of(context).brightness == Brightness.dark ? Colors.red.shade900 : Colors.red.shade100)
                                : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : null))
                        : (selectedIndex == i ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.grey.shade300) : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : null)))
                    : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : null),
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IgnorePointer(
                    child: Icon(
                        selectedIndex == i
                            ? (isTrainingMode || showExplanation
                                ? (i == correctIndex ? Icons.check_circle : Icons.cancel)
                              : Icons.radio_button_checked)
                            : (isTrainingMode || showExplanation
                                ? Icons.circle_outlined
                                : Icons.radio_button_unchecked),
                        color: (isTrainingMode || showExplanation)
                            ? (selectedIndex == i
                                ? (i == correctIndex
                                    ? (Theme.of(context).brightness == Brightness.dark ? Colors.greenAccent : Colors.green)
                                    : (Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : Colors.red))
                                : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black))
                          : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                      '${i + 1}. ${answers[i]}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
                    ),
                  )),
                ],
              ),
            ),
          ),
          ),
        if (selectedIndex != null && explanation != null && showExplanation) ...[
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFatalQuiz)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Đây là câu điểm liệt',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  if (selectedIndex == -1) ...[
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Bạn không làm câu này',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                  Row(
                    children: [
                      Icon(
                        selectedIndex == correctIndex ? Icons.check_circle : Icons.cancel,
                        color: selectedIndex == correctIndex ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedIndex == correctIndex ? 'Bạn đã chọn đúng' : 'Bạn đã chọn sai',
                        style: TextStyle(
                          color: selectedIndex == correctIndex ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      ),
                    ],
                  const SizedBox(height: 8),
                  Text(
                    'Đáp án đúng: số  ${correctIndex + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    explanation!,
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
} 