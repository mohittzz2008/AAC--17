import '../../domain/models/firmware_bundle.dart';
import '../../domain/repositories/firmware_repository.dart';
import '../datasources/firmware_data_source.dart';

class FirmwareRepositoryImpl implements FirmwareRepository {
  final FirmwareDataSource _dataSource;

  FirmwareRepositoryImpl(this._dataSource);

  @override
  Future<FirmwareBundle> fetchFirmwareInfo() {
    return _dataSource.getFirmwareInfo();
  }

  @override
  Future<FirmwareBundle> checkForUpdates() {
    return _dataSource.queryUpdates();
  }
}

