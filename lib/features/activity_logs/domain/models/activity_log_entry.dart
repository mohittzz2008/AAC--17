import '../../../../shared/domain/enums/log_category.dart';
import '../../../../shared/domain/enums/log_severity.dart';

class ActivityLogEntry {
  final String id;
  final String timestamp;
  final LogCategory category;
  final LogSeverity severity;
  final String title;
  final String description;
  final String source;
  final String? errorCode;

  const ActivityLogEntry({
    required this.id,
    required this.timestamp,
    required this.category,
    required this.severity,
    required this.title,
    required this.description,
    required this.source,
    this.errorCode,
  });
}

