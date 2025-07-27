import 'package:flutter/material.dart';
import '../../utils/quiz_constants.dart';
import '../../utils/app_colors.dart';

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

  Color _getAnswerOptionColor(ThemeData theme, int index, int? selectedIndex, bool isTrainingMode, bool showExplanation, int correctIndex) {
    if (selectedIndex == null) {
      return theme.answerOptionBackground;
    }
    
    if (isTrainingMode || showExplanation) {
      if (index == correctIndex) {
        return theme.answerOptionCorrect;
      } else if (selectedIndex == index) {
        return theme.answerOptionIncorrect;
      } else {
        return theme.answerOptionBackground;
      }
    } else {
      if (selectedIndex == index) {
        return theme.answerOptionSelected;
      } else {
        return theme.answerOptionBackground;
      }
    }
  }

  Color _getAnswerOptionIconColor(ThemeData theme, int index, int? selectedIndex, bool isTrainingMode, bool showExplanation, int correctIndex) {
    if (isTrainingMode || showExplanation) {
      if (selectedIndex == index) {
        if (index == correctIndex) {
          return theme.answerOptionIconCorrect;
        } else {
          return theme.answerOptionIconIncorrect;
        }
      } else {
        return theme.answerOptionIcon;
      }
    } else {
      return theme.answerOptionIcon;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                color: _getAnswerOptionColor(theme, i, selectedIndex, isTrainingMode, showExplanation, correctIndex),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                        color: _getAnswerOptionIconColor(theme, i, selectedIndex, isTrainingMode, showExplanation, correctIndex),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(
                      '${i + 1}. ${answers[i]}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.answerOptionText,
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
                color: theme.answerExplanationBackground,
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
                          color: theme.errorColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  if (selectedIndex == -1) ...[
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: theme.warningColor),
                        const SizedBox(width: 8),
                        Text(
                          'Bạn không làm câu này',
                          style: TextStyle(
                            color: theme.warningColor,
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
                        color: selectedIndex == correctIndex ? theme.answerOptionIconCorrect : theme.answerOptionIconIncorrect,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedIndex == correctIndex ? 'Bạn đã chọn đúng' : 'Bạn đã chọn sai',
                        style: TextStyle(
                          color: selectedIndex == correctIndex ? theme.answerOptionIconCorrect : theme.answerOptionIconIncorrect,
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
                      color: theme.answerExplanationText,
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