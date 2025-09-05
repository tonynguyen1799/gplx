import 'package:flutter/material.dart';
import 'package:gplx_vn/models/hive/quiz_progress.dart';
import 'package:gplx_vn/constants/ui_constants.dart';
import 'package:gplx_vn/models/riverpod/quizzes_progress.dart';
import 'package:gplx_vn/constants/app_colors.dart';

class TotalQuizzesProgress extends StatelessWidget {
  final int totalQuizzes;
  final QuizzesProgress quizzesProgress;
  final VoidCallback? onTap;
  const TotalQuizzesProgress({
    super.key,
    required this.totalQuizzes,
    required this.quizzesProgress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(CONTENT_PADDING),
        decoration: BoxDecoration(
          color: theme.SURFACE_VARIANT,
          borderRadius: BorderRadius.circular(BORDER_RADIUS),
          border: Border(
            left: BorderSide(
              color: Colors.amber,
              width: 4.0,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiến hành ôn luyện',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SECTION_SPACING),
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${quizzesProgress.totalPracticedQuizzes} / $totalQuizzes câu đã luyện',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: SUB_SECTION_SPACING),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
                        child: LinearProgressIndicator(
                          value: totalQuizzes == 0 ? 0 : quizzesProgress.totalPracticedQuizzes / totalQuizzes,
                          minHeight: 6.0,
                          backgroundColor: theme.PROGRESS_BAR_BG,
                          valueColor: AlwaysStoppedAnimation(
                            theme.PROGRESS_BAR_FG,
                          ),
                        ),
                      ),
                      const SizedBox(height: SUB_SECTION_SPACING),
                      Row(
                        children: [
                          Text(
                            'Đúng ${quizzesProgress.totalCorrectQuizzes}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: SECTION_SPACING * 2),
                          Text(
                            'Sai ${quizzesProgress.totalIncorrectQuizzes}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: SECTION_SPACING),
                  width: 1,
                  height: 60,
                  color: theme.dividerColor,
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Icon(Icons.insights, color: Colors.blue),
                      const SizedBox(height: SUB_SECTION_SPACING),
                      Text(
                        totalQuizzes == 0 ? '0%' : '${((quizzesProgress.totalPracticedQuizzes / totalQuizzes) * 100).round()}%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ]
        ),
      ),
    );
  }
}
