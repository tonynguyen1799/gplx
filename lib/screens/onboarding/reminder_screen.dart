import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../utils/dialog_utils.dart' as dialog_utils;
import '../../constants/route_constants.dart';
import '../../services/hive_service.dart';
import '../../services/notification_service.dart';
import '../../constants/app_colors.dart';
import 'package:gplx_vn/constants/navigation_constants.dart';
import 'package:gplx_vn/constants/ui_constants.dart';

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
      selectedTime = reminderTime.isNotEmpty ? reminderTime : "20:30";
    });
  }

  void _selectTime() async {
    if (!isReminderOn) return;

    final picked = await dialog_utils.showTimePicker(
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
    await setReminderTime(selectedTime);
    if (isReminderOn) {
      final message = NotificationService.getRandomDailyMessage();
      await NotificationService.scheduleDailyReminder(selectedTime, message);
    } else {
      await NotificationService.cancelReminder();
    }
    await setOnboardingComplete(true);
    context.go('/main', extra: {'initialIndex': MainNav.TAB_HOME});
  }

  @override
  Widget build(BuildContext context) {
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
                    'Bật nhắc nhở học tập',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: SECTION_SPACING * 2),
                  Text(
                    'Ứng dụng sẽ gửi thông báo nhắc nhở bạn học tập mỗi ngày.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SECTION_SPACING),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
              padding: const EdgeInsets.all(CONTENT_PADDING),
              decoration: BoxDecoration(
                border: Border.all(color: theme.DARK_SURFACE_VARIANT, width: 1),
                borderRadius: BorderRadius.circular(BORDER_RADIUS),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notifications_active, color: theme.BLUE_COLOR, size: LARGE_ICON_SIZE),
                      const SizedBox(width: CONTENT_PADDING),
                      Text('Bật nhắc nhở hàng ngày', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Switch(
                    activeColor: theme.BLUE_COLOR,
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
            const SizedBox(height: SECTION_SPACING),
            GestureDetector(
              onTap: isReminderOn ? _selectTime : null,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
                padding: const EdgeInsets.all(CONTENT_PADDING),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.DARK_SURFACE_VARIANT, width: 1),
                  borderRadius: BorderRadius.circular(BORDER_RADIUS),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, color: theme.BLUE_COLOR, size: LARGE_ICON_SIZE),
                        const SizedBox(width: CONTENT_PADDING),
                        Text(
                          'Thời gian nhắc mỗi ngày',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
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
                  backgroundColor: theme.NAVIGATION_FG,
                  padding: const EdgeInsets.symmetric(vertical: CONTENT_PADDING),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                child: Text(
                  'Tiếp tục',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.NAVIGATION_BG,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
