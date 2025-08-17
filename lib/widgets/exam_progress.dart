import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';

class _ExamsProgressConstants {
  static const double contentPadding = 16.0;
  static const double borderRadius = 12.0;
  static const double sectionSpacing = 12.0;
  static const double subSectionSpacing = 6.0;

  static const String title = 'Thi thử mô phỏng';
  static const String description = 'Bộ %d đề thi, thời gian và cách thức làm bài như thực tế';
  static const String routePath = '/exams';
}

class ExamsProgress extends StatelessWidget {
  final int totalExams;
  const ExamsProgress({super.key, this.totalExams = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        context.push(_ExamsProgressConstants.routePath);
      },
      child: Container(
        padding: const EdgeInsets.all(_ExamsProgressConstants.contentPadding),
        decoration: BoxDecoration(
          color: theme.EXAM_WIDGET_BG,
          borderRadius: BorderRadius.circular(_ExamsProgressConstants.borderRadius),
        ),
        child: Row(
          children: [
            Icon(
              Icons.assignment,
              size: 32.0,
              color: theme.EXAM_WIDGET_ICON,
            ),
            const SizedBox(width: _ExamsProgressConstants.sectionSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _ExamsProgressConstants.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: _ExamsProgressConstants.subSectionSpacing),
                  Text(
                    _ExamsProgressConstants.description.replaceAll('%d', '$totalExams'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
