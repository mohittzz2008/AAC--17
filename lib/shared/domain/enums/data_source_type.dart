/// Identifies where the telemetry data originates.
enum DataSourceType {
  /// Data is simulated (e.g. demo mode presentation).
  demoSimulated('SIMULATED'),

  /// Data originates from active live hardware.
  hardwareLive('LIVE');

  final String displayLabel;
  const DataSourceType(this.displayLabel);

  bool get isSimulated => this == DataSourceType.demoSimulated;
  bool get isLive => this == DataSourceType.hardwareLive;
}

