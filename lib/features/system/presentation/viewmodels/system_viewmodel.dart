import 'package:flutter/foundation.dart';
import '../../domain/repositories/system_repository.dart';
import '../state/system_state.dart';

class SystemViewModel extends ChangeNotifier {
  final SystemRepository _repository;
  SystemState _state = const SystemInitial();
  bool _disposed = false;

  SystemViewModel(this._repository);

  SystemState get state => _state;

  Future<void> loadSystem() async {
    if (_disposed) return;
    _state = const SystemLoading();
    notifyListeners();

    try {
      final bundle = await _repository.fetchSystemTelemetry();
      if (_disposed) return;
      _state = SystemLoaded(bundle);
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _state = SystemError(e.toString());
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_disposed) return;
    try {
      final bundle = await _repository.refresh();
      if (_disposed) return;
      _state = SystemLoaded(bundle);
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _state = SystemError(e.toString());
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

