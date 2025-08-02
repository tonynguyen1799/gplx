/// QuizScreen Business Logic Documentation
///
/// ---
///
/// ## Core Principles
/// - This screen is for training/practice only. All logic here is **independent** from the exam quiz screen.
/// - Changes to exam mode (e.g., re-answering, feedback, answer locking) do **not** affect this screen.
/// - `_currentFilteredQuizzes` is a **snapshot** of the filtered quiz list, updated only on initial load and when the filter changes.
/// - Navigation and answer selection always operate on this snapshot, not a live filtered list.
/// - All quiz data and status are managed in-memory via Riverpod and synced to Hive in the background.
/// - The UI is always reactive to in-memory state, never direct Hive reads.
/// - **BookmarkButton** uses Riverpod for instant, reactive updates; no direct Hive access in the UI.
///
/// ## User Experience
/// - When a filter is applied, the quiz list is fixed until the filter changes again.
/// - Users can navigate and answer within the current snapshot, even if quiz status changes in the background.
/// - If a quiz is answered and no longer matches the filter, it remains in the snapshot until the filter is changed.
/// - **Bookmarking a quiz is instant and always reflects the latest state.**
/// - **Bookmark icon and label update immediately when tapped, with no loading spinner or delay.**
/// - **Bookmark state persists across navigation and app restarts.**
/// - **All status changes (answer, bookmark, progress) are reflected instantly in the UI.**
///
/// ## User Behavior & App Response
///
/// - **Apply Filter:**
///   - *User:* Selects a filter (e.g., done, not done, saved).
///   - *App:* Updates `_currentFilteredQuizzes` snapshot, resets quiz index and answer selection, UI shows new filtered list instantly.
///
/// - **Answer Quiz:**
///   - *User:* Selects an answer for the current quiz (can only answer once per quiz).
///   - *App:* Updates in-memory status (practiced/correct), UI highlights answer and updates progress bar instantly, syncs to Hive in background.
///
/// - **Bookmark Quiz:**
///   - *User:* Taps the bookmark icon.
///   - *App:* Toggles bookmark status in-memory, icon and label update instantly, syncs to Hive in background, persists across navigation and restarts.
///
/// - **Navigate Quiz:**
///   - *User:* Moves to next/previous quiz.
///   - *App:* Updates current index, resets answer selection, UI shows new quiz content instantly.
///
/// - **Restart App:**
///   - *User:* Closes and reopens the app.
///   - *App:* Loads all quiz data and status from Hive into memory, UI reflects last known state, including bookmarks and progress.
///
/// ## State Flow
/// 1. User answers a quiz → Riverpod provider updates in-memory state → UI updates instantly.
/// 2. User bookmarks a quiz → Riverpod provider updates in-memory state → UI updates instantly.
/// 3. Provider syncs changes to Hive in the background for persistence.
///
/// ## Provider Roles
/// - `quizzesProvider`: All quizzes for each license type.
/// - `topicsProvider`: All topics for each license type.
/// - `quizStatusProvider`: All quiz statuses, in-memory and synced to Hive.
/// - `progressSelectorProvider`: Computes progress from in-memory status.
///
/// ## Edge Cases
/// - If the user navigates to a quiz that is no longer in the current snapshot, navigation is clamped to the available range.
/// - If there are no quizzes matching the filter, a friendly message is shown.
///
/// ## Do Not
/// - Do not recalculate `_currentFilteredQuizzes` on every build.
/// - Do not read or write quiz status directly from Hive in the UI.
/// - Do not update the snapshot except on filter change or initial load.
/// - **Do not use direct Hive calls in BookmarkButton or any UI widget.**
///
/// ## Quick Reference Table
/// | User Action      | State Change                | UI Update                |
/// |------------------|----------------------------|--------------------------|
/// | Apply filter     | New snapshot, reset index   | New quiz list, reset UI  |
/// | Answer quiz      | Update provider, sync Hive  | Highlight, progress bar  |
/// | Bookmark quiz    | Update provider, sync Hive  | Icon/label update instant|
/// | Navigate quiz    | Update index, reset answer  | Show new quiz            |
/// | Change status    | Provider updates, UI reacts | Progress, status update  |
///
/// ---
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/quiz.dart';
import '../../providers/app_data_providers.dart';
import '../../models/license_type.dart';
import '../../models/quiz_practice_status.dart';
import '../../models/topic.dart';
import '../../services/hive_service.dart';
import 'package:go_router/go_router.dart';
import '../../utils/quiz_constants.dart';
import 'dart:async';
import '../../widgets/answer_options.dart';
import '../../widgets/quiz_content.dart';
import '../../providers/learning_progress.provider.dart';
import '../../widgets/quiz_shortcut.dart';
import '../../utils/app_colors.dart';
import '../../widgets/bookmark_button.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final Object? extra;
  const QuizScreen({super.key, this.extra});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int currentIndex = 0;
  late final PageController _pageController;
  String? licenseTypeCode;
  String? mode;
  String? topicId;
  String _currentFilter = 'all';
  int? _selectedIndex; // Selected answer index for the current quiz

  // Rename _filteredQuizSnapshot to _currentFilteredQuizzes
  List<Quiz> _currentFilteredQuizzes = [];

  late final LicenseType licenseType = (() {
    final licenseTypes = ref.watch(licenseTypesProvider);
    return licenseTypes.firstWhere(
      (lt) => lt.code == licenseTypeCode,
      orElse: () => LicenseType(
        code: licenseTypeCode ?? '',
        name: licenseTypeCode ?? '',
        description: '',
      ),
    );
  })();

  late final List<Topic> topics = (() {
    final topicsMap = ref.watch(topicsProvider);
    return topicsMap[licenseTypeCode] ?? [];
  })();

  late final List<Quiz> quizzes = (() {
    final quizzesMap = ref.watch(quizzesProvider);
    return quizzesMap.containsKey(licenseTypeCode)
        ? List<Quiz>.from(quizzesMap[licenseTypeCode]!)
        : <Quiz>[];
  })();

  late final String fatalTopicId = '${licenseTypeCode?.toLowerCase()}-fatal';

  void _updateCurrentFilteredQuizzes(String filter) {
    final topicsMap = ref.watch(topicsProvider);
    final quizzesMap = ref.watch(quizzesProvider);
    final statusMap = ref.watch(quizStatusProvider)[licenseTypeCode] ?? {};
    final List<Topic> topics = topicsMap[licenseTypeCode] ?? [];
    final List<Quiz> quizzes = quizzesMap.containsKey(licenseTypeCode)
        ? List<Quiz>.from(quizzesMap[licenseTypeCode]!)
        : <Quiz>[];
    final fatalTopicId = '${licenseTypeCode?.toLowerCase()}-fatal';
    final filtered = _getFilteredQuizzes(
      quizzes,
      statusMap,
      fatalTopicId,
      filter,
    );
    int newIndex = 0;
    if (filter == 'all') {
      newIndex = filtered.indexWhere((q) => statusMap[q.id]?.practiced != true);
      if (newIndex == -1) newIndex = 0;
    }
    // Debug print for currentIndex and filter
    print('Filter: $filter, Filtered count: ${filtered.length}, currentIndex: $newIndex');
    setState(() {
      _currentFilter = filter;
      _currentFilteredQuizzes = filtered;
      _selectedIndex = null;
      currentIndex = newIndex;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(currentIndex);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final params = widget.extra as Map<String, dynamic>?;
    if (params != null) {
      licenseTypeCode = params['licenseTypeCode'] as String?;
      mode = params['mode'] as String?;
      topicId = params['topicId'] as String?;
      final startIndex = params['startIndex'] as int?;
      if (startIndex != null) {
        currentIndex = startIndex;
      }
      final filter = params['filter'] as String?;
      if (filter != null && filter.isNotEmpty) {
        _currentFilter = filter;
      }
    }
    _pageController = PageController(initialPage: currentIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (licenseTypeCode != null) {
        _updateCurrentFilteredQuizzes(_currentFilter);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Centralized filtering method
  List<Quiz> _getFilteredQuizzes(
    List<Quiz> quizzes,
    Map<String, QuizPracticeStatus> statusMap,
    String fatalTopicId,
    String filter,
  ) {
    List<Quiz> filtered = quizzes;
    if (mode == QuizModes.TRAINING_BY_TOPIC_MODE &&
        topicId != null &&
        topicId!.isNotEmpty) {
      filtered = filtered.where((q) => q.topicIds.contains(topicId)).toList();
    }
    switch (filter) {
      case 'done':
        filtered = filtered.where((q) => statusMap[q.id]?.practiced == true).toList();
        break;
      case 'not_done':
        filtered = filtered
            .where((q) => statusMap[q.id] == null || statusMap[q.id]!.practiced != true)
            .toList();
        break;
      case 'wrong':
        filtered = filtered
            .where(
              (q) =>
                  statusMap[q.id]?.practiced == true &&
                  statusMap[q.id]?.correct == false,
            )
            .toList();
        break;
      case 'correct':
        filtered = filtered
            .where(
              (q) =>
                  statusMap[q.id]?.practiced == true &&
                  statusMap[q.id]?.correct == true,
            )
            .toList();
        break;
      case 'saved':
        filtered = filtered
            .where((q) => statusMap[q.id]?.saved == true)
            .toList();
        break;
      case 'fatal':
        filtered = filtered
            .where((q) => q.topicIds.contains(fatalTopicId))
            .toList();
        break;
      case 'difficult':
        filtered = filtered.where((q) => q.isDifficult == true).toList();
        break;
      case 'all':
      default:
        break;
    }
    return filtered;
  }

  // When user applies a new filter, update only the filter and reload the future
  Future<void> _applyFilter(String filter) async {
    if (licenseTypeCode == null) return;
    _updateCurrentFilteredQuizzes(filter);
  }

  Future<void> _selectAnswer(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    // Do async work in the background, do not block UI
    () async {
      if (licenseTypeCode != null) {
        final currentQuiz = _currentFilteredQuizzes[currentIndex];
        final quizId = currentQuiz.id;
        final statusMap = ref.read(quizStatusProvider)[licenseTypeCode!] ?? {};
        final isCorrect = index == currentQuiz.correctIndex;
        final prevStatus = statusMap[quizId];
        await ref.read(quizStatusProvider.notifier).updateStatus(
          licenseTypeCode!,
          quizId,
          QuizPracticeStatus(
            practiced: true,
            correct: isCorrect,
            saved: prevStatus?.saved ?? false,
            selectedIndex: index,
          ),
        );
      }
      // TODO: Handle errors if async work fails (e.g., show a snackbar)
    }();
  }

  void _nextQuestion(int total) {
    if (currentIndex < total - 1) {
      setState(() {
        currentIndex++;
        // Reset selection for the new quiz so user can re-answer
        _selectedIndex = null;
      });
    }
  }

  void _prevQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        // Reset selection for the new quiz so user can re-answer
        _selectedIndex = null;
      });
    }
  }

  Widget _buildFilterTile(
    BuildContext context,
    String label,
    String value, {
    bool isSelected = false,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: theme.quizFilterText,
        ),
      ),
      onTap: () => Navigator.pop(context, value),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      dense: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: theme.quizFilterCheckIcon,
            )
          : null,
    );
  }

  Widget _buildDivider() => Divider(
    color: Theme.of(context).dividerColor,
    height: 1,
    thickness: 1,
    indent: 16,
    endIndent: 16,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (licenseTypeCode == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy loại bằng lái.')),
      );
    }
    final statusMap = ref.watch(quizStatusProvider)[licenseTypeCode] ?? {};
    String? topicName;
    if (mode == QuizModes.TRAINING_BY_TOPIC_MODE &&
        topicId != null &&
        topicId!.isNotEmpty) {
      final topic = topics.firstWhere(
        (t) => t.id == topicId,
        orElse: () => Topic(id: topicId!, name: topicId!, description: ''),
      );
      topicName = topic.name;
    }
    if (currentIndex >= _currentFilteredQuizzes.length) {
      currentIndex = _currentFilteredQuizzes.isEmpty
          ? 0
          : _currentFilteredQuizzes.length - 1;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          mode == QuizModes.TRAINING_BY_TOPIC_MODE && topicName != null
                            ? '$topicName'
                            : (mode == QuizModes.TRAINING_MODE
                                  ? '${licenseType.name} - ${licenseType.code}'
                                  : licenseType.name),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
        centerTitle: true,
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () async {
            context.pop();
          },
                  ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                TextButton(
                      onPressed: () async {
                        final selected = await showModalBottomSheet<String>(
                          context: context,
                          builder: (context) {
                            return SafeArea(
                              child: Container(
                                decoration: BoxDecoration(
                              color: theme.quizFilterBackground,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                        child: Text(
                                          'Lọc câu hỏi',
                                          style: TextStyle(
                                        fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                        color: theme.quizFilterText,
                                          ),
                                        ),
                                      ),
                                      // First group
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                      color: theme.quizFilterGroupBackground,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            _buildFilterTile(
                                              context,
                                              mode ==
                                                          QuizModes
                                                              .TRAINING_BY_TOPIC_MODE &&
                                                  topicName != null
                                              ? 'Tất cả trong chủ đề này'
                                              : 'Tất cả',
                                              'all',
                                              isSelected: _currentFilter == 'all',
                                            ),
                                            Divider(
                                              height: 1,
                                          color: theme.dividerColor,
                                            ),
                                            _buildFilterTile(
                                              context,
                                              'Câu đã làm',
                                              'done',
                                              isSelected:
                                                  _currentFilter == 'done',
                                            ),
                                            Divider(
                                              height: 1,
                                          color: theme.dividerColor,
                                            ),
                                            _buildFilterTile(
                                              context,
                                              'Câu chưa làm',
                                              'not_done',
                                              isSelected:
                                                  _currentFilter == 'not_done',
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Second group
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                      color: theme.quizFilterGroupBackground,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            _buildFilterTile(
                                              context,
                                              'Câu sai',
                                              'wrong',
                                              isSelected:
                                                  _currentFilter == 'wrong',
                                            ),
                                            Divider(
                                              height: 1,
                                          color: theme.dividerColor,
                                            ),
                                            _buildFilterTile(
                                              context,
                                              'Câu đúng',
                                              'correct',
                                              isSelected:
                                                  _currentFilter == 'correct',
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Third group
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                      color: theme.quizFilterGroupBackground,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          children: [
                                            _buildFilterTile(
                                              context,
                                              'Câu đã lưu',
                                              'saved',
                                              isSelected:
                                                  _currentFilter == 'saved',
                                            ),
                                            Divider(
                                              height: 1,
                                          color: theme.dividerColor,
                                            ),
                                            _buildFilterTile(
                                              context,
                                              'Câu điểm liệt',
                                              'fatal',
                                              isSelected:
                                                  _currentFilter == 'fatal',
                                            ),
                                            Divider(
                                              height: 1,
                                          color: theme.dividerColor,
                                            ),
                                            _buildFilterTile(
                                              context,
                                              'Câu khó',
                                              'difficult',
                                              isSelected:
                                                  _currentFilter == 'difficult',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                        if (selected != null && selected != _currentFilter) {
                          await _applyFilter(selected);
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black,
                      ),
                  child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                      const Text(
                                'Lọc',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      const SizedBox(width: 6),
                              Icon(
                                Icons.filter_list,
                        color: theme.quizFilterButtonIcon,
                                size: 26,
                              ),
                            ],
                  ),
                          ),
                          if (_currentFilter != 'all')
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                  ),
                ),
              ],
            ),
      body: _currentFilteredQuizzes.isEmpty
          ? Container(
              width: double.infinity,
              color: theme.quizFilterBackground,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_alt_off, size: 48, color: theme.quizEmptyStateIcon),
                    const SizedBox(height: 20),
                    Text(
                      'Không có câu hỏi nào phù hợp với bộ lọc hiện tại',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: theme.quizEmptyStateText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : PageView.builder(
                      key: ValueKey(_currentFilter),
                      controller: _pageController,
                      itemCount: _currentFilteredQuizzes.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                          _selectedIndex = null;
                        });
                      },
                      itemBuilder: (context, index) {
                        final quiz = _currentFilteredQuizzes[index];
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                      children: [
                      const SizedBox(height: 8),
                        QuizContent(
                                quiz: quiz,
                                quizIndex: index,
                          totalQuizzes: _currentFilteredQuizzes.length,
                          licenseTypeCode: licenseTypeCode!,
                                status: statusMap[quiz.id],
                          onBookmarkChanged: () => setState(() {}),
                          fatalTopicId: fatalTopicId,
                                quizCode: '${licenseTypeCode}.${quizzes.indexWhere((q) => q.id == quiz.id) + 1}',
                          mode: mode,
                        ),
                              Padding(
                        padding: const EdgeInsets.all(12),
                        child: Divider(thickness: 1, height: 1, color: theme.dividerColor),
                              ),
                        AnswerOptions(
                                key: ValueKey(quiz.id),
                                answers: quiz.answers,
                                correctIndex: quiz.correctIndex,
                          onSelect: _selectAnswer,
                                selectedIndex: index == currentIndex ? _selectedIndex : null,
                                showExplanation: mode == QuizModes.TRAINING_MODE || mode == QuizModes.TRAINING_BY_TOPIC_MODE,
                                explanation: (mode == QuizModes.TRAINING_MODE || mode == QuizModes.TRAINING_BY_TOPIC_MODE) ? quiz.explanation : null,
                        tip: (mode == QuizModes.TRAINING_MODE || mode == QuizModes.TRAINING_BY_TOPIC_MODE) ? quiz.tip : null,
                          mode: mode ?? QuizModes.TRAINING_MODE,
                          lockAnswer: false,
                                isFatalQuiz: quiz.topicIds.contains(fatalTopicId),
                          examMode: '',
                        ),
                      const SizedBox(height: 8),
                      ],
                    ),
                        );
                      },
                  ),
      bottomNavigationBar: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed:
                                (_currentFilteredQuizzes.isNotEmpty && currentIndex > 0)
                                    ? () {
                                        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                                      }
                                : null,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade200,
                              disabledForegroundColor: Colors.grey,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Câu trước'),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: _currentFilteredQuizzes.isNotEmpty
                                ? () async {
                                    final selected = await showModalBottomSheet<int>(
                                      context: context,
                                      isScrollControlled: true,
                                      builder: (context) {
                                        return SafeArea(
                                          child: Container(
                                color: theme.quizBottomSheetBackground,
                                            child: SizedBox(
                                              height: MediaQuery.of(context).size.height * 0.7,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                                    ),
                                                    child: Text(
                                                      'Chọn câu hỏi',
                                                      style: TextStyle(
                                            fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                            color: theme.quizBottomSheetText,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: ListView.separated(
                                                      itemCount:
                                                          _currentFilteredQuizzes
                                                              .length,
                                                      separatorBuilder:
                                                          (context, idx) =>
                                                              Divider(
                                                                height: 1,
                                                    color: theme.dividerColor,
                                                              ),
                                                      itemBuilder: (context, idx) {
                                                        final q =
                                                            _currentFilteredQuizzes[idx];
                                                        return QuizShortcut(
                                                          quiz: q,
                                                          index: idx,
                                              originalIndex: quizzes.indexWhere((quiz) => quiz.id == q.id),
                                                          selected: idx == currentIndex,
                                                          onTap: () => Navigator.pop(context, idx),
                                              totalQuizzes: _currentFilteredQuizzes.length,
                                              practiced: statusMap[q.id]?.practiced == true,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                    if (selected != null) {
                                      _pageController.jumpToPage(selected);
                                    }
                                  }
                                : null,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue,
                              disabledBackgroundColor: Colors.grey.shade200,
                              disabledForegroundColor: Colors.grey,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: SizedBox(
                              height: 18,
                              child: Icon(Icons.list),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: _currentFilteredQuizzes.isNotEmpty && currentIndex < _currentFilteredQuizzes.length - 1
                                ? () {
                                    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                                  }
                                : null,
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade200,
                              disabledForegroundColor: Colors.grey,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Tiếp theo'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

String _filterLabel(String filter) {
  switch (filter) {
    case 'done':
      return 'Câu đã làm';
    case 'not_done':
      return 'Câu chưa làm';
    case 'wrong':
      return 'Câu sai';
    case 'correct':
      return 'Câu đúng';
    case 'saved':
      return 'Câu đã lưu';
    case 'fatal':
      return 'Câu điểm liệt';
    case 'difficult':
      return 'Câu khó';
    default:
      return filter;
  }
}
