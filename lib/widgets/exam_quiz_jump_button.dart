import 'package:flutter/material.dart';
import '../../models/riverpod/data/quiz.dart';
import '../../utils/app_colors.dart';

class ExamQuizJumpButton extends StatelessWidget {
  final int idx;
  final int currentIndex;
  final Quiz quiz;
  final bool isAnswered;
  final bool isQuickExam;
  final int? selectedIdx;
  final VoidCallback onTap;
  final bool reviewMode;
  final bool isCorrect;
  final bool isUnanswered;

  const ExamQuizJumpButton({
    required this.idx,
    required this.currentIndex,
    required this.quiz,
    required this.isAnswered,
    required this.isQuickExam,
    required this.selectedIdx,
    required this.onTap,
    this.reviewMode = false,
    this.isCorrect = false,
    this.isUnanswered = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? bgColor;
    Color? textColor;
    BoxBorder? border;
    Color? borderColor;
    if (reviewMode) {
      if (isUnanswered) {
        bgColor = theme.examJumpUnansweredBackground;
        textColor = theme.examJumpUnansweredText;
        borderColor = theme.examJumpUnansweredBorder;
      } else if (isCorrect) {
        bgColor = theme.examJumpCorrectBackground;
        textColor = theme.examJumpCorrectText;
        borderColor = theme.examJumpCorrectBorder;
      } else {
        bgColor = theme.examJumpIncorrectBackground;
        textColor = theme.examJumpIncorrectText;
        borderColor = theme.examJumpIncorrectBorder;
      }
    } else if (isQuickExam && isAnswered) {
      if (selectedIdx == quiz.correctIndex) {
        bgColor = theme.examJumpCorrectBackground;
        textColor = theme.examJumpCorrectText;
        borderColor = theme.examJumpCorrectBorder;
      } else {
        bgColor = theme.examJumpIncorrectBackground;
        textColor = theme.examJumpIncorrectText;
        borderColor = theme.examJumpIncorrectBorder;
      }
    } else if (isAnswered) {
      bgColor = theme.examJumpAnsweredBackground;
      textColor = theme.examJumpAnsweredText;
      borderColor = theme.examJumpAnsweredBorder;
    } else {
      bgColor = theme.examJumpUnansweredBackground;
      textColor = theme.examJumpUnansweredText;
      borderColor = theme.examJumpUnansweredBorder;
    }
    if (idx == currentIndex) {
      if (!isQuickExam && !reviewMode && !isAnswered) {
        textColor = theme.examJumpCurrentText;
        borderColor = theme.examJumpCurrentBorder;
      }
      border = Border.all(color: borderColor ?? Colors.blue, width: 2);
    }
    return SizedBox(
      width: 28,
      height: 28,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: border,
          borderRadius: BorderRadius.zero,
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: EdgeInsets.zero,
          ),
          onPressed: onTap,
          child: Text(
            '${idx + 1}',
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
} 