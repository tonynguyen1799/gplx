class RoadDiagram {
  final String title;
  final List<RoadDiagramSection> sections;
  final String closingRemark;
  final String callToAction;

  RoadDiagram({
    required this.title,
    required this.sections,
    required this.closingRemark,
    required this.callToAction,
  });

  factory RoadDiagram.fromJson(Map<String, dynamic> json) {
    return RoadDiagram(
      title: json['title'] ?? '',
      sections: (json['sections'] as List<dynamic>?)?.map((e) => RoadDiagramSection.fromJson(e)).toList() ?? [],
      closingRemark: json['closing_remark'] ?? '',
      callToAction: json['call_to_action'] ?? '',
    );
  }
}

class RoadDiagramSection {
  final String heading;
  final String? content;
  final List<RoadDiagramSubSection>? subSections;
  final List<RoadDiagramLesson>? lessons;
  final List<String>? listItems;
  final String? youtube;

  RoadDiagramSection({
    required this.heading,
    this.content,
    this.subSections,
    this.lessons,
    this.listItems,
    this.youtube,
  });

  factory RoadDiagramSection.fromJson(Map<String, dynamic> json) {
    return RoadDiagramSection(
      heading: json['heading'] ?? '',
      content: json['content'],
      subSections: (json['sub_sections'] as List<dynamic>?)?.map((e) => RoadDiagramSubSection.fromJson(e)).toList(),
      lessons: (json['lessons'] as List<dynamic>?)?.map((e) => RoadDiagramLesson.fromJson(e)).toList(),
      listItems: (json['list_items'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      youtube: json['youtube'],
    );
  }
}

class RoadDiagramSubSection {
  final String subHeading;
  final List<String> listItems;

  RoadDiagramSubSection({required this.subHeading, required this.listItems});

  factory RoadDiagramSubSection.fromJson(Map<String, dynamic> json) {
    return RoadDiagramSubSection(
      subHeading: json['sub_heading'] ?? '',
      listItems: (json['list_items'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class RoadDiagramLesson {
  final String lessonNumber;
  final String title;
  final String objective;
  final List<String> howToDo;
  final String tips;

  RoadDiagramLesson({
    required this.lessonNumber,
    required this.title,
    required this.objective,
    required this.howToDo,
    required this.tips,
  });

  factory RoadDiagramLesson.fromJson(Map<String, dynamic> json) {
    return RoadDiagramLesson(
      lessonNumber: json['lesson_number'] ?? '',
      title: json['title'] ?? '',
      objective: json['objective'] ?? '',
      howToDo: (json['how_to_do'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      tips: json['tips'] ?? '',
    );
  }
} 