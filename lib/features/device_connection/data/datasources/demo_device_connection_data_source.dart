import '../../../../shared/domain/enums/connection_status.dart';
import '../../domain/models/connection_history_entry.dart';
import '../../domain/models/discovered_device.dart';
import 'device_connection_data_source.dart';

class DemoDeviceConnectionDataSource implements DeviceConnectionDataSource {
  const DemoDeviceConnectionDataSource();

  @override
  Future<List<DiscoveredDevice>> discoverDevices() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return const [
      DiscoveredDevice(
        deviceId: 'ROVER-01-DEMO',
        name: 'ROVER-01 (Demo)',
        hardwareType: 'ESP32 DevKit · Not Connected',
        status: ConnectionStatus.disconnected,
        signalStrength: '--',
        isDemo: true,
      ),
    ];
  }

  @override
  Future<bool> connectToDevice(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Physical hardware endpoint is absent in demo mode
    return false;
  }

  @override
  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<List<ConnectionHistoryEntry>> getConnectionHistory() async {
    return const [
      ConnectionHistoryEntry(timestamp: '10:24', event: 'Discovery completed', isSuccess: true),
      ConnectionHistoryEntry(timestamp: '10:20', event: 'Connection attempt failed (unreachable)', isSuccess: false),
      ConnectionHistoryEntry(timestamp: '09:58', event: 'Discovery started', isSuccess: true),
    ];
  }
}

