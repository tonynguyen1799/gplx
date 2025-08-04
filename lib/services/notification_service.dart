import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'dart:io';
import 'dart:math';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const int _reminderNotificationId = 1001;

  static final _notStartedMessages = [
    "Hãy bắt đầu luyện tập hôm nay để tiến gần hơn tới mục tiêu lấy bằng lái!",
    "Chưa làm bài nào hôm nay? Hãy luyện tập một chút nhé!",
    "Khởi động ngày mới với vài câu hỏi luyện tập nào!",
  ];
  static final _inProgressMessages = [
    "Bạn hiền đã hoàn thành {done}/{total} câu hỏi. Tiếp tục luyện tập để đạt kết quả tốt hơn nhé!",
    "Chỉ còn {remaining} câu hỏi nữa là bạn hoàn thành mục tiêu hôm nay!",
    "Tiến độ của bạn: {done}/{total} câu hỏi. Cố lên, bạn làm rất tốt!",
  ];
  static final _almostDoneMessages = [
    "Bạn sắp hoàn thành mục tiêu luyện tập hôm nay rồi! Chỉ còn {remaining} câu hỏi nữa thôi!",
    "Gần xong rồi! Hãy hoàn thành nốt {remaining} câu hỏi để duy trì phong độ nhé!",
  ];
  static final _completedMessages = [
    "Tuyệt vời! Bạn đã hoàn thành mục tiêu luyện tập hôm nay. Hãy duy trì đều đặn nhé!",
    "Bạn đã hoàn thành {done}/{total} câu hỏi hôm nay. Nghỉ ngơi một chút và chuẩn bị cho ngày mai nhé!",
  ];
  static final _motivationMessages = [
    "Kiên trì luyện tập mỗi ngày sẽ giúp bạn tự tin hơn khi thi nào!",
    "Mỗi ngày một ít, thành công sẽ đến với bạn!",
    "Đừng quên luyện tập hôm nay để đạt kết quả tốt nhất trong kỳ thi nhé!",
  ];

  static final _examNotStartedMessages = [
    "Bạn chưa thử làm bài thi mô phỏng nào hôm nay. Hãy thử sức với một đề thi nhé!",
    "Đã đến lúc kiểm tra kiến thức bằng một bài thi mô phỏng!",
    "Hãy bắt đầu một bài thi mô phỏng để đánh giá trình độ của bạn!",
  ];
  static final _examInProgressMessages = [
    "Bạn đã hoàn thành {doneExam}/{totalExam} bài thi mô phỏng. Tiếp tục luyện tập để nâng cao kết quả!",
    "Chỉ còn {remainingExam} bài thi mô phỏng nữa là bạn hoàn thành mục tiêu hôm nay!",
    "Tiến độ thi mô phỏng: {doneExam}/{totalExam} bài. Cố gắng lên nhé!",
  ];
  static final _examCompletedMessages = [
    "Tuyệt vời! Bạn đã hoàn thành tất cả các bài thi mô phỏng hôm nay. Hãy duy trì phong độ này!",
    "Bạn đã hoàn thành {doneExam}/{totalExam} bài thi mô phỏng. Nghỉ ngơi một chút và chuẩn bị cho ngày mai nhé!",
  ];
  static final _examMotivationMessages = [
    "Luyện tập thi mô phỏng thường xuyên sẽ giúp bạn tự tin hơn khi thi thật!",
    "Đừng quên làm bài thi mô phỏng để kiểm tra kiến thức của mình nhé!",
  ];

  static final _genericDailyMessages = [
    ..._notStartedMessages,
    ..._motivationMessages,
    ..._examNotStartedMessages,
    ..._examMotivationMessages,
  ];

  static Future<void> init() async {
    if (_initialized) return;
    initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    final InitializationSettings settings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _plugin.initialize(settings);
    if (Platform.isIOS) {
      await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    _initialized = true;
  }

  static Future<void> scheduleDailyReminder(TimeOfDay time, String message) async {
    await init();
    await cancelReminder();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      _reminderNotificationId,
      'Nhắc nhở học tập',
      message,
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Nhắc nhở học tập',
          channelDescription: 'Thông báo nhắc nhở học tập hàng ngày',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelReminder() async {
    await init();
    await _plugin.cancel(_reminderNotificationId);
  }

  static String getPersonalizedReminderMessageVN({
    required int practiced,
    required int total,
    required int correct,
    required int incorrect,
    int? doneExam,
    int? totalExam,
  }) {
    final remaining = total - practiced;
    final rand = Random();
    String template;
    // If exam progress is provided, sometimes use exam messages
    if (doneExam != null && totalExam != null && totalExam > 0) {
      final remainingExam = totalExam - doneExam;
      if (doneExam == 0) {
        template = _examNotStartedMessages[rand.nextInt(_examNotStartedMessages.length)];
      } else if (doneExam < totalExam) {
        if (remainingExam <= 2) {
          template = _examInProgressMessages[rand.nextInt(_examInProgressMessages.length)];
        } else {
          template = _examInProgressMessages[rand.nextInt(_examInProgressMessages.length)];
        }
      } else if (doneExam >= totalExam) {
        template = _examCompletedMessages[rand.nextInt(_examCompletedMessages.length)];
      } else {
        template = _examMotivationMessages[rand.nextInt(_examMotivationMessages.length)];
      }
      return template
        .replaceAll('{doneExam}', doneExam.toString())
        .replaceAll('{totalExam}', totalExam.toString())
        .replaceAll('{remainingExam}', remainingExam.toString());
    }
    // Otherwise, use quiz progress messages
    if (practiced == 0) {
      template = _notStartedMessages[rand.nextInt(_notStartedMessages.length)];
    } else if (practiced < total && practiced > 0) {
      if (remaining <= 5) {
        template = _almostDoneMessages[rand.nextInt(_almostDoneMessages.length)];
      } else {
        template = _inProgressMessages[rand.nextInt(_inProgressMessages.length)];
      }
    } else if (practiced >= total) {
      template = _completedMessages[rand.nextInt(_completedMessages.length)];
    } else {
      template = _motivationMessages[rand.nextInt(_motivationMessages.length)];
    }
    return template
      .replaceAll('{done}', practiced.toString())
      .replaceAll('{total}', total.toString())
      .replaceAll('{remaining}', remaining.toString());
  }

  static String getRandomDailyMessage() {
    final rand = Random();
    return _genericDailyMessages[rand.nextInt(_genericDailyMessages.length)];
  }
} 