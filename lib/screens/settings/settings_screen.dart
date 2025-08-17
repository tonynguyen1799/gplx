import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/hive_service.dart';
import '../../utils/app_colors.dart';
import '../../models/riverpod/data/license_type.dart';
import '../../providers/app_data_providers.dart';
import '../../providers/license_type_provider.dart';
import '../../utils/dialog_utils.dart';
import 'package:go_router/go_router.dart';
import '../../services/notification_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:gplx_vn/providers/reminder_provider.dart';

enum AppThemeMode { system, light, dark }

final themeModeProvider = StateProvider<AppThemeMode>((ref) => AppThemeMode.system);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _reminderEnabled = true;
  String _reminderTime = "21:00";
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _loading = true;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _reminderKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Map && extra['scrollTo'] == 'reminder') {
        _scrollToReminder();
      }
    });
  }

  void _scrollToReminder() {
    final ctx = _reminderKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  Future<void> _loadSettings() async {
    final enabled = await getReminderEnabled();
    final timeStr = await getReminderTime();
    final themeStr = await getThemeMode();
    setState(() {
      _reminderEnabled = enabled;
      // Use the time string directly
      _reminderTime = timeStr.isNotEmpty ? timeStr : "21:00";
      _themeMode = _parseThemeMode(themeStr);
      _loading = false;
    });
  }

  Future<void> _saveReminder() async {
    // Time is already properly formatted string
    await ref.read(reminderSettingsProvider.notifier).setReminderEnabled(_reminderEnabled);
    await ref.read(reminderSettingsProvider.notifier).setReminderTime(_reminderTime);
    await NotificationService.cancelReminder();
    if (_reminderEnabled) {
      final message = NotificationService.getRandomDailyMessage();
      await NotificationService.scheduleDailyReminder(_reminderTime, message);
    }
  }

  Future<void> _saveThemeMode(AppThemeMode mode) async {
    await setThemeMode(mode.name);
    setState(() => _themeMode = mode);
    ref.read(themeModeProvider.notifier).state = mode;
  }

  static AppThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      default:
        return AppThemeMode.system;
    }
  }

  Widget _buildThemeChoice(BuildContext context, AppThemeMode mode, String label, IconData icon) {
    final isSelected = _themeMode == mode;
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? theme.colorScheme.primary : theme.iconTheme.color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) _saveThemeMode(mode);
      },
      selectedColor: theme.colorScheme.primary.withOpacity(0.15),
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }

  IconData _getLicenseTypeIcon(String code) {
    switch (code) {
      case 'A1':
        return Icons.two_wheeler;
      case 'A2':
        return Icons.motorcycle;
      case 'B1':
        return Icons.directions_car;
      case 'B2':
        return Icons.directions_car_filled;
      case 'C':
        return Icons.local_shipping;
      case 'D':
        return Icons.directions_bus;
      case 'E':
        return Icons.airport_shuttle;
      case 'F':
        return Icons.emoji_transportation;
      default:
        return Icons.drive_eta;
    }
  }

  Color _getLicenseTypeColor(String code) {
    switch (code) {
      case 'A1':
        return Colors.orange;
      case 'A2':
        return Colors.deepOrange;
      case 'B1':
        return Colors.blue;
      case 'B2':
        return Colors.indigo;
      case 'C':
        return Colors.green;
      case 'D':
        return Colors.teal;
      case 'E':
        return Colors.purple;
      case 'F':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  Widget _buildAppVersionTile(ThemeData theme) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData ? snapshot.data!.version : '';
        return ListTile(
          leading: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Icon(Icons.info_outline, color: theme.colorScheme.primary),
            ),
          ),
          title: const Text('GPLX Việt Nam', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          subtitle: Text('Phiên bản $version', style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
          onTap: () {},
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final licenseTypes = ref.watch(licenseTypesProvider);
    final selectedLicenseTypeAsync = ref.watch(licenseTypeProvider);
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: theme.appBarBackground,
        foregroundColor: theme.appBarText,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
            // Section: License Type
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                // 'Loại bằng lái đang ôn luyện',
                'LOẠI BẰNG LÁI',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            // const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: selectedLicenseTypeAsync.when(
                data: (selectedCode) {
                  LicenseType? selected;
                  if (licenseTypes.isNotEmpty) {
                    selected = licenseTypes.firstWhere(
                      (lt) => lt.code == selectedCode,
                      orElse: () => licenseTypes.first,
                    );
                  } else {
                    selected = null;
                  }
                  return ListTile(
                    leading: Container(
                      alignment: Alignment.center,
                      height: 40,
                      width: 40,
                      child: Icon(Icons.badge, size: 24, color: theme.colorScheme.primary),
                    ),
                    title: Text(
                      selected != null ? '${selected.name} - ${selected.code}' : 'Chưa chọn',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      (selected != null ? selected.description : '') + '\nNhấn để thay đổi loại bằng lái',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    isThreeLine: true,
                    trailing: Container(
                      alignment: Alignment.center,
                      height: 40,
                      width: 40,
                      child: Icon(Icons.keyboard_arrow_down, size: 24, color: theme.colorScheme.primary),
                    ),
                    onTap: () async {
                      final newType = await showModalBottomSheet<LicenseType>(
                        context: context,
                        builder: (ctx) => SafeArea(
                          child: SizedBox(
                            height: MediaQuery.of(ctx).size.height * 0.6,
                            child: CustomScrollView(
                              shrinkWrap: true,
                              slivers: [
                                SliverPersistentHeader(
                                  pinned: true,
                                  delegate: _StickyHeaderDelegate(
                                    child: Container(
                                      color: Theme.of(ctx).scaffoldBackgroundColor,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Chọn loại bằng lái',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                SliverList(
                                  delegate: SliverChildListDelegate([
                                    ...licenseTypes.map((type) {
                                      final isSelected = selected?.code == type.code;
                                      final isDark = Theme.of(ctx).brightness == Brightness.dark;
                                      final selectedBg = isDark ? Colors.blue.shade900 : Colors.blue.shade50;
                                      final selectedBorder = isDark ? Colors.blue.shade400 : Colors.blue.shade200;
                                      final tile = ListTile(
                                        leading: Icon(
                                          _getLicenseTypeIcon(type.code),
                                          color: isSelected ? Theme.of(ctx).colorScheme.primary : _getLicenseTypeColor(type.code),
                                          size: 32,
                                        ),
                                        title: Text('${type.code} - ${type.name}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                        subtitle: Text(type.description, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
                                        tileColor: Colors.transparent,
                                        onTap: () => Navigator.of(ctx).pop(type),
                                      );
                                      if (isSelected) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: selectedBg,
                                            border: Border.all(color: selectedBorder, width: 1),
                                            borderRadius: BorderRadius.zero,
                                          ),
                                          child: tile,
                                        );
                                      } else {
                                        return tile;
                                      }
                                    }),
                                  ]),
              ),
            ],
          ),
                          ),
                        ),
                      );
                      if (newType != null && newType.code != selected?.code) {
                        await ref.read(licenseTypeProvider.notifier).setLicenseType(newType.code);
                        setState(() {});
                      }
                    },
                  );
                },
                loading: () => const ListTile(
                  leading: CircularProgressIndicator(),
                  title: Text('Đang tải...', style: TextStyle(fontSize: 15)),
                ),
                error: (_, __) => const ListTile(
                  leading: Icon(Icons.error),
                  title: Text('Không thể tải loại bằng lái', style: TextStyle(fontSize: 15)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Section: Reminder
            Padding(
              key: _reminderKey,
              padding: const EdgeInsets.all(4),
              child: Text(
                // 'Nhắc nhở học tập',
                'NHẮC NHỞ HỌC TẬP',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            // const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 16, 0),
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      value: _reminderEnabled,
                      onChanged: (v) async {
                        setState(() => _reminderEnabled = v);
                        await _saveReminder();
                      },
                      title: const Text('Bật nhắc nhở hàng ngày', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Nhận thông báo nhắc nhở học tập mỗi ngày', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
                      secondary: SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: Icon(Icons.notifications_active, color: theme.warningColor),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    ListTile(
                      enabled: _reminderEnabled,
                      leading: SizedBox(
                        height: 40,
                        width: 40,
                        child: Center(
                          child: Icon(Icons.access_time, color: theme.warningColor),
                        ),
                      ),
                      title: const Text('Thời gian nhắc nhở', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(_reminderTime, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            onTap: _reminderEnabled
                ? () async {
                              final picked = await showSpinnerTimePicker(
                      context: context,
                      initialTime: _reminderTime,
                    );
                    if (picked != null) {
                      setState(() => _reminderTime = picked);
                                await _saveReminder();
                    }
                  }
                : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      minVerticalPadding: 0,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Section: Theme
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                // 'Giao diện',
                'GIAO DIỆN',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            // const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    _buildThemeChoice(context, AppThemeMode.system, 'Tự động', Icons.brightness_auto),
                    _buildThemeChoice(context, AppThemeMode.light, 'Sáng', Icons.light_mode),
                    _buildThemeChoice(context, AppThemeMode.dark, 'Tối', Icons.dark_mode),
                ],
              ),
            ),
          ),
            const SizedBox(height: 12),
            // Section: Data
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                // 'Dữ liệu',
                'DỮ LIỆU',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
            ),
            // const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
            children: [
                  ListTile(
                    leading: SizedBox(
                      width: 40,
                      height: 40,
                      child: Center(
                        child: Icon(Icons.delete, color: theme.colorScheme.error),
                      ),
                    ),
                    title: Text('Xóa toàn bộ dữ liệu và đặt lại ứng dụng', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.colorScheme.error)),
                    subtitle: const Text('Tất cả tiến trình, cài đặt sẽ bị xóa', style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xác nhận'),
                          content: const Text('Bạn có chắc chắn muốn xóa toàn bộ dữ liệu và đặt lại ứng dụng?', style: TextStyle(fontSize: 15)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Hủy', style: TextStyle(fontSize: 15)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text('Xoá và đặt lại', style: TextStyle(fontSize: 15, color: Theme.of(ctx).colorScheme.error)),
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
              ),
            ],
              ),
          ),
            const SizedBox(height: 12),
            // Section: About
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 4),
              child: Text(
                // 'Thông tin',
                'THÔNG TIN',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            // const SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
            ),
              child: _buildAppVersionTile(theme),
          ),
        ],
      ),
    );
    
  }
} 

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyHeaderDelegate({required this.child});
  @override
  double get minExtent => kMinInteractiveDimension;
  @override
  double get maxExtent => kMinInteractiveDimension;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
} 