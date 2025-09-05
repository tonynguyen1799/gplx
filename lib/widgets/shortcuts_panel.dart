import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


import 'package:gplx_vn/constants/quiz_constants.dart';
import 'package:gplx_vn/constants/route_constants.dart';

import 'package:gplx_vn/widgets/shortcut_widget.dart';
import 'package:gplx_vn/widgets/animated_shortcut_widget.dart';
import '../constants/app_colors.dart';
import 'package:gplx_vn/constants/ui_constants.dart';
import 'package:gplx_vn/screens/quiz/quiz_screen.dart';

class ShortcutsPanel extends StatelessWidget {
  final int totalSavedQuizzes;
  final int totalDifficultQuizzes;
  final int totalIncorrectQuizzes;
  final bool reminderEnabled;
  final String reminderTime;
  final VoidCallback? onNavigateToSettings;
  
  const ShortcutsPanel({
    super.key, 
    required this.totalSavedQuizzes, 
    required this.totalDifficultQuizzes, 
    required this.totalIncorrectQuizzes, 
    this.reminderEnabled = false,
    this.reminderTime = '21:00',
    this.onNavigateToSettings,
  });

  static const double containerPadding = CONTENT_PADDING;
  static const double borderRadius = BORDER_RADIUS;
  static const double subSectionSpacing = SECTION_SPACING;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shortcuts = <Widget>[
      ShortcutWidget(
        title: 'Câu đã lưu',
        icon: Icons.bookmark,
        badgeText: totalSavedQuizzes > 0 ? '$totalSavedQuizzes' : null,
        color: Colors.amber.shade600,
        onTap: () {
          final params = QuizScreenParams(
            trainingMode: TrainingMode.TOTAL,
            startIndex: 0,
                          filter: QuizFilterConstants.QUIZ_FILTER_SAVED,
          );
          context.push(RouteConstants.ROUTE_QUIZ, extra: params);
        },
      ),
      ShortcutWidget(
        title: 'Câu làm sai',
        icon: Icons.close,
        badgeText: totalIncorrectQuizzes > 0 ? '$totalIncorrectQuizzes' : null,
        color: Colors.red.shade400,
        onTap: () {
          final params = QuizScreenParams(
            trainingMode: TrainingMode.TOTAL,
            startIndex: 0,
                          filter: QuizFilterConstants.QUIZ_FILTER_INCORRECT,
          );
          context.push(RouteConstants.ROUTE_QUIZ, extra: params);
        },
      ),
      ShortcutWidget(
        title: 'Câu khó',
        icon: Icons.lightbulb,
        badgeText: totalDifficultQuizzes > 0 ? '$totalDifficultQuizzes' : null,
        color: Colors.deepPurple.shade400,
        onTap: () {
          final params = QuizScreenParams(
            trainingMode: TrainingMode.TOTAL,
            startIndex: 0,
                          filter: QuizFilterConstants.QUIZ_FILTER_DIFFICULT,
          );
          context.push(RouteConstants.ROUTE_QUIZ, extra: params);
        },
      ),
      ShortcutWidget(
        title: 'Biển báo',
        icon: Icons.signpost,
        color: Colors.indigo.shade400,
        onTap: () {
          context.push(RouteConstants.ROUTE_TRAFFIC_SIGNS);
        },
      ),
      ShortcutWidget(
        title: 'Sa hình',
        icon: Icons.map,
        color: Colors.teal.shade400,
        onTap: () {
          context.push(RouteConstants.ROUTE_ROAD_DIAGRAM);
        },
      ),
      ShortcutWidget(
        title: 'Mẹo',
        icon: Icons.tips_and_updates,
        color: Colors.orange.shade400,
        onTap: () {
          context.push(RouteConstants.ROUTE_TIPS);
        },
      ),
      ShortcutWidget(
        title: 'Nhắc nhở',
        icon: reminderEnabled ? Icons.notifications_active : Icons.notifications_off,
        badgeText: reminderEnabled && reminderTime.isNotEmpty ? reminderTime : null,
        color: Colors.green.shade800,
        onTap: onNavigateToSettings ?? () {},
      ),
      AnimatedShortcutWidget(
        title: 'Ủng hộ',
        icon: Icons.favorite,
        color: Colors.pink.shade300,
        onTap: () async {
        },
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.SURFACE_VARIANT,
        borderRadius: BorderRadius.circular(ShortcutsPanel.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: ShortcutsPanel.containerPadding,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: shortcuts.sublist(0, 4)
                  .map((widget) => Expanded(child: widget))
                  .toList(),
            ),
            const SizedBox(height: ShortcutsPanel.subSectionSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: shortcuts.sublist(4, 8)
                  .map((widget) => Expanded(child: widget))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
