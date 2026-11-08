import '../../domain/models/camera_telemetry.dart';

abstract class CameraDataSource {
  Future<CameraTelemetry> getCameraTelemetry();
  Future<CameraTelemetry> attemptConnection();
}

