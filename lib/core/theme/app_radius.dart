import 'package:flutter/material.dart';

/// Standard corner radii for ROVER COMMAND.
abstract final class AppRadius {
  static const double sm = 6.0;
  static const double md = 10.0;
  static const double card = 14.0;
  static const double lg = 18.0;
  static const double pill = 999.0;

  static const BorderRadius smBorder = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdBorder = BorderRadius.all(Radius.circular(md));
  static const BorderRadius cardBorder = BorderRadius.all(Radius.circular(card));
  static const BorderRadius lgBorder = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillBorder = BorderRadius.all(Radius.circular(pill));
}

