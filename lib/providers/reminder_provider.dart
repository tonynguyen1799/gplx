import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_settings.dart';
import '../services/hive_service.dart' as hive;

class ReminderSettingsNotifier extends StateNotifier<AsyncValue<ReminderSettings>> {
  ReminderSettingsNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final enabled = await hive.getReminderEnabled();
      final time = await hive.getReminderTime();
      state = AsyncValue.data(ReminderSettings(enabled: enabled, time24h: time));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setReminderEnabled(bool enabled) async {
    final currentSettings = state.value ?? const ReminderSettings(enabled: false, time24h: '21:00');
    state = AsyncValue.data(ReminderSettings(enabled: enabled, time24h: currentSettings.time24h));
    await hive.setReminderEnabled(enabled);
  }

  Future<void> setReminderTime(String time24h) async {
    final currentSettings = state.value ?? const ReminderSettings(enabled: false, time24h: '21:00');
    state = AsyncValue.data(ReminderSettings(enabled: currentSettings.enabled, time24h: time24h));
    await hive.setReminderTime(time24h);
  }

  Future<void> refresh() => _load();
}

final reminderSettingsProvider = StateNotifierProvider<ReminderSettingsNotifier, AsyncValue<ReminderSettings>>((ref) {
  return ReminderSettingsNotifier();
}); 