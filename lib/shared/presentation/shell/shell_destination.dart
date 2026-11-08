import 'package:flutter/material.dart';

/// The five primary destinations supported by the ROVER COMMAND application shell.
enum ShellDestination {
  dashboard('Dashboard', Icons.home_outlined),
  camera('Camera', Icons.videocam_outlined),
  sensors('Sensors', Icons.show_chart),
  roverOperation('Operation', Icons.sports_esports_outlined),
  system('System', Icons.settings_outlined);

  final String label;
  final IconData icon;

  const ShellDestination(this.label, this.icon);
}

