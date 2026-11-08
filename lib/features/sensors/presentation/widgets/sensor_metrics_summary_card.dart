import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/sensor_summary.dart';

class SensorMetricsSummaryCard extends StatelessWidget {
  final SensorSummary summary;

  const SensorMetricsSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildMetricItem('Total', '${summary.totalCount}', AppColors.white)),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricItem('Available', '${summary.availableCount}', AppColors.gold)),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricItem('Unverified', '${summary.unverifiedCount}', AppColors.secondaryText)),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.telemetryValue.copyWith(
              color: valueColor,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

