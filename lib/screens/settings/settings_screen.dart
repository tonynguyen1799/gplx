import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/reminder_settings.dart';
import '../../models/theme_settings.dart';
import '../../models/riverpod/data/license_type.dart';
import '../../providers/app_data_providers.dart';
import '../../providers/license_type_provider.dart';
import '../../providers/theme_mode_provider.dart';
import 'package:gplx_vn/providers/reminder_provider.dart';
import '../../services/hive_service.dart' show cleanUp;
import '../../services/notification_service.dart';
import '../../constants/app_colors.dart';
import '../../utils/dialog_utils.dart' as dialog_utils;
import 'package:gplx_vn/constants/ui_constants.dart';
import '../../widgets/license_types_bottom_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final licenseTypes = ref.watch(licenseTypesProvider);
    final licenseTypeAsync = ref.watch(licenseTypeProvider);
    final reminderSettingsAsync = ref.watch(reminderSettingsProvider);
    final themeSettingsAsync = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: NAVIGATION_HEIGHT,
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            fontSize: APP_BAR_FONT_SIZE,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.APP_BAR_BG,
        foregroundColor: theme.APP_BAR_FG,
        elevation: 0,
        leading: null,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
        children: [
          const SizedBox(height: SECTION_SPACING),
          _buildLicenseTypeSection(theme, licenseTypes, licenseTypeAsync),
          const SizedBox(height: SECTION_SPACING * 2),
          _buildReminderSection(theme, reminderSettingsAsync),
          const SizedBox(height: SECTION_SPACING * 2),
          _buildThemeSection(theme, themeSettingsAsync),
          const SizedBox(height: SECTION_SPACING * 2),
          _buildDataSection(theme),
          const SizedBox(height: SECTION_SPACING),
        ],
      ),
    );
  }

  Widget _buildLicenseTypeSection(ThemeData theme, List<LicenseType> licenseTypes, AsyncValue<String?> licenseTypeAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOẠI BẰNG LÁI',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: SUB_SECTION_SPACING),
        Container(
          decoration: BoxDecoration(
            color: theme.SURFACE_VARIANT,
            borderRadius: BorderRadius.circular(BORDER_RADIUS),
          ),
          child: licenseTypeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Lỗi khi tải dữ liệu: $err')),
            data: (licenseTypeCode) {
              LicenseType? selected;
              if (licenseTypeCode != null && licenseTypes.isNotEmpty) {
                selected = licenseTypes.firstWhere(
                  (lt) => lt.code == licenseTypeCode,
                  orElse: () => licenseTypes.first,
                );
              } else {
                selected = null;
              }
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: CONTENT_PADDING, vertical: SUB_SECTION_SPACING),
                leading: Container(
                  alignment: Alignment.center,
                  height: NAVIGATION_HEIGHT,
                  width: NAVIGATION_HEIGHT,
                  child: Icon(Icons.badge, color: theme.BLUE_COLOR),
                ),
                title: Text(
                  selected != null ? '${selected.name} - ${selected.code}' : 'Chưa chọn',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  (selected != null ? selected.description : '') + '\nNhấn để thay đổi loại bằng lái',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                  ),
                ),
                trailing: Container(
                  alignment: Alignment.center,
                  height: NAVIGATION_HEIGHT,
                  width: NAVIGATION_HEIGHT,
                  child: Icon(Icons.keyboard_arrow_down, color: theme.BLUE_COLOR),
                ),
                onTap: () async {
                  final newType = await LicenseTypesBottomSheet.show(
                    context,
                    licenseTypes: licenseTypes,
                    selectedType: selected,
                  );
                  if (newType != null && newType.code != selected?.code) {
                    await ref.read(licenseTypeProvider.notifier).setLicenseType(newType.code);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReminderSection(ThemeData theme, AsyncValue<ReminderSettings> reminderSettingsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NHẮC NHỞ HỌC TẬP',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: SUB_SECTION_SPACING),
        Container(
          padding: const EdgeInsets.symmetric(vertical: SUB_SECTION_SPACING),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.SURFACE_VARIANT,
            borderRadius: BorderRadius.circular(BORDER_RADIUS),
          ),
          child: reminderSettingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Lỗi khi tải dữ liệu: $err')),
            data: (reminderSettings) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
                  child: Row(
                    children: [
                      SizedBox(
                        width: NAVIGATION_HEIGHT,
                        height: NAVIGATION_HEIGHT,
                        child: Center(
                          child: Icon(Icons.notifications_active, color: theme.WARNING_COLOR),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bật nhắc nhở hàng ngày',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Nhận thông báo nhắc nhở học tập mỗi ngày',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: reminderSettings.enabled,
                        onChanged: (v) async {
                          await ref.read(reminderSettingsProvider.notifier).setReminderEnabled(v);
                          await NotificationService.cancelReminder();
                          if (v) {
                            final message = NotificationService.getRandomDailyMessage();
                            await NotificationService.scheduleDailyReminder(reminderSettings.time24h, message);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SUB_SECTION_SPACING),
                InkWell(
                  onTap: reminderSettings.enabled
                      ? () async {
                          final picked = await dialog_utils.showTimePicker(
                            context: context,
                            initialTime: reminderSettings.time24h,
                          );
                          if (picked != null) {
                            await ref.read(reminderSettingsProvider.notifier).setReminderTime(picked);
                            final message = NotificationService.getRandomDailyMessage();
                            await NotificationService.scheduleDailyReminder(picked, message);
                          }
                        }
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: Icon(
                              Icons.access_time,
                              color: reminderSettings.enabled ? theme.WARNING_COLOR : theme.WARNING_COLOR.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Thời gian nhắc nhở',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: reminderSettings.enabled ? null : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                ),
                              ),
                              Text(
                                reminderSettings.time24h,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: reminderSettings.enabled ? null : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeChoice(BuildContext context, ThemeMode currentMode, ThemeMode mode, String label, IconData icon) {
    final isSelected = currentMode == mode;
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? theme.BLUE_COLOR : null),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) async {
        if (selected) {
          await ref.read(themeModeProvider.notifier).setThemeMode(mode);
        }
      },
      selectedColor: theme.BLUE_COLOR.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SMALL_BORDER_RADIUS)),
      elevation: 0,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    );
  }

  Widget _buildThemeSection(ThemeData theme, AsyncValue<ThemeSettings> themeSettingsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GIAO DIỆN',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: SUB_SECTION_SPACING),
        Container(
          decoration: BoxDecoration(
            color: theme.SURFACE_VARIANT,
            borderRadius: BorderRadius.circular(BORDER_RADIUS),
          ),
          child: themeSettingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Lỗi khi tải dữ liệu: $err')),
            data: (themeSettings) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildThemeChoice(context, themeSettings.mode, ThemeMode.system, 'Tự động', Icons.brightness_auto),
                  _buildThemeChoice(context, themeSettings.mode, ThemeMode.light, 'Sáng', Icons.light_mode),
                  _buildThemeChoice(context, themeSettings.mode, ThemeMode.dark, 'Tối', Icons.dark_mode),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DỮ LIỆU',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: SUB_SECTION_SPACING),
        Container(
          padding: const EdgeInsets.symmetric(vertical: SUB_SECTION_SPACING),
          decoration: BoxDecoration(
            color: theme.SURFACE_VARIANT,
            borderRadius: BorderRadius.circular(BORDER_RADIUS),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Xác nhận', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                      content: Text(
                        'Bạn có chắc chắn muốn xóa toàn bộ dữ liệu và đặt lại ứng dụng?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                        )
                      ),
                      actionsPadding: const EdgeInsets.all(CONTENT_PADDING),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: Text('Hủy', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: Text(
                            'Xoá và đặt lại',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.ERROR_COLOR,
                            )
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await cleanUp();
                    if (mounted) {
                      context.go('/');
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
                  child: Row(
                    children: [
                      SizedBox(
                        width: NAVIGATION_HEIGHT,
                        height: NAVIGATION_HEIGHT,
                        child: Center(
                          child: Icon(Icons.delete, color: theme.ERROR_COLOR),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xóa toàn bộ dữ liệu và đặt lại ứng dụng',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.ERROR_COLOR,
                              ),
                            ),
                            Text(
                              'Tất cả tiến trình, cài đặt sẽ bị xóa',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}