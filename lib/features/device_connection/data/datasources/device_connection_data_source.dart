import '../../domain/models/connection_history_entry.dart';
import '../../domain/models/discovered_device.dart';

abstract class DeviceConnectionDataSource {
  Future<List<DiscoveredDevice>> discoverDevices();
  Future<bool> connectToDevice(String deviceId);
  Future<void> disconnect();
  Future<List<ConnectionHistoryEntry>> getConnectionHistory();
}

