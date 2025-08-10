import 'package:flutter/material.dart';
import 'package:gplx_vn/widgets/real_exam_section.dart';
import 'package:gplx_vn/widgets/shortcut_grid_section.dart';
import 'package:gplx_vn/widgets/study_by_topic_section.dart';
import 'package:gplx_vn/widgets/study_progress_section.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:gplx_vn/services/hive_service.dart';
import 'package:gplx_vn/models/license_type.dart';
import 'package:gplx_vn/providers/app_data_providers.dart';
import 'package:gplx_vn/models/quiz.dart';
import 'package:gplx_vn/models/exam.dart';
import 'package:gplx_vn/utils/icon_color_utils.dart';
import 'package:gplx_vn/screens/home/viewmodel/shortcut_grid_view_model.dart';
import 'package:gplx_vn/screens/home/viewmodel/topic_progress_view_model.dart';
import 'package:gplx_vn/screens/home/viewmodel/real_exam_view_model.dart';
import 'package:gplx_vn/models/riverpod/quizzes_progress.dart';
import 'package:gplx_vn/models/topic.dart';
import 'package:gplx_vn/models/hive/quiz_progress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/quizzes_progress_provider.dart';
import 'package:gplx_vn/widgets/bottom_navigation_bar.dart';
import 'package:gplx_vn/utils/app_colors.dart';

ShortcutGridViewModel buildShortcutGridViewModel({required int saved, required int difficult, required int wrong}) {
  return ShortcutGridViewModel(saved: saved, difficult: difficult, wrong: wrong);
}

List<TopicProgressViewModel> buildTopicProgressViewModels(List<Topic> topics, List<Quiz> quizzes, Map perTopicProgress) {
  return topics.map<TopicProgressViewModel>((topic) {
    final total = quizzes.where((q) => q.topicIds.contains(topic.id)).length;
    final done = perTopicProgress[topic.id] ?? 0;
    return TopicProgressViewModel(
      id: topic.id,
      title: topic.name,
      done: done,
      total: total,
      icon: iconFromString(topic.icon),
      color: colorFromHex(topic.color),
    );
  }).toList();
}

RealExamViewModel buildRealExamViewModel(List<Exam> exams) {
  return RealExamViewModel(examCount: exams.length);
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Removed didChangeDependencies to prevent flicker

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ref = this.ref;
    final codeAsync = ref.watch(selectedLicenseTypeProvider);
    final licenseTypes = ref.watch(licenseTypesProvider);

    return codeAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Trang chủ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: theme.appBarBackground,
          foregroundColor: theme.appBarText,
          elevation: 0,
          leading: null,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: const [
              SizedBox(height: 24),
              // Placeholder skeletons
            ],
          ),
        ),
      ),
      error: (err, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Trang chủ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: theme.appBarBackground,
          foregroundColor: theme.appBarText,
          elevation: 0,
          leading: null,
        ),
        body: const SizedBox.shrink(),
      ),
      data: (code) {
        if (code == null || !licenseTypes.any((lt) => lt.code == code)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.go('/');
            }
          });
          return const SizedBox.shrink();
        }

        final type = licenseTypes.firstWhere((lt) => lt.code == code);
        final quizzesMap = ref.watch(quizzesProvider);
        final List<Quiz> quizzes = quizzesMap.containsKey(code)
            ? List<Quiz>.from(quizzesMap[code]!)
            : <Quiz>[];
        final progress = ref.watch(totalQuizzesProgressProvider(code));
        final topicsMap = ref.watch(topicsProvider);
        final perTopicProgress = ref.watch(topicQuizzessProgressProvider(code));
        final List<Topic> topics = topicsMap.containsKey(code)
            ? List<Topic>.from(topicsMap[code]!)
            : <Topic>[];
        final examsMap = ref.watch(examsProvider);
        final List<Exam> exams = examsMap.containsKey(code)
            ? List<Exam>.from(examsMap[code]!)
            : <Exam>[];
        final viewModel = buildRealExamViewModel(exams);

        return Scaffold(
          appBar: AppBar(
            title: Align(
              alignment: Alignment.center,
              child: Text('${type.name} - ${type.code}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            centerTitle: true,
            backgroundColor: theme.appBarBackground,
            foregroundColor: theme.appBarText,
            elevation: 0,
            leading: null,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FutureBuilder<Map<String, QuizProgress>>(
              future: loadQuizStatus(code),
              builder: (context, snapshot) {
                final statusMap = snapshot.data ?? {};
                final perTopicProgressInt = perTopicProgress.map((k, v) => MapEntry(k, v.totalPracticedQuizzes));
                return ListView(
                  children: [
                    const SizedBox(height: 12),
                    StudyProgressSection(
                      key: ValueKey(code),
                      total: quizzes.length,
                      progress: progress,
                      statusMap: statusMap,
                      onTap: () {
                        int startIndex = 0;
                        for (int i = 0; i < quizzes.length; i++) {
                          if (!(statusMap[quizzes[i].id]?.isPracticed ?? false)) {
                            startIndex = i;
                            break;
                          }
                          if (i == quizzes.length - 1) startIndex = i;
                        }
                        context.push('/quiz', extra: {
                          'licenseTypeCode': code,
                          'startIndex': startIndex,
                          'mode': 'training',
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    RealExamSection(
                      key: ValueKey(code),
                      examCount: viewModel.examCount,
                    ),
                    const SizedBox(height: 18),
                    Builder(builder: (context) {
                      final difficultCount = quizzes.where((q) => q.isDifficult == true).length;
                      return ShortcutGridSection(
                        viewModel: buildShortcutGridViewModel(
                          saved: progress.savedQuizIds.length,
                          difficult: difficultCount,
                          wrong: progress.totalIncorrectQuizzes,
                        ),
                        licenseTypeCode: code,
                      );
                    }),
                    const SizedBox(height: 12),
                    StudyByTopicSection(
                      topics: buildTopicProgressViewModels(
                        topics,
                        quizzes,
                        perTopicProgressInt,
                      ),
                      licenseTypeCode: code,
                      quizzes: quizzes,
                      statusMap: {},
                      perTopicProgress: perTopicProgress,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}