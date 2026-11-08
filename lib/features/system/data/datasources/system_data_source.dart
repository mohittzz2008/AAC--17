import '../../domain/models/system_telemetry_bundle.dart';

abstract class SystemDataSource {
  Future<SystemTelemetryBundle> getSystemTelemetry();
}

