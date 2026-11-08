import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/hardware_inventory_item.dart';

/// Reusable card displaying an individual hardware component spec and verification status.
class HardwareInventoryCard extends StatelessWidget {
  final HardwareInventoryItem item;

  const HardwareInventoryCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.categoryKey,
            style: AppTypography.fieldLabel,
          ),
          const SizedBox(height: 8),
          Text(
            item.specification,
            style: AppTypography.telemetryValueRegular,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            item.verification.displayLabel,
            style: AppTypography.statusTagGold,
          ),
        ],
      ),
    );
  }
}

