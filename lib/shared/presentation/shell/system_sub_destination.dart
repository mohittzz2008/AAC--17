import 'package:flutter/material.dart';

/// Secondary management destinations hosted under the System feature.
enum SystemSubDestination {
  deviceConnection('Device Connection', Icons.link_rounded),
  diagnostics('Diagnostics & Health', Icons.monitor_heart_outlined),
  activityLogs('Activity & Event Logs', Icons.receipt_long_outlined),
  configuration('Configuration & Calibration', Icons.tune_rounded),
  firmware('Firmware & Maintenance', Icons.system_update_alt_rounded);

  final String label;
  final IconData icon;

  const SystemSubDestination(this.label, this.icon);
}

