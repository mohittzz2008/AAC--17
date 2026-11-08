import '../models/system_telemetry_bundle.dart';

abstract class SystemRepository {
  Future<SystemTelemetryBundle> fetchSystemTelemetry();
  Future<SystemTelemetryBundle> refresh();
}

