import '../models/camera_telemetry.dart';

/// Repository contract for camera telemetry and streaming operations.
abstract class CameraRepository {
  Future<CameraTelemetry> fetchCameraTelemetry();
  Future<CameraTelemetry> retryConnection();
}

