import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/license_type.dart';
import '../models/quiz.dart';
import '../models/exam.dart';
import '../models/topic.dart';
import '../services/hive_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/traffic_sign.dart';

final licenseTypesProvider = StateProvider<List<LicenseType>>((ref) => []);
final topicsProvider = StateProvider<Map<String, List<Topic>>>((ref) => {});
final quizzesProvider = StateProvider<Map<String, List<Quiz>>>((ref) => {});
final examsProvider = StateProvider<Map<String, List<Exam>>>((ref) => {}); 
final configsProvider = StateProvider<Map<String, dynamic>>((ref) => {});
final trafficSignCategoriesProvider = StateProvider<List<Map<String, String>>>((ref) => []);

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