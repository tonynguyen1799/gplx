import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/quiz_constants.dart';
import 'package:gplx_vn/constants/ui_constants.dart';

class ExamQuizJumpButton extends StatelessWidget {
  final int idx;
  final bool isSelected;
  final bool isAnswered;
  final bool isCorrect;
  final int mode;
  final VoidCallback onTap;

  const ExamQuizJumpButton({
    required this.idx,
    required this.isSelected,
    required this.isAnswered,
    required this.onTap,
    required this.mode,
    this.isCorrect = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? backgroundColor;
    Color? borderColor;
    
    bool isUnanswered = !isAnswered;
    bool isIncorrect = !isCorrect;
    switch (mode) {
      case ExamModes.EXAM_REVIEW_MODE:
      case ExamModes.EXAM_QUICK_MODE:
        if (isUnanswered) {
          borderColor = theme.textTheme.bodyMedium!.color;
        } else if (isCorrect) {
          backgroundColor = theme.SUCCESS_COLOR.withValues(alpha: 0.4);
          borderColor = theme.SUCCESS_COLOR;
        } else if (isIncorrect) {
          backgroundColor = theme.ERROR_COLOR.withValues(alpha: 0.4);
          borderColor = theme.ERROR_COLOR;
        }
        break;
      case ExamModes.EXAM_NORMAL_MODE:
        if (isAnswered) {
          backgroundColor = theme.BLUE_COLOR;
        } else {
          backgroundColor = theme.SURFACE_VARIANT;
          borderColor = theme.textTheme.bodyMedium!.color;
        }
        break;
    }
    
    BoxBorder? border;
    if (isSelected) {
      border = Border.all(color: borderColor ?? Colors.blue, width: 2);
    }
    
    return SizedBox(
      width: LARGE_ICON_SIZE,
      height: LARGE_ICON_SIZE,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
          borderRadius: BorderRadius.zero,
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          onPressed: onTap,
          child: Text(
            '${idx + 1}',
            style: theme.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
} 