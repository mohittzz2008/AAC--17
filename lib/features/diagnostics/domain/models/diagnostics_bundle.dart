import '../../../../shared/domain/enums/subsystem_health_status.dart';
import 'diagnostic_issue.dart';

class DiagnosticsBundle {
  final SubsystemHealthStatus overallHealth;
  final SubsystemHealthStatus controllerHealth;
  final SubsystemHealthStatus cameraHealth;
  final SubsystemHealthStatus sensorHealth;
  final SubsystemHealthStatus communicationHealth;
  final SubsystemHealthStatus powerHealth;
  final List<DiagnosticIssue> activeIssues;
  final List<DiagnosticIssue> recentIssues;
  final String statusSubtitle;
  final bool isDemo;

  const DiagnosticsBundle({
    required this.overallHealth,
    required this.controllerHealth,
    required this.cameraHealth,
    required this.sensorHealth,
    required this.communicationHealth,
    required this.powerHealth,
    required this.activeIssues,
    required this.recentIssues,
    required this.statusSubtitle,
    this.isDemo = true,
  });
}

