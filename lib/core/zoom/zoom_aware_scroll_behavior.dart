import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Global application scroll behavior that prevents child scrollable widgets
/// (ListView, SingleChildScrollView, GridView) from scrolling when the user
/// is performing a zoom action with the Control or Meta key held.
class ZoomAwareScrollBehavior extends MaterialScrollBehavior {
  const ZoomAwareScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ZoomAwareScrollPhysics();
  }
}

/// Scroll physics that rejects user pointer scroll events whenever CTRL or META is pressed.
class ZoomAwareScrollPhysics extends ScrollPhysics {
  const ZoomAwareScrollPhysics({super.parent});

  @override
  ZoomAwareScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return ZoomAwareScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    if (HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed) {
      return false;
    }
    return super.shouldAcceptUserOffset(position);
  }
}

