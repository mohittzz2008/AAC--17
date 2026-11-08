import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../dashboard/domain/models/motion_sensor_telemetry.dart';

class SensorsMotionCard extends StatelessWidget {
  final MotionSensorTelemetry sensor;

  const SensorsMotionCard({super.key, required this.sensor});

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
        children: [
          Row(
            children: [
              const Icon(Icons.sensors, size: 16, color: AppColors.gold),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sensor.sensorId,
                  style: AppTypography.cardTitle.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                sensor.sensorId.contains('01') ? 'M1' : 'M2',
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            sensor.hardwareModel,
            style: AppTypography.fieldLabel.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 16),
          Text(
            sensor.resolvedState.label,
            style: AppTypography.telemetryValueLarge.copyWith(
              fontSize: 22,
              color: sensor.resolvedState == MotionState.motion ? AppColors.gold : AppColors.white,
            ),
          ),
          const SizedBox(height: 24),
          // Footer badge
          Row(
            children: [
              Container(
                width: 3,
                height: 10,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: AppColors.burgundy,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              Expanded(
                child: Text(
                  'NOT VERIFIED / DEMO',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryText,
                    letterSpacing: 0.4,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
