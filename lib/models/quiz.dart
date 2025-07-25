class Quiz {
  final String id;
  final String licenseTypeCode;
  final List<String> topicIds;
  final String text;
  final List<String> answers;
  final int correctIndex;
  final String? imageUrl;
  final bool isDifficult;
  final String title;
  final int index;
  final String? explanation;

  Quiz({
    required this.id,
    required this.licenseTypeCode,
    required this.topicIds,
    required this.text,
    required this.answers,
    required this.correctIndex,
    this.imageUrl,
    this.isDifficult = false,
    required this.title,
    required this.index,
    this.explanation,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
        id: json['id'],
        licenseTypeCode: json['licenseTypeCode'],
        topicIds: json['topicIds'] != null
            ? List<String>.from(json['topicIds'])
            : (json['topicId'] != null ? [json['topicId']] : []),
        text: json['text'],
        answers: List<String>.from(json['answers']),
        correctIndex: json['correctIndex'],
        imageUrl: json['imageUrl'],
        isDifficult: json['isDifficult'] == true,
        title: json['title'] ?? '',
        index: json['index'] ?? 0,
        explanation: json['explanation'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'licenseTypeCode': licenseTypeCode,
        'topicIds': topicIds,
        'text': text,
        'answers': answers,
        'correctIndex': correctIndex,
        'imageUrl': imageUrl,
        'isDifficult': isDifficult,
        'title': title,
        'index': index,
        'explanation': explanation,
      };
} 