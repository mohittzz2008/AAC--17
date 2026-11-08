import 'package:flutter_test/flutter_test.dart';
import 'package:rover_command/features/dashboard/domain/models/camera_preview_telemetry.dart';
import 'package:rover_command/features/dashboard/domain/models/dashboard_telemetry_bundle.dart';
import 'package:rover_command/features/dashboard/domain/models/distance_sensor_telemetry.dart';
import 'package:rover_command/features/dashboard/domain/models/hardware_inventory_item.dart';
import 'package:rover_command/features/dashboard/domain/models/motion_sensor_telemetry.dart';
import 'package:rover_command/features/dashboard/domain/models/rover_session_status.dart';
import 'package:rover_command/shared/domain/enums/data_source_type.dart';
import 'package:rover_command/shared/domain/enums/measurement_validity.dart';

void main() {
  group('MeasurementValidity & Threshold Tests', () {
    test('MeasurementValidity keeps unavailable and error distinct', () {
      expect(MeasurementValidity.valid.isValid, isTrue);
      expect(MeasurementValidity.valid.isUnavailable, isFalse);
      expect(MeasurementValidity.valid.isError, isFalse);

      expect(MeasurementValidity.unavailable.isUnavailable, isTrue);
      expect(MeasurementValidity.unavailable.isValid, isFalse);
      expect(MeasurementValidity.unavailable.isError, isFalse);

      expect(MeasurementValidity.error.isError, isTrue);
      expect(MeasurementValidity.error.isValid, isFalse);
      expect(MeasurementValidity.error.isUnavailable, isFalse);
    });

    test('DistanceSensorTelemetry does not enforce unverified HC-SR04 thresholds', () {
      // Structurally valid readings outside arbitrary ranges are preserved as-is
      // without inventing hardware calibration boundaries
      const sensorLarge = DistanceSensorTelemetry(
        sensorId: '01',
        distanceCm: 1200,
        validity: MeasurementValidity.valid,
      );
      expect(sensorLarge.verifiedDistance, 1200);

      const sensorSmall = DistanceSensorTelemetry(
        sensorId: '02',
        distanceCm: 0,
        validity: MeasurementValidity.valid,
      );
      expect(sensorSmall.verifiedDistance, 0);

      const sensorNegative = DistanceSensorTelemetry(
        sensorId: '03',
        distanceCm: -5,
        validity: MeasurementValidity.error,
      );
      // When validity is error, verifiedDistance is null
      expect(sensorNegative.verifiedDistance, isNull);
    });
  });

  group('MotionSensorTelemetry Unknown State & Validity Tests', () {
    test('Valid CLEAR and MOTION states resolve correctly', () {
      const clearMotion = MotionSensorTelemetry(
        sensorId: '01',
        state: MotionState.clear,
        validity: MeasurementValidity.valid,
      );
      expect(clearMotion.resolvedState, MotionState.clear);
      expect(clearMotion.isClear, isTrue);
      expect(clearMotion.isMotionDetected, isFalse);

      const activeMotion = MotionSensorTelemetry(
        sensorId: '02',
        state: MotionState.motion,
        validity: MeasurementValidity.valid,
      );
      expect(activeMotion.resolvedState, MotionState.motion);
      expect(activeMotion.isMotionDetected, isTrue);
      expect(activeMotion.isClear, isFalse);
    });

    test('MotionState.unknown cannot be presented as CLEAR or MOTION', () {
      const unknownMotion = MotionSensorTelemetry(
        sensorId: '01',
        state: MotionState.unknown,
        validity: MeasurementValidity.valid,
      );
      expect(unknownMotion.resolvedState, MotionState.unknown);
      expect(unknownMotion.isClear, isFalse);
      expect(unknownMotion.isMotionDetected, isFalse);
    });

    test('Non-valid measurements force resolvedState to unknown', () {
      // Even if raw state says motion, an unavailable reading must resolve to unknown
      const unavailableReading = MotionSensorTelemetry(
        sensorId: '01',
        state: MotionState.motion,
        validity: MeasurementValidity.unavailable,
      );
      expect(unavailableReading.resolvedState, MotionState.unknown);
      expect(unavailableReading.isMotionDetected, isFalse);
      expect(unavailableReading.isClear, isFalse);

      // Even if raw state says clear, an error reading must resolve to unknown
      const errorReading = MotionSensorTelemetry(
        sensorId: '02',
        state: MotionState.clear,
        validity: MeasurementValidity.error,
      );
      expect(errorReading.resolvedState, MotionState.unknown);
      expect(errorReading.isClear, isFalse);
      expect(errorReading.isMotionDetected, isFalse);
    });
  });

  group('Data-Source Consistency Tests', () {
    test('hasConsistentProvenance returns true when all child items match session provenance', () {
      final bundle = DashboardTelemetryBundle(
        session: const RoverSessionStatus(
          roverId: 'ROVER-01',
          sessionDescription: 'Simulated data only',
          dataSourceType: DataSourceType.demoSimulated,
        ),
        hardwareOverview: const [
          HardwareInventoryItem(
            categoryKey: 'BATTERY',
            specification: '12V Li-ion',
            dataSourceType: DataSourceType.demoSimulated,
          ),
        ],
        cameraPreview: const CameraPreviewTelemetry(
          dataSourceType: DataSourceType.demoSimulated,
        ),
        distanceSensors: const [
          DistanceSensorTelemetry(
            sensorId: '01',
            distanceCm: 124,
            dataSourceType: DataSourceType.demoSimulated,
          ),
        ],
        motionSensors: const [
          MotionSensorTelemetry(
            sensorId: '01',
            state: MotionState.clear,
            dataSourceType: DataSourceType.demoSimulated,
          ),
        ],
        timestamp: DateTime.now(),
      );

      expect(bundle.hasConsistentProvenance, isTrue);
    });

    test('hasConsistentProvenance returns false if child item has mismatched provenance', () {
      final inconsistentBundle = DashboardTelemetryBundle(
        session: const RoverSessionStatus(
          roverId: 'ROVER-01',
          sessionDescription: 'Simulated data only',
          dataSourceType: DataSourceType.demoSimulated,
        ),
        hardwareOverview: const [
          HardwareInventoryItem(
            categoryKey: 'BATTERY',
            specification: '12V Li-ion',
            // Inconsistent: live child inside simulated session
            dataSourceType: DataSourceType.hardwareLive,
          ),
        ],
        cameraPreview: const CameraPreviewTelemetry(
          dataSourceType: DataSourceType.demoSimulated,
        ),
        distanceSensors: const [
          DistanceSensorTelemetry(
            sensorId: '01',
            distanceCm: 124,
            dataSourceType: DataSourceType.demoSimulated,
          ),
        ],
        motionSensors: const [
          MotionSensorTelemetry(
            sensorId: '01',
            state: MotionState.clear,
            dataSourceType: DataSourceType.demoSimulated,
          ),
        ],
        timestamp: DateTime.now(),
      );

      expect(inconsistentBundle.hasConsistentProvenance, isFalse);
    });
  });

  group('Immutability Protection Tests', () {
    test('DashboardTelemetryBundle lists are unmodifiable', () {
      final mutableHardware = <HardwareInventoryItem>[
        const HardwareInventoryItem(categoryKey: 'BATTERY', specification: '12V Li-ion'),
      ];
      final mutableDistance = <DistanceSensorTelemetry>[
        const DistanceSensorTelemetry(sensorId: '01', distanceCm: 124),
      ];
      final mutableMotion = <MotionSensorTelemetry>[
        const MotionSensorTelemetry(sensorId: '01', state: MotionState.clear),
      ];

      final bundle = DashboardTelemetryBundle(
        session: const RoverSessionStatus(
          roverId: 'ROVER-01',
          sessionDescription: 'Simulated data only',
        ),
        hardwareOverview: mutableHardware,
        cameraPreview: const CameraPreviewTelemetry(),
        distanceSensors: mutableDistance,
        motionSensors: mutableMotion,
        timestamp: DateTime.now(),
      );

      // Attempting to mutate lists must throw an UnsupportedError
      expect(
        () => bundle.hardwareOverview.add(
          const HardwareInventoryItem(categoryKey: 'CAMERA', specification: 'ESP32-CAM'),
        ),
        throwsUnsupportedError,
      );

      expect(
        () => bundle.distanceSensors.add(
          const DistanceSensorTelemetry(sensorId: '02', distanceCm: 86),
        ),
        throwsUnsupportedError,
      );

      expect(
        () => bundle.motionSensors.add(
          const MotionSensorTelemetry(sensorId: '02', state: MotionState.motion),
        ),
        throwsUnsupportedError,
      );
    });
  });
}
