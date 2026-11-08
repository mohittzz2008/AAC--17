/// Identifies the validity of an individual sensor reading independent of its value.
enum MeasurementValidity {
  /// The measurement was read successfully within sensor operating limits.
  valid,

  /// The measurement is not available (e.g. sensor disconnected or not sampled).
  unavailable,

  /// The sensor reported a fault, bus error, or out-of-range value.
  error;

  bool get isValid => this == MeasurementValidity.valid;
  bool get isUnavailable => this == MeasurementValidity.unavailable;
  bool get isError => this == MeasurementValidity.error;
}

