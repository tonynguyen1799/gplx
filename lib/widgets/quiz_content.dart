import 'package:flutter/material.dart';
import '../../models/riverpod/data/quiz.dart';
import '../../models/hive/quiz_progress.dart';
import '../../models/riverpod/data/license_type.dart';
import '../../models/riverpod/data/topic.dart';
import 'bookmark_button.dart';
import '../../utils/app_colors.dart';

class QuizContent extends StatelessWidget {
  final Quiz quiz;
  final int quizIndex;
  final int totalQuizzes;
  final String licenseTypeCode;
  final QuizProgress? status;
  final VoidCallback onBookmarkChanged;
  final String? fatalTopicId;
  final String? quizCode;
  final int? mode;

  const QuizContent({
    Key? key,
    required this.quiz,
    required this.quizIndex,
    required this.totalQuizzes,
    required this.licenseTypeCode,
    required this.status,
    required this.onBookmarkChanged,
    this.fatalTopicId,
    this.quizCode,
    this.mode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Câu ${quizIndex + 1}/$totalQuizzes  [${quizCode}]',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.quizContentHeader),
                  ),
                  const SizedBox(width: 4),
                  if (status?.isPracticed == true)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '| đã học',
                          style: TextStyle(color: theme.quizContentPracticed, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.check_circle, color: theme.quizContentCheckIcon, size: 18),
                      ],
                    ),
                ],
              ),
              BookmarkButton(
                key: ValueKey(quiz.id),
                quizId: quiz.id,
                licenseTypeCode: licenseTypeCode,
              ),
            ],
          ),
          Text(
            quiz.text,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.quizContentText),
          ),
          if (quiz.imageUrl != null && quiz.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Image.asset('assets/images/quizzes/' + quiz.imageUrl!),
          ],
        ],
      ),
    );
  }
} 