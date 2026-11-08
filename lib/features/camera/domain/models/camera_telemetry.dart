import '../../../../shared/domain/enums/connection_status.dart';
import '../../../../shared/domain/enums/data_source_type.dart';
import '../../../../shared/domain/enums/hardware_verification_status.dart';

/// Strongly typed domain entity representing camera telemetry and stream status.
class CameraTelemetry {
  final String moduleTitle;
  final ConnectionStatus connectionStatus;
  final HardwareVerificationStatus verification;
  final DataSourceType dataSourceType;
  final String? resolution;
  final double? frameRate;
  final DateTime? lastUpdate;
  final String? streamHealth;
  final String disclaimer;

  const CameraTelemetry({
    required this.moduleTitle,
    required this.connectionStatus,
    required this.verification,
    required this.dataSourceType,
    this.resolution,
    this.frameRate,
    this.lastUpdate,
    this.streamHealth,
    required this.disclaimer,
  });

  bool get isStreaming => connectionStatus == ConnectionStatus.connected && resolution != null;
}

