import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_data_providers.dart';
import '../providers/license_type_provider.dart';
import '../providers/exams_progress_provider.dart';
import '../constants/app_colors.dart';
import '../constants/route_constants.dart';
import '../models/hive/exam_progress.dart';
import '../constants/ui_constants.dart';
import '../widgets/error_scaffold.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});
 
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final licenseTypeAsync = ref.watch(licenseTypeProvider);
    final examsAsync = ref.watch(examsProvider);
    
    if (licenseTypeAsync.isLoading || examsAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    if (licenseTypeAsync.hasError || examsAsync.hasError) {
      return ErrorScaffold(message: 'Lỗi khi tải dữ liệu');
    }
    
    final licenseTypeCode = licenseTypeAsync.value;
    final exams = examsAsync.value!;
    
    if (licenseTypeCode == null || licenseTypeCode.isEmpty) {
      return const ErrorScaffold(message: 'Không tìm thấy loại bằng lái.');
    }
    
    if (exams.isEmpty) {
      return const ErrorScaffold(message: 'Không có đề thi nào.');
    }
    
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: NAVIGATION_HEIGHT,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Danh sách đề thi - $licenseTypeCode',
          style: TextStyle(
            fontSize: APP_BAR_FONT_SIZE, 
            fontWeight: FontWeight.w600
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.APP_BAR_BG,
        foregroundColor: theme.APP_BAR_FG,
        elevation: 0,
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final examsProgress = ref.watch(examsProgressProvider);
          final Map<String, ExamProgress> examIdToExamProgress = examsProgress[licenseTypeCode] ?? {};
          return GridView.builder(
            padding: const EdgeInsets.all(CONTENT_PADDING),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: CONTENT_PADDING,
              mainAxisSpacing: CONTENT_PADDING,
              childAspectRatio: kIsWeb ? 2 : 1.2,
            ),
            itemCount: exams.length,
            itemBuilder: (context, index) {
              final exam = exams[index];
              final examProgress = examIdToExamProgress[exam.id];
              final isPracticed = examProgress != null;
              final isPassed = examProgress?.isPassed ?? false;
              final bgColor = !isPracticed
                    ? theme.SURFACE_VARIANT
                    : isPassed ? theme.SUCCESS_COLOR : theme.ERROR_COLOR;
              final fgColor = isPracticed ? Colors.white : null;

              return GestureDetector(
                onTap: () {
                  context.push(RouteConstants.ROUTE_EXAM_DESCRIPTION, extra: {
                    'exam': exam,
                  });
                },
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: kIsWeb ? 100 : 200),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(BORDER_RADIUS),
                    ),
                    padding: const EdgeInsets.all(CONTENT_PADDING),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // Prevent column from taking too much space
                    children: [
                      Text(
                        exam.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: fgColor,
                        ),
                      ),
                      if (isPracticed) ...[
                        Row(
                          children: [
                            Icon(
                              isPassed ? Icons.check_circle : Icons.cancel,
                              color: fgColor,
                            ),
                            SizedBox(width: SUB_SECTION_SPACING),
                            Text(
                              isPassed ? 'Đạt' : 'Không đạt',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: fgColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: SECTION_SPACING),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Đúng ${examProgress?.totalCorrectQuizzes ?? 0}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: fgColor?.withValues(alpha: 0.8),
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Sai ${examProgress?.totalIncorrectQuizzes ?? 0}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: fgColor?.withValues(alpha: 0.8),
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
            },
          );
        },
      ),
    );
  }
} 