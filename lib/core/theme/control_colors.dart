import 'package:flutter/material.dart';

/// ROVER COMMAND - Rover Operation Control Color Palette.
/// Strictly defined in Section 13 of the project specification.
/// These colors are dedicated to the remote rover operation controls,
/// command panels, and emergency stop systems.
abstract final class ControlColors {
  /// Control Burgundy: #6C151E — Main control-section identity, Rover Status card background.
  static const Color controlBurgundy = Color(0xFF6C151E);

  /// Control Green / Dark Teal: #0F3D3A — Supporting surfaces, directional buttons, panel borders.
  static const Color controlGreen = Color(0xFF0F3D3A);

  /// Control Cream: #F5DABF — Contrast surfaces, movement control card, control highlights.
  static const Color controlCream = Color(0xFFF5DABF);

  /// Emergency Stop Red: #D32F2F — High-priority emergency stop surface.
  static const Color emergencyRed = Color(0xFFD32F2F);

  /// Emergency Stop Glow: Translucent red glow for emergency stop elevation.
  static const Color emergencyGlow = Color(0x66D32F2F);

  /// Dark surface overlay for control cards: #131317.
  static const Color controlDarkSurface = Color(0xFF131317);

  /// Muted green text/icon tone: #27AE60 / #4ECCA3.
  static const Color statusGreen = Color(0xFF27AE60);

  /// Active button press highlight for cream buttons.
  static const Color creamActive = Color(0xFFDFC0A0);

  /// Active button press highlight for green buttons.
  static const Color greenActive = Color(0xFF175752);
}

