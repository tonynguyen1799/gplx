import 'package:flutter/material.dart';
import '../models/question_progress.dart';

class StudyProgressSection extends StatelessWidget {
  final int total;
  final QuestionProgress progress;
  final VoidCallback? onTap;
  final Map<String, dynamic>? statusMap;
  const StudyProgressSection({super.key, required this.total, required this.progress, this.onTap, this.statusMap});

  @override
  Widget build(BuildContext context) {
    final quizTotal = total;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[850]
              : Colors.grey.shade100,
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
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : null,
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
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: quizTotal == 0 ? 0 : progress.practiced / quizTotal,
                          minHeight: 8,
                          backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[600] : Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).brightness == Brightness.dark ? Colors.amber : Colors.blue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Đúng ${progress.correct}    Sai ${progress.incorrect}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey.shade500,
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
                  color: Theme.of(context).colorScheme.outline,
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
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
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
