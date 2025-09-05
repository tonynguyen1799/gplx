import 'package:flutter/material.dart';
import '../constants/quiz_constants.dart';
import '../constants/ui_constants.dart';
import '../constants/app_colors.dart';

class QuizFilterBottomSheet extends StatelessWidget {
  final int currentFilter;
  final TrainingMode? trainingMode;
  final String? topic;
  final VoidCallback? onFilterSelected;

  const QuizFilterBottomSheet({
    super.key,
    required this.currentFilter,
    this.trainingMode,
    this.topic,
    this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: CONTENT_PADDING, 
          right: CONTENT_PADDING, 
          top: 0, 
          bottom: CONTENT_PADDING
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(CONTENT_PADDING),
              child: Text(
                'Lọc câu hỏi',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: theme.SURFACE_VARIANT,
                borderRadius: BorderRadius.circular(BORDER_RADIUS),
              ),
              child: Column(
                children: [
                  _buildFilterTile(
                    trainingMode == TrainingMode.BY_TOPIC && topic != null
                        ? 'Tất cả trong chủ đề này'
                        : 'Tất cả',
                                                    QuizFilterConstants.QUIZ_FILTER_ALL,
                                                    currentFilter == QuizFilterConstants.QUIZ_FILTER_ALL,
                    context,
                    theme,
                  ),
                  const Divider(height: 1),
                  _buildFilterTile(
                    'Câu đã làm',
                                                    QuizFilterConstants.QUIZ_FILTER_PRACTICED,
                                                    currentFilter == QuizFilterConstants.QUIZ_FILTER_PRACTICED,
                    context,
                    theme,
                  ),
                  const Divider(height: 1),
                  _buildFilterTile(
                    'Câu chưa làm',
                                                    QuizFilterConstants.QUIZ_FILTER_UNPRACTICED,
                                                    currentFilter == QuizFilterConstants.QUIZ_FILTER_UNPRACTICED,
                    context,
                    theme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: SECTION_SPACING),
            Container(
              decoration: BoxDecoration(
                color: theme.SURFACE_VARIANT,
                borderRadius: BorderRadius.circular(BORDER_RADIUS),
              ),
              child: Column(
                children: [
                  _buildFilterTile(
                    'Câu sai',
                                                    QuizFilterConstants.QUIZ_FILTER_INCORRECT,
                                currentFilter == QuizFilterConstants.QUIZ_FILTER_INCORRECT,
                    context,
                    theme,
                  ),
                  const Divider(height: 1),
                  _buildFilterTile(
                    'Câu đúng',
                                                    QuizFilterConstants.QUIZ_FILTER_CORRECT,
                                currentFilter == QuizFilterConstants.QUIZ_FILTER_CORRECT,
                    context,
                    theme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: SECTION_SPACING),
            Container(
              decoration: BoxDecoration(
                color: theme.SURFACE_VARIANT,
                borderRadius: BorderRadius.circular(BORDER_RADIUS),
              ),
              child: Column(
                children: [
                  _buildFilterTile(
                    'Câu đã lưu',
                                                    QuizFilterConstants.QUIZ_FILTER_SAVED,
                                currentFilter == QuizFilterConstants.QUIZ_FILTER_SAVED,
                    context,
                    theme,
                  ),
                  const Divider(height: 1),
                  _buildFilterTile(
                    'Câu điểm liệt',
                                                    QuizFilterConstants.QUIZ_FILTER_FATAL,
                                currentFilter == QuizFilterConstants.QUIZ_FILTER_FATAL,
                    context,
                    theme,
                  ),
                  const Divider(height: 1),
                  _buildFilterTile(
                    'Câu khó',
                                                    QuizFilterConstants.QUIZ_FILTER_DIFFICULT,
                                currentFilter == QuizFilterConstants.QUIZ_FILTER_DIFFICULT,
                    context,
                    theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTile(
    String label,
    int value,
    bool isSelected,
    BuildContext context,
    ThemeData theme,
  ) {
    return ListTile(
      title: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
        ),
      ),
      onTap: () {
        if (onFilterSelected != null) {
          onFilterSelected!();
        }
        Navigator.pop(context, value);
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
      dense: true,
      trailing: isSelected ? Icon(Icons.check) : null,
    );
  }
}
