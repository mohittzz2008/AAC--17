import '../../domain/models/activity_log_entry.dart';

abstract class ActivityLogsDataSource {
  Future<List<ActivityLogEntry>> getLogs();
}

