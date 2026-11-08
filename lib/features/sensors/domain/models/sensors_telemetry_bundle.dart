import '../../../dashboard/domain/models/distance_sensor_telemetry.dart';
import '../../../dashboard/domain/models/motion_sensor_telemetry.dart';
import '../../../dashboard/domain/models/rover_session_status.dart';
import 'sensor_summary.dart';

class SensorHistoryPoint {
  final DateTime timestamp;
  final double d1Distance;
  final double d2Distance;

  const SensorHistoryPoint({
    required this.timestamp,
    required this.d1Distance,
    required this.d2Distance,
  });
}

class SensorsTelemetryBundle {
  final RoverSessionStatus session;
  final SensorSummary summary;
  final List<DistanceSensorTelemetry> distanceSensors;
  final List<MotionSensorTelemetry> motionSensors;
  final List<SensorHistoryPoint> historyPoints;
  final String streamStatus;
  final String lastSampleTime;

  const SensorsTelemetryBundle({
    required this.session,
    required this.summary,
    required this.distanceSensors,
    required this.motionSensors,
    required this.historyPoints,
    required this.streamStatus,
    required this.lastSampleTime,
  });
}

