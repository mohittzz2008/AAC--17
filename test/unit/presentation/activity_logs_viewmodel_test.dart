import 'package:flutter_test/flutter_test.dart';
import 'package:rover_command/features/activity_logs/data/datasources/demo_activity_logs_data_source.dart';
import 'package:rover_command/features/activity_logs/data/repositories/activity_logs_repository_impl.dart';
import 'package:rover_command/features/activity_logs/presentation/state/activity_logs_state.dart';
import 'package:rover_command/features/activity_logs/presentation/viewmodels/activity_logs_viewmodel.dart';
import 'package:rover_command/shared/domain/enums/log_category.dart';
import 'package:rover_command/shared/domain/enums/log_severity.dart';

void main() {
  group('ActivityLogsViewModel Tests', () {
    late ActivityLogsViewModel viewModel;

    setUp(() {
      final repository = ActivityLogsRepositoryImpl(const DemoActivityLogsDataSource());
      viewModel = ActivityLogsViewModel(repository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('loadLogs populates allLogs and filteredLogs', () async {
      await viewModel.loadLogs();

      expect(viewModel.state, isA<ActivityLogsLoaded>());
      final state = viewModel.state as ActivityLogsLoaded;
      expect(state.allLogs.isNotEmpty, isTrue);
      expect(state.filteredLogs.length, state.allLogs.length);
    });

    test('search query filters records correctly', () async {
      await viewModel.loadLogs();
      viewModel.setSearchQuery('Camera');

      final state = viewModel.state as ActivityLogsLoaded;
      expect(state.filteredLogs.every((l) => l.title.toLowerCase().contains('camera') || l.description.toLowerCase().contains('camera')), isTrue);
    });

    test('category filter isolates specific functional events', () async {
      await viewModel.loadLogs();
      viewModel.selectCategory(LogCategory.communication);

      final state = viewModel.state as ActivityLogsLoaded;
      expect(state.filteredLogs.every((l) => l.category == LogCategory.communication), isTrue);
    });

    test('severity filter isolates warnings and errors', () async {
      await viewModel.loadLogs();
      viewModel.selectSeverity(LogSeverity.warning);

      final state = viewModel.state as ActivityLogsLoaded;
      expect(state.filteredLogs.every((l) => l.severity == LogSeverity.warning), isTrue);
    });
  });
}

