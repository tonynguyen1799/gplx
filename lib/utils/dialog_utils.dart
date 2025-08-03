import 'package:flutter/material.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_picker_plus/flutter_picker_plus.dart';
import 'package:time_picker_spinner/time_picker_spinner.dart';
import 'package:gplx_vn/utils/app_colors.dart';

Future<TimeOfDay?> showAppTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showTimePicker(
    context: context,
    initialTime: initialTime,
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme,
        ),
        child: child!,
      );
    },
  );
}

Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  String? title,
}) async {
  DateTime selectedDateTime = DateTime(2000, 1, 1, initialTime.hour, initialTime.minute);
  TimeOfDay? result;
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title ?? 'Chọn thời gian',
              style: const TextStyle(fontFamily: 'Mulish', fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ScrollDateTimePicker(
                itemExtent: 54,
                infiniteScroll: true,
                dateOption: DateTimePickerOption(
                  dateFormat: DateFormat('HH:mm'),
                  initialDate: selectedDateTime,
                  minDate: DateTime(2000, 1, 1, 0, 0),
                  maxDate: DateTime(2000, 1, 1, 23, 59),
                ),
                style: DateTimePickerStyle(
                  activeStyle: const TextStyle(fontFamily: 'Mulish', fontSize: 24, color: Colors.blue),
                  inactiveStyle: const TextStyle(fontFamily: 'Mulish', fontSize: 20, color: Colors.grey),
                ),
                onChange: (datetime) {
                  selectedDateTime = datetime;
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy', style: TextStyle(fontFamily: 'Mulish')),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    result = TimeOfDay(hour: selectedDateTime.hour, minute: selectedDateTime.minute);
                    Navigator.pop(context);
                  },
                  child: const Text('Chọn', style: TextStyle(fontFamily: 'Mulish')),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  return result;
}

Future<TimeOfDay?> showPickerPlusTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  String? title,
}) async {
  TimeOfDay? result;
  await Picker(
    adapter: DateTimePickerAdapter(
      type: PickerDateTimeType.kHM,
      value: DateTime(2000, 1, 1, initialTime.hour, initialTime.minute),
      customColumnType: [3, 4],
    ),
    height: 220,
    itemExtent: 40,
    title: Text(
      title ?? 'Chọn thời gian',
      style: const TextStyle(fontFamily: 'Mulish', fontSize: 18, fontWeight: FontWeight.bold),
    ),
    textStyle: const TextStyle(fontFamily: 'Mulish', fontSize: 20),
    selectedTextStyle: const TextStyle(fontFamily: 'Mulish', fontSize: 24, color: Colors.blue),
    cancelText: 'Hủy',
    confirmText: 'Chọn',
    onConfirm: (Picker picker, List<int> value) {
      final dateTime = (picker.adapter as DateTimePickerAdapter).value;
      if (dateTime != null) {
        result = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      }
    },
  ).showModal(context);
  return result;
}

Future<TimeOfDay?> showSpinnerTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  String? title,
}) async {
  DateTime selectedDateTime = DateTime(2000, 1, 1, initialTime.hour, initialTime.minute);
  TimeOfDay? lastValue = initialTime;
  return await showModalBottomSheet<TimeOfDay>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Cancel and Select buttons
            Container(
              color: Theme.of(ctx).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // More compact
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Hủy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(32, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  Text(
                    title ?? 'Chọn thời gian',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx, TimeOfDay(hour: selectedDateTime.hour, minute: selectedDateTime.minute));
                    },
                    child: const Text('Chọn', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(32, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            // Body with padding
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TimePickerSpinner(
                          is24HourMode: true,
                          normalTextStyle: TextStyle(
                            fontSize: 18,
                            color: Theme.of(ctx).textTheme.bodyLarge?.color,
                          ),
                          highlightedTextStyle: TextStyle(
                            fontSize: 24,
                            color: isDark ? Theme.of(ctx).colorScheme.primary : Colors.blue,
                          ),
                          time: selectedDateTime,
                          spacing: 30,
                          itemHeight: 40,
                          isShowSeconds: false,
                          alignment: Alignment.center,
                          isForce2Digits: true,
                          minutesInterval: 5,
                          onTimeChange: (time) {
                            selectedDateTime = time;
                          },
                        ),
                        Text(
                          ':',
                          style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(ctx).primaryText,
                          ),
                        ),
                        // Overlay labels on the same line as the spinner
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 4),
                                  child: Text('Giờ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(ctx).primaryText)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Text('Phút', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(ctx).primaryText)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
} 