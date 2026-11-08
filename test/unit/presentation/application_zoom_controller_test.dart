import 'package:flutter_test/flutter_test.dart';
import 'package:rover_command/core/zoom/application_zoom_controller.dart';

void main() {
  late ApplicationZoomController controller;

  setUp(() {
    controller = ApplicationZoomController();
  });

  tearDown(() {
    controller.dispose();
  });

  group('ApplicationZoomController Core Tests', () {
    test('initial state defaults to 1.0 (100%) and Offset.zero', () {
      expect(controller.scale, 1.0);
      expect(controller.scalePercentage, 100);
      expect(controller.translation, Offset.zero);
      expect(controller.isDefault, isTrue);
    });

    test('zoomIn increases scale by 10%', () {
      controller.zoomIn();
      expect(controller.scale, closeTo(1.10, 0.001));
      expect(controller.scalePercentage, 110);
      expect(controller.isDefault, isFalse);
    });

    test('zoomOut decreases scale by 10%', () {
      controller.zoomOut();
      expect(controller.scale, closeTo(0.90, 0.001));
      expect(controller.scalePercentage, 90);
    });

    test('clamping limits scale between 0.70 and 2.00', () {
      // Zoom out repeatedly past minimum
      for (int i = 0; i < 15; i++) {
        controller.zoomOut();
      }
      expect(controller.scale, 0.70);
      expect(controller.scalePercentage, 70);

      // Zoom in repeatedly past maximum
      for (int i = 0; i < 30; i++) {
        controller.zoomIn();
      }
      expect(controller.scale, 2.00);
      expect(controller.scalePercentage, 200);
    });

    test('resetZoom restores scale to 1.0 and translation to Offset.zero', () {
      controller.zoomIn();
      controller.zoomIn();
      expect(controller.scalePercentage, 120);

      controller.resetZoom();
      expect(controller.scale, 1.0);
      expect(controller.scalePercentage, 100);
      expect(controller.translation, Offset.zero);
      expect(controller.isDefault, isTrue);
    });

    test('zoomByWheel performs exponential scaling anchored to focal point', () {
      const focalPoint = Offset(300, 200);

      // Wheel upward (negative delta) zooms in
      controller.zoomByWheel(focalPoint, -50.0);
      expect(controller.scale, greaterThan(1.0));

      // Check focal point preservation formula:
      // contentPoint = (focalPoint - translation) / scale
      final contentPoint = (focalPoint - controller.translation) / controller.scale;
      expect(contentPoint.dx, closeTo(focalPoint.dx, 1.0));
      expect(contentPoint.dy, closeTo(focalPoint.dy, 1.0));

      // Wheel downward (positive delta) zooms out
      controller.zoomByWheel(focalPoint, 80.0);
      expect(controller.scale, lessThan(1.10));
    });

    test('zoomByGesture applies scale factor', () {
      const focalPoint = Offset(400, 300);
      controller.zoomByGesture(focalPoint, 1.25);
      expect(controller.scale, closeTo(1.25, 0.01));
    });
  });
}

