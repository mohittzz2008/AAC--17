import '../../../../shared/domain/enums/connection_status.dart';
import '../../../../shared/domain/enums/data_source_type.dart';
import '../../../../shared/domain/enums/hardware_verification_status.dart';

/// Represents the high-level rover session status banner telemetry.
class RoverSessionStatus {
  final String roverId;
  final String sessionDescription;
  final DataSourceType dataSourceType;
  final HardwareVerificationStatus verification;
  final ConnectionStatus connection;

  const RoverSessionStatus({
    required this.roverId,
    required this.sessionDescription,
    this.dataSourceType = DataSourceType.demoSimulated,
    this.verification = HardwareVerificationStatus.notVerified,
    this.connection = ConnectionStatus.disconnected,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoverSessionStatus &&
          runtimeType == other.runtimeType &&
          roverId == other.roverId &&
          sessionDescription == other.sessionDescription &&
          dataSourceType == other.dataSourceType &&
          verification == other.verification &&
          connection == other.connection;

  @override
  int get hashCode =>
      roverId.hashCode ^
      sessionDescription.hashCode ^
      dataSourceType.hashCode ^
      verification.hashCode ^
      connection.hashCode;
}

