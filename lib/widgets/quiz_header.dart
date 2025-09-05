import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import '../../constants/app_colors.dart';

class QuizHeader extends StatelessWidget {
  final int quizIndex;
  final int totalQuizzes;
  final String licenseTypeCode;
  final int quizIdx;
  final bool isPracticed;
  final Widget? trailing;

  const QuizHeader({
    Key? key,
    required this.quizIndex,
    required this.totalQuizzes,
    required this.licenseTypeCode,
    required this.quizIdx,
    required this.isPracticed,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Câu ${quizIndex + 1}/$totalQuizzes',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: SUB_SECTION_SPACING),
            Text(
              '[${licenseTypeCode}.${quizIdx}]',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
            if (isPracticed) ...[
              const SizedBox(width: SUB_SECTION_SPACING),
              Text(
                '|',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: SUB_SECTION_SPACING),
              Text(
                'đã học',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: SUB_SECTION_SPACING),
              Icon(Icons.check_circle, color: theme.SUCCESS_COLOR, size: 16),
            ],
          ],
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}


