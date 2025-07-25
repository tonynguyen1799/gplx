import 'package:flutter/material.dart';
import '../../models/quiz.dart';

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
    Color? bgColor;
    Color? textColor;
    BoxBorder? border;
    Color? borderColor;
    if (reviewMode) {
      if (isUnanswered) {
        bgColor = Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey.shade200;
        textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
        borderColor = Theme.of(context).brightness == Brightness.dark ? Colors.grey[600] : Colors.grey;
      } else if (isCorrect) {
        bgColor = Theme.of(context).brightness == Brightness.dark ? Colors.green.shade900 : Colors.green.shade100;
        textColor = Theme.of(context).brightness == Brightness.dark ? Colors.greenAccent : Colors.green;
        borderColor = Theme.of(context).brightness == Brightness.dark ? Colors.greenAccent : Colors.green;
      } else {
        bgColor = Theme.of(context).brightness == Brightness.dark ? Colors.red.shade900 : Colors.red.shade100;
        textColor = Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : Colors.red;
        borderColor = Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : Colors.red;
      }
    } else if (isQuickExam && isAnswered) {
      if (selectedIdx == quiz.correctIndex) {
        bgColor = Theme.of(context).brightness == Brightness.dark ? Colors.green.shade900 : Colors.green.shade100;
        textColor = Theme.of(context).brightness == Brightness.dark ? Colors.greenAccent : Colors.green;
        borderColor = Theme.of(context).brightness == Brightness.dark ? Colors.greenAccent : Colors.green;
      } else {
        bgColor = Theme.of(context).brightness == Brightness.dark ? Colors.red.shade900 : Colors.red.shade100;
        textColor = Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : Colors.red;
        borderColor = Theme.of(context).brightness == Brightness.dark ? Colors.redAccent : Colors.red;
      }
    } else if (isAnswered) {
      bgColor = Theme.of(context).brightness == Brightness.dark ? Colors.blue.shade900 : Colors.blue.shade100;
      textColor = Theme.of(context).brightness == Brightness.dark ? Colors.blueAccent : Colors.blue;
      borderColor = Theme.of(context).brightness == Brightness.dark ? Colors.blueAccent : Colors.blue;
    } else {
      bgColor = Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey.shade200;
      textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey;
      borderColor = Theme.of(context).brightness == Brightness.dark ? Colors.grey[600] : Colors.grey;
    }
    if (idx == currentIndex) {
      if (!isQuickExam && !reviewMode &!isAnswered) {
        textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;
        borderColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey;
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