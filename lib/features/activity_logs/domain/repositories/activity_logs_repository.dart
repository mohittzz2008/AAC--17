import '../models/activity_log_entry.dart';

abstract class ActivityLogsRepository {
  Future<List<ActivityLogEntry>> fetchLogs();
  Future<String> exportLogs();
}

