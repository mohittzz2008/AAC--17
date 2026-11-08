import 'package:flutter/foundation.dart';
import '../../../../shared/domain/enums/log_category.dart';
import '../../../../shared/domain/enums/log_severity.dart';
import '../../domain/models/activity_log_entry.dart';
import '../../domain/repositories/activity_logs_repository.dart';
import '../state/activity_logs_state.dart';

class ActivityLogsViewModel extends ChangeNotifier {
  final ActivityLogsRepository _repository;
  ActivityLogsState _state = const ActivityLogsInitial();
  bool _disposed = false;

  ActivityLogsViewModel(this._repository);

  ActivityLogsState get state => _state;

  Future<void> loadLogs() async {
    if (_disposed) return;
    _state = const ActivityLogsLoading();
    notifyListeners();

    try {
      final logs = await _repository.fetchLogs();
      if (_disposed) return;
      _state = ActivityLogsLoaded(allLogs: logs, filteredLogs: logs);
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _state = ActivityLogsError(e.toString());
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_state is! ActivityLogsLoaded) return;
    final current = _state as ActivityLogsLoaded;
    final updated = current.copyWith(searchQuery: query);
    _applyFilters(updated);
  }

  void selectCategory(LogCategory? category) {
    if (_state is! ActivityLogsLoaded) return;
    final current = _state as ActivityLogsLoaded;
    final updated = current.selectedCategory == category
        ? current.copyWith(clearCategory: true)
        : current.copyWith(selectedCategory: category);
    _applyFilters(updated);
  }

  void selectSeverity(LogSeverity? severity) {
    if (_state is! ActivityLogsLoaded) return;
    final current = _state as ActivityLogsLoaded;
    final updated = current.selectedSeverity == severity
        ? current.copyWith(clearSeverity: true)
        : current.copyWith(selectedSeverity: severity);
    _applyFilters(updated);
  }

  void _applyFilters(ActivityLogsLoaded state) {
    List<ActivityLogEntry> result = state.allLogs;

    if (state.selectedCategory != null) {
      result = result.where((l) => l.category == state.selectedCategory).toList();
    }

    if (state.selectedSeverity != null) {
      result = result.where((l) => l.severity == state.selectedSeverity).toList();
    }

    if (state.searchQuery.trim().isNotEmpty) {
      final q = state.searchQuery.trim().toLowerCase();
      result = result.where((l) {
        return l.title.toLowerCase().contains(q) ||
            l.description.toLowerCase().contains(q) ||
            l.source.toLowerCase().contains(q);
      }).toList();
    }

    _state = state.copyWith(filteredLogs: result);
    notifyListeners();
  }

  Future<String> exportLogs() {
    return _repository.exportLogs();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }
}

