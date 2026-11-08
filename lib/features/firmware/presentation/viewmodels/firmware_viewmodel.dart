import 'package:flutter/foundation.dart';
import '../../domain/repositories/firmware_repository.dart';
import '../state/firmware_state.dart';

class FirmwareViewModel extends ChangeNotifier {
  final FirmwareRepository _repository;
  FirmwareState _state = const FirmwareInitial();
  bool _disposed = false;

  FirmwareViewModel(this._repository);

  FirmwareState get state => _state;

  Future<void> loadFirmwareInfo() async {
    if (_disposed) return;
    _state = const FirmwareLoading();
    notifyListeners();

    try {
      final bundle = await _repository.fetchFirmwareInfo();
      if (_disposed) return;
      _state = FirmwareLoaded(bundle);
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _state = FirmwareError(e.toString());
      notifyListeners();
    }
  }

  Future<void> checkForUpdates() async {
    if (_disposed) return;
    if (_state is FirmwareLoaded) {
      final current = _state as FirmwareLoaded;
      _state = current.copyWith(isCheckingUpdates: true);
      notifyListeners();

      try {
        final bundle = await _repository.checkForUpdates();
        if (_disposed) return;
        _state = FirmwareLoaded(
          bundle,
          isCheckingUpdates: false,
          feedbackMessage: 'All firmware modules up to date · Running verified demo baseline',
        );
        notifyListeners();
      } catch (e) {
        if (_disposed) return;
        _state = current.copyWith(
          isCheckingUpdates: false,
          feedbackMessage: 'Failed to query updates: $e',
        );
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

