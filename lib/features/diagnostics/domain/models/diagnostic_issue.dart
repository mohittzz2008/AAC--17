import '../../../../shared/domain/enums/log_severity.dart';

class DiagnosticIssue {
  final String title;
  final String description;
  final LogSeverity severity;
  final String subsystem;

  const DiagnosticIssue({
    required this.title,
    required this.description,
    required this.severity,
    required this.subsystem,
  });
}

