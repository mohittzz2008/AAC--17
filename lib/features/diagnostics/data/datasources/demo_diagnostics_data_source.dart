import '../../../../shared/domain/enums/log_severity.dart';
import '../../../../shared/domain/enums/subsystem_health_status.dart';
import '../../domain/models/diagnostic_issue.dart';
import '../../domain/models/diagnostics_bundle.dart';
import 'diagnostics_data_source.dart';

class DemoDiagnosticsDataSource implements DiagnosticsDataSource {
  const DemoDiagnosticsDataSource();

  @override
  Future<DiagnosticsBundle> getDiagnostics() async {
    return const DiagnosticsBundle(
      overallHealth: SubsystemHealthStatus.warning,
      controllerHealth: SubsystemHealthStatus.warning,
      cameraHealth: SubsystemHealthStatus.error,
      sensorHealth: SubsystemHealthStatus.operational,
      communicationHealth: SubsystemHealthStatus.error,
      powerHealth: SubsystemHealthStatus.unknown,
      statusSubtitle: 'Some components are not verified · Demo session active',
      activeIssues: [
        DiagnosticIssue(
          title: 'Camera stream unavailable',
          description: 'ESP32-CAM module not connected or streaming unverified.',
          severity: LogSeverity.warning,
          subsystem: 'Camera',
        ),
        DiagnosticIssue(
          title: 'Data not verified',
          description: 'Rover is running in demo simulation mode with assembly pending.',
          severity: LogSeverity.info,
          subsystem: 'System',
        ),
      ],
      recentIssues: [
        DiagnosticIssue(
          title: 'No critical hardware faults',
          description: 'Demo self-test completed with zero fatal exceptions.',
          severity: LogSeverity.info,
          subsystem: 'General',
        ),
      ],
    );
  }

  @override
  Future<DiagnosticsBundle> executeDiagnostics() async {
    await Future.delayed(const Duration(milliseconds: 900));
    return getDiagnostics();
  }
}

