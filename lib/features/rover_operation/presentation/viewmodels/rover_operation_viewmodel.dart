import 'package:flutter/foundation.dart';
import '../../domain/models/movement_direction.dart';
import '../../domain/repositories/rover_operation_repository.dart';
import '../state/rover_operation_state.dart';

/// ViewModel orchestrating directional motion, safety arbitration, emergency stops,
/// camera expansion toggles, and multi-input coordination (Keyboard + Touch).
class RoverOperationViewModel extends ChangeNotifier {
  final RoverOperationRepository _repository;

  RoverOperationState _state = const RoverOperationInitial();
  bool _disposed = false;

  /// Tracks currently held physical keys to prevent OS key-repeat floods
  /// and perform deterministic multi-key arbitration.
  final Set<String> _heldKeys = <String>{};

  RoverOperationViewModel(this._repository);

  RoverOperationState get state => _state;

  Future<void> initialize() async {
    if (_disposed) return;
    _state = const RoverOperationLoading();
    notifyListeners();

    try {
      final telemetry = await _repository.fetchOperationTelemetry();
      if (_disposed) return;
      _state = RoverOperationLoaded(telemetry: telemetry);
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _state = RoverOperationError(e.toString());
      notifyListeners();
    }
  }

  /// Initiates movement in a given direction (via on-screen touch or keyboard).
  Future<void> startMovement(MovementDirection direction) async {
    if (_disposed) return;
    final currentState = _state;
    if (currentState is! RoverOperationLoaded) return;

    if (currentState.isEmergencyStopped) {
      _notifyNotice('Cannot move: Emergency Stop is currently engaged!');
      return;
    }

    // Do not re-dispatch if already moving in this direction.
    if (currentState.activeDirection == direction) return;

    // Immediate synchronous UI state update for instant response
    _state = currentState.copyWith(
      activeDirection: direction,
      noticeMessage: null,
      clearNotice: true,
    );
    notifyListeners();

    try {
      await _repository.sendMovementCommand(direction);
    } catch (e) {
      if (_disposed) return;
      _notifyNotice('Movement dispatch failed: $e');
    }
  }

  /// Stops directional movement (touch release, key release, touch cancellation).
  Future<void> stopMovement() async {
    if (_disposed) return;
    final currentState = _state;
    if (currentState is! RoverOperationLoaded) return;

    if (currentState.activeDirection == MovementDirection.stop) return;

    // Immediate synchronous UI state update
    _state = currentState.copyWith(
      activeDirection: MovementDirection.stop,
    );
    notifyListeners();

    try {
      await _repository.sendStopCommand();
    } catch (e) {
      if (_disposed) return;
      _notifyNotice('Stop dispatch failed: $e');
    }
  }

  /// Keyboard key down handler with auto-repeat suppression and conflict arbitration.
  void handleKeyDown(String key) {
    final normalized = (key == ' ' || key.toUpperCase() == 'SPACE')
        ? ' '
        : key.trim().toUpperCase();
    if (_heldKeys.contains(normalized)) {
      // Ignore OS key auto-repeat
      return;
    }
    _heldKeys.add(normalized);

    if (normalized == ' ') {
      triggerEmergencyStop();
      return;
    }

    _arbitrateHeldKeys();
  }

  /// Keyboard key release handler.
  void handleKeyUp(String key) {
    final normalized = (key == ' ' || key.toUpperCase() == 'SPACE')
        ? ' '
        : key.trim().toUpperCase();
    _heldKeys.remove(normalized);

    _arbitrateHeldKeys();
  }

  /// Arbitrates multi-key combinations:
  /// - Supports both W/A/S/D and Arrow Keys (Arrow Up, Down, Left, Right).
  /// - Opposing keys (Forward and Backward, or Left and Right) halt movement safely.
  /// - Emergency Stop maintains strict priority over any movement.
  void _arbitrateHeldKeys() {
    final hasForward = _heldKeys.contains('W') ||
        _heldKeys.contains('ARROW UP') ||
        _heldKeys.contains('ARROWUP') ||
        _heldKeys.contains('UP');
    final hasBackward = _heldKeys.contains('S') ||
        _heldKeys.contains('ARROW DOWN') ||
        _heldKeys.contains('ARROWDOWN') ||
        _heldKeys.contains('DOWN');
    final hasLeft = _heldKeys.contains('A') ||
        _heldKeys.contains('ARROW LEFT') ||
        _heldKeys.contains('ARROWLEFT') ||
        _heldKeys.contains('LEFT');
    final hasRight = _heldKeys.contains('D') ||
        _heldKeys.contains('ARROW RIGHT') ||
        _heldKeys.contains('ARROWRIGHT') ||
        _heldKeys.contains('RIGHT');

    // Conflicting opposing keys
    if ((hasForward && hasBackward) || (hasLeft && hasRight)) {
      stopMovement();
      return;
    }

    if (hasForward) {
      startMovement(MovementDirection.forward);
    } else if (hasBackward) {
      startMovement(MovementDirection.backward);
    } else if (hasLeft) {
      startMovement(MovementDirection.left);
    } else if (hasRight) {
      startMovement(MovementDirection.right);
    } else {
      // No directional movement keys held
      stopMovement();
    }
  }

  /// Triggers immediate Emergency Stop with highest priority.
  Future<void> triggerEmergencyStop() async {
    if (_disposed) return;
    final currentState = _state;
    if (currentState is! RoverOperationLoaded) return;

    _heldKeys.clear();

    // Immediate synchronous safety lock
    _state = currentState.copyWith(
      activeDirection: MovementDirection.stop,
      isEmergencyStopped: true,
      noticeMessage: 'EMERGENCY STOP ENGAGED: Motors halted.',
    );
    notifyListeners();

    try {
      await _repository.triggerEmergencyStop();
    } catch (e) {
      if (_disposed) return;
      _notifyNotice('Emergency Stop trigger error: $e');
    }
  }

  /// Releases/resets Emergency Stop after safety verification.
  Future<void> resetEmergencyStop() async {
    if (_disposed) return;
    final currentState = _state;
    if (currentState is! RoverOperationLoaded) return;

    try {
      await _repository.resetEmergencyStop();
      if (_disposed) return;

      _state = currentState.copyWith(
        isEmergencyStopped: false,
        activeDirection: MovementDirection.stop,
        noticeMessage: 'Emergency Stop released. Rover ready.',
      );
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _notifyNotice('Emergency Stop reset error: $e');
    }
  }

  /// Safety handler when window or focus is lost.
  void handleFocusLost() {
    _heldKeys.clear();
    stopMovement();
  }

  /// Safety handler when app is backgrounded / paused.
  void handleAppPaused() {
    _heldKeys.clear();
    stopMovement();
  }

  /// Toggles camera expansion view.
  void toggleCameraExpanded() {
    final currentState = _state;
    if (currentState is! RoverOperationLoaded) return;

    _state = currentState.copyWith(
      isCameraExpanded: !currentState.isCameraExpanded,
    );
    notifyListeners();
  }

  /// Selects the status tab for mobile landscape overlay.
  void selectStatusTab(OperationStatusTab tab) {
    final currentState = _state;
    if (currentState is! RoverOperationLoaded) return;

    _state = currentState.copyWith(activeStatusTab: tab);
    notifyListeners();
  }

  /// Toggles simulated recording flag.
  void toggleRecording() {
    final currentState = _state;
    if (currentState is! RoverOperationLoaded) return;

    _state = currentState.copyWith(isRecording: !currentState.isRecording);
    notifyListeners();
  }

  /// Simulates snapshot photo capture.
  void captureSnapshot() {
    final currentState = _state;
    if (currentState is! RoverOperationLoaded) return;

    _state = currentState.copyWith(isSnapshotActive: true);
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!_disposed && _state is RoverOperationLoaded) {
        _state = (_state as RoverOperationLoaded).copyWith(
          isSnapshotActive: false,
          noticeMessage: 'Snapshot captured and saved.',
        );
        notifyListeners();
      }
    });
  }

  void _notifyNotice(String msg) {
    final currentState = _state;
    if (currentState is RoverOperationLoaded) {
      _state = currentState.copyWith(noticeMessage: msg);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _heldKeys.clear();
    super.dispose();
  }
}
