import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rover_command/core/theme/app_theme.dart';
import 'package:rover_command/features/dashboard/data/datasources/demo_dashboard_data_source.dart';
import 'package:rover_command/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:rover_command/features/dashboard/domain/models/dashboard_telemetry_bundle.dart';
import 'package:rover_command/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:rover_command/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:rover_command/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:rover_command/features/dashboard/presentation/widgets/camera_preview_card.dart';
import 'package:rover_command/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:rover_command/features/dashboard/presentation/widgets/distance_sensors_section.dart';
import 'package:rover_command/features/dashboard/presentation/widgets/hardware_overview_grid.dart';
import 'package:rover_command/features/dashboard/presentation/widgets/motion_sensors_section.dart';
import 'package:rover_command/features/dashboard/presentation/widgets/rover_status_alert_banner.dart';

class TestMockRepository implements DashboardRepository {
  final Future<DashboardTelemetryBundle> Function() fetchCallback;

  TestMockRepository(this.fetchCallback);

  @override
  Future<DashboardTelemetryBundle> getTelemetrySnapshot() => fetchCallback();
}

void main() {
  Widget buildTestScreen({required DashboardViewModel viewModel}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: DashboardScreen(viewModel: viewModel),
      ),
    );
  }

  group('DashboardScreen Presentation & Content Tests', () {
    late DashboardRepository repository;
    late DashboardViewModel viewModel;

    setUp(() {
      repository = const DashboardRepositoryImpl(
        dataSource: DemoDashboardDataSource(),
      );
      viewModel = DashboardViewModel(repository: repository);
    });

    tearDown(() {
      viewModel.dispose();
    });

    testWidgets('renders all six primary Figma dashboard sections upon load', (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen(viewModel: viewModel));
      await tester.pumpAndSettle();

      // 1. DashboardHeader
      expect(find.byType(DashboardHeader), findsOneWidget);
      expect(find.text('ROVER COMMAND'), findsOneWidget);
      expect(find.text('INSPECTION & MONITORING'), findsOneWidget);
      expect(find.text('DEMO MODE'), findsOneWidget);

      // 2. RoverStatusAlertBanner
      expect(find.byType(RoverStatusAlertBanner), findsOneWidget);
      expect(find.text('ROVER-01'), findsOneWidget);
      expect(find.text('Simulated data only · No live connection'), findsOneWidget);

      // 3. HardwareOverviewGrid
      expect(find.byType(HardwareOverviewGrid), findsOneWidget);

      // 4. CameraPreviewCard
      expect(find.byType(CameraPreviewCard), findsOneWidget);

      // 5. DistanceSensorsSection
      expect(find.byType(DistanceSensorsSection), findsOneWidget);

      // 6. MotionSensorsSection
      expect(find.byType(MotionSensorsSection), findsOneWidget);
    });

    testWidgets('displays exact 4-item hardware inventory specification', (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen(viewModel: viewModel));
      await tester.pumpAndSettle();

      // Battery
      expect(find.text('BATTERY'), findsOneWidget);
      expect(find.text('12V Li-ion'), findsOneWidget);

      // Controller
      expect(find.text('CONTROLLER'), findsOneWidget);
      expect(find.text('2 × ESP32 DevKit'), findsOneWidget);

      // Camera
      expect(find.text('CAMERA'), findsOneWidget);
      expect(find.text('ESP32-CAM'), findsOneWidget);

      // Hardware
      expect(find.text('HARDWARE'), findsOneWidget);
      expect(find.text('Assembly pending'), findsOneWidget);
    });

    testWidgets('displays exact simulated distance sensor readings and units', (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen(viewModel: viewModel));
      await tester.pumpAndSettle();

      expect(find.text('HC-SR04 / 01'), findsOneWidget);
      expect(find.text('124'), findsOneWidget);

      expect(find.text('HC-SR04 / 02'), findsOneWidget);
      expect(find.text('86'), findsOneWidget);

      expect(find.text('cm'), findsNWidgets(2));
    });

    testWidgets('displays exact simulated motion sensor states', (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen(viewModel: viewModel));
      await tester.pumpAndSettle();

      expect(find.text('RCWL-0516 / 01'), findsOneWidget);
      expect(find.text('CLEAR'), findsOneWidget);

      expect(find.text('RCWL-0516 / 02'), findsOneWidget);
      expect(find.text('MOTION'), findsOneWidget);
    });

    testWidgets('displays camera disconnected placeholder without live feed', (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen(viewModel: viewModel));
      await tester.pumpAndSettle();

      expect(find.text('CAMERA PREVIEW'), findsOneWidget);
      expect(find.text('ESP32-CAM preview'), findsOneWidget);
      expect(find.text('NO VIDEO FEED / NOT CONNECTED'), findsOneWidget);
      expect(find.text('Placeholder · Streaming unverified'), findsOneWidget);
      expect(find.byIcon(Icons.videocam_outlined), findsOneWidget);
    });

    testWidgets('visibly presents SIMULATED and NOT VERIFIED labels', (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestScreen(viewModel: viewModel));
      await tester.pumpAndSettle();

      // SIMULATED tags (2 distance + 2 motion = 4)
      expect(find.text('SIMULATED'), findsNWidgets(4));

      // NOT VERIFIED tags appear across session banner, 4 HW cards, camera, 2 distance, 2 motion
      expect(find.text('NOT VERIFIED'), findsWidgets);
    });
  });

  group('DashboardScreen State Transition Tests', () {
    testWidgets('displays loading view while telemetry request is in-flight', (tester) async {
      final completer = Completer<DashboardTelemetryBundle>();
      final mockRepo = TestMockRepository(() => completer.future);
      final vm = DashboardViewModel(repository: mockRepo);
      addTearDown(vm.dispose);

      await tester.pumpWidget(buildTestScreen(viewModel: vm));
      await tester.pump(); // Trigger frame without completing future

      expect(find.text('LOADING ROVER TELEMETRY...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Now complete
      completer.complete(await const DemoDashboardDataSource().fetchTelemetry());
      await tester.pumpAndSettle();

      expect(find.byType(DashboardHeader), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays error card with retry button on failure', (tester) async {
      var fail = true;
      final mockRepo = TestMockRepository(() async {
        if (fail) throw StateError('Hardware communication bus timeout');
        return const DemoDashboardDataSource().fetchTelemetry();
      });
      final vm = DashboardViewModel(repository: mockRepo);
      addTearDown(vm.dispose);

      await tester.pumpWidget(buildTestScreen(viewModel: vm));
      await tester.pumpAndSettle();

      expect(find.text('TELEMETRY INTEGRITY ERROR'), findsOneWidget);
      expect(find.text('Hardware communication bus timeout'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'RETRY'), findsOneWidget);

      // Tap retry with failure turned off
      fail = false;
      await tester.tap(find.widgetWithText(ElevatedButton, 'RETRY'));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardHeader), findsOneWidget);
      expect(find.text('TELEMETRY INTEGRITY ERROR'), findsNothing);
    });
  });
}

