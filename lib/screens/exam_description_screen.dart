import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/riverpod/data/exam.dart';

import '../constants/quiz_constants.dart';
import '../constants/route_constants.dart';
import '../providers/app_data_providers.dart';
import '../utils/app_colors.dart';

class ExamDescriptionScreen extends StatefulWidget {
  final Exam exam;
  final String licenseTypeCode;

  const ExamDescriptionScreen({Key? key, required this.exam, required this.licenseTypeCode}) : super(key: key);

  @override
  State<ExamDescriptionScreen> createState() => _ExamDescriptionScreenState();
}

class _ExamDescriptionScreenState extends State<ExamDescriptionScreen> {
  int _selectedMode = 0; // 0: Chấm điểm sau khi nộp bài, 1: Chấm điểm nhanh khi chọn đáp án

  void _onModeChanged(int mode) {
    setState(() {
      _selectedMode = mode;
    });
  }

  void _startExam() {
            context.push(RouteConstants.ROUTE_EXAM_QUIZ, extra: {
      'exam_mode': _selectedMode == 0 ? ExamModes.EXAM_NORMAL_MODE : ExamModes.EXAM_QUICK_MODE,
      'examId': widget.exam.id,
      'startIndex': 0,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mô tả đề thi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarText,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Consumer(
          builder: (context, ref, _) {
            final asyncConfig = ref.watch(configProvider);
            
            return asyncConfig.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi khi tải dữ liệu: $err')),
              data: (config) {
                    final minCorrect = config.exam.totalRequiredCorrectQuizzes;
    final numQuizzes = config.exam.totalOfQuizzes;
                final duration = config.exam.durationInMinutes;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Bài thi thử lý thuyết GPLX hạng ${widget.licenseTypeCode}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text('Số câu hỏi', textAlign: TextAlign.left, style: TextStyle(fontSize: 14, color: theme.primaryText)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('${widget.exam.quizIds.length}', textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: theme.primaryText)),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text('Số câu đúng tối thiểu để đạt', textAlign: TextAlign.left, style: const TextStyle(fontSize: 14)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('$minCorrect/$numQuizzes', textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text('Thời gian làm bài', textAlign: TextAlign.left, style: const TextStyle(fontSize: 14)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('$duration phút', textAlign: TextAlign.right, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text('Học viên trả lời sai câu hỏi điểm liệt sẽ bị trượt bài thi', textAlign: TextAlign.left, style: const TextStyle(fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _ExamModeSelector(
                  selectedMode: _selectedMode,
                  onModeChanged: _onModeChanged,
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
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: _startExam,
          child: const Text(
            'Bắt đầu làm bài',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExamModeSelector extends StatelessWidget {
  final int selectedMode;
  final ValueChanged<int> onModeChanged;
  const _ExamModeSelector({Key? key, required this.selectedMode, required this.onModeChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn chế độ làm bài',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text('Chấm điểm sau khi nộp bài', style: TextStyle(fontSize: 14, color: theme.primaryText)),
                onTap: () => onModeChanged(0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                trailing: selectedMode == 0 ? Icon(Icons.check, color: theme.primaryColor) : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                dense: true,
              ),
              Divider(height: 1, thickness: 1, color: theme.dividerColor, indent: 16, endIndent: 16),
              ListTile(
                title: Text('Chấm điểm nhanh khi chọn đáp án', style: TextStyle(fontSize: 14, color: theme.primaryText)),
                onTap: () => onModeChanged(1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                trailing: selectedMode == 1 ? Icon(Icons.check, color: theme.primaryColor) : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                dense: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (selectedMode == 0) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: Text(
                  'Ứng dụng sẽ chấm điểm và hiển thị kết quả sau khi bạn nộp bài thi',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: Text(
                  'Chế độ này tương tự khi thi sát hạch và phù hợp để luyện tập thi thử',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
        if (selectedMode == 1) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: Text(
                  'Ứng dụng sẽ chấm điểm ngay sau khi bạn chọn đáp án',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Expanded(
                child: Text(
                  'Chế độ này giúp xem nhanh kết quả và phù hợp để ôn tập nhanh trước ngày làm bài thi thật',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
} 