import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../dashboard/domain/models/distance_sensor_telemetry.dart';

class SensorsDistanceCard extends StatelessWidget {
  final DistanceSensorTelemetry sensor;

  const SensorsDistanceCard({super.key, required this.sensor});

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
              const Icon(Icons.straighten, size: 16, color: AppColors.gold),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sensor.sensorId,
                  style: AppTypography.cardTitle.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                sensor.sensorId.contains('01') ? 'D1' : 'D2',
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
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                sensor.verifiedDistance != null ? '${sensor.verifiedDistance}' : '--',
                style: AppTypography.telemetryValueLarge.copyWith(fontSize: 26),
              ),
              const SizedBox(width: 6),
              Text(
                'cm',
                style: AppTypography.caption.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Dot bar indicator
          Row(
            children: List.generate(10, (index) {
              final isFilled = sensor.verifiedDistance != null && (index / 10.0) < (sensor.verifiedDistance! / 200.0);
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 9 ? 3 : 0),
                  decoration: BoxDecoration(
                    color: isFilled ? AppColors.gold : AppColors.raisedSurface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
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
