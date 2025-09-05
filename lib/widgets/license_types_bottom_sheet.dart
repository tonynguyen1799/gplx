import 'package:flutter/material.dart';
import '../models/riverpod/data/license_type.dart';
import '../constants/app_colors.dart';
import '../utils/icon_color_utils.dart';

class LicenseTypesBottomSheet extends StatelessWidget {
  final List<LicenseType> licenseTypes;
  final LicenseType? selectedType;

  const LicenseTypesBottomSheet({
    super.key,
    required this.licenseTypes,
    this.selectedType,
  });

  static Future<LicenseType?> show(
    BuildContext context, {
    required List<LicenseType> licenseTypes,
    LicenseType? selectedType,
  }) {
    return showModalBottomSheet<LicenseType>(
      context: context,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.7,
          child: LicenseTypesBottomSheet(
            licenseTypes: licenseTypes,
            selectedType: selectedType,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            'Chọn loại bằng lái',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: licenseTypes.length,
            itemBuilder: (context, index) {
              final type = licenseTypes[index];
              final isSelected = selectedType?.code == type.code;

              return ListTile(
                leading: Icon(
                  getLicenseTypeIcon(type.code),
                  color: isSelected ? null : getLicenseTypeColor(type.code),
                ),
                title: Text(
                  '${type.code} - ${type.name}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  type.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                  ),
                ),
                selected: isSelected,
                selectedTileColor: theme.BLUE_COLOR.withValues(alpha: 0.2),
                tileColor: Colors.transparent,
                shape: isSelected ? RoundedRectangleBorder(
                  side: BorderSide(color: theme.BLUE_COLOR, width: 1),
                  borderRadius: BorderRadius.zero,
                ) : null,
                onTap: () => Navigator.of(context).pop(type),
              );
            },
          ),
        ),
      ],
    );
  }
}