import '../../../../shared/domain/enums/connection_status.dart';
import '../../../../shared/domain/enums/hardware_verification_status.dart';
import '../../../../shared/domain/enums/measurement_validity.dart';
import '../../../dashboard/domain/models/rover_session_status.dart';

class SystemOverview {
  final String roverId;
  final String mode;
  final ConnectionStatus connection;
  final String lastUpdate;

  const SystemOverview({
    required this.roverId,
    required this.mode,
    required this.connection,
    required this.lastUpdate,
  });
}

class SystemPowerInfo {
  final String batteryDescription;
  final String buckDescription;
  final MeasurementValidity voltageValidity;
  final MeasurementValidity chargeValidity;
  final MeasurementValidity buckOutputValidity;

  const SystemPowerInfo({
    required this.batteryDescription,
    required this.buckDescription,
    this.voltageValidity = MeasurementValidity.unavailable,
    this.chargeValidity = MeasurementValidity.unavailable,
    this.buckOutputValidity = MeasurementValidity.unavailable,
  });
}

class SystemTelemetryBundle {
  final RoverSessionStatus session;
  final SystemOverview overview;
  final SystemPowerInfo power;
  final HardwareVerificationStatus verificationStatus;

  const SystemTelemetryBundle({
    required this.session,
    required this.overview,
    required this.power,
    required this.verificationStatus,
  });
}

