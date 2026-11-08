import '../../../../shared/domain/enums/data_source_type.dart';
import '../../../../shared/domain/enums/hardware_verification_status.dart';

/// Telemetry bundle dedicated to the Rover Operation screen.
class RoverOperationTelemetry {
  final DataSourceType dataSourceType;
  final HardwareVerificationStatus verificationStatus;
  final String roverId;
  final bool isConnected;
  final int latencyMs;
  final int batteryPercentage;
  final String motionStatusText;
  final String systemStatusText;
  final String cameraHealthText;
  final String motorDriverHealthText;
  final String controllerHealthText;
  final String sensorModulesHealthText;
  final String overallHealthText;
  final double temperatureCelsius;
  final int humidityPercentage;
  final double ultrasonicDistanceMeters;
  final int lightLux;
  final double pitchDegrees;
  final double rollDegrees;
  final String cameraResolution;
  final int cameraFps;
  final DateTime lastUpdated;

  const RoverOperationTelemetry({
    required this.dataSourceType,
    required this.verificationStatus,
    required this.roverId,
    required this.isConnected,
    required this.latencyMs,
    required this.batteryPercentage,
    required this.motionStatusText,
    required this.systemStatusText,
    required this.cameraHealthText,
    required this.motorDriverHealthText,
    required this.controllerHealthText,
    required this.sensorModulesHealthText,
    required this.overallHealthText,
    required this.temperatureCelsius,
    required this.humidityPercentage,
    required this.ultrasonicDistanceMeters,
    required this.lightLux,
    required this.pitchDegrees,
    required this.rollDegrees,
    required this.cameraResolution,
    required this.cameraFps,
    required this.lastUpdated,
  });

  bool get isSimulated => dataSourceType == DataSourceType.demoSimulated;
}

