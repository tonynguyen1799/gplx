import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_colors.dart';

class RealExamSection extends StatelessWidget {
  final int examCount;
  const RealExamSection({super.key, this.examCount = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        context.push('/exams');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: theme.realExamBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.assignment,
              size: 32,
              color: theme.realExamIcon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thi thử mô phỏng',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.realExamTitle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bộ $examCount đề thi, thời gian và cách thức làm bài như thực tế',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.realExamDescription,
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
