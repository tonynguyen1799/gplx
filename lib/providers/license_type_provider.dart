import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart' as hive;

class LicenseTypeNotifier extends StateNotifier<AsyncValue<String?>> {
  LicenseTypeNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final code = await hive.getLicenseType();
      state = AsyncValue.data(code);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setLicenseType(String code) async {
    state = AsyncValue.data(code);
    await hive.setLicenseType(code);
  }
}

final licenseTypeProvider = StateNotifierProvider<LicenseTypeNotifier, AsyncValue<String?>>((ref) {
  return LicenseTypeNotifier();
}); 