import '../../domain/models/dashboard_telemetry_bundle.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_data_source.dart';

/// Concrete implementation of [DashboardRepository].
/// Delegates to a [DashboardDataSource] and validates telemetry provenance integrity.
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource _dataSource;

  const DashboardRepositoryImpl({
    required DashboardDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<DashboardTelemetryBundle> getTelemetrySnapshot() async {
    final bundle = await _dataSource.fetchTelemetry();

    if (!bundle.hasConsistentProvenance) {
      throw StateError(
        'Telemetry bundle failed provenance consistency check: '
        'Child components have mismatched DataSourceType compared to session (${bundle.session.dataSourceType.displayLabel}).',
      );
    }

    return bundle;
  }
}

