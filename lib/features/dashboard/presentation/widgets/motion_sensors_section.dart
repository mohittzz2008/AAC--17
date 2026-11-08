import 'package:flutter/material.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/motion_sensor_telemetry.dart';
import 'motion_sensor_card.dart';

/// Section rendering the dual RCWL-0516 radar motion sensors.
class MotionSensorsSection extends StatelessWidget {
  final List<MotionSensorTelemetry> sensors;

  const MotionSensorsSection({
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
          'MOTION SENSORS',
          style: AppTypography.sectionHeader,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: MotionSensorCard(sensor: sensors[0])),
            if (sensors.length > 1) ...[
              const SizedBox(width: 12),
              Expanded(child: MotionSensorCard(sensor: sensors[1])),
            ],
          ],
        ),
      ],
    );
  }
}

