import 'package:flutter/material.dart';
import '../screens/home/viewmodel/topic_progress_view_model.dart';
import 'package:go_router/go_router.dart';
import '../utils/quiz_constants.dart';
import '../models/quiz.dart';
import '../models/hive/quiz_progress.dart';
import '../utils/app_colors.dart';

class StudyByTopicSection extends StatelessWidget {
  final List<TopicProgressViewModel> topics;
  final String licenseTypeCode;
  final List<Quiz> quizzes;
  final Map<String, QuizProgress> statusMap;
  final Map<String, dynamic>? perTopicProgress;

  const StudyByTopicSection({
    super.key,
    required this.topics,
    required this.licenseTypeCode,
    required this.quizzes,
    required this.statusMap,
    this.perTopicProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Tiến độ theo chủ đề',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
          ),
          ...List.generate(topics.length, (i) {
            final topic = topics[i];
            final progress = topic.total == 0
                ? 0.0
                : topic.done / topic.total.clamp(1, double.infinity);
            final topicProg = perTopicProgress != null ? perTopicProgress![topic.id] : null;
            return GestureDetector(
              onTap: () {
                // Find quizzes for this topic
                final topicQuizIds = quizzes.where((q) => q.topicIds.contains(topic.id)).map((q) => q.id).toList();
                int startIndex = 0;
                for (int i = 0; i < topicQuizIds.length; i++) {
                  if (!(statusMap[topicQuizIds[i]]?.isPracticed ?? false)) {
                    startIndex = i;
                    break;
                  }
                  if (i == topicQuizIds.length - 1) startIndex = i;
                }
                context.push('/quiz', extra: {
                  'licenseTypeCode': licenseTypeCode,
                  'mode': QuizModes.TRAINING_BY_TOPIC_MODE,
                  'topicId': topic.id,
                  'filter': 'all',
                  'startIndex': startIndex,
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.studyProgressBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          topic.icon,
                          color: topic.color,
                          size: 32,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            topic.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.studyProgressText,
                            ),
                          )
                        ),
                        Text(
                          '${topic.done}/${topic.total}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: topic.total == 0 ? 0 : topic.done / topic.total.clamp(1, double.infinity),
                        minHeight: 8,
                        backgroundColor: theme.studyProgressBarBackground,
                        valueColor: AlwaysStoppedAnimation(
                          theme.studyProgressBarColor,
                        ),
                      ),
                    ),
                    if (topicProg != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Đúng ${topicProg.totalCorrectQuizzes}    Sai ${topicProg.totalIncorrectQuizzes}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.studyProgressStats,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
