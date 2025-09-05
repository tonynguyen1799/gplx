import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/ui_constants.dart';
import '../constants/app_colors.dart';

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
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant ExamTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.durationSeconds != widget.durationSeconds) {
      _timer?.cancel();
      _timer = null;
      _remainingSeconds = widget.durationSeconds;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null; // Ensure timer is set to null after cancellation
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        timer.cancel();
        _timer = null;
        if (widget.onTimeout != null && mounted) widget.onTimeout!();
      }
    });
  }

  static const int _secondsPerMinute = 60;
  
  String _formatTime(int seconds) {
    final m = (seconds ~/ _secondsPerMinute).toString().padLeft(2, '0');
    final s = (seconds % _secondsPerMinute).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer_rounded, color: theme.ERROR_COLOR),
        const SizedBox(width: SUB_SECTION_SPACING),
        Text(
          _formatTime(_remainingSeconds),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.ERROR_COLOR,
          ),
        ),
      ],
    );
  }
} 