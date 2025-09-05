import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quizzes_progress_provider.dart';
import '../models/hive/quiz_progress.dart';
import '../constants/app_colors.dart';
import '../constants/ui_constants.dart';

class BookmarkButton extends ConsumerWidget {
  final String quizId;
  final String licenseTypeCode;
  const BookmarkButton({super.key, required this.quizId, required this.licenseTypeCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quizzesProgress = ref.watch(quizzesProgressProvider)[licenseTypeCode] ?? {};
    final quiz = quizzesProgress[quizId];
    final isSaved = quiz?.isSaved ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleSaved(ref),
        borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
      child: Row(
        children: [
          Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: isSaved ? theme.AMBER_COLOR : null,
          ),
          const SizedBox(width: SUB_SECTION_SPACING),
          Text(
            isSaved ? 'Đã lưu' : 'Lưu lại',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSaved ? theme.AMBER_COLOR : null,
            ),
          ),
        ],
        ),
      ),
    );
  }

  Future<void> _toggleSaved(WidgetRef ref) async {
    final quizProgress = ref.read(quizzesProgressProvider)[licenseTypeCode]?[quizId];
    await ref.read(quizzesProgressProvider.notifier).updateQuizProgress(
      licenseTypeCode,
      quizId,
      QuizProgress(
        isPracticed: quizProgress?.isPracticed ?? false,
        isCorrect: quizProgress?.isCorrect ?? false,
        isSaved: !(quizProgress?.isSaved ?? false),
      ),
    );
  }
} 