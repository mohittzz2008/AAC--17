import '../../domain/models/camera_telemetry.dart';
import '../../domain/repositories/camera_repository.dart';
import '../datasources/camera_data_source.dart';

class CameraRepositoryImpl implements CameraRepository {
  final CameraDataSource _dataSource;

  CameraRepositoryImpl(this._dataSource);

  @override
  Future<CameraTelemetry> fetchCameraTelemetry() {
    return _dataSource.getCameraTelemetry();
  }

  @override
  Future<CameraTelemetry> retryConnection() {
    return _dataSource.attemptConnection();
  }
}

