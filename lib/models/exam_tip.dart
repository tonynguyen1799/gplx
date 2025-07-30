class ExamTip {
  final String tipTitle;
  final String tipContent;
  final List<int> relatedQuestions;

  ExamTip({
    required this.tipTitle,
    required this.tipContent,
    required this.relatedQuestions,
  });

  factory ExamTip.fromJson(Map<String, dynamic> json) => ExamTip(
        tipTitle: json['tip_title'] ?? '',
        tipContent: json['tip_content'] ?? '',
        relatedQuestions: json['related_questions'] != null
            ? List<int>.from(json['related_questions'])
            : [],
      );

  Map<String, dynamic> toJson() => {
        'tip_title': tipTitle,
        'tip_content': tipContent,
        'related_questions': relatedQuestions,
      };
}

class ExamTipTopic {
  final String topicId;
  final String topicName;
  final String topicDescription;
  final List<ExamTip> tips;

  ExamTipTopic({
    required this.topicId,
    required this.topicName,
    required this.topicDescription,
    required this.tips,
  });

  factory ExamTipTopic.fromJson(Map<String, dynamic> json) => ExamTipTopic(
        topicId: json['topic_id'] ?? '',
        topicName: json['topic_name'] ?? '',
        topicDescription: json['topic_description'] ?? '',
        tips: json['tips'] != null
            ? (json['tips'] as List).map((tip) => ExamTip.fromJson(tip)).toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        'topic_id': topicId,
        'topic_name': topicName,
        'topic_description': topicDescription,
        'tips': tips.map((tip) => tip.toJson()).toList(),
      };
}

class ExamTips {
  final List<ExamTipTopic> examTips;

  ExamTips({
    required this.examTips,
  });

  factory ExamTips.fromJson(Map<String, dynamic> json) => ExamTips(
        examTips: json['exam_tips'] != null
            ? (json['exam_tips'] as List).map((topic) => ExamTipTopic.fromJson(topic)).toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        'exam_tips': examTips.map((topic) => topic.toJson()).toList(),
      };
} 