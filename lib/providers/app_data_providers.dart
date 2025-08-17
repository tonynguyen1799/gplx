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

final licenseTypesProvider = StateProvider<List<LicenseType>>((ref) => []);
final trafficSignCategoriesProvider = StateProvider<List<TrafficSignCategory>>((ref) => []);

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