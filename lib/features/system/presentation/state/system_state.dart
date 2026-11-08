import '../../domain/models/system_telemetry_bundle.dart';

sealed class SystemState {
  const SystemState();
}

class SystemInitial extends SystemState {
  const SystemInitial();
}

class SystemLoading extends SystemState {
  const SystemLoading();
}

class SystemLoaded extends SystemState {
  final SystemTelemetryBundle data;
  const SystemLoaded(this.data);
}

class SystemError extends SystemState {
  final String message;
  const SystemError(this.message);
}

