import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/license_type.dart';
import '../models/quiz.dart';
import '../models/exam.dart';
import '../models/topic.dart';
import '../services/hive_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/traffic_sign.dart';
import '../models/exam_tip.dart';
import '../models/road_diagram.dart';

final licenseTypesProvider = StateProvider<List<LicenseType>>((ref) => []);
final topicsProvider = StateProvider<Map<String, List<Topic>>>((ref) => {});
final quizzesProvider = StateProvider<Map<String, List<Quiz>>>((ref) => {});
final examsProvider = StateProvider<Map<String, List<Exam>>>((ref) => {}); 
final configsProvider = StateProvider<Map<String, dynamic>>((ref) => {});
final trafficSignCategoriesProvider = StateProvider<List<Map<String, String>>>((ref) => []);
final mainNavIndexProvider = StateProvider<int>((ref) => 0); // 0: Home, 1: Settings, 2: Info

final trafficSignsProvider = FutureProvider<List<TrafficSign>>((ref) async {
  final String jsonString = await rootBundle.loadString('assets/traffic_signs.json');
  final Map<String, dynamic> jsonMap = json.decode(jsonString);
  final List<TrafficSign> signs = [];
  for (final entry in jsonMap.entries) {
    final key = entry.key;
    final category = entry.value;
    if (category is Map && category['signs'] is List) {
      signs.addAll((category['signs'] as List).map((e) => TrafficSign.fromJson(e, categoryKey: key)));
    }
  }
  return signs;
}); 

final selectedLicenseTypeProvider = FutureProvider<String?>((ref) async {
  return await getSelectedLicenseType();
}); 

final tipsProvider = StateProvider<Map<String, ExamTips>>((ref) => {});

final roadDiagramProvider = FutureProvider<RoadDiagram>((ref) async {
  final selectedLicenseType = await ref.watch(selectedLicenseTypeProvider.future);
  String? licenseType = selectedLicenseType?.toLowerCase() ?? 'b2';
  final supported = ['a1', 'a2', 'b1', 'b2', 'c', 'd', 'e', 'f'];
  final type = supported.contains(licenseType) ? licenseType : 'b2';
  final fileName = 'assets/road_diagram_${type}.json';
  try {
    final jsonStr = await rootBundle.loadString(fileName);
    final json = jsonDecode(jsonStr);
    return RoadDiagram.fromJson(json);
  } catch (e) {
    final jsonStr = await rootBundle.loadString('assets/road_diagram_b2.json');
    final json = jsonDecode(jsonStr);
    return RoadDiagram.fromJson(json);
  }
}); 