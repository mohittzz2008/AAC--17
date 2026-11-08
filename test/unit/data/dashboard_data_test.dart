import 'package:flutter_test/flutter_test.dart';
import 'package:rover_command/features/dashboard/data/datasources/dashboard_data_source.dart';
import 'package:rover_command/features/dashboard/data/datasources/demo_dashboard_data_source.dart';
import 'package:rover_command/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:rover_command/features/dashboard/domain/models/camera_preview_telemetry.dart';
import 'package:rover_command/features/dashboard/domain/models/dashboard_telemetry_bundle.dart';
import 'package:rover_command/features/dashboard/domain/models/distance_sensor_telemetry.dart';
import 'package:rover_command/features/dashboard/domain/models/hardware_inventory_item.dart';
import 'package:rover_command/features/dashboard/domain/models/motion_sensor_telemetry.dart';
import 'package:rover_command/features/dashboard/domain/models/rover_session_status.dart';
import 'package:rover_command/shared/domain/enums/connection_status.dart';
import 'package:rover_command/shared/domain/enums/data_source_type.dart';
import 'package:rover_command/shared/domain/enums/hardware_verification_status.dart';
import 'package:rover_command/shared/domain/enums/measurement_validity.dart';

/// Test double that returns a controlled telemetry bundle.
class MockDashboardDataSource implements DashboardDataSource {
  final DashboardTelemetryBundle Function() onFetch;

  MockDashboardDataSource(this.onFetch);

  @override
  Future<DashboardTelemetryBundle> fetchTelemetry() async => onFetch();
}

void main() {
  group('DemoDashboardDataSource Tests', () {
    late DemoDashboardDataSource dataSource;

    setUp(() {
      dataSource = const DemoDashboardDataSource();
    });

    test('returns exact Figma rover session telemetry', () async {
      final bundle = await dataSource.fetchTelemetry();

      expect(bundle.session.roverId, 'ROVER-01');
      expect(bundle.session.sessionDescription, 'Simulated data only · No live connection');
      expect(bundle.session.dataSourceType, DataSourceType.demoSimulated);
      expect(bundle.session.verification, HardwareVerificationStatus.notVerified);
      expect(bundle.session.connection, ConnectionStatus.disconnected);
    });

    test('returns exact 4-item hardware inventory with unverified states', () async {
      final bundle = await dataSource.fetchTelemetry();
      final items = bundle.hardwareOverview;

      expect(items.length, 4);

      // 1. Battery
      expect(items[0].categoryKey, 'BATTERY');
      expect(items[0].specification, '12V Li-ion');
      expect(items[0].verification, HardwareVerificationStatus.notVerified);
      expect(items[0].dataSourceType, DataSourceType.demoSimulated);

      // 2. Controller
      expect(items[1].categoryKey, 'CONTROLLER');
      expect(items[1].specification, '2 × ESP32 DevKit');
      expect(items[1].verification, HardwareVerificationStatus.notVerified);
      expect(items[1].dataSourceType, DataSourceType.demoSimulated);

      // 3. Camera
      expect(items[2].categoryKey, 'CAMERA');
      expect(items[2].specification, 'ESP32-CAM');
      expect(items[2].verification, HardwareVerificationStatus.notVerified);
      expect(items[2].dataSourceType, DataSourceType.demoSimulated);

      // 4. Hardware
      expect(items[3].categoryKey, 'HARDWARE');
      expect(items[3].specification, 'Assembly pending');
      expect(items[3].verification, HardwareVerificationStatus.notVerified);
      expect(items[3].dataSourceType, DataSourceType.demoSimulated);
    });

    test('returns disconnected camera preview with placeholder disclaimer', () async {
      final bundle = await dataSource.fetchTelemetry();
      final camera = bundle.cameraPreview;

      expect(camera.moduleTitle, 'ESP32-CAM preview');
      expect(camera.statusHeadline, 'NO VIDEO FEED / NOT CONNECTED');
      expect(camera.streamDisclaimer, 'Placeholder · Streaming unverified');
      expect(camera.connection, ConnectionStatus.disconnected);
      expect(camera.verification, HardwareVerificationStatus.notVerified);
      expect(camera.dataSourceType, DataSourceType.demoSimulated);
    });

    test('returns correct simulated distance sensor readings (124 cm and 86 cm)', () async {
      final bundle = await dataSource.fetchTelemetry();
      final sensors = bundle.distanceSensors;

      expect(sensors.length, 2);

      // Sensor 01
      expect(sensors[0].sensorId, '01');
      expect(sensors[0].hardwareModel, 'HC-SR04');
      expect(sensors[0].distanceCm, 124);
      expect(sensors[0].validity, MeasurementValidity.valid);
      expect(sensors[0].verification, HardwareVerificationStatus.notVerified);
      expect(sensors[0].dataSourceType, DataSourceType.demoSimulated);

      // Sensor 02
      expect(sensors[1].sensorId, '02');
      expect(sensors[1].hardwareModel, 'HC-SR04');
      expect(sensors[1].distanceCm, 86);
      expect(sensors[1].validity, MeasurementValidity.valid);
      expect(sensors[1].verification, HardwareVerificationStatus.notVerified);
      expect(sensors[1].dataSourceType, DataSourceType.demoSimulated);
    });

    test('returns correct simulated motion sensor states (CLEAR and MOTION)', () async {
      final bundle = await dataSource.fetchTelemetry();
      final sensors = bundle.motionSensors;

      expect(sensors.length, 2);

      // Motion Sensor 01
      expect(sensors[0].sensorId, '01');
      expect(sensors[0].hardwareModel, 'RCWL-0516');
      expect(sensors[0].state, MotionState.clear);
      expect(sensors[0].isClear, isTrue);
      expect(sensors[0].isMotionDetected, isFalse);
      expect(sensors[0].verification, HardwareVerificationStatus.notVerified);
      expect(sensors[0].dataSourceType, DataSourceType.demoSimulated);

      // Motion Sensor 02
      expect(sensors[1].sensorId, '02');
      expect(sensors[1].hardwareModel, 'RCWL-0516');
      expect(sensors[1].state, MotionState.motion);
      expect(sensors[1].isMotionDetected, isTrue);
      expect(sensors[1].isClear, isFalse);
      expect(sensors[1].verification, HardwareVerificationStatus.notVerified);
      expect(sensors[1].dataSourceType, DataSourceType.demoSimulated);
    });

    test('guarantees consistent demoSimulated provenance across all child components', () async {
      final bundle = await dataSource.fetchTelemetry();
      expect(bundle.hasConsistentProvenance, isTrue);
    });
  });

  group('DashboardRepositoryImpl Tests', () {
    test('returns bundle when provenance is consistent', () async {
      final repository = DashboardRepositoryImpl(
        dataSource: const DemoDashboardDataSource(),
      );

      final bundle = await repository.getTelemetrySnapshot();
      expect(bundle, isNotNull);
      expect(bundle.session.roverId, 'ROVER-01');
      expect(bundle.hasConsistentProvenance, isTrue);
    });

    test('rejects bundle and throws StateError when provenance is inconsistent', () async {
      final inconsistentDataSource = MockDashboardDataSource(() {
        return DashboardTelemetryBundle(
          session: const RoverSessionStatus(
            roverId: 'ROVER-01',
            sessionDescription: 'Simulated data only',
            dataSourceType: DataSourceType.demoSimulated,
          ),
          hardwareOverview: const [
            HardwareInventoryItem(
              categoryKey: 'BATTERY',
              specification: '12V Li-ion',
              // Inconsistent child marked live inside simulated session
              dataSourceType: DataSourceType.hardwareLive,
            ),
          ],
          cameraPreview: const CameraPreviewTelemetry(
            dataSourceType: DataSourceType.demoSimulated,
          ),
          distanceSensors: const [
            DistanceSensorTelemetry(sensorId: '01', distanceCm: 124),
          ],
          motionSensors: const [
            MotionSensorTelemetry(sensorId: '01', state: MotionState.clear),
          ],
          timestamp: DateTime.now(),
        );
      });

      final repository = DashboardRepositoryImpl(
        dataSource: inconsistentDataSource,
      );

      expect(
        () => repository.getTelemetrySnapshot(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('failed provenance consistency check'),
        )),
      );
    });
  });
}

