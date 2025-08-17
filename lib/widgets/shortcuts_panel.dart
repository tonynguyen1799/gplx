import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:gplx_vn/constants/navigation_constants.dart';
import 'package:gplx_vn/constants/quiz_constants.dart';
import 'package:gplx_vn/constants/route_constants.dart';

import 'package:gplx_vn/widgets/shortcut_widget.dart';
import 'package:gplx_vn/widgets/animated_shortcut_widget.dart';
import 'package:gplx_vn/screens/main_navigation_screen.dart';
import '../utils/app_colors.dart';

class ShortcutsPanel extends StatelessWidget {
  final int totalSavedQuizzes;
  final int totalDifficultQuizzes;
  final int totalIncorrectQuizzes;
  final bool reminderEnabled;
  final String reminderTime;
  
  const ShortcutsPanel({
    super.key, 
    required this.totalSavedQuizzes, 
    required this.totalDifficultQuizzes, 
    required this.totalIncorrectQuizzes, 
    this.reminderEnabled = false,
    this.reminderTime = '',
  });

  static const double containerPadding = 16.0;
  static const double borderRadius = 12.0;
  static const double subSectionSpacing = 12.0;

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
          context.push(RouteConstants.ROUTE_QUIZ, extra: {
            'mode': QuizModes.TRAINING_MODE,
            'startIndex': 0,
            'filter': QuizConstants.QUIZ_FILTER_SAVED,
          });
        },
      ),
      ShortcutWidget(
        title: 'Câu làm sai',
        icon: Icons.close,
        badgeText: totalIncorrectQuizzes > 0 ? '$totalIncorrectQuizzes' : null,
        color: Colors.red.shade400,
        onTap: () {
          context.push(RouteConstants.ROUTE_QUIZ, extra: {
            'mode': QuizModes.TRAINING_MODE,
            'startIndex': 0,
            'filter': QuizConstants.QUIZ_FILTER_INCORRECT,
          });
        },
      ),
      ShortcutWidget(
        title: 'Câu khó',
        icon: Icons.lightbulb,
        badgeText: totalDifficultQuizzes > 0 ? '$totalDifficultQuizzes' : null,
        color: Colors.deepPurple.shade400,
        onTap: () {
          context.push(RouteConstants.ROUTE_QUIZ, extra: {
            'mode': QuizModes.TRAINING_MODE,
            'startIndex': 0,
            'filter': QuizConstants.QUIZ_FILTER_DIFFICULT,
          });
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
        color: Colors.green.shade400,
        onTap: () {
          MainNavigationScreen.switchToTab(MainNav.TAB_SETTINGS);
        },
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
