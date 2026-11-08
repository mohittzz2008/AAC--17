import '../../domain/models/dashboard_telemetry_bundle.dart';

/// Data source interface for fetching raw telemetry bundles.
abstract interface class DashboardDataSource {
  /// Fetches a raw telemetry bundle.
  Future<DashboardTelemetryBundle> fetchTelemetry();
}

