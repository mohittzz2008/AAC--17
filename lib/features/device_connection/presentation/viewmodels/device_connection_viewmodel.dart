import 'package:flutter/foundation.dart';
import '../../../../shared/domain/enums/connection_status.dart';
import '../../domain/repositories/device_connection_repository.dart';
import '../state/device_connection_state.dart';

class DeviceConnectionViewModel extends ChangeNotifier {
  final DeviceConnectionRepository _repository;
  DeviceConnectionState _state = const DeviceConnectionInitial();
  bool _disposed = false;

  DeviceConnectionViewModel(this._repository);

  DeviceConnectionState get state => _state;

  Future<void> initialize() async {
    if (_disposed) return;
    _state = const DeviceConnectionDiscovering();
    notifyListeners();

    final devices = await _repository.discoverDevices();
    final history = await _repository.getConnectionHistory();

    if (_disposed) return;
    _state = DeviceConnectionLoaded(
      status: ConnectionStatus.disconnected,
      availableDevices: devices,
      history: history,
    );
    notifyListeners();
  }

  Future<void> startDiscovery() async {
    if (_disposed) return;
    if (_state is DeviceConnectionLoaded) {
      final current = _state as DeviceConnectionLoaded;
      _state = current.copyWith(feedbackMessage: 'Scanning local network for rover endpoints...');
      notifyListeners();
    }

    final devices = await _repository.discoverDevices();
    final history = await _repository.getConnectionHistory();

    if (_disposed) return;
    _state = DeviceConnectionLoaded(
      status: ConnectionStatus.disconnected,
      availableDevices: devices,
      history: history,
      feedbackMessage: 'Discovery finished · 1 demo endpoint listed',
    );
    notifyListeners();
  }

  Future<void> connectToDevice(String deviceId) async {
    if (_disposed) return;
    if (_state is DeviceConnectionLoaded) {
      final current = _state as DeviceConnectionLoaded;
      _state = current.copyWith(
        isConnecting: true,
        feedbackMessage: 'Connecting to $deviceId...',
      );
      notifyListeners();

      final success = await _repository.connectToDevice(deviceId);

      if (_disposed) return;
      if (!success) {
        _state = current.copyWith(
          isConnecting: false,
          status: ConnectionStatus.disconnected,
          feedbackMessage: 'Connection failed · No live ESP32 endpoint reachable. Running in demo mode.',
        );
      } else {
        _state = current.copyWith(
          isConnecting: false,
          status: ConnectionStatus.connected,
          feedbackMessage: 'Connected to $deviceId',
        );
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }
}

