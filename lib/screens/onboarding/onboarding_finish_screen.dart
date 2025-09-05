import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/hive_service.dart';
import '../../constants/app_colors.dart';
import 'package:gplx_vn/constants/navigation_constants.dart';
import 'package:gplx_vn/constants/ui_constants.dart';

class OnboardingFinishScreen extends ConsumerWidget {
  const OnboardingFinishScreen({super.key});

  Future<void> _completeOnboarding(BuildContext context, WidgetRef ref) async {
    await setOnboardingComplete(true);
            context.go('/main', extra: {'initialIndex': MainNav.TAB_HOME});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: SECTION_SPACING * 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bắt đầu hành trình ôn tập!',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Bạn muốn học từng phần hay làm bài thi mô phỏng ngay?',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SECTION_SPACING),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => _completeOnboarding(context, ref),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(CONTENT_PADDING),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.DARK_SURFACE_VARIANT, width: 1),
                          borderRadius: BorderRadius.circular(BORDER_RADIUS),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.list_alt, size: 28, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Luyện tập từng phần', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Học theo từng chủ đề, từng loại câu hỏi',
                                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => _completeOnboarding(context, ref),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer, size: 28, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Thi thử mô phỏng', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Trải nghiệm bài thi thật với giới hạn thời gian',
                                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.5), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _completeOnboarding(context, ref),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: const Text('Tôi chưa chắc, để tôi khám phá trước'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
