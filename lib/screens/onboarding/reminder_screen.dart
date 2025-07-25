import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import '../../services/hive_service.dart';

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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) {
        DateTime initial = DateTime(0, 0, 0, selectedTime.hour, selectedTime.minute);
        DateTime tempTime = initial;
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TimePickerSpinner(
                      is24HourMode: true,
                      normalTextStyle: const TextStyle(fontSize: 18, color: Colors.grey),
                      highlightedTextStyle: const TextStyle(fontSize: 24, color: Colors.blue),
                      time: initial,
                      minutesInterval: 1,
                      onTimeChange: (time) {
                        tempTime = time;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedTime = TimeOfDay(hour: tempTime.hour, minute: tempTime.minute);
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: const Text('Xác nhận'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.Hm().format(dt);
  }

  Future<void> _onNext() async {
    await setReminderEnabled(isReminderOn);
    await setReminderTime('${selectedTime.hour}:${selectedTime.minute}');
    context.push('/onboarding/finish');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bật nhắc nhở học tập',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ứng dụng sẽ gửi thông báo nhắc nhở bạn học tập mỗi ngày.',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active, color: Colors.blue, size: 28),
                      const SizedBox(width: 8),
                      const Text('Bật nhắc nhở hàng ngày', style: TextStyle(fontSize: 16)),
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
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.blue, size: 28),
                        const SizedBox(width: 8),
                        const Text('Thời gian nhắc mỗi ngày', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    Text(
                      _formatTime(selectedTime),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isReminderOn ? Colors.black : Colors.grey,
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
                  backgroundColor: Colors.blue,
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
