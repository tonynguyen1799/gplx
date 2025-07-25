import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/exam.dart';
import '../providers/app_data_providers.dart';
import '../services/hive_service.dart';
import '../screens/exam_description_screen.dart';
import '../models/exam_progress.dart';
import '../providers/exam_progress_provider.dart';

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get selected license type (async)
    return FutureBuilder<String?>(
      future: getSelectedLicenseType(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final licenseTypeCode = snapshot.data!;
        final examsMap = ref.watch(examsProvider);
        final exams = examsMap[licenseTypeCode] ?? <Exam>[];

        // Dummy fallback if no exams (for dev)
        if (exams.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Về trang chủ',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              title: const Text('Danh sách đề thi', style: TextStyle(fontSize: 18)),
            ),
            body: const Center(child: Text('Không có đề thi nào.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: 'Về trang chủ',
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            title: const Text('Danh sách đề thi', style: TextStyle(fontSize: 18)),
          ),
          body: Consumer(
            builder: (context, ref, _) {
              final progressMap = ref.watch(examsProgressProvider);
              return Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
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
                    final passed = progress?.passed ?? false;
                    final correct = progress?.correctCount ?? 0;
                    final incorrect = progress?.incorrectCount ?? 0;
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ExamDescriptionScreen(
                              exam: exam,
                              licenseTypeCode: licenseTypeCode,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: !done
                              ? (Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.grey.shade100)
                              : passed
                                  ? (Theme.of(context).brightness == Brightness.dark ? Colors.green.shade900 : Colors.green.shade50)
                                  : (Theme.of(context).brightness == Brightness.dark ? Colors.red.shade900 : Colors.red.shade50),
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
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            if (done) ...[
                              Row(
                                children: [
                                  Icon(
                                    passed ? Icons.check_circle : Icons.cancel,
                                    color: passed ? Colors.green : Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(passed ? 'Đạt' : 'Không đạt', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Đúng $correct',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Sai $incorrect',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
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
                ),
              );
            },
          ),
        );
      },
    );
  }
} 