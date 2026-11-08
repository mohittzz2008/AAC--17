import '../models/sensors_telemetry_bundle.dart';

abstract class SensorsRepository {
  Future<SensorsTelemetryBundle> fetchSensorsTelemetry();
  Future<SensorsTelemetryBundle> refresh();
}

