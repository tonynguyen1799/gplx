import 'package:flutter/material.dart';
import '../../models/riverpod/data/quiz.dart';
import '../../models/hive/quiz_progress.dart';
import '../../constants/app_colors.dart';
import '../../constants/ui_constants.dart';
import 'quiz_header.dart';
import 'bookmark_button.dart';

class QuizContent extends StatelessWidget {
  final Quiz quiz;
  final int quizIndex;
  final int totalQuizzes;
  final QuizProgress? quizProgress;

  const QuizContent({
    Key? key,
    required this.quiz,
    required this.quizIndex,
    required this.totalQuizzes,
    required this.quizProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuizHeader(
            quizIndex: quizIndex,
            totalQuizzes: totalQuizzes,
            licenseTypeCode: quiz.licenseTypeCode,
            quizIdx: quiz.index,
            isPracticed: quizProgress?.isPracticed == true,
            trailing: BookmarkButton(
              key: ValueKey(quiz.id),
              quizId: quiz.id,
              licenseTypeCode: quiz.licenseTypeCode,
            ),
          ),
          Text(
            quiz.text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              // color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
            ),
          ),
          if (quiz.imageUrl != null && quiz.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: SECTION_SPACING),
            Image.asset('assets/images/quizzes/${quiz.imageUrl!}'),
          ],
        ],
      ),
    );
  }
}