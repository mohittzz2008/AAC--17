import 'package:flutter/foundation.dart';
import '../../domain/repositories/sensors_repository.dart';
import '../state/sensors_state.dart';

class SensorsViewModel extends ChangeNotifier {
  final SensorsRepository _repository;
  SensorsState _state = const SensorsInitial();
  bool _disposed = false;

  SensorsViewModel(this._repository);

  SensorsState get state => _state;

  Future<void> loadSensors() async {
    if (_disposed) return;
    _state = const SensorsLoading();
    notifyListeners();

    try {
      final bundle = await _repository.fetchSensorsTelemetry();
      if (_disposed) return;
      _state = SensorsLoaded(bundle);
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _state = SensorsError(e.toString());
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_disposed) return;
    try {
      final bundle = await _repository.refresh();
      if (_disposed) return;
      _state = SensorsLoaded(bundle);
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _state = SensorsError(e.toString());
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

