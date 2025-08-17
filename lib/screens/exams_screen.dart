import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/app_data_providers.dart';
import '../providers/license_type_provider.dart';
import '../providers/exams_progress_provider.dart';
import '../utils/app_colors.dart';
import '../constants/route_constants.dart';
import '../models/hive/exam_progress.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  static const double appBarFontSize = 18.0;
  static const double contentPadding = 16.0;
  static const double borderRadius = 12.0;
  static const double sectionSpacing = 12.0;
  static const double subSectionSpacing = 6.0;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final licenseTypeAsync = ref.watch(licenseTypeProvider);

    return licenseTypeAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const Scaffold(body: Center(child: Text('Không thể tải loại GPLX'))),
      data: (licenseTypeCode) {
        final asyncExams = ref.watch(examsProvider);

        return asyncExams.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Lỗi khi tải dữ liệu: $err')),
          data: (exams) {
            return Scaffold(
              appBar: AppBar(
                toolbarHeight: 48.0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  'Thi thử mô phỏng - $licenseTypeCode',
                  style: TextStyle(
                    fontSize: appBarFontSize, 
                    fontWeight: FontWeight.w600
                  ),
                ),
                centerTitle: true,
                backgroundColor: theme.appBarBackground,
                foregroundColor: theme.appBarText,
                elevation: 0,
              ),
              body: exams.isEmpty
                  ? const Center(child: Text('Không có đề thi nào.'))
                  : Consumer(
                    builder: (context, ref, _) {
                      final examsProgress = ref.watch(examsProgressProvider);
                      final Map<String, ExamProgress> examIdToExamProgress = examsProgress[licenseTypeCode] ?? {};
                      return GridView.builder(
                        padding: const EdgeInsets.all(contentPadding),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: contentPadding,
                          mainAxisSpacing: contentPadding,
                          childAspectRatio: 1.1,
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
                                'licenseTypeCode': licenseTypeCode,
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(borderRadius),
                              ),
                              padding: const EdgeInsets.all(contentPadding),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                        SizedBox(width: subSectionSpacing),
                                        Text(
                                          isPassed ? 'Đạt' : 'Không đạt',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: fgColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: sectionSpacing),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Đúng ${examProgress?.totalCorrectQuizzes ?? 0}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: fgColor?.withOpacity(0.8),
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Sai ${examProgress?.totalIncorrectQuizzes ?? 0}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: fgColor?.withOpacity(0.8),
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
                          );
                        },
                      );
                    },
                  ),
            );
          },
        );
      },
    );
  }
} 