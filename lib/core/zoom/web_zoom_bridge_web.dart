import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'application_zoom_controller.dart';

@JS('_flutterOnWheelZoom')
external set _flutterOnWheelZoom(JSFunction? fn);

@JS('_flutterOnKeyboardZoom')
external set _flutterOnKeyboardZoom(JSFunction? fn);

/// Web-specific DOM event bridge connecting browser-level Ctrl+wheel, touchpad pinch,
/// and keyboard zoom events directly to the ApplicationZoomController.
void registerWebZoomBridge(ApplicationZoomController controller) {
  _flutterOnWheelZoom = ((JSNumber x, JSNumber y, JSNumber deltaY) {
    controller.zoomByWheel(
      Offset(x.toDartDouble, y.toDartDouble),
      deltaY.toDartDouble,
    );
  }).toJS;

  _flutterOnKeyboardZoom = ((JSString key) {
    final k = key.toDart;
    if (k == '=' || k == '+') {
      controller.zoomIn();
    } else if (k == '-' || k == '_') {
      controller.zoomOut();
    } else if (k == '0') {
      controller.resetZoom();
    }
  }).toJS;
}

