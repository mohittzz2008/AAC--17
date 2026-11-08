import '../../domain/models/sensors_telemetry_bundle.dart';
import '../../domain/repositories/sensors_repository.dart';
import '../datasources/sensors_data_source.dart';

class SensorsRepositoryImpl implements SensorsRepository {
  final SensorsDataSource _dataSource;

  SensorsRepositoryImpl(this._dataSource);

  @override
  Future<SensorsTelemetryBundle> fetchSensorsTelemetry() {
    return _dataSource.getSensorsTelemetry();
  }

  @override
  Future<SensorsTelemetryBundle> refresh() {
    return _dataSource.getSensorsTelemetry();
  }
}

