import '../../../../shared/domain/enums/data_source_type.dart';
import '../../../../shared/domain/enums/hardware_verification_status.dart';
import '../../../../shared/domain/enums/measurement_validity.dart';

/// Represents a numeric distance reading from an HC-SR04 ultrasonic sensor.
class DistanceSensorTelemetry {
  final String sensorId;
  final String hardwareModel;
  final int? distanceCm;
  final MeasurementValidity validity;
  final HardwareVerificationStatus verification;
  final DataSourceType dataSourceType;

  const DistanceSensorTelemetry({
    required this.sensorId,
    this.hardwareModel = 'HC-SR04',
    this.distanceCm,
    this.validity = MeasurementValidity.valid,
    this.verification = HardwareVerificationStatus.notVerified,
    this.dataSourceType = DataSourceType.demoSimulated,
  });

  /// Returns the numeric value if valid, or null if unavailable/error.
  int? get verifiedDistance => validity == MeasurementValidity.valid ? distanceCm : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistanceSensorTelemetry &&
          runtimeType == other.runtimeType &&
          sensorId == other.sensorId &&
          hardwareModel == other.hardwareModel &&
          distanceCm == other.distanceCm &&
          validity == other.validity &&
          verification == other.verification &&
          dataSourceType == other.dataSourceType;

  @override
  int get hashCode =>
      sensorId.hashCode ^
      hardwareModel.hashCode ^
      distanceCm.hashCode ^
      validity.hashCode ^
      verification.hashCode ^
      dataSourceType.hashCode;
}

