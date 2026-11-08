import '../../domain/models/sensors_telemetry_bundle.dart';

sealed class SensorsState {
  const SensorsState();
}

class SensorsInitial extends SensorsState {
  const SensorsInitial();
}

class SensorsLoading extends SensorsState {
  const SensorsLoading();
}

class SensorsLoaded extends SensorsState {
  final SensorsTelemetryBundle data;
  const SensorsLoaded(this.data);
}

class SensorsError extends SensorsState {
  final String message;
  const SensorsError(this.message);
}

