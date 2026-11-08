import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rover_command/core/theme/app_theme.dart';
import 'package:rover_command/features/rover_operation/data/datasources/demo_rover_operation_data_source.dart';
import 'package:rover_command/features/rover_operation/data/repositories/rover_operation_repository_impl.dart';
import 'package:rover_command/features/rover_operation/domain/models/movement_direction.dart';
import 'package:rover_command/features/rover_operation/presentation/desktop/desktop_expanded_layout.dart';
import 'package:rover_command/features/rover_operation/presentation/desktop/desktop_normal_layout.dart';
import 'package:rover_command/features/rover_operation/presentation/mobile/mobile_landscape_expanded_layout.dart';
import 'package:rover_command/features/rover_operation/presentation/mobile/mobile_portrait_layout.dart';
import 'package:rover_command/features/rover_operation/presentation/screens/rover_operation_screen.dart';
import 'package:rover_command/features/rover_operation/presentation/state/rover_operation_state.dart';
import 'package:rover_command/features/rover_operation/presentation/viewmodels/rover_operation_viewmodel.dart';
import 'package:rover_command/features/rover_operation/presentation/widgets/camera_hud_viewport.dart';
import 'package:rover_command/features/rover_operation/presentation/widgets/directional_control_pad.dart';
import 'package:rover_command/features/rover_operation/presentation/widgets/emergency_stop_button.dart';

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

  Widget buildTestScreen() {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: RoverOperationScreen(viewModel: viewModel),
      ),
    );
  }

  group('RoverOperationScreen Responsive Layout & UI Tests', () {
    testWidgets('renders Desktop Normal Layout on workstation viewport (1440x900)', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      expect(find.byType(DesktopNormalLayout), findsOneWidget);
      expect(find.byType(CameraHudViewport), findsOneWidget);
      expect(find.byType(DirectionalControlPad), findsOneWidget);
      expect(find.byType(EmergencyStopButton), findsOneWidget);
      expect(find.text('Movement Control'), findsOneWidget);
      expect(find.text('Rover Status'), findsOneWidget);
      expect(find.text('Live Sensors'), findsOneWidget);
    });

    testWidgets('renders Desktop Expanded Layout when camera expansion is activated', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Toggle camera expanded
      viewModel.toggleCameraExpanded();
      await tester.pumpAndSettle();

      expect(find.byType(DesktopExpandedLayout), findsOneWidget);
      expect(find.text('RoverControl'), findsOneWidget);
      expect(find.text('Normal View'), findsOneWidget);
    });

    testWidgets('renders Mobile Portrait Layout on 390x844 viewport', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      expect(find.byType(MobilePortraitLayout), findsOneWidget);
      expect(find.byType(DirectionalControlPad), findsOneWidget);
      expect(find.byType(EmergencyStopButton), findsOneWidget);
      expect(find.text('Rover Status'), findsOneWidget);
      expect(find.text('Temp'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
    });

    testWidgets('renders Mobile Landscape Expanded Layout on 844x390 viewport', (tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      expect(find.byType(MobileLandscapeExpandedLayout), findsOneWidget);
      expect(find.text('Live Sensors'), findsOneWidget);
      expect(find.text('Hardware Health'), findsOneWidget);
      expect(find.text('Overall Status'), findsOneWidget);
      expect(find.byType(DirectionalControlPad), findsOneWidget);
      expect(find.byType(EmergencyStopButton), findsOneWidget);
    });

    testWidgets('tapping Emergency Stop engages E-Stop lock and updates button label', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      expect(find.text('EMERGENCY STOP'), findsOneWidget);

      await tester.tap(find.byType(EmergencyStopButton));
      await tester.pumpAndSettle();

      expect(find.text('STOP ENGAGED (TAP TO RESET)'), findsOneWidget);
    });

    testWidgets('keyboard arrow keys trigger rover movement and update DirectionalControlPad visual state', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Press Arrow Up
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      var loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.forward);

      var pad = tester.widget<DirectionalControlPad>(find.byType(DirectionalControlPad));
      expect(pad.activeDirection, MovementDirection.forward);

      // Release Arrow Up
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);
      pad = tester.widget<DirectionalControlPad>(find.byType(DirectionalControlPad));
      expect(pad.activeDirection, MovementDirection.stop);
    });

    testWidgets('browser zoom key shortcuts with Ctrl modifier are ignored by RoverOperationScreen', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen());
      await tester.pumpAndSettle();

      // Simulate Ctrl + '+' (Zoom In)
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.equal);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.equal);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      var loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);

      // Simulate Ctrl + '-' (Zoom Out)
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.minus);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.minus);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);
    });

    testWidgets('movement keys are ignored when an EditableText has focus', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final textController = TextEditingController();
      final textFocusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Column(
              children: [
                TextField(
                  controller: textController,
                  focusNode: textFocusNode,
                ),
                Expanded(
                  child: RoverOperationScreen(viewModel: viewModel),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Focus the text field
      textFocusNode.requestFocus();
      await tester.pumpAndSettle();
      expect(textFocusNode.hasFocus, isTrue);

      // Send 'w' key
      await tester.sendKeyEvent(LogicalKeyboardKey.keyW);
      await tester.pump();

      var loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);

      // Send Arrow Up key
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();

      loaded = viewModel.state as RoverOperationLoaded;
      expect(loaded.activeDirection, MovementDirection.stop);

      textFocusNode.dispose();
      textController.dispose();
    });
  });
}

