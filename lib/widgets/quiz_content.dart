import 'package:flutter/material.dart';
import '../../models/quiz.dart';
import '../../models/quiz_practice_status.dart';
import '../../models/license_type.dart';
import '../../models/topic.dart';
import 'bookmark_button.dart';
import '../../utils/app_colors.dart';

class QuizContent extends StatelessWidget {
  final Quiz quiz;
  final int quizIndex;
  final int totalQuizzes;
  final String licenseTypeCode;
  final QuizPracticeStatus? status;
  final VoidCallback onBookmarkChanged;
  final String? fatalTopicId;
  final String? quizCode;
  final String? mode;

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
                  if (status?.practiced == true)
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
            Image.asset('assets/images/' + quiz.imageUrl!),
          ],
        ],
      ),
    );
  }
} 