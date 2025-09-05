import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../constants/quiz_constants.dart';
import '../../constants/ui_constants.dart';
import '../../models/riverpod/data/quiz.dart';
import '../../models/riverpod/data/license_type.dart';
import '../../models/hive/quiz_progress.dart';
import '../../models/riverpod/data/topic.dart';
import '../../providers/app_data_providers.dart';
import '../../providers/quizzes_progress_provider.dart';
import '../../providers/license_type_provider.dart';
import '../../constants/app_colors.dart';
import '../../widgets/quiz_bottom_navigation.dart';
import '../../widgets/quiz_page.dart';
import '../../widgets/quiz_filter_bottom_sheet.dart';
import '../../widgets/quiz_shortcuts_bottom_sheet.dart';
import '../../widgets/error_scaffold.dart';

class QuizScreenParams {
  final TrainingMode? trainingMode;
  final String? topicId;
  final int? startIndex;
  final int? filter;

  const QuizScreenParams({
    this.trainingMode,
    this.topicId,
    this.startIndex,
    this.filter,
  });
}

class QuizScreen extends ConsumerStatefulWidget {
  final QuizScreenParams params;
  
  const QuizScreen({
    super.key,
    required this.params,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  int? _answeredIndex;
  int _currentFilter = QuizFilterConstants.QUIZ_FILTER_ALL;
  List<Quiz> _currentFilteredQuizzes = [];
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    if (widget.params.startIndex != null) {
      _currentIndex = widget.params.startIndex!;
    }
    if (widget.params.filter != null) {
      _currentFilter = widget.params.filter!;
    }
    _pageController = PageController(initialPage: _currentIndex);

  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final topicsAsync = ref.watch(topicsProvider);
    final quizzesAsync = ref.watch(quizzesProvider);
    final licenseTypeAsync = ref.watch(licenseTypeProvider);
    final licenseTypes = ref.watch(licenseTypesProvider); // This is not AsyncValue
    
    if (topicsAsync.isLoading || quizzesAsync.isLoading || licenseTypeAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (topicsAsync.hasError || quizzesAsync.hasError || licenseTypeAsync.hasError) {
      return ErrorScaffold(message: 'Lỗi khi tải dữ liệu.');
    }
    
    final topics = topicsAsync.value!;
    final quizzes = quizzesAsync.value!;
    final licenseTypeCode = licenseTypeAsync.value;
    
    if (licenseTypeCode == null || licenseTypeCode.isEmpty) {
      return const ErrorScaffold(message: 'Không tìm thấy loại bằng lái.');
    }
    
    if (quizzes.isEmpty) {
      return const ErrorScaffold(message: 'Không có câu hỏi nào.');
    }
    
    final licenseType = licenseTypes.firstWhere(
      (lt) => lt.code == licenseTypeCode,
      orElse: () => LicenseType(
        code: licenseTypeCode,
        name: licenseTypeCode,
        description: '',
      ),
    );

    final quizzesProgress = ref.read(quizzesProgressProvider)[licenseTypeCode] ?? {};
    
    if (_currentFilteredQuizzes.isEmpty && quizzes.isNotEmpty) {
      _currentFilteredQuizzes = _getFilteredQuizzes(
        quizzes, 
        quizzesProgress, 
        licenseTypeCode, 
        _currentFilter,
        widget.params.trainingMode,
        widget.params.topicId,
      );
    }

    if (_currentIndex >= _currentFilteredQuizzes.length) {
      _currentIndex = _currentFilteredQuizzes.isEmpty ? 0 : _currentFilteredQuizzes.length - 1;
    }

    final topic = widget.params.trainingMode == TrainingMode.BY_TOPIC &&
        widget.params.topicId != null &&
        widget.params.topicId!.isNotEmpty
        ? topics.firstWhere(
          (t) => t.id == widget.params.topicId,
          orElse: () => Topic(id: widget.params.topicId!, name: widget.params.topicId!, description: ''),
        ).name
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          topic != null
            ? '$topic'
            : '${licenseType.name} - ${licenseType.code}',
          style: const TextStyle(
            fontSize: APP_BAR_FONT_SIZE,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.APP_BAR_BG,
        foregroundColor: theme.APP_BAR_FG,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          Align(
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                TextButton(
                  onPressed: () async {
                    final selectedFilter = await showModalBottomSheet<int>(
                      context: context,
                      builder: (context) => QuizFilterBottomSheet(
                        currentFilter: _currentFilter,
                        trainingMode: widget.params.trainingMode,
                        topic: topic,
                      ),
                    );
                    if (selectedFilter != null && selectedFilter != _currentFilter) {
                      _onFilter(
                        selectedFilter, 
                        licenseTypeCode, 
                        quizzes, 
                        quizzesProgress,
                        widget.params.trainingMode,
                        widget.params.topicId,
                      );
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Lọc',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.filter_list,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ],
                  ),
                ),
                if (_currentFilter != QuizFilterConstants.QUIZ_FILTER_ALL)
                  Positioned(
                    top: 12,
                    right: 6,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: _currentFilteredQuizzes.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_alt_off, size: 48),
                Text(
                  'Không có câu hỏi nào phù hợp với bộ lọc hiện tại',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : PageView.builder(
            key: ValueKey(_currentFilter),
            controller: _pageController,
            itemCount: _currentFilteredQuizzes.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final currentQuiz = _currentFilteredQuizzes[index];
              final currentStatus = quizzesProgress[currentQuiz.id];
              
              return QuizPage(
                quiz: currentQuiz,
                progress: currentStatus,
                quizIndex: index,
                totalQuizzes: _currentFilteredQuizzes.length,
                selectedIdx: index == _currentIndex ? _answeredIndex : null,
                isViewed: _answeredIndex != null,
                lockAnswer: _answeredIndex != null,
                onAnswer: (answerIndex) {
                  _onAnswered(
                    answerIndex,
                    licenseTypeCode,
                    quizzesProgress,
                  );
                },
              );
            },
        ),
      bottomNavigationBar: QuizBottomNavigation(
        onPrevious: (_currentIndex > 0) ? _onPreviousPage : null,
        onShowQuizzes: _currentFilteredQuizzes.isNotEmpty ? () => _onShowQuizzes(licenseTypeCode, quizzesProgress) : null,
        onNext: (_currentIndex < _currentFilteredQuizzes.length - 1) ? _onNextPage : null,
      ),
    );
  }

  void _onFilter(
    int filter, 
    String licenseTypeCode, 
    List<Quiz> quizzes, 
    Map<String, QuizProgress> quizzesProgress,
    TrainingMode? trainingMode,
    String? topicId,
  ) {
    final filteredQuizzes = _getFilteredQuizzes(
      quizzes,
      quizzesProgress,
      licenseTypeCode,
      filter,
      trainingMode,
      topicId,
    );
    int currentIndex = 0;
    if (filter == QuizFilterConstants.QUIZ_FILTER_ALL) {
      currentIndex = filteredQuizzes.indexWhere((q) => quizzesProgress[q.id]?.isPracticed != true);
      if (currentIndex == -1) currentIndex = 0;
    }
    setState(() {
      _currentFilter = filter;
      _currentFilteredQuizzes = filteredQuizzes;
      _answeredIndex = null;
      _currentIndex = currentIndex;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      }
    });
  }

  List<Quiz> _getFilteredQuizzes(
    List<Quiz> quizzes,
    Map<String, QuizProgress> quizzesProgress,
    String licenseTypeCode,
    int filter,
    TrainingMode? trainingMode,
    String? topicId,
  ) {
    final fatalTopicId = '${licenseTypeCode.toLowerCase()}-fatal';

    List<Quiz> filteredQuizzes = quizzes;
    if (trainingMode == TrainingMode.BY_TOPIC &&
        topicId != null &&
        topicId.isNotEmpty) {
      filteredQuizzes = filteredQuizzes.where((q) => q.topicIds.contains(topicId)).toList();
    }
    switch (filter) {
      case QuizFilterConstants.QUIZ_FILTER_PRACTICED:
        filteredQuizzes = filteredQuizzes.where((q) => quizzesProgress[q.id]?.isPracticed == true).toList();
        break;
      case QuizFilterConstants.QUIZ_FILTER_UNPRACTICED:
        filteredQuizzes = filteredQuizzes
            .where((q) => quizzesProgress[q.id] == null || quizzesProgress[q.id]!.isPracticed != true)
            .toList();
        break;
      case QuizFilterConstants.QUIZ_FILTER_INCORRECT:
        filteredQuizzes = filteredQuizzes
            .where(
              (q) =>
                  quizzesProgress[q.id]?.isPracticed == true &&
                  quizzesProgress[q.id]?.isCorrect == false,
            )
            .toList();
        break;
      case QuizFilterConstants.QUIZ_FILTER_CORRECT:
        filteredQuizzes = filteredQuizzes
            .where(
              (q) =>
                  quizzesProgress[q.id]?.isPracticed == true &&
                  quizzesProgress[q.id]?.isCorrect == true,
            )
            .toList();
        break;
      case QuizFilterConstants.QUIZ_FILTER_SAVED:
        filteredQuizzes = filteredQuizzes
            .where((q) => quizzesProgress[q.id]?.isSaved == true)
            .toList();
        break;
      case QuizFilterConstants.QUIZ_FILTER_FATAL:
        filteredQuizzes = filteredQuizzes
            .where((q) => q.topicIds.contains(fatalTopicId))
            .toList();
        break;
      case QuizFilterConstants.QUIZ_FILTER_DIFFICULT:
        filteredQuizzes = filteredQuizzes.where((q) => q.isDifficult == true).toList();
        break;
      case QuizFilterConstants.QUIZ_FILTER_ALL:
      default:
        break;
    }
    return filteredQuizzes;
  }
  
  void _onAnswered(
    int index,
    String licenseTypeCode,
    Map<String, QuizProgress> quizzesProgress,
  ) {
    setState(() {
      _answeredIndex = index;
    });

    final currentQuiz = _currentFilteredQuizzes[_currentIndex];
    final quizId = currentQuiz.id;
    final isCorrect = index == currentQuiz.correctIndex;
    final prevProgress = quizzesProgress[quizId];
    
    ref.read(quizzesProgressProvider.notifier).updateQuizProgress(
      licenseTypeCode,
      quizId,
      QuizProgress(
        isPracticed: true,
        isCorrect: isCorrect,
        isSaved: prevProgress?.isSaved ?? false,
        selectedIdx: index,
      ),
    );
  }

  void _onPreviousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _onNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _onShowQuizzes(String licenseTypeCode, Map<String, QuizProgress> quizzesProgress) async {
    final selectedQuizIndex = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => QuizShortcutsBottomSheet(
        quizzes: _currentFilteredQuizzes,
        currentIndex: _currentIndex,
        quizzesProgress: quizzesProgress,
      ),
    );
    if (selectedQuizIndex != null) {
      _pageController.jumpToPage(selectedQuizIndex);
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _answeredIndex = null;
    });
  }
}