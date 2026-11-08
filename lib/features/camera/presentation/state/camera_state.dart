import '../../domain/models/camera_telemetry.dart';

sealed class CameraState {
  const CameraState();
}

class CameraInitial extends CameraState {
  const CameraInitial();
}

class CameraConnecting extends CameraState {
  const CameraConnecting();
}

class CameraLoaded extends CameraState {
  final CameraTelemetry telemetry;
  const CameraLoaded(this.telemetry);
}

class CameraError extends CameraState {
  final String message;
  const CameraError(this.message);
}

