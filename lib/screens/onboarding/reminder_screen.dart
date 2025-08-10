import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../utils/dialog_utils.dart';
import '../../services/hive_service.dart';
import '../../services/notification_service.dart';
import '../../providers/quizzes_progress_provider.dart';
import '../../providers/app_data_providers.dart';

class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  bool isReminderOn = true;
  TimeOfDay selectedTime = const TimeOfDay(hour: 20, minute: 30);

  @override
  void initState() {
    super.initState();
    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    final reminderEnabled = await getReminderEnabled();
    final reminderTime = await getReminderTime();
    setState(() {
      isReminderOn = reminderEnabled;
      if (reminderTime != null && reminderTime is String) {
        final parts = reminderTime.split(':');
        if (parts.length == 2) {
          selectedTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 20,
            minute: int.tryParse(parts[1]) ?? 30,
          );
        } else {
          selectedTime = const TimeOfDay(hour: 20, minute: 30);
        }
      } else {
        selectedTime = const TimeOfDay(hour: 20, minute: 30);
      }
    });
  }

  void _selectTime() async {
    if (!isReminderOn) return;
    final picked = await showSpinnerTimePicker(
      context: context,
      initialTime: selectedTime,
      title: 'Chọn thời gian',
    );
    if (picked != null) {
                    setState(() {
        selectedTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.Hm().format(dt);
  }

  Future<void> _onNext() async {
    await setReminderEnabled(isReminderOn);
    await setReminderTime('${selectedTime.hour}:${selectedTime.minute}');
    if (isReminderOn) {
      final message = NotificationService.getRandomDailyMessage();
      await NotificationService.scheduleDailyReminder(selectedTime, message);
    } else {
      await NotificationService.cancelReminder();
    }
    context.push('/onboarding/finish');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bật nhắc nhở học tập',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ứng dụng sẽ gửi thông báo nhắc nhở bạn học tập mỗi ngày.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.left,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications_active, color: theme.colorScheme.primary, size: 28),
                      const SizedBox(width: 8),
                      Text('Bật nhắc nhở hàng ngày', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Switch(
                    value: isReminderOn,
                    onChanged: (value) {
                      setState(() {
                        isReminderOn = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: isReminderOn ? _selectTime : null,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 8),
                        Text('Thời gian nhắc mỗi ngày', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Text(
                      _formatTime(selectedTime),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isReminderOn ? theme.textTheme.bodyMedium?.color : theme.disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _onNext,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: const Text('Tiếp tục'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
