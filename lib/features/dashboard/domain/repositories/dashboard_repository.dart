import '../models/dashboard_telemetry_bundle.dart';

/// Contract for retrieving aggregated Dashboard telemetry.
/// Independent of whether data originates from demo simulation or physical hardware.
abstract interface class DashboardRepository {
  /// Retrieves a snapshot of the current Dashboard telemetry bundle.
  Future<DashboardTelemetryBundle> getTelemetrySnapshot();
}

