import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/dependency_container.dart';
import '../../../core/responsive/screen_breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/zoom/application_zoom_wrapper.dart';
import '../../../features/activity_logs/presentation/screens/activity_logs_screen.dart';
import '../../../features/camera/presentation/screens/camera_screen.dart';
import '../../../features/configuration/presentation/screens/configuration_screen.dart';
import '../../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../../features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart';
import '../../../features/device_connection/presentation/screens/device_connection_screen.dart';
import '../../../features/diagnostics/presentation/screens/diagnostics_screen.dart';
import '../../../features/firmware/presentation/screens/firmware_screen.dart';
import '../../../features/rover_operation/presentation/screens/rover_operation_screen.dart';
import '../../../features/sensors/presentation/screens/sensors_screen.dart';
import '../../../features/system/presentation/screens/system_screen.dart';
import '../widgets/rover_bottom_navigation_bar.dart';
import '../widgets/rover_navigation_rail.dart';
import 'shell_destination.dart';
import 'system_sub_destination.dart';

/// The root application shell managing global navigation, secondary management sub-routes,
/// and responsive layout adaptation.
class RoverShell extends StatefulWidget {
  final ShellDestination initialDestination;
  final SystemSubDestination? initialSubDestination;
  final DashboardViewModel? dashboardViewModel;

  const RoverShell({
    super.key,
    this.initialDestination = ShellDestination.dashboard,
    this.initialSubDestination,
    this.dashboardViewModel,
  });

  @override
  State<RoverShell> createState() => _RoverShellState();
}

class _RoverShellState extends State<RoverShell> {
  late ShellDestination _currentDestination;
  SystemSubDestination? _activeSubDestination;
  late final DependencyContainer _container;
  late final DashboardViewModel _dashboardViewModel;

  @override
  void initState() {
    super.initState();
    _currentDestination = widget.initialDestination;
    _activeSubDestination = widget.initialSubDestination;
    _container = DependencyContainer();
    _dashboardViewModel = widget.dashboardViewModel ?? _container.dashboardViewModel;

    try {
      final uri = Uri.base;
      final tabParam = uri.queryParameters['tab']?.toLowerCase();
      final subParam = uri.queryParameters['sub']?.toLowerCase();

      if (tabParam != null) {
        switch (tabParam) {
          case 'camera':
            _currentDestination = ShellDestination.camera;
            break;
          case 'sensors':
            _currentDestination = ShellDestination.sensors;
            break;
          case 'operation':
          case 'control':
            _currentDestination = ShellDestination.roverOperation;
            break;
          case 'system':
            _currentDestination = ShellDestination.system;
            break;
          case 'dashboard':
            _currentDestination = ShellDestination.dashboard;
            break;
        }
      }

      if (subParam != null) {
        _currentDestination = ShellDestination.system;
        switch (subParam) {
          case 'connection':
            _activeSubDestination = SystemSubDestination.deviceConnection;
            break;
          case 'diagnostics':
            _activeSubDestination = SystemSubDestination.diagnostics;
            break;
          case 'logs':
            _activeSubDestination = SystemSubDestination.activityLogs;
            break;
          case 'config':
            _activeSubDestination = SystemSubDestination.configuration;
            break;
          case 'firmware':
            _activeSubDestination = SystemSubDestination.firmware;
            break;
        }
      }
    } catch (_) {}
  }

  void _onDestinationSelected(ShellDestination destination) {
    if (_currentDestination != destination) {
      setState(() {
        _currentDestination = destination;
      });
    }
  }

  void _openSubDestination(SystemSubDestination sub) {
    setState(() {
      _currentDestination = ShellDestination.system;
      _activeSubDestination = sub;
    });
  }

  void _closeSubDestination() {
    setState(() {
      _activeSubDestination = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= ScreenBreakpoints.tabletMax;

        Widget scaffold;
        if (isDesktop) {
          scaffold = Scaffold(
            backgroundColor: AppColors.background,
            body: Row(
              children: [
                RoverNavigationRail(
                  currentDestination: _currentDestination,
                  onDestinationSelected: _onDestinationSelected,
                ),
                Expanded(
                  child: ApplicationZoomWrapper(
                    child: _buildDestinationBody(isFloatingNav: false),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Mobile & Tablet: Floating bottom navigation bar capsule
          scaffold = Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ApplicationZoomWrapper(
                      child: _buildDestinationBody(isFloatingNav: true),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 16,
                    child: RoverBottomNavigationBar(
                      currentDestination: _currentDestination,
                      onDestinationSelected: _onDestinationSelected,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Shortcuts(
          shortcuts: _currentDestination == ShellDestination.roverOperation
              ? const <ShortcutActivator, Intent>{}
              : const <ShortcutActivator, Intent>{
                  SingleActivator(LogicalKeyboardKey.arrowUp):
                      DirectionalFocusIntent(TraversalDirection.up),
                  SingleActivator(LogicalKeyboardKey.arrowDown):
                      DirectionalFocusIntent(TraversalDirection.down),
                  SingleActivator(LogicalKeyboardKey.arrowLeft):
                      DirectionalFocusIntent(TraversalDirection.left),
                  SingleActivator(LogicalKeyboardKey.arrowRight):
                      DirectionalFocusIntent(TraversalDirection.right),
                },
          child: FocusTraversalGroup(
            policy: ReadingOrderTraversalPolicy(),
            child: scaffold,
          ),
        );
      },
    );
  }

  Widget _buildDestinationBody({required bool isFloatingNav}) {
    final bottomInset = isFloatingNav ? 90.0 : 0.0;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: IndexedStack(
        index: _currentDestination.index,
        children: [
          // 01. Dashboard
          DashboardScreen(viewModel: _dashboardViewModel),

          // 02. Camera
          CameraScreen(
            viewModel: _container.cameraViewModel,
            onOpenDiagnostics: () => _openSubDestination(SystemSubDestination.diagnostics),
          ),

          // 03. Sensors
          SensorsScreen(viewModel: _container.sensorsViewModel),

          // 04. Rover Operation
          RoverOperationScreen(viewModel: _container.roverOperationViewModel),

          // 05-09. System & Secondary Navigation Modules
          _buildSystemFeatureHost(),
        ],
      ),
    );
  }

  Widget _buildSystemFeatureHost() {
    switch (_activeSubDestination) {
      case null:
        return SystemScreen(
          viewModel: _container.systemViewModel,
          onSelectSubDestination: _openSubDestination,
        );
      case SystemSubDestination.deviceConnection:
        return DeviceConnectionScreen(
          viewModel: _container.deviceConnectionViewModel,
          onBack: _closeSubDestination,
        );
      case SystemSubDestination.diagnostics:
        return DiagnosticsScreen(
          viewModel: _container.diagnosticsViewModel,
          onBack: _closeSubDestination,
          onOpenLogs: () => _openSubDestination(SystemSubDestination.activityLogs),
        );
      case SystemSubDestination.activityLogs:
        return ActivityLogsScreen(
          viewModel: _container.activityLogsViewModel,
          onBack: _closeSubDestination,
        );
      case SystemSubDestination.configuration:
        return ConfigurationScreen(
          viewModel: _container.configurationViewModel,
          onBack: _closeSubDestination,
        );
      case SystemSubDestination.firmware:
        return FirmwareScreen(
          viewModel: _container.firmwareViewModel,
          onBack: _closeSubDestination,
        );
    }
  }
}
