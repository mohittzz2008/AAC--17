import 'package:flutter/material.dart';

/// ROVER COMMAND core color tokens.
/// Strictly restricted to the 8 approved project palette colors.
abstract final class AppColors {
  /// Burgundy: #7A0D26 — Rover session status alert banner background.
  static const Color burgundy = Color(0xFF7A0D26);

  /// Gold: #D1A037 — DEMO MODE badge, active navigation item, primary accents.
  static const Color gold = Color(0xFFD1A037);

  /// White: #F6F6F6 — High-contrast primary text, major readouts, title text.
  static const Color white = Color(0xFFF6F6F6);

  /// Black: #000000 — Camera viewport interior, badge text contrast.
  static const Color black = Color(0xFF000000);

  /// Main background: #101014 — Global viewport background.
  static const Color background = Color(0xFF101014);

  /// Card surface: #19191F — Telemetry cards, camera preview card shell.
  static const Color surface = Color(0xFF19191F);

  /// Raised surface: #25252D — 1px card borders, navigation shell, dividers.
  static const Color raisedSurface = Color(0xFF25252D);

  /// Secondary text: #C8C6C7 — Metric labels, units, subheaders, captions.
  static const Color secondaryText = Color(0xFFC8C6C7);
}

