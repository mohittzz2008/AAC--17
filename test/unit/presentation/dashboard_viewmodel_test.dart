import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:rover_command/features/dashboard/domain/models/camera_preview_telemetry.dart';
import 'package:rover_command/features/dashboard/domain/models/dashboard_telemetry_bundle.dart';
import 'package:rover_command/features/dashboard/domain/models/distance_sensor_telemetry.dart';
import 'package:rover_command/features/dashboard/domain/models/hardware_inventory_item.dart';
import 'package:rover_command/features/dashboard/domain/models/motion_sensor_telemetry.dart';
import 'package:rover_command/features/dashboard/domain/models/rover_session_status.dart';
import 'package:rover_command/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:rover_command/features/dashboard/presentation/state/dashboard_state.dart';
import 'package:rover_command/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:rover_command/shared/domain/enums/data_source_type.dart';

/// Fake repository implementation for deterministic ViewModel unit tests.
class FakeDashboardRepository implements DashboardRepository {
  Future<DashboardTelemetryBundle> Function()? onGetSnapshot;
  int callCount = 0;

  @override
  Future<DashboardTelemetryBundle> getTelemetrySnapshot() async {
    callCount++;
    if (onGetSnapshot != null) {
      return onGetSnapshot!();
    }
    return _buildSampleBundle(dataSourceType: DataSourceType.demoSimulated);
  }

  static DashboardTelemetryBundle _buildSampleBundle({
    required DataSourceType dataSourceType,
  }) {
    return DashboardTelemetryBundle(
      session: RoverSessionStatus(
        roverId: 'ROVER-01',
        sessionDescription: 'Simulated data only',
        dataSourceType: dataSourceType,
      ),
      hardwareOverview: [
        HardwareInventoryItem(
          categoryKey: 'BATTERY',
          specification: '12V Li-ion',
          dataSourceType: dataSourceType,
        ),
      ],
      cameraPreview: CameraPreviewTelemetry(
        dataSourceType: dataSourceType,
      ),
      distanceSensors: [
        DistanceSensorTelemetry(
          sensorId: '01',
          distanceCm: 124,
          dataSourceType: dataSourceType,
        ),
      ],
      motionSensors: [
        MotionSensorTelemetry(
          sensorId: '01',
          state: MotionState.clear,
          dataSourceType: dataSourceType,
        ),
      ],
      timestamp: DateTime(2026, 11, 7, 19, 0),
    );
  }
}

void main() {
  group('DashboardViewModel Tests', () {
    late FakeDashboardRepository repository;
    late DashboardViewModel viewModel;

    setUp(() {
      repository = FakeDashboardRepository();
      viewModel = DashboardViewModel(repository: repository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('initial state is DashboardInitial and not fetching', () {
      expect(viewModel.state, isA<DashboardInitial>());
      expect(viewModel.isFetching, isFalse);
    });

    test('emits DashboardLoading then DashboardLoaded upon success', () async {
      final stateHistory = <DashboardState>[];
      viewModel.addListener(() {
        stateHistory.add(viewModel.state);
      });

      await viewModel.loadTelemetry();

      expect(stateHistory.length, 2);
      expect(stateHistory[0], isA<DashboardLoading>());
      expect(stateHistory[1], isA<DashboardLoaded>());

      final loaded = stateHistory[1] as DashboardLoaded;
      expect(loaded.data.session.roverId, 'ROVER-01');
      expect(loaded.isDemoMode, isTrue);
      expect(viewModel.isFetching, isFalse);
    });

    test('preserves demoSimulated provenance in isDemoMode', () async {
      repository.onGetSnapshot = () async {
        return FakeDashboardRepository._buildSampleBundle(
          dataSourceType: DataSourceType.demoSimulated,
        );
      };

      await viewModel.loadTelemetry();

      expect(viewModel.state, isA<DashboardLoaded>());
      final loaded = viewModel.state as DashboardLoaded;
      expect(loaded.isDemoMode, isTrue);
      expect(loaded.data.session.dataSourceType.isSimulated, isTrue);
    });

    test('emits DashboardError when repository fails', () async {
      repository.onGetSnapshot = () async {
        throw StateError('Simulated hardware bus disconnect');
      };

      final stateHistory = <DashboardState>[];
      viewModel.addListener(() {
        stateHistory.add(viewModel.state);
      });

      await viewModel.loadTelemetry();

      expect(stateHistory.length, 2);
      expect(stateHistory[0], isA<DashboardLoading>());
      expect(stateHistory[1], isA<DashboardError>());

      final error = stateHistory[1] as DashboardError;
      expect(error.userMessage, contains('Simulated hardware bus disconnect'));
      expect(viewModel.isFetching, isFalse);
    });

    test('prevents repeated concurrent requests while a fetch is running', () async {
      final completer = Completer<DashboardTelemetryBundle>();
      repository.onGetSnapshot = () => completer.future;

      // Launch first request (blocks until completer completes)
      final future1 = viewModel.loadTelemetry();
      expect(viewModel.isFetching, isTrue);
      expect(repository.callCount, 1);

      // Attempt second request while first is still in-flight
      final future2 = viewModel.loadTelemetry();
      // Should still be 1 call to repository
      expect(repository.callCount, 1);

      // Complete the in-flight request
      completer.complete(
        FakeDashboardRepository._buildSampleBundle(
          dataSourceType: DataSourceType.demoSimulated,
        ),
      );

      await Future.wait([future1, future2]);

      expect(repository.callCount, 1);
      expect(viewModel.state, isA<DashboardLoaded>());
      expect(viewModel.isFetching, isFalse);
    });

    test('refresh() updates state without resetting to DashboardLoading', () async {
      // First, perform normal initial load
      await viewModel.loadTelemetry();
      expect(viewModel.state, isA<DashboardLoaded>());

      final statesDuringRefresh = <DashboardState>[];
      viewModel.addListener(() {
        statesDuringRefresh.add(viewModel.state);
      });

      await viewModel.refresh();

      // With showLoadingIndicator: false, state updates directly to new DashboardLoaded
      expect(statesDuringRefresh.length, 1);
      expect(statesDuringRefresh[0], isA<DashboardLoaded>());
    });

    test('does not notify listeners or mutate state after disposal', () async {
      final completer = Completer<DashboardTelemetryBundle>();
      repository.onGetSnapshot = () => completer.future;

      var listenerNotified = false;
      viewModel.addListener(() {
        listenerNotified = true;
      });

      final future = viewModel.loadTelemetry();
      listenerNotified = false; // Reset after initial loading notification

      // Dispose while request is in-flight
      viewModel.dispose();

      // Now complete the future
      completer.complete(
        FakeDashboardRepository._buildSampleBundle(
          dataSourceType: DataSourceType.demoSimulated,
        ),
      );
      await future;

      // Listener should not be called after disposal
      expect(listenerNotified, isFalse);
    });
  });
}

