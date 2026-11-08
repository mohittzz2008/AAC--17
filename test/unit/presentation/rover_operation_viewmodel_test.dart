import 'package:flutter_test/flutter_test.dart';
import 'package:rover_command/features/rover_operation/data/datasources/demo_rover_operation_data_source.dart';
import 'package:rover_command/features/rover_operation/data/repositories/rover_operation_repository_impl.dart';
import 'package:rover_command/features/rover_operation/domain/models/movement_direction.dart';
import 'package:rover_command/features/rover_operation/presentation/state/rover_operation_state.dart';
import 'package:rover_command/features/rover_operation/presentation/viewmodels/rover_operation_viewmodel.dart';

void main() {
  late DemoRoverOperationDataSource dataSource;
  late RoverOperationRepositoryImpl repository;
  late RoverOperationViewModel viewModel;

  setUp(() {
    dataSource = DemoRoverOperationDataSource();
    repository = RoverOperationRepositoryImpl(dataSource);
    viewModel = RoverOperationViewModel(repository);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('RoverOperationViewModel Movement & State Tests', () {
    test('initial state is RoverOperationInitial', () {
      expect(viewModel.state, isA<RoverOperationInitial>());
    });

    test('initialize transitions to RoverOperationLoaded with valid telemetry', () async {
      await viewModel.initialize();

      expect(viewModel.state, isA<RoverOperationLoaded>());
      final loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.telemetry.isConnected, isTrue);
      expect(loaded.telemetry.latencyMs, 48);
      expect(loaded.telemetry.batteryPercentage, 76);
      expect(loaded.activeDirection, MovementDirection.stop);
      expect(loaded.isEmergencyStopped, isFalse);
    });

    test('startMovement updates activeDirection to forward', () async {
      await viewModel.initialize();
      await viewModel.startMovement(MovementDirection.forward);

      final loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.forward);
      expect(loaded.isMoving, isTrue);
    });

    test('stopMovement sets activeDirection back to stop', () async {
      await viewModel.initialize();
      await viewModel.startMovement(MovementDirection.forward);
      await viewModel.stopMovement();

      final loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);
      expect(loaded.isMoving, isFalse);
    });

    test('handleKeyDown and handleKeyUp coordinate movement without duplicate floods', () async {
      await viewModel.initialize();

      // Press 'W' key
      viewModel.handleKeyDown('W');
      var loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.forward);

      // Repeat 'W' (auto-repeat should be safely ignored)
      viewModel.handleKeyDown('W');
      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.forward);

      // Release 'W'
      viewModel.handleKeyUp('W');
      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);
    });

    test('opposing simultaneous keys (W and S) safely stop the rover', () async {
      await viewModel.initialize();

      viewModel.handleKeyDown('W');
      var loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.forward);

      // Press conflicting S key simultaneously
      viewModel.handleKeyDown('S');
      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);
    });

    test('triggerEmergencyStop engages safety lock and blocks all movement', () async {
      await viewModel.initialize();
      await viewModel.startMovement(MovementDirection.forward);

      // Trigger E-Stop
      await viewModel.triggerEmergencyStop();

      var loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.isEmergencyStopped, isTrue);
      expect(loaded.activeDirection, MovementDirection.stop);
      expect(loaded.isMoving, isFalse);

      // Attempting to move while locked has no effect
      await viewModel.startMovement(MovementDirection.forward);
      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);

      // Reset E-Stop restores readiness
      await viewModel.resetEmergencyStop();
      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.isEmergencyStopped, isFalse);
    });

    test('arrow keys trigger corresponding movement directions', () async {
      await viewModel.initialize();

      // Arrow Up -> Forward
      viewModel.handleKeyDown('ARROW UP');
      var loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.forward);
      viewModel.handleKeyUp('ARROW UP');
      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);

      // Arrow Down -> Backward
      viewModel.handleKeyDown('ARROW DOWN');
      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.backward);
      viewModel.handleKeyUp('ARROW DOWN');
      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);

      // Arrow Left -> Left
      viewModel.handleKeyDown('ARROW LEFT');
      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.left);
      viewModel.handleKeyUp('ARROW LEFT');
      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);

      // Arrow Right -> Right
      viewModel.handleKeyDown('ARROW RIGHT');
      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.right);
      viewModel.handleKeyUp('ARROW RIGHT');
      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);
    });

    test('arbitration between WASD and arrow keys handles opposing conflicts safely', () async {
      await viewModel.initialize();

      // Arrow Up + Arrow Down
      viewModel.handleKeyDown('ARROW UP');
      expect((viewModel.state as RoverOperationLoaded).activeDirection, MovementDirection.forward);
      viewModel.handleKeyDown('ARROW DOWN');
      expect((viewModel.state as RoverOperationLoaded).activeDirection, MovementDirection.stop);
      viewModel.handleKeyUp('ARROW DOWN');
      expect((viewModel.state as RoverOperationLoaded).activeDirection, MovementDirection.forward);
      viewModel.handleKeyUp('ARROW UP');
      expect((viewModel.state as RoverOperationLoaded).activeDirection, MovementDirection.stop);

      // W + Arrow Down
      viewModel.handleKeyDown('W');
      expect((viewModel.state as RoverOperationLoaded).activeDirection, MovementDirection.forward);
      viewModel.handleKeyDown('ARROW DOWN');
      expect((viewModel.state as RoverOperationLoaded).activeDirection, MovementDirection.stop);
      viewModel.handleKeyUp('W');
      expect((viewModel.state as RoverOperationLoaded).activeDirection, MovementDirection.backward);
      viewModel.handleKeyUp('ARROW DOWN');
      expect((viewModel.state as RoverOperationLoaded).activeDirection, MovementDirection.stop);

      // A + Arrow Right
      viewModel.handleKeyDown('A');
      expect((viewModel.state as RoverOperationLoaded).activeDirection, MovementDirection.left);
      viewModel.handleKeyDown('ARROW RIGHT');
      expect((viewModel.state as RoverOperationLoaded).activeDirection, MovementDirection.stop);
      viewModel.handleKeyUp('A');
      expect((viewModel.state as RoverOperationLoaded).activeDirection, MovementDirection.right);
      viewModel.handleKeyUp('ARROW RIGHT');
      expect((viewModel.state as RoverOperationLoaded).activeDirection, MovementDirection.stop);
    });

    test('spacebar triggers Emergency Stop immediately regardless of held directional keys', () async {
      await viewModel.initialize();
      viewModel.handleKeyDown('ARROW UP');
      expect((viewModel.state as RoverOperationLoaded).activeDirection, MovementDirection.forward);

      viewModel.handleKeyDown(' ');
      final loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.isEmergencyStopped, isTrue);
      expect(loaded.activeDirection, MovementDirection.stop);
    });

    test('focus loss and app backgrounding immediately halt movement', () async {
      await viewModel.initialize();
      await viewModel.startMovement(MovementDirection.forward);

      viewModel.handleFocusLost();
      var loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);

      await viewModel.startMovement(MovementDirection.left);
      viewModel.handleAppPaused();
      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);
    });

    test('camera expansion toggle and status tab selection update state correctly', () async {
      await viewModel.initialize();

      expect((viewModel.state as RoverOperationLoaded).isCameraExpanded, isFalse);
      viewModel.toggleCameraExpanded();
      expect((viewModel.state as RoverOperationLoaded).isCameraExpanded, isTrue);

      viewModel.selectStatusTab(OperationStatusTab.hardwareHealth);
      expect((viewModel.state as RoverOperationLoaded).activeStatusTab, OperationStatusTab.hardwareHealth);
    });
  });
}

