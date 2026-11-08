/// Represents the operational health status of a rover subsystem or component.
enum SubsystemHealthStatus {
  /// Subsystem is verified and functioning within nominal parameters.
  operational('OPERATIONAL'),

  /// Subsystem is active but has non-critical warnings, degraded performance, or pending assembly checks.
  warning('WARNING'),

  /// Subsystem has failed self-test or encountered an unrecoverable fault.
  error('ERROR'),

  /// Health status is unknown due to missing telemetry or unverified connection.
  unknown('UNKNOWN'),

  /// Component has no diagnostic telemetry or monitoring sensor attached.
  unavailable('UNAVAILABLE');

  final String displayLabel;
  const SubsystemHealthStatus(this.displayLabel);

  bool get isOperational => this == SubsystemHealthStatus.operational;
  bool get isWarning => this == SubsystemHealthStatus.warning;
  bool get isError => this == SubsystemHealthStatus.error;
  bool get isUnknown => this == SubsystemHealthStatus.unknown;
  bool get isUnavailable => this == SubsystemHealthStatus.unavailable;
}

