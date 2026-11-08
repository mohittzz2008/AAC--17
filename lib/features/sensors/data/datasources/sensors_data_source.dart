import '../../domain/models/sensors_telemetry_bundle.dart';

abstract class SensorsDataSource {
  Future<SensorsTelemetryBundle> getSensorsTelemetry();
}

