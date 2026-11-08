import 'package:flutter/material.dart';
import '../state/rover_operation_state.dart';
import '../viewmodels/rover_operation_viewmodel.dart';
import '../desktop/desktop_normal_layout.dart';
import '../widgets/camera_hud_viewport.dart';
import '../widgets/directional_control_pad.dart';
import '../widgets/emergency_stop_button.dart';
import '../widgets/live_sensors_card.dart';
import '../widgets/rover_status_card.dart';

/// Adaptive tablet layout handling both tablet portrait and tablet landscape orientations.
class TabletOperationLayout extends StatelessWidget {
  final RoverOperationLoaded state;
  final RoverOperationViewModel viewModel;
  final bool isLandscape;

  const TabletOperationLayout({
    super.key,
    required this.state,
    required this.viewModel,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    if (isLandscape) {
      // In tablet landscape, reuse the balanced side-by-side structure
      return DesktopNormalLayout(state: state, viewModel: viewModel);
    }

    // Tablet Portrait Layout
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Camera Viewport
          CameraHudViewport(
            state: state,
            viewModel: viewModel,
            height: 320,
          ),
          const SizedBox(height: 16),

          // Side-by-side Directional Pad and Emergency Stop
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DirectionalControlPad(
                size: 190,
                activeDirection: state.activeDirection,
                isEmergencyStopped: state.isEmergencyStopped,
                useCreamButtons: false,
                onDirectionDown: viewModel.startMovement,
                onDirectionUp: viewModel.stopMovement,
              ),
              const SizedBox(width: 24),
              Flexible(
                child: EmergencyStopButton(
                  isEmergencyStopped: state.isEmergencyStopped,
                  onTrigger: viewModel.triggerEmergencyStop,
                  onReset: viewModel.resetEmergencyStop,
                  height: 64,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Rover Status Card
          RoverStatusCard(state: state, isBurgundyTheme: true),
          const SizedBox(height: 14),

          // Live Sensors Card
          LiveSensorsCard(state: state, isCreamTheme: true),
        ],
      ),
    );
  }
}

