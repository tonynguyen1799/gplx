import 'package:flutter/material.dart';
import 'package:time_picker_spinner/time_picker_spinner.dart';
import 'package:gplx_vn/constants/app_colors.dart';
import 'package:gplx_vn/constants/ui_constants.dart';

Future<String?> showTimePicker({
  required BuildContext context,
  required String initialTime,
  String? title,
}) async {
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
      final theme = Theme.of(ctx);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(CONTENT_PADDING),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Hủy', style: TextStyle(fontSize: theme.textTheme.bodyLarge?.fontSize, fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(LARGE_ICON_SIZE, LARGE_ICON_SIZE),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  Text(
                    title ?? 'Chọn thời gian',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  TextButton(
                    onPressed: () {
                      final hh = selectedDateTime.hour.toString().padLeft(2, '0');
                      final mm = selectedDateTime.minute.toString().padLeft(2, '0');
                      Navigator.pop(ctx, '$hh:$mm');
                    },
                    child: Text('Chọn', style: TextStyle(fontSize: theme.textTheme.bodyLarge?.fontSize, fontWeight: FontWeight.w600)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size(LARGE_ICON_SIZE, LARGE_ICON_SIZE),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: CONTENT_PADDING * 5, horizontal: CONTENT_PADDING),
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
                          normalTextStyle: theme.textTheme.titleLarge,
                          highlightedTextStyle: theme.textTheme.headlineSmall?.copyWith(color: theme.BLUE_COLOR, fontWeight: FontWeight.w600),
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
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Giờ', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                Text('Phút', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
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