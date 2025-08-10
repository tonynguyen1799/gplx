import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/license_type.dart';
import '../../models/quiz.dart';
import '../../models/exam.dart';
import '../../models/topic.dart';
import '../../models/traffic_sign.dart';
import '../../providers/app_data_providers.dart';
import 'package:hive/hive.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/hive_service.dart';
import '../../providers/quizzes_progress_provider.dart';
import '../../providers/exam_progress_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String? _error;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final start = DateTime.now();
      setState(() => _progress = 0.05);
      // 1. Load license types
      final licenseTypesJson = await rootBundle.loadString('assets/license_types.json');
      setState(() => _progress = 0.15);
      final licenseTypesList = json.decode(licenseTypesJson) as List;
      final licenseTypes = licenseTypesList.map((e) => LicenseType.fromJson(e)).toList();
      ref.read(licenseTypesProvider.notifier).state = licenseTypes;
      // Load all quiz statuses into memory at startup
      final licenseTypeCodes = licenseTypes.map((lt) => lt.code).toList();
      await ref.read(quizzesProgressProvider.notifier).loadQuizzesProgress(licenseTypeCodes);
      setState(() => _progress = 0.25);

      // Prepare maps for topics, quizzes, exams, configs
      final topicsMap = <String, List<Topic>>{};
      final quizzesMap = <String, List<Quiz>>{};
      final examsMap = <String, List<Exam>>{};
      final configsMap = <String, dynamic>{};
      List<TrafficSign> trafficSigns = [];

      final totalSteps = licenseTypes.length * 4; // now 4 steps per license
      int currentStep = 0;

      // 2. For each license type, load topics, quizzes, exams, configs
      for (final lt in licenseTypes) {
        final code = lt.code.toLowerCase();
        // Topics
        final topicsJson = await rootBundle.loadString('assets/topics_${code}.json');
        topicsMap[lt.code] = (json.decode(topicsJson) as List).map((e) => Topic.fromJson(e)).toList();
        currentStep++;
        setState(() => _progress = 0.25 + 0.5 * (currentStep / totalSteps));
        // Quizzes
        final quizzesJson = await rootBundle.loadString('assets/quizzes_${code}.json');
        quizzesMap[lt.code] = (json.decode(quizzesJson) as List).map((e) => Quiz.fromJson(e)).toList();
        currentStep++;
        setState(() => _progress = 0.25 + 0.5 * (currentStep / totalSteps));
        // Exams
        final examsJson = await rootBundle.loadString('assets/exams_${code}.json');
        examsMap[lt.code] = (json.decode(examsJson) as List).map((e) => Exam.fromJson(e)).toList();
        currentStep++;
        setState(() => _progress = 0.25 + 0.5 * (currentStep / totalSteps));
        // Configs
        final configsJson = await rootBundle.loadString('assets/configs_${code}.json');
        configsMap[lt.code] = json.decode(configsJson);
        currentStep++;
        setState(() => _progress = 0.25 + 0.5 * (currentStep / totalSteps));
      }
      // Load traffic signs
      final String trafficSignsJson = await rootBundle.loadString('assets/traffic_signs.json');
      final Map<String, dynamic> trafficSignsMap = json.decode(trafficSignsJson);
      List<Map<String, String>> trafficSignCategories = [];
      for (final entry in trafficSignsMap.entries) {
        final key = entry.key;
        final name = entry.value['name'] as String? ?? key;
        trafficSignCategories.add({'key': key, 'name': name});
        if (entry.value is Map && entry.value['signs'] is List) {
          trafficSigns.addAll((entry.value['signs'] as List).map((e) => TrafficSign.fromJson(e, categoryKey: key)));
        }
      }

      ref.read(topicsProvider.notifier).state = topicsMap;
      setState(() => _progress = 0.8);
      ref.read(quizzesProvider.notifier).state = quizzesMap;
      setState(() => _progress = 0.9);
      ref.read(examsProvider.notifier).state = examsMap;
      ref.read(configsProvider.notifier).state = configsMap;
      ref.read(trafficSignCategoriesProvider.notifier).state = trafficSignCategories;
      // ref.read(trafficSignsProvider.notifier).state = AsyncData(trafficSigns); // Not needed for FutureProvider
      await ref.read(examsProgressProvider.notifier).loadExamsProgress();
      setState(() => _progress = 1.0);

      // 3. Navigate to home or onboarding
      final completed = await isOnboardingComplete();
      final elapsed = DateTime.now().difference(start);
      if (elapsed.inMilliseconds < 2000) {
        await Future.delayed(Duration(milliseconds: 3000 - elapsed.inMilliseconds));
      }
      if (mounted) {
        if (completed) {
          context.go('/home');
        } else {
          context.go('/onboarding/get-started');
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(child: Text('Lỗi khi tải dữ liệu:  [31m [1m [4m$_error [0m')),
      );
    }
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset(
            'assets/images/splash_bg.svg',
            fit: BoxFit.cover,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120.0),
              child: Text(
                'Chào mừng bạn đến với ứng dụng Ôn thi GPLX!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900, // Flat, dark blue for contrast
                  // No shadow for minimalist style
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 48.0, left: 32, right: 32),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
