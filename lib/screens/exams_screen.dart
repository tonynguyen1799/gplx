import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/exam.dart';
import '../providers/app_data_providers.dart';
import '../providers/exam_progress_provider.dart';
import '../utils/app_colors.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final licenseTypeAsync = ref.watch(selectedLicenseTypeProvider);

    return licenseTypeAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => const Scaffold(body: Center(child: Text('Không thể tải loại GPLX'))),
      data: (licenseTypeCode) {
        final examsMap = ref.watch(examsProvider);
        final exams = examsMap[licenseTypeCode] ?? <Exam>[];

        if (exams.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Về trang chủ',
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Danh sách đề thi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              backgroundColor: theme.appBarBackground,
              foregroundColor: theme.appBarText,
              elevation: 0,
            ),
            body: const Center(child: Text('Không có đề thi nào.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Về trang chủ',
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Danh sách đề thi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            backgroundColor: theme.appBarBackground,
            foregroundColor: theme.appBarText,
            elevation: 0,
          ),
          body: Consumer(
            builder: (context, ref, _) {
              final progressMap = ref.watch(examsProgressProvider);
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: exams.length,
                itemBuilder: (context, index) {
                  final exam = exams[index];
                  final progress = progressMap[exam.id];
                  final done = progress != null;
                  final passed = progress?.isPassed ?? false;
                  final correct = progress?.totalCorrectQuizzes ?? 0;
                  final incorrect = progress?.totalIncorrectQuizzes ?? 0;

                  final backgroundColor = !done
                      ? theme.cardColor
                      : passed
                          ? theme.colorScheme.secondaryContainer
                          : theme.colorScheme.errorContainer;
                  final contentColor = !done
                      ? theme.colorScheme.onSurface
                      : passed
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onErrorContainer;

                  return GestureDetector(
                    onTap: () {
                      context.push('/exam-description', extra: {
                        'exam': exam,
                        'licenseTypeCode': licenseTypeCode,
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.22),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            exam.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: contentColor,
                            ),
                          ),
                          if (done) ...[
                            Row(
                              children: [
                                Icon(
                                  passed ? Icons.check_circle : Icons.cancel,
                                  color: contentColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  passed ? 'Đạt' : 'Không đạt',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: contentColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Đúng $correct',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: contentColor,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Sai $incorrect',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: contentColor,
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
  }
} 