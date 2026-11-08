import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rover_command/core/theme/app_theme.dart';
import 'package:rover_command/core/zoom/application_zoom_controller.dart';
import 'package:rover_command/core/zoom/application_zoom_wrapper.dart';
import 'package:rover_command/core/zoom/zoom_aware_scroll_behavior.dart';

void main() {
  late ApplicationZoomController controller;

  setUp(() {
    controller = ApplicationZoomController();
  });

  tearDown(() {
    controller.dispose();
  });

  Widget buildTestApp({Widget? child}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      scrollBehavior: const ZoomAwareScrollBehavior(),
      home: Scaffold(
        body: ApplicationZoomWrapper(
          controller: controller,
          child: child ??
              ListView.builder(
                itemCount: 50,
                itemBuilder: (context, i) => SizedBox(
                  height: 40,
                  child: Text('Workspace Row $i'),
                ),
              ),
        ),
      ),
    );
  }

  group('ApplicationZoomWrapper Widget & Gesture Tests', () {
    testWidgets('renders child content and zoom HUD controls cleanly', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Workspace Row 0'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('Ctrl + Mouse Wheel scales the workspace around the cursor position', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final targetCenter = tester.getCenter(find.text('Workspace Row 0'));

      // Press Ctrl key
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);

      // Wheel upward (zoom in)
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: targetCenter,
          scrollDelta: const Offset(0, -60),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.scale, greaterThan(1.0));
      expect(controller.scalePercentage, greaterThan(100));

      // Wheel downward (zoom out)
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: targetCenter,
          scrollDelta: const Offset(0, 100),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.scalePercentage, lessThan(115));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    });

    testWidgets('Mouse Wheel without Ctrl scrolls content without triggering zoom', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      final targetCenter = tester.getCenter(find.text('Workspace Row 0'));

      // Wheel downward without Ctrl
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: targetCenter,
          scrollDelta: const Offset(0, 50),
        ),
      );
      await tester.pumpAndSettle();

      // Zoom remains unchanged at 100%
      expect(controller.scale, 1.0);
      expect(controller.scalePercentage, 100);
    });

    testWidgets('HUD buttons interactively zoom in, zoom out, and reset', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('100%'), findsOneWidget);

      // Tap '+' button in HUD
      final zoomInBtn = find.byTooltip('Zoom In (Ctrl + +)');
      expect(zoomInBtn, findsOneWidget);
      await tester.tap(zoomInBtn);
      await tester.pumpAndSettle();

      expect(controller.scalePercentage, 110);
      expect(find.text('110%'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      // Tap 'Reset' button
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(controller.scalePercentage, 100);
      expect(find.text('100%'), findsOneWidget);
    });
  });
}

