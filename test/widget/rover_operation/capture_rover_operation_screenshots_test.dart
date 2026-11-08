import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rover_command/core/theme/app_theme.dart';
import 'package:rover_command/features/rover_operation/data/datasources/demo_rover_operation_data_source.dart';
import 'package:rover_command/features/rover_operation/data/repositories/rover_operation_repository_impl.dart';
import 'package:rover_command/features/rover_operation/presentation/screens/rover_operation_screen.dart';
import 'package:rover_command/features/rover_operation/presentation/viewmodels/rover_operation_viewmodel.dart';
import 'package:rover_command/shared/presentation/shell/rover_shell.dart';
import 'package:rover_command/shared/presentation/shell/shell_destination.dart';

void main() {
  final boundaryKey = GlobalKey();

  Future<void> saveScreenshot(WidgetTester tester, String filename) async {
    await tester.runAsync(() async {
      final boundary = boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final file = File('screenshots/$filename');
      await file.writeAsBytes(bytes);
    });
  }

  Widget wrapWithRepaint(Widget child) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: RepaintBoundary(
        key: boundaryKey,
        child: child,
      ),
    );
  }

  testWidgets('Capture Desktop Normal 1440x900', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      wrapWithRepaint(
        const RoverShell(initialDestination: ShellDestination.roverOperation),
      ),
    );
    await tester.pumpAndSettle();

    await saveScreenshot(tester, 'rover_operation_desktop_normal_1440.png');
  });

  testWidgets('Capture Desktop Expanded 1440x900', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final ds = DemoRoverOperationDataSource();
    final repo = RoverOperationRepositoryImpl(ds);
    final vm = RoverOperationViewModel(repo);
    await vm.initialize();
    vm.toggleCameraExpanded();

    await tester.pumpWidget(
      wrapWithRepaint(
        Scaffold(body: RoverOperationScreen(viewModel: vm)),
      ),
    );
    await tester.pumpAndSettle();

    await saveScreenshot(tester, 'rover_operation_desktop_expanded_1440.png');
    vm.dispose();
  });

  testWidgets('Capture Mobile Portrait 390x844', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      wrapWithRepaint(
        const RoverShell(initialDestination: ShellDestination.roverOperation),
      ),
    );
    await tester.pumpAndSettle();

    await saveScreenshot(tester, 'rover_operation_mobile_portrait_390.png');
  });

  testWidgets('Capture Mobile Landscape Expanded 844x390', (tester) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final ds = DemoRoverOperationDataSource();
    final repo = RoverOperationRepositoryImpl(ds);
    final vm = RoverOperationViewModel(repo);
    await vm.initialize();
    vm.toggleCameraExpanded();

    await tester.pumpWidget(
      wrapWithRepaint(
        Scaffold(body: RoverOperationScreen(viewModel: vm)),
      ),
    );
    await tester.pumpAndSettle();

    await saveScreenshot(tester, 'rover_operation_mobile_landscape_844.png');
    vm.dispose();
  });

  testWidgets('Capture Tablet Portrait 768x1024', (tester) async {
    tester.view.physicalSize = const Size(768, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      wrapWithRepaint(
        const RoverShell(initialDestination: ShellDestination.roverOperation),
      ),
    );
    await tester.pumpAndSettle();

    await saveScreenshot(tester, 'rover_operation_tablet_portrait_768.png');
  });

  testWidgets('Capture Tablet Landscape 1024x768', (tester) async {
    tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      wrapWithRepaint(
        const RoverShell(initialDestination: ShellDestination.roverOperation),
      ),
    );
    await tester.pumpAndSettle();

    await saveScreenshot(tester, 'rover_operation_tablet_landscape_1024.png');
  });
}

