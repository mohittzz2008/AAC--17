import '../../../../shared/domain/enums/connection_status.dart';
import '../../../../shared/domain/enums/data_source_type.dart';
import '../../../../shared/domain/enums/hardware_verification_status.dart';
import '../../../../shared/domain/enums/measurement_validity.dart';
import '../../domain/models/camera_preview_telemetry.dart';
import '../../domain/models/dashboard_telemetry_bundle.dart';
import '../../domain/models/distance_sensor_telemetry.dart';
import '../../domain/models/hardware_inventory_item.dart';
import '../../domain/models/motion_sensor_telemetry.dart';
import '../../domain/models/rover_session_status.dart';
import 'dashboard_data_source.dart';

/// Provides deterministic demo telemetry matching the approved Figma reference.
class DemoDashboardDataSource implements DashboardDataSource {
  const DemoDashboardDataSource();

  @override
  Future<DashboardTelemetryBundle> fetchTelemetry() async {
    return DashboardTelemetryBundle(
      session: const RoverSessionStatus(
        roverId: 'ROVER-01',
        sessionDescription: 'Simulated data only · No live connection',
        dataSourceType: DataSourceType.demoSimulated,
        verification: HardwareVerificationStatus.notVerified,
        connection: ConnectionStatus.disconnected,
      ),
      hardwareOverview: const [
        HardwareInventoryItem(
          categoryKey: 'BATTERY',
          specification: '12V Li-ion',
          verification: HardwareVerificationStatus.notVerified,
          dataSourceType: DataSourceType.demoSimulated,
        ),
        HardwareInventoryItem(
          categoryKey: 'CONTROLLER',
          specification: '2 × ESP32 DevKit',
          verification: HardwareVerificationStatus.notVerified,
          dataSourceType: DataSourceType.demoSimulated,
        ),
        HardwareInventoryItem(
          categoryKey: 'CAMERA',
          specification: 'ESP32-CAM',
          verification: HardwareVerificationStatus.notVerified,
          dataSourceType: DataSourceType.demoSimulated,
        ),
        HardwareInventoryItem(
          categoryKey: 'HARDWARE',
          specification: 'Assembly pending',
          verification: HardwareVerificationStatus.notVerified,
          dataSourceType: DataSourceType.demoSimulated,
        ),
      ],
      cameraPreview: const CameraPreviewTelemetry(
        moduleTitle: 'ESP32-CAM preview',
        statusHeadline: 'NO VIDEO FEED / NOT CONNECTED',
        streamDisclaimer: 'Placeholder · Streaming unverified',
        connection: ConnectionStatus.disconnected,
        verification: HardwareVerificationStatus.notVerified,
        dataSourceType: DataSourceType.demoSimulated,
      ),
      distanceSensors: const [
        DistanceSensorTelemetry(
          sensorId: '01',
          hardwareModel: 'HC-SR04',
          distanceCm: 124,
          validity: MeasurementValidity.valid,
          verification: HardwareVerificationStatus.notVerified,
          dataSourceType: DataSourceType.demoSimulated,
        ),
        DistanceSensorTelemetry(
          sensorId: '02',
          hardwareModel: 'HC-SR04',
          distanceCm: 86,
          validity: MeasurementValidity.valid,
          verification: HardwareVerificationStatus.notVerified,
          dataSourceType: DataSourceType.demoSimulated,
        ),
      ],
      motionSensors: const [
        MotionSensorTelemetry(
          sensorId: '01',
          hardwareModel: 'RCWL-0516',
          state: MotionState.clear,
          validity: MeasurementValidity.valid,
          verification: HardwareVerificationStatus.notVerified,
          dataSourceType: DataSourceType.demoSimulated,
        ),
        MotionSensorTelemetry(
          sensorId: '02',
          hardwareModel: 'RCWL-0516',
          state: MotionState.motion,
          validity: MeasurementValidity.valid,
          verification: HardwareVerificationStatus.notVerified,
          dataSourceType: DataSourceType.demoSimulated,
        ),
      ],
      timestamp: DateTime.now(),
    );
  }
}

