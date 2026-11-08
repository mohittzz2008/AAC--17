import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SystemControllersCard extends StatelessWidget {
  const SystemControllersCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildItem('CONTROLLERS', '2 × ESP32 DevKit', 'NOT VERIFIED'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildItem('MODULE', 'ESP32-CAM', 'NOT VERIFIED'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Controller roles and assignments are not verified.',
          style: AppTypography.caption.copyWith(
            color: AppColors.secondaryText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildItem(String label, String value, String tag) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.fieldLabel),
          const SizedBox(height: 6),
          Text(value, style: AppTypography.cardTitle.copyWith(fontSize: 14), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text(
            tag,
            style: const TextStyle(
              color: AppColors.gold,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
