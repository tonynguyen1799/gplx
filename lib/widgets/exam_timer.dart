import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/app_colors.dart';

class ExamTimer extends StatefulWidget {
  final int durationSeconds;
  final void Function()? onTimeout;
  const ExamTimer({super.key, required this.durationSeconds, this.onTimeout});

  @override
  State<ExamTimer> createState() => _ExamTimerState();
}

class _ExamTimerState extends State<ExamTimer> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        if (widget.onTimeout != null) widget.onTimeout!();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_rounded, color: theme.errorColor, size: 20),
        const SizedBox(width: 4),
        Text(
          _formatTime(_remainingSeconds),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.errorColor),
        ),
      ],
    );
  }
} 