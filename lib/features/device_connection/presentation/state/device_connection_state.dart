import '../../../../shared/domain/enums/connection_status.dart';
import '../../domain/models/connection_history_entry.dart';
import '../../domain/models/discovered_device.dart';

sealed class DeviceConnectionState {
  const DeviceConnectionState();
}

class DeviceConnectionInitial extends DeviceConnectionState {
  const DeviceConnectionInitial();
}

class DeviceConnectionDiscovering extends DeviceConnectionState {
  const DeviceConnectionDiscovering();
}

class DeviceConnectionLoaded extends DeviceConnectionState {
  final ConnectionStatus status;
  final List<DiscoveredDevice> availableDevices;
  final List<ConnectionHistoryEntry> history;
  final String? feedbackMessage;
  final bool isConnecting;

  const DeviceConnectionLoaded({
    required this.status,
    required this.availableDevices,
    required this.history,
    this.feedbackMessage,
    this.isConnecting = false,
  });

  DeviceConnectionLoaded copyWith({
    ConnectionStatus? status,
    List<DiscoveredDevice>? availableDevices,
    List<ConnectionHistoryEntry>? history,
    String? feedbackMessage,
    bool? isConnecting,
  }) {
    return DeviceConnectionLoaded(
      status: status ?? this.status,
      availableDevices: availableDevices ?? this.availableDevices,
      history: history ?? this.history,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      isConnecting: isConnecting ?? this.isConnecting,
    );
  }
}

