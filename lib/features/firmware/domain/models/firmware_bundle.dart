import 'device_firmware_info.dart';

class MaintenanceRecord {
  final String date;
  final String description;
  final String technician;

  const MaintenanceRecord({
    required this.date,
    required this.description,
    required this.technician,
  });
}

class FirmwareBundle {
  final List<DeviceFirmwareInfo> devices;
  final String updateStatusText;
  final String updateDisclaimer;
  final bool hasAvailableUpdate;
  final List<MaintenanceRecord> maintenanceHistory;

  const FirmwareBundle({
    required this.devices,
    required this.updateStatusText,
    required this.updateDisclaimer,
    this.hasAvailableUpdate = false,
    required this.maintenanceHistory,
  });
}

