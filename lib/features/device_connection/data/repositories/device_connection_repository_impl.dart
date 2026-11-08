import '../../domain/models/connection_history_entry.dart';
import '../../domain/models/discovered_device.dart';
import '../../domain/repositories/device_connection_repository.dart';
import '../datasources/device_connection_data_source.dart';

class DeviceConnectionRepositoryImpl implements DeviceConnectionRepository {
  final DeviceConnectionDataSource _dataSource;

  DeviceConnectionRepositoryImpl(this._dataSource);

  @override
  Future<List<DiscoveredDevice>> discoverDevices() {
    return _dataSource.discoverDevices();
  }

  @override
  Future<bool> connectToDevice(String deviceId) {
    return _dataSource.connectToDevice(deviceId);
  }

  @override
  Future<void> disconnect() {
    return _dataSource.disconnect();
  }

  @override
  Future<List<ConnectionHistoryEntry>> getConnectionHistory() {
    return _dataSource.getConnectionHistory();
  }
}

