import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/system_telemetry_bundle.dart';

class SystemPowerCard extends StatelessWidget {
  final SystemPowerInfo power;

  const SystemPowerCard({super.key, required this.power});

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
              Text(
                power.batteryDescription,
                style: AppTypography.cardTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                power.buckDescription,
                style: AppTypography.caption.copyWith(color: AppColors.secondaryText, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.raisedSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'NOMINAL RATINGS · NOT MEASUREMENTS',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildRow('Battery voltage', 'UNAVAILABLE'),
              const Divider(color: AppColors.raisedSurface, height: 18),
              _buildRow('Battery charge', 'UNAVAILABLE'),
              const Divider(color: AppColors.raisedSurface, height: 18),
              _buildRow('Buck outputs (×2)', 'UNAVAILABLE'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Voltage, charge and outputs remain unavailable until measured.',
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
