import 'package:flutter/material.dart';
import '../models/riverpod/data/quiz.dart';
import 'exam_key_button.dart';

class ExamKeyButtonsWidget extends StatelessWidget {
  final Quiz quiz;
  final bool lockAnswer;
  final Function(String, int) onAnswer;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const ExamKeyButtonsWidget({
    super.key,
    required this.quiz,
    required this.lockAnswer,
    required this.onAnswer,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double gap = 0;
        const int totalButtons = 6; // prev, 1,2,3,4, next
        final double rawSize = (constraints.maxWidth - gap * (totalButtons - 1)) / totalButtons;
        final double buttonSize = rawSize.clamp(56.0, 110.0);
        final double arrowIconSize = (buttonSize * 0.20).clamp(16.0, 26.0);
        final double numberFontSize = (buttonSize * 0.28).clamp(14.0, 22.0);

        return Row(
          children: [
            ...[for (int i = 0; i < 4; i++) ...[
              if (i > 0) SizedBox(width: gap),
              Builder(
                builder: (_) {
                  final idx = i;
                  final enabled = !lockAnswer && quiz.answers.length > idx;
                  return ExamKeyButton(
                    notPressedAssetPath: 'assets/images/key_not_pressed.png',
                    pressedAssetPath: 'assets/images/key_pressed.png',
                    size: buttonSize,
                    bleedPx: 16,
                    isEnabled: enabled,
                    overlayChild: Text('${idx + 1}', style: TextStyle(fontWeight: FontWeight.w700, fontSize: numberFontSize, color: Colors.black87)),
                    overlayAlignment: const Alignment(0, -0.12),
                    onTap: () {
                      if (enabled) {
                        onAnswer(quiz.id, idx);
                      }
                    },
                  );
                },
              ),
            ]],
            SizedBox(width: gap),
            ExamKeyButton(
              notPressedAssetPath: 'assets/images/key_not_pressed.png',
              pressedAssetPath: 'assets/images/key_pressed.png',
              size: buttonSize,
              bleedPx: 16,
              isEnabled: onPrevious != null,
              overlayChild: Icon(Icons.arrow_back_ios_new, size: arrowIconSize, color: Colors.black87),
              overlayAlignment: const Alignment(0, -0.12),
              onTap: onPrevious,
            ),
            SizedBox(width: gap),
            ExamKeyButton(
              notPressedAssetPath: 'assets/images/key_not_pressed.png',
              pressedAssetPath: 'assets/images/key_pressed.png',
              size: buttonSize,
              bleedPx: 16,
              isEnabled: onNext != null,
              overlayChild: Icon(Icons.arrow_forward_ios, size: arrowIconSize, color: Colors.black87),
              overlayAlignment: const Alignment(0, -0.12),
              onTap: onNext,
            ),
          ],
        );
      },
    );
  }
}
