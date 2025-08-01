import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:gplx_vn/screens/home/home_screen.dart';
import 'package:gplx_vn/screens/onboarding/get_started_screen.dart';
import 'package:gplx_vn/screens/onboarding/onboarding_finish_screen.dart';
import 'package:gplx_vn/screens/onboarding/reminder_screen.dart';
import 'package:gplx_vn/screens/onboarding/splash_screen.dart';
import 'package:gplx_vn/screens/quiz/quiz_screen.dart';
import 'package:gplx_vn/screens/quiz/exam_quiz_screen.dart';
import 'package:gplx_vn/screens/exams_screen.dart';
import 'package:gplx_vn/utils/quiz_constants.dart';
import 'package:gplx_vn/screens/quiz/exam_summary_screen.dart';
import 'package:gplx_vn/screens/traffic_signs_screen.dart';
import 'package:gplx_vn/screens/settings/settings_screen.dart';
import 'package:gplx_vn/screens/info_screen.dart';
import 'package:gplx_vn/screens/exam_description_screen.dart';
import 'package:gplx_vn/screens/tips_screen.dart';
import 'package:gplx_vn/widgets/bottom_navigation_bar.dart';
import 'package:gplx_vn/screens/main_navigation_screen.dart';
final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding/get-started',
      builder: (context, state) => const GetStartedScreen(),
    ),
    GoRoute(
      path: '/onboarding/reminder',
      builder: (context, state) => const ReminderScreen(),
    ),
    GoRoute(
      path: '/onboarding/finish',
      builder: (context, state) => const OnboardingFinishScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigationScreen(initialIndex: 0),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const MainNavigationScreen(initialIndex: 1),
    ),
    GoRoute(
      path: '/info',
      builder: (context, state) => const MainNavigationScreen(initialIndex: 2),
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return QuizScreen(key: state.pageKey, extra: state.extra);
      },
    ),
    GoRoute(
      path: '/exam-quiz',
      builder: (context, state) => ExamQuizScreen(key: state.pageKey, extra: state.extra),
    ),
    GoRoute(
      path: '/exams',
      builder: (context, state) => const ExamsScreen(),
    ),
    GoRoute(
      path: '/exam-description',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ExamDescriptionScreen(
          exam: extra?['exam'],
          licenseTypeCode: extra?['licenseTypeCode'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/exam-summary',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ExamSummaryScreen(
          quizzes: extra?['quizzes'] ?? [],
          selectedAnswers: extra?['selectedAnswers'] ?? {},
          licenseTypeCode: extra?['licenseTypeCode'] ?? '',
          examId: extra?['examId'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/traffic-signs',
      builder: (context, state) => const TrafficSignsScreen(),
    ),
    GoRoute(
      path: '/tips',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return TipsScreen(
          licenseTypeCode: extra?['licenseTypeCode'] ?? '',
        );
      },
    ),
  ],
);
