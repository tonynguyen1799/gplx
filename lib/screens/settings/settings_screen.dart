import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/hive_service.dart';
import 'package:hive/hive.dart';

enum AppThemeMode { system, light, dark }

final themeModeProvider = StateProvider<AppThemeMode>((ref) => AppThemeMode.system);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _reminderEnabled = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 21, minute: 0);
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await getReminderEnabled();
    final timeStr = await getReminderTime();
    final themeStr = await _getThemeMode();
    setState(() {
      _reminderEnabled = enabled;
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        _reminderTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 21,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
      _themeMode = _parseThemeMode(themeStr);
      _loading = false;
    });
  }

  Future<void> _saveReminder() async {
    await setReminderEnabled(_reminderEnabled);
    await setReminderTime('${_reminderTime.hour}:${_reminderTime.minute}');
  }

  Future<void> _saveThemeMode(AppThemeMode mode) async {
    await _setThemeMode(mode);
    setState(() => _themeMode = mode);
    ref.read(themeModeProvider.notifier).state = mode;
  }

  Future<void> _resetData() async {
    await clearOnboardingBox();
    await clearReminderSettings();
    await clearQuizStatusBox();
    await clearExamProgressBox();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa toàn bộ dữ liệu.')));
    }
  }

  static Future<String> _getThemeMode() async {
    final box = await Hive.openBox('settings');
    return box.get('themeMode', defaultValue: 'system');
  }

  static Future<void> _setThemeMode(AppThemeMode mode) async {
    final box = await Hive.openBox('settings');
    await box.put('themeMode', mode.name);
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt', style: TextStyle(fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Nhắc nhở học tập', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Bật nhắc nhở hàng ngày'),
              Switch(
                value: _reminderEnabled,
                onChanged: (v) => setState(() => _reminderEnabled = v),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _reminderEnabled
                ? () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime,
                    );
                    if (picked != null) {
                      setState(() => _reminderTime = picked);
                    }
                  }
                : null,
            child: AbsorbPointer(
              absorbing: !_reminderEnabled,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Thời gian nhắc nhở'),
                  Text('${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _saveReminder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              elevation: 0,
            ),
            child: const Text('Lưu nhắc nhở'),
          ),
          const SizedBox(height: 32),
          const Text('Giao diện', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Column(
            children: [
              RadioListTile<AppThemeMode>(
                value: AppThemeMode.system,
                groupValue: _themeMode,
                onChanged: (v) => v != null ? _saveThemeMode(v) : null,
                title: const Text('Tự động theo hệ thống'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<AppThemeMode>(
                value: AppThemeMode.light,
                groupValue: _themeMode,
                onChanged: (v) => v != null ? _saveThemeMode(v) : null,
                title: const Text('Sáng'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              RadioListTile<AppThemeMode>(
                value: AppThemeMode.dark,
                groupValue: _themeMode,
                onChanged: (v) => v != null ? _saveThemeMode(v) : null,
                title: const Text('Tối'),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Dữ liệu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Xóa toàn bộ dữ liệu và đặt lại ứng dụng'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              elevation: 0,
            ),
            onPressed: _resetData,
          ),
        ],
      ),
    );
  }
} 