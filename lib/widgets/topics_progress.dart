import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/quiz_constants.dart';
import '../constants/route_constants.dart';
import '../models/riverpod/topic_progress.dart';
import '../models/riverpod/data/topic.dart';
import '../constants/app_colors.dart';
import '../constants/ui_constants.dart';
import '../screens/quiz/quiz_screen.dart';

class _TopicIcons {
  static const Map<String, IconData> icons = {
    'warning_amber_rounded': Icons.warning_amber_rounded,
    'rule_rounded': Icons.rule_rounded,
    'psychology_rounded': Icons.psychology_rounded,
    'sports_motorsports_rounded': Icons.sports_motorsports_rounded,
    'construction_rounded': Icons.construction_rounded,
    'traffic_rounded': Icons.traffic_rounded,
    'signpost_rounded': Icons.signpost_rounded,
  };
}




class TopicsProgress extends StatelessWidget {
  final List<Topic> topics;
  final Map<String, TopicProgress>? topicQuizzesProgress;

  const TopicsProgress({
    super.key,
    required this.topics,
    this.topicQuizzesProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: SECTION_SPACING),
          child: Text(
            'Tiến độ theo chủ đề',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: topics.length,
          itemBuilder: (context, index) => _buildTopicProgress(context, topics[index]),
          separatorBuilder: (context, index) => SizedBox(height: SECTION_SPACING),
        ),
      ],
    );
  }

  Widget _buildTopicProgress(BuildContext context, Topic topic) {
    final theme = Theme.of(context);
    final topicProgress = topicQuizzesProgress?[topic.id];
    final totalTopicPracticedQuizzes = topicProgress?.totalPracticedQuizzes ?? 0;
    final totalTopicQuizzes = topicProgress?.totalQuizzes ?? 0;
    
    return GestureDetector(
      onTap: () {
        final params = QuizScreenParams(
          trainingMode: TrainingMode.BY_TOPIC,
          topicId: topic.id,
                        filter: QuizFilterConstants.QUIZ_FILTER_ALL,
          startIndex: 0,
        );
        context.push(RouteConstants.ROUTE_QUIZ, extra: params);
      },
      child: Container(
        padding: const EdgeInsets.all(CONTENT_PADDING),
        decoration: BoxDecoration(
          color: theme.LIGHT_SURFACE_VARIANT,
          borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _TopicIcons.icons[topic.icon] ?? Icons.help,
                  color: topic.color != null ? Color(int.parse(topic.color!)) : Colors.grey,
                  size: 32.0,
                ),
                const SizedBox(width: SECTION_SPACING),
                Expanded(
                  child: Text(
                    topic.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                  ),
                ),
                Text(
                  '$totalTopicPracticedQuizzes/$totalTopicQuizzes',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SUB_SECTION_SPACING),
            ClipRRect(
              borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS),
              child: LinearProgressIndicator(
                value: totalTopicQuizzes == 0 ? 0 : totalTopicPracticedQuizzes / totalTopicQuizzes,
                minHeight: 4.0,
                backgroundColor: theme.PROGRESS_BAR_BG,
                valueColor: AlwaysStoppedAnimation(
                  theme.PROGRESS_BAR_FG,
                ),
              ),
            ),
            if (topicQuizzesProgress != null && topicQuizzesProgress![topic.id] != null) ...[
              const SizedBox(height: SUB_SECTION_SPACING),
              Row(
                children: [
                  Text(
                    'Đúng ${topicQuizzesProgress![topic.id]!.totalCorrectQuizzes}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: SECTION_SPACING * 2),
                  Text(
                    'Sai ${topicQuizzesProgress![topic.id]!.totalIncorrectQuizzes}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }


}
