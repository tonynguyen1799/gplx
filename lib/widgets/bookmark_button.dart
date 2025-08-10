import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/quizzes_progress_provider.dart';
import '../models/hive/quiz_progress.dart';
import '../utils/app_colors.dart';

class BookmarkButton extends ConsumerWidget {
  final String quizId;
  final String licenseTypeCode;
  const BookmarkButton({super.key, required this.quizId, required this.licenseTypeCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusMap = ref.watch(quizzesProgressProvider)[licenseTypeCode] ?? {};
    final status = statusMap[quizId];
    final isSaved = status?.isSaved ?? false;
    final loading = false; // Always false, as state is instant

    Future<void> toggleSaved() async {
      final prevStatus = status;
    final newSaved = !(prevStatus?.isSaved ?? false);
      final newStatus = QuizProgress(
      isPracticed: prevStatus?.isPracticed ?? false,
      isCorrect: prevStatus?.isCorrect ?? false,
      isSaved: newSaved,
    );
      await ref.read(quizzesProgressProvider.notifier).updateQuizProgress(
        licenseTypeCode,
        quizId,
        newStatus,
      );
  }

    if (loading) {
      return SizedBox(width: 60, height: 24, child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))));
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: toggleSaved,
        borderRadius: BorderRadius.circular(6),
      child: Row(
        children: [
          Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: isSaved ? theme.amberColor : theme.primaryText,
            size: 24,
          ),
          const SizedBox(width: 4),
          Text(
            isSaved ? 'Đã lưu' : 'Lưu lại',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isSaved ? theme.amberColor : theme.primaryText,
            ),
          ),
        ],
        ),
      ),
    );
  }
} 