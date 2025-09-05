import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';
import '../constants/app_colors.dart';

class QuizBottomNavigation extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onShowQuizzes;
  final VoidCallback? onNext;

  const QuizBottomNavigation({
    super.key,
    this.onPrevious,
    this.onShowQuizzes,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        height: NAVIGATION_HEIGHT,
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: onPrevious,
                style: TextButton.styleFrom(
                  backgroundColor: theme.NAVIGATION_FG,
                  foregroundColor: theme.NAVIGATION_BG,
                  disabledBackgroundColor: Colors.grey.shade200,
                  disabledForegroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  minimumSize: const Size(0, NAVIGATION_HEIGHT),
                ),
                child: Text('Câu trước', style: theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.NAVIGATION_BG,
                )),
              ),
            ),

            Expanded(
              child: TextButton(
                onPressed: onShowQuizzes,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: theme.textTheme.bodyMedium!.color,
                  disabledBackgroundColor: Colors.grey.shade200,
                  disabledForegroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  minimumSize: const Size(0, NAVIGATION_HEIGHT),
                ),
                child: const Center(
                  child: Icon(Icons.list),
                ),
              ),
            ),

            Expanded(
              child: TextButton(
                onPressed: onNext,
                style: TextButton.styleFrom(
                  backgroundColor: theme.NAVIGATION_FG,
                  foregroundColor: theme.NAVIGATION_BG,
                  disabledBackgroundColor: Colors.grey.shade200,
                  disabledForegroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  minimumSize: const Size(0, NAVIGATION_HEIGHT),
                ),
                child: Text('Tiếp theo', style: theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.NAVIGATION_BG,
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
