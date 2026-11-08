import '../../domain/models/dashboard_telemetry_bundle.dart';

/// Sealed hierarchy representing the immutable UI state of the Dashboard screen.
sealed class DashboardState {
  const DashboardState();
}

/// Initial uninitialized state before any telemetry request has commenced.
final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// State indicating an active telemetry fetch/refresh is in progress.
final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// State representing successfully loaded and validated telemetry.
final class DashboardLoaded extends DashboardState {
  final DashboardTelemetryBundle data;
  final bool isDemoMode;
  final DateTime lastUpdated;

  const DashboardLoaded({
    required this.data,
    this.isDemoMode = true,
    required this.lastUpdated,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardLoaded &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          isDemoMode == other.isDemoMode &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode => data.hashCode ^ isDemoMode.hashCode ^ lastUpdated.hashCode;
}

/// State representing a failed telemetry fetch or provenance integrity error.
final class DashboardError extends DashboardState {
  final String userMessage;

  const DashboardError(this.userMessage);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardError &&
          runtimeType == other.runtimeType &&
          userMessage == other.userMessage;

  @override
  int get hashCode => userMessage.hashCode;
}

