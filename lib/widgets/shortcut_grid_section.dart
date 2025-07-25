import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shortcut_item.dart';
import '../widgets/shortcut_grid_item.dart';
import '../screens/home/viewmodel/shortcut_grid_view_model.dart';
import 'package:go_router/go_router.dart';
import '../utils/quiz_constants.dart';
import 'package:hive/hive.dart';
import '../services/hive_service.dart';

class ShortcutGridSection extends StatelessWidget {
  final ShortcutGridViewModel viewModel;
  final String licenseTypeCode;
  const ShortcutGridSection({super.key, required this.viewModel, required this.licenseTypeCode});

  @override
  Widget build(BuildContext context) {
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
        onTap: () {},
      ),
      ShortcutItem(
        title: 'Mẹo',
        icon: Icons.tips_and_updates,
        color: Colors.orange.shade400,
        onTap: () {},
      ),
      ShortcutItem(
        title: 'Nhắc nhở',
        icon: Icons.notifications,
        color: Colors.green.shade400,
        onTap: () {},
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

    return Column(
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
    );
  }
}
