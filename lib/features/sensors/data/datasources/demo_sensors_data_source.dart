import '../../../../shared/domain/enums/connection_status.dart';
import '../../../../shared/domain/enums/data_source_type.dart';
import '../../../../shared/domain/enums/hardware_verification_status.dart';
import '../../../../shared/domain/enums/measurement_validity.dart';
import '../../../dashboard/domain/models/distance_sensor_telemetry.dart';
import '../../../dashboard/domain/models/motion_sensor_telemetry.dart';
import '../../../dashboard/domain/models/rover_session_status.dart';
import '../../domain/models/sensor_summary.dart';
import '../../domain/models/sensors_telemetry_bundle.dart';
import 'sensors_data_source.dart';

class DemoSensorsDataSource implements SensorsDataSource {
  const DemoSensorsDataSource();

  @override
  Future<SensorsTelemetryBundle> getSensorsTelemetry() async {
    final now = DateTime.now();

    return SensorsTelemetryBundle(
      session: const RoverSessionStatus(
        roverId: 'ROVER-01',
        sessionDescription: 'Demo session only · Hardware connection not verified.',
        verification: HardwareVerificationStatus.notVerified,
        connection: ConnectionStatus.disconnected,
        dataSourceType: DataSourceType.demoSimulated,
      ),
      summary: const SensorSummary(
        totalCount: 4,
        availableCount: 4,
        unverifiedCount: 4,
        issuesCount: 0,
      ),
      distanceSensors: const [
        DistanceSensorTelemetry(
          sensorId: 'HC-SR04 / 01',
          hardwareModel: 'HC-SR04',
          distanceCm: 124,
          validity: MeasurementValidity.valid,
          verification: HardwareVerificationStatus.notVerified,
          dataSourceType: DataSourceType.demoSimulated,
        ),
        DistanceSensorTelemetry(
          sensorId: 'HC-SR04 / 02',
          hardwareModel: 'HC-SR04',
          distanceCm: 86,
          validity: MeasurementValidity.valid,
          verification: HardwareVerificationStatus.notVerified,
          dataSourceType: DataSourceType.demoSimulated,
        ),
      ],
      motionSensors: const [
        MotionSensorTelemetry(
          sensorId: 'RCWL-0516 / 01',
          hardwareModel: 'RCWL-0516',
          state: MotionState.clear,
          validity: MeasurementValidity.valid,
          verification: HardwareVerificationStatus.notVerified,
          dataSourceType: DataSourceType.demoSimulated,
        ),
        MotionSensorTelemetry(
          sensorId: 'RCWL-0516 / 02',
          hardwareModel: 'RCWL-0516',
          state: MotionState.motion,
          validity: MeasurementValidity.valid,
          verification: HardwareVerificationStatus.notVerified,
          dataSourceType: DataSourceType.demoSimulated,
        ),
      ],
      historyPoints: [
        SensorHistoryPoint(timestamp: now.subtract(const Duration(seconds: 30)), d1Distance: 120, d2Distance: 82),
        SensorHistoryPoint(timestamp: now.subtract(const Duration(seconds: 25)), d1Distance: 122, d2Distance: 84),
        SensorHistoryPoint(timestamp: now.subtract(const Duration(seconds: 20)), d1Distance: 125, d2Distance: 88),
        SensorHistoryPoint(timestamp: now.subtract(const Duration(seconds: 15)), d1Distance: 123, d2Distance: 85),
        SensorHistoryPoint(timestamp: now.subtract(const Duration(seconds: 10)), d1Distance: 124, d2Distance: 86),
        SensorHistoryPoint(timestamp: now.subtract(const Duration(seconds: 5)), d1Distance: 124, d2Distance: 86),
      ],
      streamStatus: 'Data stream: not verified',
      lastSampleTime: '--',
    );
  }
}
