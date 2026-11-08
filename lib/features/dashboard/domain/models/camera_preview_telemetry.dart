import '../../../../shared/domain/enums/connection_status.dart';
import '../../../../shared/domain/enums/data_source_type.dart';
import '../../../../shared/domain/enums/hardware_verification_status.dart';

/// Represents the camera preview viewport telemetry state.
class CameraPreviewTelemetry {
  final String moduleTitle;
  final String statusHeadline;
  final String streamDisclaimer;
  final ConnectionStatus connection;
  final HardwareVerificationStatus verification;
  final DataSourceType dataSourceType;

  const CameraPreviewTelemetry({
    this.moduleTitle = 'ESP32-CAM preview',
    this.statusHeadline = 'NO VIDEO FEED / NOT CONNECTED',
    this.streamDisclaimer = 'Placeholder · Streaming unverified',
    this.connection = ConnectionStatus.disconnected,
    this.verification = HardwareVerificationStatus.notVerified,
    this.dataSourceType = DataSourceType.demoSimulated,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CameraPreviewTelemetry &&
          runtimeType == other.runtimeType &&
          moduleTitle == other.moduleTitle &&
          statusHeadline == other.statusHeadline &&
          streamDisclaimer == other.streamDisclaimer &&
          connection == other.connection &&
          verification == other.verification &&
          dataSourceType == other.dataSourceType;

  @override
  int get hashCode =>
      moduleTitle.hashCode ^
      statusHeadline.hashCode ^
      streamDisclaimer.hashCode ^
      connection.hashCode ^
      verification.hashCode ^
      dataSourceType.hashCode;
}

