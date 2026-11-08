import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SystemDriveHardwareCard extends StatelessWidget {
  const SystemDriveHardwareCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.raisedSurface, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRow('2 × DRV8833 drivers', 'NOT VERIFIED'),
              const Divider(color: AppColors.raisedSurface, height: 18),
              _buildRow('3 × 6V DC motors', 'NOT VERIFIED'),
              const Divider(color: AppColors.raisedSurface, height: 18),
              _buildRow('4 × MG90S servos', 'NOT VERIFIED'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Wiring and control mapping are not verified. Independent control is not confirmed.',
          style: AppTypography.caption.copyWith(
            color: AppColors.secondaryText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.white,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          status,
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
