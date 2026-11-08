import '../../domain/models/system_telemetry_bundle.dart';
import '../../domain/repositories/system_repository.dart';
import '../datasources/system_data_source.dart';

class SystemRepositoryImpl implements SystemRepository {
  final SystemDataSource _dataSource;

  SystemRepositoryImpl(this._dataSource);

  @override
  Future<SystemTelemetryBundle> fetchSystemTelemetry() {
    return _dataSource.getSystemTelemetry();
  }

  @override
  Future<SystemTelemetryBundle> refresh() {
    return _dataSource.getSystemTelemetry();
  }
}

