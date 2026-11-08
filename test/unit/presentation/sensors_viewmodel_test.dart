import 'package:flutter_test/flutter_test.dart';
import 'package:rover_command/features/dashboard/domain/models/motion_sensor_telemetry.dart';
import 'package:rover_command/features/sensors/data/datasources/demo_sensors_data_source.dart';
import 'package:rover_command/features/sensors/data/repositories/sensors_repository_impl.dart';
import 'package:rover_command/features/sensors/presentation/state/sensors_state.dart';
import 'package:rover_command/features/sensors/presentation/viewmodels/sensors_viewmodel.dart';

void main() {
  group('SensorsViewModel Tests', () {
    late SensorsViewModel viewModel;

    setUp(() {
      final repository = SensorsRepositoryImpl(const DemoSensorsDataSource());
      viewModel = SensorsViewModel(repository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('initial state is SensorsInitial', () {
      expect(viewModel.state, isA<SensorsInitial>());
    });

    test('loadSensors transitions to SensorsLoaded with 4 total simulated sensors', () async {
      await viewModel.loadSensors();

      expect(viewModel.state, isA<SensorsLoaded>());
      final state = viewModel.state as SensorsLoaded;
      expect(state.data.summary.totalCount, 4);
      expect(state.data.distanceSensors.length, 2);
      expect(state.data.motionSensors.length, 2);

      // Verify simulated distance measurements
      expect(state.data.distanceSensors[0].verifiedDistance, 124);
      expect(state.data.distanceSensors[1].verifiedDistance, 86);

      // Verify simulated motion states
      expect(state.data.motionSensors[0].resolvedState, MotionState.clear);
      expect(state.data.motionSensors[1].resolvedState, MotionState.motion);
    });
  });
}

