import 'package:flutter/material.dart';
import '../models/riverpod/data/quiz.dart';
import '../constants/app_colors.dart';
import '../constants/ui_constants.dart';
import 'quiz_header.dart';

class QuizShortcut extends StatelessWidget {
  final Quiz quiz;
  final int quizIndex;
  final int totalQuizzes;
  final bool isPracticed;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? tileColor;

  const QuizShortcut({
    Key? key,
    required this.quiz,
    required this.quizIndex,
    required this.totalQuizzes,
    required this.isPracticed,
    required this.isSelected,
    required this.onTap,
    this.tileColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.all(CONTENT_PADDING),
      tileColor: tileColor ?? Colors.transparent,
      selectedTileColor: theme.BLUE_COLOR.withValues(alpha: 0.2),
      shape: isSelected ? RoundedRectangleBorder(
        side: BorderSide(color: theme.BLUE_COLOR, width: 1),
        borderRadius: BorderRadius.zero,
      ) : null,
      title: QuizHeader(
        quizIndex: quizIndex,
        totalQuizzes: totalQuizzes,
        licenseTypeCode: quiz.licenseTypeCode,
        quizIdx: quiz.index,
        isPracticed: isPracticed,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  quiz.text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: SUB_SECTION_SPACING),
              if (quiz.imageUrl != null && quiz.imageUrl!.isNotEmpty)
                SizedBox(
                  height: SECTION_SPACING * 5,
                  child: Image.asset(
                    'assets/images/quizzes/${quiz.imageUrl!}',
                    fit: BoxFit.fitHeight,
                  ),
                ),
            ],
          ),
          if (quiz.topicIds.any((id) => id.endsWith('-fatal')))
            Padding(
              padding: const EdgeInsets.only(top: SUB_SECTION_SPACING),
              child: Text(
                'Câu điểm liệt',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.FALTA_COLOR,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      trailing: null,
      selected: isSelected,
    );
  }
} 