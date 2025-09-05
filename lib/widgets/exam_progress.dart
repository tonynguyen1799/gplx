import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import 'package:gplx_vn/constants/ui_constants.dart';
import 'package:gplx_vn/constants/route_constants.dart';

class ExamsProgress extends StatelessWidget {
  final int totalExams;
  const ExamsProgress({super.key, required this.totalExams});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        context.push(RouteConstants.ROUTE_EXAMS);
      },
      child: Container(
        padding: const EdgeInsets.all(CONTENT_PADDING),
        decoration: BoxDecoration(
          color: theme.EXAM_WIDGET_BG,
          borderRadius: BorderRadius.circular(BORDER_RADIUS),
        ),
        child: Row(
          children: [
            Icon(
              Icons.assignment,
              size: 32.0,
              color: theme.EXAM_WIDGET_ICON,
            ),
            const SizedBox(width: SECTION_SPACING),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thi thử mô phỏng',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SUB_SECTION_SPACING),
                  Text(
                    'Bộ $totalExams đề thi, thời gian và cách thức làm bài như thực tế',
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
