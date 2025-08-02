import 'package:flutter/material.dart';
import '../models/question_progress.dart';
import '../utils/app_colors.dart';

class StudyProgressSection extends StatelessWidget {
  final int total;
  final QuestionProgress progress;
  final VoidCallback? onTap;
  final Map<String, dynamic>? statusMap;
  const StudyProgressSection({super.key, required this.total, required this.progress, this.onTap, this.statusMap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quizTotal = total;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.studyProgressBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: Colors.amber,
              width: 6,
            ),
          ),
        ),
        child: 
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tiến độ học tập',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.studyProgressTitle,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Left side
                Expanded(
                  flex: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${progress.practiced} / $quizTotal câu đã luyện',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.studyProgressText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: quizTotal == 0 ? 0 : progress.practiced / quizTotal,
                          minHeight: 8,
                          backgroundColor: theme.studyProgressBarBackground,
                          valueColor: AlwaysStoppedAnimation(
                            theme.studyProgressBarColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Đúng ${progress.correct}    Sai ${progress.incorrect}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.studyProgressStats,
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 1,
                  height: 60,
                  color: theme.dividerColor,
                ),
                // Right side
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      const Icon(Icons.insights, size: 24, color: Colors.blue),
                      const SizedBox(height: 6),
                      Text(
                        quizTotal == 0 ? '0%' : '${((progress.practiced / quizTotal) * 100).round()}%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.studyProgressPercentage,
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
