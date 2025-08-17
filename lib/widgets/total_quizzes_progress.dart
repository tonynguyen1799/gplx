import 'package:flutter/material.dart';
import 'package:gplx_vn/models/hive/quiz_progress.dart';
import 'package:gplx_vn/models/riverpod/quizzes_progress.dart';
import 'package:gplx_vn/utils/app_colors.dart';

class _TotalQuizzesProgressConstants {
  static const double contentPadding = 16.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 6.0;
  static const double leftBorderWidth = 6.0;
  static const double sectionSpacing = 12.0;
  static const double subSectionSpacing = 6.0;
  static const double progressBarHeight = 8.0;

  static const String title = 'Tiến độ học tập';
  static const String progressText = 'câu đã luyện';
  static const String correctText = 'Đúng';
  static const String incorrectText = 'Sai';
}

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
        padding: const EdgeInsets.all(_TotalQuizzesProgressConstants.contentPadding),
        decoration: BoxDecoration(
          color: theme.SURFACE_VARIANT,
          borderRadius: BorderRadius.circular(_TotalQuizzesProgressConstants.borderRadius),
          border: Border(
            left: BorderSide(
              color: Colors.amber,
              width: _TotalQuizzesProgressConstants.leftBorderWidth,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _TotalQuizzesProgressConstants.title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: _TotalQuizzesProgressConstants.sectionSpacing),
            Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${quizzesProgress.totalPracticedQuizzes} / $totalQuizzes ${_TotalQuizzesProgressConstants.progressText}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: _TotalQuizzesProgressConstants.subSectionSpacing),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(_TotalQuizzesProgressConstants.smallBorderRadius),
                        child: LinearProgressIndicator(
                          value: totalQuizzes == 0 ? 0 : quizzesProgress.totalPracticedQuizzes / totalQuizzes,
                          minHeight: _TotalQuizzesProgressConstants.progressBarHeight,
                          backgroundColor: theme.PROGRESS_BAR_BG,
                          valueColor: AlwaysStoppedAnimation(
                            theme.PROGRESS_BAR_FG,
                          ),
                        ),
                      ),
                      const SizedBox(height: _TotalQuizzesProgressConstants.subSectionSpacing),
                      Row(
                        children: [
                          Text(
                            '${_TotalQuizzesProgressConstants.correctText} ${quizzesProgress.totalCorrectQuizzes}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: _TotalQuizzesProgressConstants.sectionSpacing * 2),
                          Text(
                            '${_TotalQuizzesProgressConstants.incorrectText} ${quizzesProgress.totalIncorrectQuizzes}',
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
                  margin: const EdgeInsets.symmetric(horizontal: _TotalQuizzesProgressConstants.sectionSpacing),
                  width: 1,
                  height: 60,
                  color: theme.dividerColor,
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Icon(Icons.insights, color: Colors.blue),
                      const SizedBox(height: _TotalQuizzesProgressConstants.subSectionSpacing),
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
