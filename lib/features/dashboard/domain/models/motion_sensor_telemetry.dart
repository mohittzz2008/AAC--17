import '../../../../shared/domain/enums/data_source_type.dart';
import '../../../../shared/domain/enums/hardware_verification_status.dart';
import '../../../../shared/domain/enums/measurement_validity.dart';

/// Discrete motion detection states for RCWL-0516 radar sensors.
enum MotionState {
  clear('CLEAR'),
  motion('MOTION'),
  unknown('UNKNOWN');

  final String label;
  const MotionState(this.label);
}

/// Represents motion detection telemetry from an RCWL-0516 microwave sensor.
class MotionSensorTelemetry {
  final String sensorId;
  final String hardwareModel;
  final MotionState state;
  final MeasurementValidity validity;
  final HardwareVerificationStatus verification;
  final DataSourceType dataSourceType;

  const MotionSensorTelemetry({
    required this.sensorId,
    this.hardwareModel = 'RCWL-0516',
    required this.state,
    this.validity = MeasurementValidity.valid,
    this.verification = HardwareVerificationStatus.notVerified,
    this.dataSourceType = DataSourceType.demoSimulated,
  });

  /// The structurally resolved motion state.
  /// If the measurement validity is not valid, the state is strictly [MotionState.unknown].
  MotionState get resolvedState =>
      validity == MeasurementValidity.valid ? state : MotionState.unknown;

  /// Whether active motion is confirmed by a structurally valid reading.
  bool get isMotionDetected => resolvedState == MotionState.motion;

  /// Whether clear state is confirmed by a structurally valid reading.
  bool get isClear => resolvedState == MotionState.clear;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MotionSensorTelemetry &&
          runtimeType == other.runtimeType &&
          sensorId == other.sensorId &&
          hardwareModel == other.hardwareModel &&
          state == other.state &&
          validity == other.validity &&
          verification == other.verification &&
          dataSourceType == other.dataSourceType;

  @override
  int get hashCode =>
      sensorId.hashCode ^
      hardwareModel.hashCode ^
      state.hashCode ^
      validity.hashCode ^
      verification.hashCode ^
      dataSourceType.hashCode;
}
