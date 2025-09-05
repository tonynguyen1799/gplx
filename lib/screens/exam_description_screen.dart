import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/riverpod/data/exam.dart';
import '../constants/quiz_constants.dart';
import '../constants/route_constants.dart';
import '../providers/app_data_providers.dart';
import '../providers/license_type_provider.dart';
import '../constants/app_colors.dart';
import '../constants/ui_constants.dart';
import '../screens/quiz/exam_quiz_screen.dart' show ExamQuizScreenParams;

class ExamDescriptionScreen extends StatefulWidget {
  final Exam exam;

  const ExamDescriptionScreen({Key? key, required this.exam}) : super(key: key);

  @override
  State<ExamDescriptionScreen> createState() => _ExamDescriptionScreenState();
}

class _ExamDescriptionScreenState extends State<ExamDescriptionScreen> {
  int _examMode = ExamModes.EXAM_NORMAL_MODE;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer(
      builder: (context, ref, _) {
        final asyncLicenseType = ref.watch(licenseTypeProvider);
        return asyncLicenseType.when(
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) => Scaffold(body: Center(child: Text('Lỗi khi tải loại GPLX: $err'))),
          data: (licenseTypeCode) => Scaffold(
            appBar: AppBar(
              toolbarHeight: NAVIGATION_HEIGHT,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              title: Text(
                '${widget.exam.name} - $licenseTypeCode',
                style: const TextStyle(fontSize: APP_BAR_FONT_SIZE, fontWeight: FontWeight.w600),
              ),
              backgroundColor: theme.APP_BAR_BG,
              foregroundColor: theme.APP_BAR_FG,
              elevation: 0,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(CONTENT_PADDING),
              child: Consumer(
                builder: (context, ref, _) {
                  final asyncConfig = ref.watch(configProvider);
                  
                  return asyncConfig.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Lỗi khi tải dữ liệu: $err')),
                    data: (config) {
                      final totalRequiredCorrectQuizzes = config.exam.totalRequiredCorrectQuizzes;
                      final totalOfQuizzes = config.exam.totalOfQuizzes;
                      final durationInMinutes = config.exam.durationInMinutes;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              'Bài thi thử lý thuyết GPLX hạng $licenseTypeCode',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: SECTION_SPACING * 2),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.SURFACE_VARIANT,
                              borderRadius: BorderRadius.circular(BORDER_RADIUS),
                            ),
                            padding: const EdgeInsets.all(CONTENT_PADDING),
                            child: Column(
                              children: [
                                _SpecRow(
                                  left: 'Số câu hỏi',
                                  right: '${widget.exam.quizIds.length}',
                                ),
                                const SizedBox(height: SECTION_SPACING * 2),
                                _SpecRow(
                                  left: 'Số câu đúng tối thiểu để đạt',
                                  right: '$totalRequiredCorrectQuizzes/$totalOfQuizzes',
                                ),
                                const SizedBox(height: SECTION_SPACING * 2),
                                _SpecRow(
                                  left: 'Thời gian làm bài',
                                  right: '$durationInMinutes phút',
                                ),
                                const SizedBox(height: SECTION_SPACING * 2),
                                const _SpecRow(
                                  left: 'Học viên trả lời sai câu hỏi điểm liệt sẽ bị trượt bài thi',
                                  // leftOpacity: 0.5,
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: CONTENT_PADDING),
                            child: Divider(height: 1, thickness: 1),
                          ),
                          _ExamModeSelector(
                            examMode: _examMode,
                            changeExamMode: _changeExamMode,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            bottomNavigationBar: SizedBox(
              width: double.infinity,
              height: NAVIGATION_HEIGHT,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: theme.NAVIGATION_FG,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                onPressed: _startExam,
                child: Text(
                  'Bắt đầu làm bài',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.NAVIGATION_BG,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _changeExamMode(int mode) {
    setState(() {
      _examMode = mode;
    });
  }

  void _startExam() {
    context.push(RouteConstants.ROUTE_EXAM_QUIZ, extra: ExamQuizScreenParams(
      examId: widget.exam.id,
      examMode: _examMode == ExamModes.EXAM_NORMAL_MODE ? ExamModes.EXAM_NORMAL_MODE : ExamModes.EXAM_QUICK_MODE,
      startIndex: 0,
    ));
  }
}

class _ExamModeSelector extends StatelessWidget {
  final int examMode;
  final ValueChanged<int> changeExamMode;
  const _ExamModeSelector({Key? key, required this.examMode, required this.changeExamMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn chế độ làm bài',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SECTION_SPACING),
        Container(
          decoration: BoxDecoration(
            color: theme.SURFACE_VARIANT,
            borderRadius: BorderRadius.circular(BORDER_RADIUS),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text('Chấm điểm sau khi nộp bài',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                )),
                onTap: () => changeExamMode(ExamModes.EXAM_NORMAL_MODE),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BORDER_RADIUS)),
                trailing: examMode == ExamModes.EXAM_NORMAL_MODE ? const Icon(Icons.check) : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
                dense: true,
              ),
              const Divider(height: 1, thickness: 1),
              ListTile(
                title: Text('Chấm điểm nhanh khi chọn đáp án',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                )),
                onTap: () => changeExamMode(ExamModes.EXAM_QUICK_MODE),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BORDER_RADIUS)),
                trailing: examMode == ExamModes.EXAM_QUICK_MODE ? const Icon(Icons.check) : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
                dense: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: SECTION_SPACING),
        if (examMode == ExamModes.EXAM_NORMAL_MODE) ...[
          const _SpecRow(
            left: 'Ứng dụng sẽ chấm điểm và hiển thị kết quả sau khi bạn nộp bài thi',
            leftOpacity: 0.5,
          ),
          SizedBox(height: SUB_SECTION_SPACING),
          const _SpecRow(
            left: 'Chế độ này tương tự khi thi sát hạch và phù hợp để luyện tập thi thử',
            leftOpacity: 0.5,
          ),
        ],
        if (examMode == ExamModes.EXAM_QUICK_MODE) ...[
          const _SpecRow(
            left: 'Ứng dụng sẽ chấm điểm ngay sau khi bạn chọn đáp án',
            leftOpacity: 0.5,
          ),
          SizedBox(height: SUB_SECTION_SPACING),
          const _SpecRow(
            left: 'Chế độ này giúp xem nhanh kết quả và phù hợp để ôn tập nhanh trước ngày làm bài thi thật',
            leftOpacity: 0.5,
          ),
        ],
      ],
    );
  }
} 

class _SpecRow extends StatelessWidget {
  final String left;
  final String? right;
  final double? leftOpacity;
  const _SpecRow({required this.left, this.right, this.leftOpacity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            left,
            textAlign: TextAlign.left,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(leftOpacity ?? 0.8),
            ),
          ),
        ),
        if (right != null)
          Expanded(
            flex: 2,
            child: Text(
              right!,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}