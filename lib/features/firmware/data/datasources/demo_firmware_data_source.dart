import '../../../../shared/domain/enums/hardware_verification_status.dart';
import '../../domain/models/device_firmware_info.dart';
import '../../domain/models/firmware_bundle.dart';
import 'firmware_data_source.dart';

class DemoFirmwareDataSource implements FirmwareDataSource {
  const DemoFirmwareDataSource();

  @override
  Future<FirmwareBundle> getFirmwareInfo() async {
    return const FirmwareBundle(
      devices: [
        DeviceFirmwareInfo(
          deviceName: 'ESP32 DevKit (Primary Controller)',
          role: 'Telemetry & Actuator Master',
          currentVersion: 'v1.0.0 (Demo)',
          verificationStatus: HardwareVerificationStatus.notVerified,
          buildDate: '2026-11-01',
        ),
        DeviceFirmwareInfo(
          deviceName: 'ESP32 DevKit (Aux Controller)',
          role: 'Sensor & Auxiliary Driver',
          currentVersion: 'v1.0.0 (Demo)',
          verificationStatus: HardwareVerificationStatus.notVerified,
          buildDate: '2026-11-01',
        ),
        DeviceFirmwareInfo(
          deviceName: 'ESP32-CAM',
          role: 'Vision Processor & Camera Host',
          currentVersion: 'v1.0.0 (Demo)',
          verificationStatus: HardwareVerificationStatus.notVerified,
          buildDate: '2026-11-01',
        ),
      ],
      updateStatusText: 'No updates available',
      updateDisclaimer: 'Firmware updates require physical hardware connection and verified bootloader.',
      hasAvailableUpdate: false,
      maintenanceHistory: [],
    );
  }

  @override
  Future<FirmwareBundle> queryUpdates() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return getFirmwareInfo();
  }
}

