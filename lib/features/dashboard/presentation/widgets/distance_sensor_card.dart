import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/distance_sensor_telemetry.dart';

/// Card displaying an HC-SR04 distance sensor readout.
class DistanceSensorCard extends StatelessWidget {
  final DistanceSensorTelemetry sensor;

  const DistanceSensorCard({
    super.key,
    required this.sensor,
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
          // Header
          Text(
            '${sensor.hardwareModel} / ${sensor.sensorId}',
            style: AppTypography.fieldLabel,
          ),
          const SizedBox(height: 8),
          // Value and Unit
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                sensor.verifiedDistance != null ? '${sensor.verifiedDistance}' : '--',
                style: AppTypography.telemetryValueLarge,
              ),
              const SizedBox(width: 6),
              Text(
                'cm',
                style: AppTypography.telemetryUnit,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Status Tags
          Text(
            sensor.dataSourceType.displayLabel,
            style: AppTypography.statusTagGold,
          ),
          const SizedBox(height: 4),
          Text(
            sensor.verification.displayLabel,
            style: AppTypography.statusTagGold,
          ),
        ],
      ),
    );
  }
}
