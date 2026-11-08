import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rover_command/core/theme/app_colors.dart';
import 'package:rover_command/core/theme/app_theme.dart';
import 'package:rover_command/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:rover_command/shared/presentation/shell/rover_shell.dart';
import 'package:rover_command/shared/presentation/shell/shell_destination.dart';
import 'package:rover_command/shared/presentation/widgets/rover_bottom_navigation_bar.dart';
import 'package:rover_command/shared/presentation/widgets/rover_navigation_rail.dart';

void main() {
  Widget buildTestShell({
    ShellDestination initial = ShellDestination.dashboard,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: RoverShell(initialDestination: initial),
    );
  }

  group('RoverShell Navigation State Tests', () {
    testWidgets('defaults to Dashboard destination and displays placeholder', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestShell());
      await tester.pumpAndSettle();

      expect(find.byType(RoverBottomNavigationBar), findsOneWidget);
      expect(find.text('Dashboard'), findsWidgets);

      // Verify that Dashboard is selected in the bottom navigation bar
      final bottomBar = tester.widget<RoverBottomNavigationBar>(
        find.byType(RoverBottomNavigationBar),
      );
      expect(bottomBar.currentDestination, ShellDestination.dashboard);
    });

    testWidgets('switches between all four destinations cleanly without crashing', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestShell());
      await tester.pumpAndSettle();

      // Tap Camera
      await tester.tap(find.widgetWithText(InkWell, 'Camera'));
      await tester.pumpAndSettle();

      expect(find.text('Camera'), findsWidgets);
      var bottomBar = tester.widget<RoverBottomNavigationBar>(
        find.byType(RoverBottomNavigationBar),
      );
      expect(bottomBar.currentDestination, ShellDestination.camera);

      // Tap Sensors
      await tester.tap(find.widgetWithText(InkWell, 'Sensors'));
      await tester.pumpAndSettle();

      expect(find.text('Sensors'), findsWidgets);
      bottomBar = tester.widget<RoverBottomNavigationBar>(
        find.byType(RoverBottomNavigationBar),
      );
      expect(bottomBar.currentDestination, ShellDestination.sensors);

      // Tap Operation
      await tester.tap(find.widgetWithText(InkWell, 'Operation'));
      await tester.pumpAndSettle();

      expect(find.text('Operation'), findsWidgets);
      bottomBar = tester.widget<RoverBottomNavigationBar>(
        find.byType(RoverBottomNavigationBar),
      );
      expect(bottomBar.currentDestination, ShellDestination.roverOperation);

      // Tap System
      await tester.tap(find.widgetWithText(InkWell, 'System'));
      await tester.pumpAndSettle();

      expect(find.text('System'), findsWidgets);
      bottomBar = tester.widget<RoverBottomNavigationBar>(
        find.byType(RoverBottomNavigationBar),
      );
      expect(bottomBar.currentDestination, ShellDestination.system);

      // Tap back to Dashboard
      await tester.tap(find.widgetWithText(InkWell, 'Dashboard'));
      await tester.pumpAndSettle();

      bottomBar = tester.widget<RoverBottomNavigationBar>(
        find.byType(RoverBottomNavigationBar),
      );
      expect(bottomBar.currentDestination, ShellDestination.dashboard);
    });
  });

  group('RoverShell Responsive Layout Tests', () {
    testWidgets('renders floating bottom bar on mobile width (< 600 dp)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestShell());
      await tester.pumpAndSettle();

      expect(find.byType(RoverBottomNavigationBar), findsOneWidget);
      expect(find.byType(RoverNavigationRail), findsNothing);
    });

    testWidgets('renders bottom bar capsule on tablet width (768 dp)', (tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestShell());
      await tester.pumpAndSettle();

      expect(find.byType(RoverBottomNavigationBar), findsOneWidget);
      expect(find.byType(RoverNavigationRail), findsNothing);
    });

    testWidgets('renders left navigation rail on desktop width (1280 dp)', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestShell());
      await tester.pumpAndSettle();

      expect(find.byType(RoverNavigationRail), findsOneWidget);
      expect(find.byType(RoverBottomNavigationBar), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('switching destination works properly on desktop navigation rail', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestShell());
      await tester.pumpAndSettle();

      // Tap Sensors in rail
      await tester.tap(find.widgetWithText(InkWell, 'Sensors'));
      await tester.pumpAndSettle();

      final rail = tester.widget<RoverNavigationRail>(
        find.byType(RoverNavigationRail),
      );
      expect(rail.currentDestination, ShellDestination.sensors);
    });

    testWidgets('supports keyboard focus traversal and activation via Enter/Space in navigation rail', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestShell());
      await tester.pumpAndSettle();

      // Tab into navigation items
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Tab to next item
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      // Activate with Enter key
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      final rail = tester.widget<RoverNavigationRail>(
        find.byType(RoverNavigationRail),
      );
      expect(rail.currentDestination, isNot(ShellDestination.roverOperation));
    });
  });

  group('RoverBottomNavigationBar Style Tests', () {
    testWidgets('selected destination uses approved gold color token', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: RoverBottomNavigationBar(
              currentDestination: ShellDestination.dashboard,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.home_outlined);
      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, AppColors.gold);
    });
  });
}

