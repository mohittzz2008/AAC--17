import '../../domain/models/activity_log_entry.dart';
import '../../domain/repositories/activity_logs_repository.dart';
import '../datasources/activity_logs_data_source.dart';

class ActivityLogsRepositoryImpl implements ActivityLogsRepository {
  final ActivityLogsDataSource _dataSource;

  ActivityLogsRepositoryImpl(this._dataSource);

  @override
  Future<List<ActivityLogEntry>> fetchLogs() {
    return _dataSource.getLogs();
  }

  @override
  Future<String> exportLogs() async {
    final logs = await _dataSource.getLogs();
    final buffer = StringBuffer();
    buffer.writeln('ROVER COMMAND - TELEMETRY EVENT LOG EXPORT');
    buffer.writeln('Exported: ${DateTime.now().toIso8601String()}');
    buffer.writeln('----------------------------------------------------');
    for (final log in logs) {
      buffer.writeln('[${log.timestamp}] [${log.severity.displayLabel}] [${log.category.displayLabel}] ${log.title} - ${log.description}');
    }
    return buffer.toString();
  }
}

