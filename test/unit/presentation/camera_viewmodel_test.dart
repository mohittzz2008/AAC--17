import 'package:flutter_test/flutter_test.dart';
import 'package:rover_command/features/camera/data/datasources/demo_camera_data_source.dart';
import 'package:rover_command/features/camera/data/repositories/camera_repository_impl.dart';
import 'package:rover_command/features/camera/presentation/state/camera_state.dart';
import 'package:rover_command/features/camera/presentation/viewmodels/camera_viewmodel.dart';
import 'package:rover_command/shared/domain/enums/connection_status.dart';
import 'package:rover_command/shared/domain/enums/hardware_verification_status.dart';

void main() {
  group('CameraViewModel Tests', () {
    late CameraViewModel viewModel;

    setUp(() {
      final repository = CameraRepositoryImpl(const DemoCameraDataSource());
      viewModel = CameraViewModel(repository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    test('initial state is CameraInitial', () {
      expect(viewModel.state, isA<CameraInitial>());
    });

    test('loadTelemetry transitions to CameraLoaded with unverified disconnected state', () async {
      await viewModel.loadTelemetry();

      expect(viewModel.state, isA<CameraLoaded>());
      final state = viewModel.state as CameraLoaded;
      expect(state.telemetry.moduleTitle, 'ESP32-CAM');
      expect(state.telemetry.connectionStatus, ConnectionStatus.disconnected);
      expect(state.telemetry.verification, HardwareVerificationStatus.notVerified);
      expect(state.telemetry.resolution, isNull);
      expect(state.telemetry.isStreaming, isFalse);
    });

    test('retryConnection updates state with honest unavailable status', () async {
      await viewModel.retryConnection();

      expect(viewModel.state, isA<CameraLoaded>());
      final state = viewModel.state as CameraLoaded;
      expect(state.telemetry.connectionStatus, ConnectionStatus.disconnected);
    });
  });
}

