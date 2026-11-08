import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/motion_sensor_telemetry.dart';

/// Card displaying an RCWL-0516 microwave radar motion readout.
class MotionSensorCard extends StatelessWidget {
  final MotionSensorTelemetry sensor;

  const MotionSensorCard({
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
          const SizedBox(height: 10),
          // Value
          Text(
            sensor.resolvedState.label,
            style: AppTypography.telemetryValueMedium,
          ),
          const SizedBox(height: 10),
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

