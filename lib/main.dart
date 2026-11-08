import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/zoom/zoom_aware_scroll_behavior.dart';
import 'shared/presentation/shell/rover_shell.dart';

void main() {
  runApp(const RoverCommandApp());
}

class RoverCommandApp extends StatelessWidget {
  const RoverCommandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROVER COMMAND',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      scrollBehavior: const ZoomAwareScrollBehavior(),
      home: const RoverShell(),
    );
  }
}
