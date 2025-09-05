import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/riverpod/data/license_type.dart';
import '../../providers/app_data_providers.dart';
import '../../services/hive_service.dart';
import '../../constants/route_constants.dart';
import '../../utils/icon_color_utils.dart';
import '../../constants/app_colors.dart';
import '../../constants/ui_constants.dart';

class GetStartedScreen extends ConsumerStatefulWidget {
  const GetStartedScreen({super.key});

  @override
  ConsumerState<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends ConsumerState<GetStartedScreen> {
  LicenseType? licenseType;

  @override
  Widget build(BuildContext context) {
    final licenseTypes = ref.watch(licenseTypesProvider);
    licenseType ??= licenseTypes.firstWhere((e) => e.isDefault, orElse: () => licenseTypes.first);

    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: SECTION_SPACING * 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: CONTENT_PADDING),
              child: Text(
                'Chọn loại bằng lái bạn muốn ôn luyện',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: CONTENT_PADDING),
            Expanded(
              child: ListView.builder(
                itemCount: licenseTypes.length,
                padding: const EdgeInsets.symmetric(horizontal: 0),
                itemBuilder: (context, index) {
                  final type = licenseTypes[index];
                  final isSelected = licenseType?.code == type.code;
                  final theme = Theme.of(context);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        licenseType = type;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(CONTENT_PADDING),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.BLUE_COLOR.withValues(alpha: 0.2) : Colors.transparent,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(getLicenseTypeIcon(type.code), color: getLicenseTypeColor(type.code), size: LARGE_ICON_SIZE),
                          const SizedBox(width: CONTENT_PADDING),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${type.code} - ${type.name}',
                                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: SUB_SECTION_SPACING),
                                Text(
                                  type.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600, 
                                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check, color: theme.BLUE_COLOR),
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
                  backgroundColor: theme.NAVIGATION_FG,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: CONTENT_PADDING),
                ),
                onPressed: licenseType != null
                    ? () async {
                        if (licenseType != null) {
                          await setLicenseType(licenseType!.code);
                        }
                        if (mounted) context.go(RouteConstants.ROUTE_ONBOARDING_REMINDER);
                      }
                    : null,
                child: Text(
                  'Tiếp tục',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.NAVIGATION_BG
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
