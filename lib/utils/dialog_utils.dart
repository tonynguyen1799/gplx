import 'package:flutter/material.dart';
import 'package:time_picker_spinner/time_picker_spinner.dart';
import 'package:gplx_vn/utils/app_colors.dart';

Future<String?> showSpinnerTimePicker({
  required BuildContext context,
  required String initialTime,
  String? title,
}) async {
  // Parse initial time string to DateTime for the spinner
  final parts = initialTime.split(':');
  final hour = int.tryParse(parts[0]) ?? 21;
  final minute = int.tryParse(parts[1]) ?? 0;
  
  DateTime selectedDateTime = DateTime(2000, 1, 1, hour, minute);
  return await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: false,
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Cancel and Select buttons
            Container(
              color: Theme.of(ctx).scaffoldBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                      // Return formatted time string in 24-hour format
                      final hh = selectedDateTime.hour.toString().padLeft(2, '0');
                      final mm = selectedDateTime.minute.toString().padLeft(2, '0');
                      Navigator.pop(ctx, '$hh:$mm');
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
                                  child: Text('Giờ', style: TextStyle(fontSize: 14, color: Theme.of(ctx).primaryText)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Text('Phút', style: TextStyle(fontSize: 14, color: Theme.of(ctx).primaryText)),
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