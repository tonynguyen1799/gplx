import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shortcut_item.dart';
import '../widgets/shortcut_grid_item.dart';
import '../screens/home/viewmodel/shortcut_grid_view_model.dart';
import 'package:go_router/go_router.dart';
import '../utils/quiz_constants.dart';
import 'package:hive/hive.dart';
import '../services/hive_service.dart';
import '../utils/app_colors.dart';
import '../providers/app_data_providers.dart';

class ShortcutGridSection extends ConsumerWidget {
  final ShortcutGridViewModel viewModel;
  final String licenseTypeCode;
  const ShortcutGridSection({super.key, required this.viewModel, required this.licenseTypeCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Reminder subtitle (time) if enabled
    final reminderFuture = Future.wait([
      getReminderEnabled(),
      getReminderTime(),
    ]);
    
    return FutureBuilder<List<dynamic>>(
      future: reminderFuture,
      builder: (context, snapshot) {
        bool reminderEnabled = false;
        String reminderTime = '';
        String reminderDisplay = '';
        if (snapshot.hasData) {
          reminderEnabled = snapshot.data![0] as bool;
          reminderTime = snapshot.data![1] as String;
          if (reminderTime.isNotEmpty) {
            final parts = reminderTime.split(':');
            if (parts.isNotEmpty) {
              final hour = int.tryParse(parts[0]);
              final minute = parts.length > 1 ? int.tryParse(parts[1]) : null;
              if (hour != null && minute != null) {
                reminderDisplay = '$hour:${minute.toString().padLeft(2, '0')}';
              } else {
                reminderDisplay = reminderTime; // fallback
              }
            }
          }
        }
        final reminderIcon = reminderEnabled ? Icons.notifications_active : Icons.notifications_off;
    final shortcuts = [
      ShortcutItem(
        title: 'Câu đã lưu',
        icon: Icons.bookmark,
        count: viewModel.saved,
        color: Colors.amber.shade600,
        onTap: () {
          context.push('/quiz', extra: {
            'licenseTypeCode': licenseTypeCode,
            'mode': QuizModes.TRAINING_MODE,
            'startIndex': 0,
            'filter': 'saved',
          });
        },
      ),
      ShortcutItem(
        title: 'Câu sai',
        icon: Icons.close,
        count: viewModel.wrong,
        color: Colors.red.shade400,
        onTap: () async {
          // Load the current incorrect quiz IDs
          final statusMap = await loadQuizStatus(licenseTypeCode);
          final quizzesBox = await Hive.openBox('quizzesBox');
          final quizzes = quizzesBox.get(licenseTypeCode) ?? [];
          final incorrectQuizIds = (quizzes as List)
            .where((q) => statusMap[q.id]?.practiced == true && statusMap[q.id]?.correct == false)
            .map((q) => q.id)
            .toList();
          context.push('/quiz', extra: {
            'licenseTypeCode': licenseTypeCode,
            'mode': QuizModes.TRAINING_MODE,
            'startIndex': 0,
            'filter': 'wrong',
            'fixedQuizIds': incorrectQuizIds,
          });
        },
      ),
      ShortcutItem(
        title: 'Câu khó',
        icon: Icons.lightbulb,
        count: viewModel.difficult,
        color: Colors.deepPurple.shade400,
        onTap: () {
          context.push('/quiz', extra: {
            'licenseTypeCode': licenseTypeCode,
            'mode': QuizModes.TRAINING_MODE,
            'startIndex': 0,
            'filter': 'difficult',
          });
        },
      ),
      ShortcutItem(
        title: 'Biển báo',
        icon: Icons.signpost,
        color: Colors.indigo.shade400,
        onTap: () {
          context.push('/traffic-signs');
        },
      ),
      ShortcutItem(
        title: 'Sa hình',
        icon: Icons.map,
        color: Colors.teal.shade400,
        onTap: () {
          context.push('/road-diagram');
        },
      ),
      ShortcutItem(
        title: 'Mẹo',
        icon: Icons.tips_and_updates,
        color: Colors.orange.shade400,
        onTap: () {
          context.push('/tips', extra: {
            'licenseTypeCode': licenseTypeCode,
          });
        },
      ),
      ShortcutItem(
        title: 'Nhắc nhở',
        icon: reminderIcon,
        subtitle: reminderEnabled && reminderDisplay.isNotEmpty ? reminderDisplay : null,
        color: Colors.green.shade400,
        onTap: () {
          ref.read(mainNavIndexProvider.notifier).state = 1;
        },
      ),
      ShortcutItem(
        title: 'Ủng hộ',
        icon: Icons.favorite,
        color: Colors.pink.shade300,
        onTap: () {},
      ),
    ];

    final firstRow = shortcuts.sublist(0, 4);
    final secondRow = shortcuts.sublist(4, 8);

    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: firstRow
              .map((item) => Expanded(child: ShortcutGridItem(item: item)))
              .toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: secondRow
              .map((item) => Expanded(child: ShortcutGridItem(item: item)))
              .toList(),
        ),
      ],
      ),
    );
    },
    );
  }
}
