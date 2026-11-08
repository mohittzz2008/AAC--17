import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/distance_sensor_telemetry.dart';
import 'distance_sensor_card.dart';

/// Section rendering the dual HC-SR04 ultrasonic distance sensors.
class DistanceSensorsSection extends StatelessWidget {
  final List<DistanceSensorTelemetry> sensors;

  const DistanceSensorsSection({
    super.key,
    required this.sensors,
  });

  @override
  Widget build(BuildContext context) {
    if (sensors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'DISTANCE SENSORS',
          style: AppTypography.sectionHeader,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: DistanceSensorCard(sensor: sensors[0])),
            if (sensors.length > 1) ...[
              const SizedBox(width: 12),
              Expanded(child: DistanceSensorCard(sensor: sensors[1])),
            ],
          ],
        ),
      ],
    );
  }
}

