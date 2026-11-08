import '../../../../shared/domain/enums/connection_status.dart';

class DiscoveredDevice {
  final String deviceId;
  final String name;
  final String hardwareType;
  final ConnectionStatus status;
  final String signalStrength;
  final bool isDemo;

  const DiscoveredDevice({
    required this.deviceId,
    required this.name,
    required this.hardwareType,
    required this.status,
    this.signalStrength = '--',
    this.isDemo = true,
  });
}

