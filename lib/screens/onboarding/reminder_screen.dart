import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/dialog_utils.dart';
import '../../constants/route_constants.dart';
import '../../services/hive_service.dart';
import '../../services/notification_service.dart';

class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  bool isReminderOn = true;
  String selectedTime = "20:30";

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
      // Use the time string directly, with fallback
      selectedTime = reminderTime.isNotEmpty ? reminderTime : "20:30";
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



  Future<void> _onNext() async {
    await setReminderEnabled(isReminderOn);
    // Time is already properly formatted string
    await setReminderTime(selectedTime);
    if (isReminderOn) {
      final message = NotificationService.getRandomDailyMessage();
      await NotificationService.scheduleDailyReminder(selectedTime, message);
    } else {
      await NotificationService.cancelReminder();
    }
    context.push(RouteConstants.ROUTE_ONBOARDING_FINISH);
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
                        selectedTime,
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
