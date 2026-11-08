import '../../../../shared/domain/enums/hardware_verification_status.dart';

class DeviceFirmwareInfo {
  final String deviceName;
  final String role;
  final String currentVersion;
  final HardwareVerificationStatus verificationStatus;
  final String buildDate;

  const DeviceFirmwareInfo({
    required this.deviceName,
    required this.role,
    required this.currentVersion,
    required this.verificationStatus,
    required this.buildDate,
  });
}

