class RoverConfiguration {
  final String deviceName;
  final String operatingMode;
  final int telemetryIntervalSeconds;
  final String networkMode;
  final String ssid;
  final String maskedPassword;
  final String distanceUnit;
  final String cameraResolution;

  const RoverConfiguration({
    required this.deviceName,
    required this.operatingMode,
    required this.telemetryIntervalSeconds,
    required this.networkMode,
    required this.ssid,
    required this.maskedPassword,
    required this.distanceUnit,
    required this.cameraResolution,
  });

  RoverConfiguration copyWith({
    String? deviceName,
    String? operatingMode,
    int? telemetryIntervalSeconds,
    String? networkMode,
    String? ssid,
    String? maskedPassword,
    String? distanceUnit,
    String? cameraResolution,
  }) {
    return RoverConfiguration(
      deviceName: deviceName ?? this.deviceName,
      operatingMode: operatingMode ?? this.operatingMode,
      telemetryIntervalSeconds: telemetryIntervalSeconds ?? this.telemetryIntervalSeconds,
      networkMode: networkMode ?? this.networkMode,
      ssid: ssid ?? this.ssid,
      maskedPassword: maskedPassword ?? this.maskedPassword,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      cameraResolution: cameraResolution ?? this.cameraResolution,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoverConfiguration &&
        other.deviceName == deviceName &&
        other.operatingMode == operatingMode &&
        other.telemetryIntervalSeconds == telemetryIntervalSeconds &&
        other.networkMode == networkMode &&
        other.ssid == ssid &&
        other.maskedPassword == maskedPassword &&
        other.distanceUnit == distanceUnit &&
        other.cameraResolution == cameraResolution;
  }

  @override
  int get hashCode => Object.hash(
        deviceName,
        operatingMode,
        telemetryIntervalSeconds,
        networkMode,
        ssid,
        maskedPassword,
        distanceUnit,
        cameraResolution,
      );
}

