import '../../domain/models/movement_direction.dart';
import '../../domain/models/rover_operation_telemetry.dart';

enum OperationStatusTab {
  liveSensors('Live Sensors'),
  hardwareHealth('Hardware Health'),
  overallStatus('Overall Status');

  final String label;
  const OperationStatusTab(this.label);
}

sealed class RoverOperationState {
  const RoverOperationState();
}

class RoverOperationInitial extends RoverOperationState {
  const RoverOperationInitial();
}

class RoverOperationLoading extends RoverOperationState {
  const RoverOperationLoading();
}

class RoverOperationLoaded extends RoverOperationState {
  final RoverOperationTelemetry telemetry;
  final MovementDirection activeDirection;
  final bool isEmergencyStopped;
  final bool isCameraExpanded;
  final OperationStatusTab activeStatusTab;
  final bool isRecording;
  final bool isSnapshotActive;
  final String? noticeMessage;

  const RoverOperationLoaded({
    required this.telemetry,
    this.activeDirection = MovementDirection.stop,
    this.isEmergencyStopped = false,
    this.isCameraExpanded = false,
    this.activeStatusTab = OperationStatusTab.liveSensors,
    this.isRecording = false,
    this.isSnapshotActive = false,
    this.noticeMessage,
  });

  bool get isMoving =>
      activeDirection != MovementDirection.stop && !isEmergencyStopped;

  RoverOperationLoaded copyWith({
    RoverOperationTelemetry? telemetry,
    MovementDirection? activeDirection,
    bool? isEmergencyStopped,
    bool? isCameraExpanded,
    OperationStatusTab? activeStatusTab,
    bool? isRecording,
    bool? isSnapshotActive,
    String? noticeMessage,
    bool clearNotice = false,
  }) {
    return RoverOperationLoaded(
      telemetry: telemetry ?? this.telemetry,
      activeDirection: activeDirection ?? this.activeDirection,
      isEmergencyStopped: isEmergencyStopped ?? this.isEmergencyStopped,
      isCameraExpanded: isCameraExpanded ?? this.isCameraExpanded,
      activeStatusTab: activeStatusTab ?? this.activeStatusTab,
      isRecording: isRecording ?? this.isRecording,
      isSnapshotActive: isSnapshotActive ?? this.isSnapshotActive,
      noticeMessage: clearNotice ? null : (noticeMessage ?? this.noticeMessage),
    );
  }
}

class RoverOperationError extends RoverOperationState {
  final String message;
  const RoverOperationError(this.message);
}

