import 'package:flutter/foundation.dart';
import '../../domain/repositories/configuration_repository.dart';
import '../state/configuration_state.dart';

class ConfigurationViewModel extends ChangeNotifier {
  final ConfigurationRepository _repository;
  ConfigurationState _state = const ConfigurationInitial();
  bool _disposed = false;

  ConfigurationViewModel(this._repository);

  ConfigurationState get state => _state;

  Future<void> loadConfiguration() async {
    if (_disposed) return;
    _state = const ConfigurationLoading();
    notifyListeners();

    try {
      final config = await _repository.fetchConfiguration();
      if (_disposed) return;
      _state = ConfigurationLoaded(currentConfig: config, savedConfig: config);
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _state = ConfigurationError(e.toString());
      notifyListeners();
    }
  }

  void updateDeviceName(String name) {
    if (_state is! ConfigurationLoaded) return;
    final current = _state as ConfigurationLoaded;
    _state = current.copyWith(
      currentConfig: current.currentConfig.copyWith(deviceName: name),
      clearFeedback: true,
    );
    notifyListeners();
  }

  void updateInterval(int seconds) {
    if (_state is! ConfigurationLoaded) return;
    final current = _state as ConfigurationLoaded;
    _state = current.copyWith(
      currentConfig: current.currentConfig.copyWith(telemetryIntervalSeconds: seconds),
      clearFeedback: true,
    );
    notifyListeners();
  }

  void updateSsid(String ssid) {
    if (_state is! ConfigurationLoaded) return;
    final current = _state as ConfigurationLoaded;
    _state = current.copyWith(
      currentConfig: current.currentConfig.copyWith(ssid: ssid),
      clearFeedback: true,
    );
    notifyListeners();
  }

  void updateDistanceUnit(String unit) {
    if (_state is! ConfigurationLoaded) return;
    final current = _state as ConfigurationLoaded;
    _state = current.copyWith(
      currentConfig: current.currentConfig.copyWith(distanceUnit: unit),
      clearFeedback: true,
    );
    notifyListeners();
  }

  Future<void> saveChanges() async {
    if (_state is! ConfigurationLoaded) return;
    final current = _state as ConfigurationLoaded;

    if (!current.hasUnsavedChanges) return;

    _state = current.copyWith(isSaving: true);
    notifyListeners();

    try {
      await _repository.saveConfiguration(current.currentConfig);
      if (_disposed) return;
      _state = current.copyWith(
        savedConfig: current.currentConfig,
        isSaving: false,
        feedbackMessage: 'Configuration saved successfully (Simulated storage)',
      );
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _state = current.copyWith(
        isSaving: false,
        feedbackMessage: 'Error saving configuration: $e',
      );
      notifyListeners();
    }
  }

  Future<void> resetToDefaults() async {
    if (_state is! ConfigurationLoaded) return;
    final current = _state as ConfigurationLoaded;
    _state = current.copyWith(isSaving: true);
    notifyListeners();

    try {
      final defaults = await _repository.resetToDefaults();
      await _repository.saveConfiguration(defaults);
      if (_disposed) return;
      _state = ConfigurationLoaded(
        currentConfig: defaults,
        savedConfig: defaults,
        feedbackMessage: 'Reset to factory demo configuration',
      );
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _state = current.copyWith(
        isSaving: false,
        feedbackMessage: 'Error resetting configuration: $e',
      );
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
