import 'camera_preview_telemetry.dart';
import 'distance_sensor_telemetry.dart';
import 'hardware_inventory_item.dart';
import 'motion_sensor_telemetry.dart';
import 'rover_session_status.dart';

/// Aggregated immutable telemetry snapshot for the Dashboard.
class DashboardTelemetryBundle {
  final RoverSessionStatus session;
  final List<HardwareInventoryItem> hardwareOverview;
  final CameraPreviewTelemetry cameraPreview;
  final List<DistanceSensorTelemetry> distanceSensors;
  final List<MotionSensorTelemetry> motionSensors;
  final DateTime timestamp;

  DashboardTelemetryBundle({
    required this.session,
    required List<HardwareInventoryItem> hardwareOverview,
    required this.cameraPreview,
    required List<DistanceSensorTelemetry> distanceSensors,
    required List<MotionSensorTelemetry> motionSensors,
    required this.timestamp,
  })  : hardwareOverview = List.unmodifiable(hardwareOverview),
        distanceSensors = List.unmodifiable(distanceSensors),
        motionSensors = List.unmodifiable(motionSensors);

  /// Verifies whether all aggregated components share the session's data provenance.
  bool get hasConsistentProvenance =>
      hardwareOverview.every((item) => item.dataSourceType == session.dataSourceType) &&
      cameraPreview.dataSourceType == session.dataSourceType &&
      distanceSensors.every((sensor) => sensor.dataSourceType == session.dataSourceType) &&
      motionSensors.every((sensor) => sensor.dataSourceType == session.dataSourceType);
}
