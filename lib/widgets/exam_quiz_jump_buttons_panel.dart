import 'package:flutter/material.dart';
import '../../models/riverpod/data/quiz.dart';
import 'exam_quiz_jump_button.dart';

class ExamQuizJumpButtonsPanel extends StatelessWidget {
  final List<Quiz> quizzes;
  final Map<String, int> selectedAnswers;
  final int currentIndex;
  final int mode;
  final ValueChanged<int> onJump;

  const ExamQuizJumpButtonsPanel({
    super.key,
    required this.quizzes,
    required this.selectedAnswers,
    required this.currentIndex,
    required this.mode,
    required this.onJump,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 0,
        runSpacing: 0,
        children: List.generate(
          quizzes.length,
          (idx) {
            final quizId = quizzes[idx].id;
            final isAnswered = selectedAnswers.containsKey(quizId);
            final selectedIdx = selectedAnswers[quizId];
            final bool isCorrect = isAnswered && selectedIdx == quizzes[idx].correctIndex;
            return ExamQuizJumpButton(
              idx: idx,
              isSelected: idx == currentIndex,
              isAnswered: isAnswered,
              onTap: () => onJump(idx),
              mode: mode,
              isCorrect: isCorrect,
            );
          },
        ),
      ),
    );
  }
}


