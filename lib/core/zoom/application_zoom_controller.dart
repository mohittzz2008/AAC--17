import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Single Source of Truth for application-wide zoom state across keyboard,
/// mouse-wheel, and touchpad gesture interactions.
class ApplicationZoomController extends ChangeNotifier {
  static final ApplicationZoomController instance = ApplicationZoomController();

  static const double minScale = 0.70;
  static const double maxScale = 2.00;
  static const double defaultScale = 1.00;
  static const double scaleStep = 0.10;

  double _scale = defaultScale;
  Offset _translation = Offset.zero;

  double _targetScale = defaultScale;
  Offset _targetTranslation = Offset.zero;

  Ticker? _ticker;
  double _lastTickTime = 0.0;

  double get scale => _scale;
  int get scalePercentage => (_scale * 100).round();
  Offset get translation => _translation;
  Matrix4 get transformMatrix {
    final matrix = Matrix4.identity();
    matrix.translateByDouble(_translation.dx, _translation.dy, 0.0, 1.0);
    matrix.scaleByDouble(_scale, _scale, 1.0, 1.0);
    return matrix;
  }

  bool get isDefault => (_scale - defaultScale).abs() < 0.001 && _translation.distance < 0.5;

  void initialize(TickerProvider vsync) {
    _ticker?.dispose();
    _ticker = vsync.createTicker(_onTick);
  }

  void _onTick(Duration elapsed) {
    final currentTime = elapsed.inMicroseconds / 1000000.0;
    if (_lastTickTime == 0.0) {
      _lastTickTime = currentTime;
      return;
    }
    final dt = (currentTime - _lastTickTime).clamp(0.001, 0.05);
    _lastTickTime = currentTime;

    // Critically damped frame interpolation (half-life ~ 50ms)
    final lerpFactor = 1.0 - math.exp(-25.0 * dt);

    final scaleDiff = _targetScale - _scale;
    final transDiff = _targetTranslation - _translation;

    if (scaleDiff.abs() < 0.0005 && transDiff.distance < 0.2) {
      _scale = _targetScale;
      _translation = _targetTranslation;
      _ticker?.stop();
      _lastTickTime = 0.0;
      notifyListeners();
      return;
    }

    _scale += scaleDiff * lerpFactor;
    _translation += transDiff * lerpFactor;
    notifyListeners();
  }

  void _ensureTickerRunning() {
    if (_ticker != null && !_ticker!.isActive) {
      _lastTickTime = 0.0;
      _ticker!.start();
    }
  }

  /// Zooms in by a discrete step (used by keyboard CTRL + PLUS and UI button).
  void zoomIn({Offset? focalPoint}) {
    final raw = (_targetScale + scaleStep).clamp(minScale, maxScale);
    final newScale = double.parse(raw.toStringAsFixed(2));
    _setTargetScale(newScale, focalPoint);
  }

  /// Zooms out by a discrete step (used by keyboard CTRL + MINUS and UI button).
  void zoomOut({Offset? focalPoint}) {
    final raw = (_targetScale - scaleStep).clamp(minScale, maxScale);
    final newScale = double.parse(raw.toStringAsFixed(2));
    _setTargetScale(newScale, focalPoint);
  }

  /// Resets zoom to 100% and centers translation (used by keyboard CTRL + 0 and UI reset).
  void resetZoom() {
    _targetScale = defaultScale;
    _targetTranslation = Offset.zero;
    if (_ticker == null) {
      _scale = defaultScale;
      _translation = Offset.zero;
      notifyListeners();
    } else {
      _ensureTickerRunning();
    }
  }

  /// Continuous zoom driven by mouse wheel or touchpad pinch.
  /// [focalPoint] is the pointer position in viewport coordinates.
  /// [deltaY] is the vertical scroll delta.
  void zoomByWheel(Offset focalPoint, double deltaY) {
    if (deltaY == 0.0) return;

    // Exponential scaling prevents runaway speed at high scales
    final factor = math.exp(-deltaY * 0.002);
    final newScale = (_targetScale * factor).clamp(minScale, maxScale);
    _setTargetScale(newScale, focalPoint);
  }

  /// Pinch gesture scale update from touch or trackpad.
  void zoomByGesture(Offset focalPoint, double scaleFactor) {
    if (scaleFactor == 1.0) return;
    final newScale = (_targetScale * scaleFactor).clamp(minScale, maxScale);
    _setTargetScale(newScale, focalPoint);
  }

  void _setTargetScale(double newScale, Offset? focalPoint) {
    if ((newScale - _targetScale).abs() < 0.0001) return;

    final anchor = focalPoint ?? Offset.zero;
    if (anchor != Offset.zero && _scale > 0.001) {
      // Preserve the visual anchor under the focal point:
      // contentPoint = (focalPoint - currentTranslation) / currentScale
      // newTranslation = focalPoint - contentPoint * newScale
      final currentContentX = (anchor.dx - _targetTranslation.dx) / _targetScale;
      final currentContentY = (anchor.dy - _targetTranslation.dy) / _targetScale;

      _targetTranslation = Offset(
        anchor.dx - currentContentX * newScale,
        anchor.dy - currentContentY * newScale,
      );
    } else {
      // Centered or default anchoring
      _targetTranslation = Offset.zero;
    }

    _targetScale = newScale;

    if (_ticker == null) {
      // If running without ticker (e.g. unit tests), apply synchronously
      _scale = _targetScale;
      _translation = _targetTranslation;
      notifyListeners();
    } else {
      _ensureTickerRunning();
    }
  }

  /// Sets scale immediately (for tests or manual overrides).
  void setScaleImmediate(double newScale, [Offset translation = Offset.zero]) {
    _scale = newScale.clamp(minScale, maxScale);
    _targetScale = _scale;
    _translation = translation;
    _targetTranslation = translation;
    _ticker?.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _ticker = null;
    super.dispose();
  }
}
