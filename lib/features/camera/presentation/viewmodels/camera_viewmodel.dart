import 'package:flutter/foundation.dart';
import '../../domain/repositories/camera_repository.dart';
import '../state/camera_state.dart';

class CameraViewModel extends ChangeNotifier {
  final CameraRepository _repository;
  CameraState _state = const CameraInitial();
  bool _disposed = false;

  CameraViewModel(this._repository);

  CameraState get state => _state;

  Future<void> loadTelemetry() async {
    if (_disposed) return;
    _state = const CameraConnecting();
    notifyListeners();

    try {
      final telemetry = await _repository.fetchCameraTelemetry();
      if (_disposed) return;
      _state = CameraLoaded(telemetry);
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _state = CameraError(e.toString());
      notifyListeners();
    }
  }

  Future<void> retryConnection() async {
    if (_disposed) return;
    _state = const CameraConnecting();
    notifyListeners();

    try {
      final telemetry = await _repository.retryConnection();
      if (_disposed) return;
      _state = CameraLoaded(telemetry);
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _state = CameraError(e.toString());
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

