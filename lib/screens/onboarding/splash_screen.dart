import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/riverpod/data/license_type.dart';
import '../../models/riverpod/data/traffic_sign_category.dart';
import '../../providers/app_data_providers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../services/hive_service.dart';
import '../../providers/quizzes_progress_provider.dart';
import '../../providers/exams_progress_provider.dart';
import 'package:gplx_vn/constants/navigation_constants.dart';
import 'package:gplx_vn/constants/route_constants.dart';

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

      // 2. Load traffic signs in their organized structure
      final String trafficSignsJson = await rootBundle.loadString('assets/traffic_signs.json');
      final Map<String, dynamic> trafficSignsMap = json.decode(trafficSignsJson);
      final List<TrafficSignCategory> categories = [];
      
      for (final entry in trafficSignsMap.entries) {
        final key = entry.key;
        final category = TrafficSignCategory.fromJson(entry.value, key);
        categories.add(category);
      }

      ref.read(trafficSignCategoriesProvider.notifier).state = categories;
      setState(() => _progress = 0.8);
      final currentCode = await getLicenseType();
      if (currentCode != null) {
        await ref.read(examsProgressProvider.notifier).loadExamsProgressFor(currentCode);
      }
      setState(() => _progress = 1.0);

      // 3. Navigate to home or onboarding
      final completed = await isOnboardingComplete();
      final elapsed = DateTime.now().difference(start);
      if (elapsed.inMilliseconds < 2000) {
        await Future.delayed(Duration(milliseconds: 3000 - elapsed.inMilliseconds));
      }
      if (mounted) {
                  if (completed) {
            context.go('/main', extra: {'initialIndex': MainNav.TAB_HOME});
          } else {
          context.go(RouteConstants.ROUTE_ONBOARDING_GET_STARTED);
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
