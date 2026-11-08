import '../../../../shared/domain/enums/log_category.dart';
import '../../../../shared/domain/enums/log_severity.dart';
import '../../domain/models/activity_log_entry.dart';

sealed class ActivityLogsState {
  const ActivityLogsState();
}

class ActivityLogsInitial extends ActivityLogsState {
  const ActivityLogsInitial();
}

class ActivityLogsLoading extends ActivityLogsState {
  const ActivityLogsLoading();
}

class ActivityLogsLoaded extends ActivityLogsState {
  final List<ActivityLogEntry> allLogs;
  final List<ActivityLogEntry> filteredLogs;
  final String searchQuery;
  final LogCategory? selectedCategory;
  final LogSeverity? selectedSeverity;

  const ActivityLogsLoaded({
    required this.allLogs,
    required this.filteredLogs,
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedSeverity,
  });

  ActivityLogsLoaded copyWith({
    List<ActivityLogEntry>? allLogs,
    List<ActivityLogEntry>? filteredLogs,
    String? searchQuery,
    LogCategory? selectedCategory,
    LogSeverity? selectedSeverity,
    bool clearCategory = false,
    bool clearSeverity = false,
  }) {
    return ActivityLogsLoaded(
      allLogs: allLogs ?? this.allLogs,
      filteredLogs: filteredLogs ?? this.filteredLogs,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedSeverity: clearSeverity ? null : (selectedSeverity ?? this.selectedSeverity),
    );
  }
}

class ActivityLogsError extends ActivityLogsState {
  final String message;
  const ActivityLogsError(this.message);
}

