import 'package:flutter/material.dart';
import '../models/riverpod/data/quiz.dart';
import '../models/hive/quiz_progress.dart';
import '../constants/ui_constants.dart';
import 'quiz_shortcut.dart';

class QuizShortcutsBottomSheet extends StatelessWidget {
  final List<Quiz> quizzes;
  final int currentIndex;
  final Map<String, QuizProgress>? quizzesProgress;
  final double heightRatio;

  const QuizShortcutsBottomSheet({
    super.key,
    required this.quizzes,
    required this.currentIndex,
    this.quizzesProgress,
    this.heightRatio = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * heightRatio,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: CONTENT_PADDING),
              child: Text(
                'Chọn câu hỏi',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: quizzes.length,
                separatorBuilder: (context, idx) => const Divider(height: 1),
                itemBuilder: (context, idx) {
                  final quiz = quizzes[idx];
                  return QuizShortcut(
                    quiz: quiz,
                    quizIndex: idx,
                    isSelected: idx == currentIndex,
                    onTap: () => Navigator.pop(context, idx),
                    totalQuizzes: quizzes.length,
                    isPracticed: quizzesProgress?[quiz.id]?.isPracticed == true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
