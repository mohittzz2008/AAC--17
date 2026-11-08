import '../models/connection_history_entry.dart';
import '../models/discovered_device.dart';

abstract class DeviceConnectionRepository {
  Future<List<DiscoveredDevice>> discoverDevices();
  Future<bool> connectToDevice(String deviceId);
  Future<void> disconnect();
  Future<List<ConnectionHistoryEntry>> getConnectionHistory();
}

