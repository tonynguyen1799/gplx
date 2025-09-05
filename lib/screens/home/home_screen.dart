import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gplx_vn/models/hive/quiz_progress.dart';
import 'package:gplx_vn/models/riverpod/data/exam.dart';
import 'package:gplx_vn/models/riverpod/data/license_type.dart';
import 'package:gplx_vn/models/riverpod/data/quiz.dart';
import 'package:gplx_vn/models/riverpod/data/topic.dart';
import 'package:gplx_vn/models/riverpod/quizzes_progress.dart';
import 'package:gplx_vn/models/riverpod/topic_progress.dart';
import 'package:gplx_vn/models/reminder_settings.dart';
import 'package:gplx_vn/providers/app_data_providers.dart';
import 'package:gplx_vn/providers/license_type_provider.dart';
import 'package:gplx_vn/providers/quizzes_progress_provider.dart';
import 'package:gplx_vn/providers/reminder_provider.dart';
import 'package:gplx_vn/providers/navigation_provider.dart';
import 'package:gplx_vn/constants/navigation_constants.dart';
import 'package:gplx_vn/services/hive_service.dart';
import 'package:gplx_vn/constants/app_colors.dart';
import 'package:gplx_vn/widgets/exam_progress.dart';
import 'package:gplx_vn/widgets/shortcuts_panel.dart';
import 'package:gplx_vn/widgets/topics_progress.dart';
import 'package:gplx_vn/widgets/total_quizzes_progress.dart';
import 'package:gplx_vn/constants/route_constants.dart';
import 'package:gplx_vn/constants/quiz_constants.dart';
import 'package:gplx_vn/constants/ui_constants.dart';
import 'package:gplx_vn/screens/quiz/quiz_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final licenseTypeCodeAsync = ref.watch(licenseTypeProvider);
    final licenseTypes = ref.watch(licenseTypesProvider);

    return licenseTypeCodeAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
      data: (licenseTypeCode) {
        if (licenseTypeCode == null || !licenseTypes.any((lt) => lt.code == licenseTypeCode)) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await cleanUp();
            if (context.mounted) context.go(RouteConstants.ROUTE_HOME);
          });
          return const SizedBox.shrink();
        }

        final licenseType = licenseTypes.firstWhere((lt) => lt.code == licenseTypeCode);
        final quizzesAsync = ref.watch(quizzesProvider);
        final totalDifficultQuizzes = ref.watch(totalDifficultQuizzesProvider(licenseTypeCode));
        final totalQuizzesProgress = ref.watch(totalQuizzesProgressProvider(licenseTypeCode));
        final quizzesProgress = ref.watch(quizzesProgressProvider)[licenseTypeCode] ?? {};
        final topicsAsync = ref.watch(topicsProvider);
        final topicQuizzesProgress = ref.watch(topicQuizzesProgressProvider(licenseTypeCode));
        final examsAsync = ref.watch(examsProvider);
        final reminderSettingsAsync = ref.watch(reminderSettingsProvider);

        return _buildMainContent(
          theme,
          licenseType,
          quizzesAsync,
          totalDifficultQuizzes,
          quizzesProgress,
          totalQuizzesProgress,
          topicsAsync,
          topicQuizzesProgress,
          examsAsync,
          reminderSettingsAsync,
        );
      },
    );
  }





  Widget _buildMainContent(
    ThemeData theme,
    LicenseType licenseType,
    AsyncValue<List<Quiz>> quizzesAsync,
    int totalDifficultQuizzes,
    Map<String, QuizProgress> quizzesProgress,
    QuizzesProgress totalQuizzesProgress,
    AsyncValue<List<Topic>> topicsAsync,
    Map<String, TopicProgress> topicQuizzesProgress,
    AsyncValue<List<Exam>> examsAsync,
    AsyncValue<ReminderSettings> reminderSettingsAsync,
  ) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: NAVIGATION_HEIGHT,
        title: Text(
          '${licenseType.name} - ${licenseType.code}',
          style: const TextStyle(
            fontSize: APP_BAR_FONT_SIZE,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.APP_BAR_BG,
        foregroundColor: theme.APP_BAR_FG,
        elevation: 0,
        leading: null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
        child: ListView(
          children: [
            const SizedBox(height: SECTION_SPACING),
            quizzesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi khi tải dữ liệu: $err')),
              data: (quizzes) => TotalQuizzesProgress(
                key: ValueKey(licenseType.code),
                totalQuizzes: quizzes.length,
                quizzesProgress: totalQuizzesProgress,
                onTap: () => _onTotalQuizzesProgressTap(quizzes, quizzesProgress, licenseType.code),
              ),
            ),
            const SizedBox(height: SECTION_SPACING),
            examsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi khi tải dữ liệu: $err')),
              data: (exams) => ExamsProgress(
                key: ValueKey(licenseType.code),
                totalExams: exams.length,
              ),
            ),
            const SizedBox(height: SECTION_SPACING),
            reminderSettingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi khi tải dữ liệu: $err')),
              data: (reminder) => ShortcutsPanel(
                totalSavedQuizzes: totalQuizzesProgress.totalSavedQuizzes,
                totalDifficultQuizzes: totalDifficultQuizzes,
                totalIncorrectQuizzes: totalQuizzesProgress.totalIncorrectQuizzes,
                reminderEnabled: reminder.enabled,
                reminderTime: reminder.time24h,
                onNavigateToSettings: () {
                  ref.read(tabProvider.notifier).navigateToTab(MainNav.TAB_SETTINGS);
                },
              ),
            ),
            const SizedBox(height: SECTION_SPACING),
            Builder(builder: (context) {
              return topicsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Lỗi khi tải dữ liệu: $err')),
                data: (topics) => TopicsProgress(
                    topics: topics,
                    topicQuizzesProgress: topicQuizzesProgress,
                ),
              );
            }),
            const SizedBox(height: SECTION_SPACING),
          ],
        ),
      ),
    );
  }

  void _onTotalQuizzesProgressTap(List<Quiz> quizzes, Map<String, QuizProgress> quizzesProgress, String licenseTypeCode) {
    final nextQuizIdx = _calculateNextQuizIdx(quizzes, quizzesProgress);
    _goToQuizScreen(nextQuizIdx);
  }
  
  int _calculateNextQuizIdx(List<Quiz> quizzes, Map<String, QuizProgress> quizzesProgress) {
    for (int i = 0; i < quizzes.length; i++) {
      if (!(quizzesProgress[quizzes[i].id]?.isPracticed ?? false)) {
        return i;
      }
    }
    return quizzes.length - 1;
  }

  void _goToQuizScreen(int startIndex) {
    final params = QuizScreenParams(
      startIndex: startIndex,
      trainingMode: TrainingMode.TOTAL,
    );
    context.push(RouteConstants.ROUTE_QUIZ, extra: params);
  }
}