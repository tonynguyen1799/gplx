import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/riverpod/data/license_type.dart';
import '../models/riverpod/data/quiz.dart';
import '../models/riverpod/data/exam.dart';
import '../models/riverpod/data/topic.dart';

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/riverpod/data/tip.dart';
import '../models/riverpod/data/road_diagram.dart';
import '../models/riverpod/data/config.dart';
import '../models/riverpod/data/traffic_sign_category.dart';
import 'license_type_provider.dart';

class LicenseTypesNotifier extends StateNotifier<List<LicenseType>> {
  LicenseTypesNotifier() : super(const []);

  Future<void> loadFromAssets() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/license_types.json');
      final list = (json.decode(jsonStr) as List)
          .map((e) => LicenseType.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      state = list;
    } catch (_) {
      state = const <LicenseType>[];
    }
  }
}

final licenseTypesProvider = StateNotifierProvider<LicenseTypesNotifier, List<LicenseType>>(
  (ref) => LicenseTypesNotifier(),
);

final topicsProvider = FutureProvider<List<Topic>>((ref) async {
  return _loadForLicense<List<Topic>>(
    ref, 
    'topics', 
    (json) => (json as List).map((e) => Topic.fromJson((e as Map).cast<String, dynamic>())).toList(),
    <Topic>[]
  );
});

final quizzesProvider = FutureProvider<List<Quiz>>((ref) async {
  return _loadForLicense<List<Quiz>>(
    ref, 
    'quizzes', 
    (json) => (json as List).map((e) => Quiz.fromJson((e as Map).cast<String, dynamic>())).toList(),
    <Quiz>[]
  );
});

final examsProvider = FutureProvider<List<Exam>>((ref) async {
  return _loadForLicense<List<Exam>>(
    ref, 
    'exams', 
    (json) => (json as List).map((e) => Exam.fromJson((e as Map).cast<String, dynamic>())).toList(),
    <Exam>[]
  );
});

final examQuizzesProvider = FutureProvider.family<List<Quiz>, String>((ref, examId) async {
  final quizzes = await ref.watch(quizzesProvider.future);
  final exams = await ref.watch(examsProvider.future);

  final exam = exams.where((e) => e.id == examId).isNotEmpty == true
      ? exams.firstWhere((e) => e.id == examId)
      : null;
  if (exam == null) return <Quiz>[];

  final examQuizIds = exam.quizIds.toSet();
  return quizzes.where((q) => examQuizIds.contains(q.id)).toList();
});

final configProvider = FutureProvider<Config>((ref) async {
  return _loadForLicense<Config>(
    ref, 
    'configs', 
    (json) => Config.fromJson((json as Map).cast<String, dynamic>()),
            Config(exam: ExamConfig(durationInMinutes: 0, totalOfQuizzes: 0, totalRequiredCorrectQuizzes: 0))
  );
});

final tipsProvider = FutureProvider<Tips>((ref) async {
  return _loadForLicense<Tips>(
    ref, 
    'tips', 
    (json) => Tips.fromJson((json as Map).cast<String, dynamic>()),
    Tips(examTips: [])
  );
});

final roadDiagramsProvider = FutureProvider<RoadDiagram>((ref) async {
  return _loadForLicense<RoadDiagram>(
    ref,
    'road_diagram',
    (json) => RoadDiagram.fromJson((json as Map).cast<String, dynamic>()),
    RoadDiagram(title: '', sections: [], closingRemark: '', callToAction: ''),
  );
}); 

final totalDifficultQuizzesProvider = Provider.family<int, String>((ref, licenseTypeCode) {
  final asyncQuizzes = ref.watch(quizzesProvider);
  
  if (asyncQuizzes.isLoading) return 0;
  if (asyncQuizzes.hasError) return 0;
  
  final quizzes = asyncQuizzes.value ?? [];
  return quizzes.where((quiz) => quiz.isDifficult == true).length;
});

final trafficSignCategoriesProvider = FutureProvider<List<TrafficSignCategory>>((ref) async {
  return _loadTrafficSigns();
});

Future<R> _loadForLicense<R>(Ref ref, String assetPrefix, R Function(dynamic) fromJson, R defaultValue) async {
  final asyncLicenseType = ref.watch(licenseTypeProvider);
  final licenseType = asyncLicenseType.asData?.value?.toLowerCase();
  if (licenseType == null || licenseType.isEmpty) return defaultValue;
  
  final fileName = 'assets/${assetPrefix}_${licenseType}.json';
  try {
    final jsonStr = await rootBundle.loadString(fileName);
    final json = jsonDecode(jsonStr);
    return fromJson(json);
  } catch (_) {
    return defaultValue;
  }
}

Future<List<TrafficSignCategory>> _loadTrafficSigns() async {
  try {
    final String trafficSignsJson = await rootBundle.loadString('assets/traffic_signs.json');
    final Map<String, dynamic> trafficSignsMap = json.decode(trafficSignsJson);
    final List<TrafficSignCategory> categories = [];
    
    for (final entry in trafficSignsMap.entries) {
      final key = entry.key;
      final category = TrafficSignCategory.fromJson(entry.value, key);
      categories.add(category);
    }
    
    return categories;
  } catch (e) {
    return [];
  }
}