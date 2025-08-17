class Tip {
  final String tipTitle;
  final String tipContent;
  final List<int> relatedQuestions;

  Tip({
    required this.tipTitle,
    required this.tipContent,
    required this.relatedQuestions,
  });

  factory Tip.fromJson(Map<String, dynamic> json) => Tip(
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

class TipTopic {
  final String topicId;
  final String topicName;
  final String topicDescription;
  final List<Tip> tips;

  TipTopic({
    required this.topicId,
    required this.topicName,
    required this.topicDescription,
    required this.tips,
  });

  factory TipTopic.fromJson(Map<String, dynamic> json) => TipTopic(
        topicId: json['topic_id'] ?? '',
        topicName: json['topic_name'] ?? '',
        topicDescription: json['topic_description'] ?? '',
        tips: json['tips'] != null
            ? (json['tips'] as List).map((tip) => Tip.fromJson(tip)).toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        'topic_id': topicId,
        'topic_name': topicName,
        'topic_description': topicDescription,
        'tips': tips.map((tip) => tip.toJson()).toList(),
      };
}

class Tips {
  final List<TipTopic> examTips;

  Tips({
    required this.examTips,
  });

  factory Tips.fromJson(Map<String, dynamic> json) => Tips(
        examTips: json['exam_tips'] != null
            ? (json['exam_tips'] as List).map((topic) => TipTopic.fromJson(topic)).toList()
            : [],
      );

  Map<String, dynamic> toJson() => {
        'exam_tips': examTips.map((topic) => topic.toJson()).toList(),
      };
} 