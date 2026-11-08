import 'package:flutter/foundation.dart';
import '../../domain/repositories/diagnostics_repository.dart';
import '../state/diagnostics_state.dart';

class DiagnosticsViewModel extends ChangeNotifier {
  final DiagnosticsRepository _repository;
  DiagnosticsState _state = const DiagnosticsInitial();
  bool _disposed = false;

  DiagnosticsViewModel(this._repository);

  DiagnosticsState get state => _state;

  Future<void> loadDiagnostics() async {
    if (_disposed) return;
    _state = const DiagnosticsLoading();
    notifyListeners();

    try {
      final bundle = await _repository.fetchDiagnostics();
      if (_disposed) return;
      _state = DiagnosticsLoaded(bundle);
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _state = DiagnosticsError(e.toString());
      notifyListeners();
    }
  }

  Future<void> runDiagnostics() async {
    if (_disposed) return;
    if (_state is DiagnosticsLoaded) {
      final current = _state as DiagnosticsLoaded;
      _state = current.copyWith(isRunningCheck: true);
      notifyListeners();

      try {
        final bundle = await _repository.runDiagnosticsCheck();
        if (_disposed) return;
        _state = DiagnosticsLoaded(bundle, isRunningCheck: false);
        notifyListeners();
      } catch (e) {
        if (_disposed) return;
        _state = DiagnosticsError(e.toString());
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }
}

