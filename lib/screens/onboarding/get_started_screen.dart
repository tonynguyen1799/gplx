import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/license_type.dart';
import '../../providers/app_data_providers.dart';
import '../../services/hive_service.dart';

IconData getLicenseTypeIcon(String code) {
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

Color getLicenseTypeColor(String code) {
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

class GetStartedScreen extends ConsumerStatefulWidget {
  const GetStartedScreen({super.key});

  @override
  ConsumerState<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends ConsumerState<GetStartedScreen> {
  LicenseType? selectedType;

  @override
  Widget build(BuildContext context) {
    final licenseTypes = ref.watch(licenseTypesProvider);
    if (licenseTypes.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Không có dữ liệu loại bằng lái.')),
      );
    }
    selectedType ??= licenseTypes.firstWhere((e) => e.isDefault, orElse: () => licenseTypes.first);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Chọn loại bằng lái bạn muốn ôn luyện',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: licenseTypes.length,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                itemBuilder: (context, index) {
                  final type = licenseTypes[index];
                  final isSelected = selectedType?.code == type.code;
                  final theme = Theme.of(context);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedType = type;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.colorScheme.primary.withOpacity(0.15) : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(color: theme.dividerColor),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(getLicenseTypeIcon(type.code), color: getLicenseTypeColor(type.code), size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${type.code} - ${type.name}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  type.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check, color: theme.colorScheme.primary, size: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: selectedType != null
                    ? () async {
                        if (selectedType != null) {
                          await setLicenseType(selectedType!.code);
                        }
                        if (mounted) context.go('/onboarding/reminder');
                      }
                    : null,
                child: const Text(
                  'Tiếp tục',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Remove bottomNavigationBar
    );
  }
}
