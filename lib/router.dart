import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gplx_vn/screens/onboarding/get_started_screen.dart';
import 'package:gplx_vn/screens/onboarding/reminder_screen.dart';
import 'package:gplx_vn/screens/onboarding/splash_screen.dart';
import 'package:gplx_vn/screens/quiz/quiz_screen.dart';
import 'package:gplx_vn/screens/quiz/exam_quiz_screen.dart' show ExamQuizScreen, ExamQuizScreenParams;
import 'package:gplx_vn/screens/exams_screen.dart';
import 'package:gplx_vn/screens/quiz/exam_summary_screen.dart';
import 'package:gplx_vn/screens/traffic_signs_screen.dart';
import 'package:gplx_vn/screens/exam_description_screen.dart';
import 'package:gplx_vn/screens/tips_screen.dart';
import 'package:gplx_vn/screens/main_navigation_screen.dart';
import 'package:gplx_vn/screens/road_diagram_screen.dart';
import 'package:gplx_vn/constants/quiz_constants.dart';


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
      path: '/main',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final initialIndex = extra?['initialIndex'] ?? 0;
        return MainNavigationScreen(initialIndex: initialIndex);
      },
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) {
        final params = state.extra as QuizScreenParams? ?? const QuizScreenParams();
        return QuizScreen(key: state.pageKey, params: params);
      },
    ),
    GoRoute(
      path: '/exam-quiz',
      builder: (context, state) {
        final params = state.extra as ExamQuizScreenParams? ?? const ExamQuizScreenParams(examId: '', examMode: ExamModes.EXAM_NORMAL_MODE);
        return ExamQuizScreen(key: state.pageKey, params: params);
      },
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
        );
      },
    ),
    GoRoute(
      path: '/exam-summary',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ExamSummaryScreen(
          selectedAnswers: extra?['selectedAnswers'] ?? {},
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
      builder: (context, state) => const TipsScreen(),
    ),
    GoRoute(
      path: '/road-diagram',
      builder: (context, state) => const RoadDiagramScreen(),
    ),
  ],
);
