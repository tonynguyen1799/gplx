import 'package:flutter/material.dart';
import '../../constants/ui_constants.dart';
import '../../constants/app_colors.dart';
import '../../models/riverpod/data/quiz.dart';
import 'package:flutter_html/flutter_html.dart';

class AnswerOptions extends StatelessWidget {
  final Quiz quiz;
  final int? selectedIdx;
  final bool isViewed;
  final bool lockAnswer;
  final void Function(int index)? onSelect;
  const AnswerOptions({
    Key? key,
    required this.quiz,
    this.selectedIdx,
    this.isViewed = false,
    this.lockAnswer = false,
    this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFatalQuiz = quiz.topicIds.any((id) => id.endsWith('-fatal'));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildAnswerOptions(theme),
        if (selectedIdx != null && quiz.explanation != null && isViewed) ...[
          const SizedBox(height: SECTION_SPACING),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
            child: Container(
              padding: const EdgeInsets.all(CONTENT_PADDING),
              decoration: BoxDecoration(
                color: theme.SURFACE_VARIANT,
                borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFatalQuiz) ...[
                    Text(
                      'Đây là câu điểm liệt',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.ERROR_COLOR,
                      ),
                    ),
                    const SizedBox(height: SECTION_SPACING),
                  ],
                  if (selectedIdx == -1) ...[
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: theme.WARNING_COLOR),
                        const SizedBox(width: SUB_SECTION_SPACING),
                        Text(
                          'Bạn không làm câu này',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.WARNING_COLOR,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          selectedIdx == quiz.correctIndex ? Icons.check_circle : Icons.cancel,
                          color: selectedIdx == quiz.correctIndex ? theme.SUCCESS_COLOR : theme.ERROR_COLOR,
                        ),
                        const SizedBox(width: SUB_SECTION_SPACING),
                        Text(
                          selectedIdx == quiz.correctIndex ? 'Bạn đã chọn đúng' : 'Bạn đã chọn sai',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: selectedIdx == quiz.correctIndex ? theme.SUCCESS_COLOR : theme.ERROR_COLOR,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: SUB_SECTION_SPACING),
                  Text(
                    'Đáp án đúng: số  ${quiz.correctIndex + 1}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SUB_SECTION_SPACING),
                  Text(
                    quiz.explanation!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                  if (quiz.tip != null && quiz.tip!.isNotEmpty) ...[
                    const SizedBox(height: SECTION_SPACING),
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: theme.WARNING_COLOR,
                        ),
                        const SizedBox(width: SUB_SECTION_SPACING),
                        Text(
                          'Mẹo ghi nhớ',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.WARNING_COLOR,
                          ),
                        ),
                      ],
                                            ),
                        const SizedBox(height: SUB_SECTION_SPACING),
                        Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Html(
                            data: quiz.tip!,
                            style: {
                              "body": Style(
                                fontSize: FontSize(theme.textTheme.bodyMedium?.fontSize ?? 14),
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                              "b": Style(
                                fontWeight: FontWeight.bold,
                              ),
                              "br": Style(
                                margin: Margins.zero,
                              ),
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnswerOptions(ThemeData theme) {
    return Column(
      children: [
        for (int i = 0; i < quiz.answers.length; i++)
          InkWell(
            onTap: (onSelect == null || lockAnswer) ? null : () => onSelect!(i),
            child: Container(
              color: _getAnswerOptionColor(theme, i),
              padding: const EdgeInsets.symmetric(vertical: SUB_SECTION_SPACING, horizontal: CONTENT_PADDING),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IgnorePointer(
                    child: _buildAnswerOptionIcon(theme, i),
                  ),
                  const SizedBox(width: SUB_SECTION_SPACING),
                  Expanded(
                    child: Text(
                      '${i + 1}. ${quiz.answers[i]}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Color _getAnswerOptionColor(ThemeData theme, int answerIdx) {
    if (isViewed) {
      if (answerIdx == quiz.correctIndex) return theme.SUCCESS_COLOR.withValues(alpha: 0.4);
      if (selectedIdx == answerIdx) return theme.ERROR_COLOR.withValues(alpha: 0.4);
      return Colors.transparent;
    }

    if (selectedIdx == answerIdx) return theme.DARK_SURFACE_VARIANT;
    return Colors.transparent;
  }

  Widget _buildAnswerOptionIcon(ThemeData theme, int answerIdx) {
    if (isViewed) {
      if (selectedIdx == answerIdx) {
        return Icon(
          answerIdx == quiz.correctIndex ? Icons.check_circle : Icons.cancel, 
          color: answerIdx == quiz.correctIndex ? theme.SUCCESS_COLOR : theme.ERROR_COLOR,
          size: 24,
        );
      }
      return Icon(Icons.circle_outlined, size: 24);
    }
    return Icon(
      (selectedIdx == answerIdx)
          ? Icons.radio_button_checked
          : Icons.radio_button_unchecked,
      size: 24,
    );
  }
} 