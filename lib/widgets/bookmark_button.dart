import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/learning_progress.provider.dart';
import '../models/quiz_practice_status.dart';
import '../utils/app_colors.dart';

class BookmarkButton extends ConsumerWidget {
  final String quizId;
  final String licenseTypeCode;
  const BookmarkButton({super.key, required this.quizId, required this.licenseTypeCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusMap = ref.watch(quizStatusProvider)[licenseTypeCode] ?? {};
    final status = statusMap[quizId];
    final isSaved = status?.saved ?? false;
    final loading = false; // Always false, as state is instant

    Future<void> toggleSaved() async {
      final prevStatus = status;
    final newSaved = !(prevStatus?.saved ?? false);
      final newStatus = QuizPracticeStatus(
      practiced: prevStatus?.practiced ?? false,
      correct: prevStatus?.correct ?? false,
      saved: newSaved,
    );
      await ref.read(quizStatusProvider.notifier).updateStatus(
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