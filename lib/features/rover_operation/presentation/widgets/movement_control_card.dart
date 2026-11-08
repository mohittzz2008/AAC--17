import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/control_colors.dart';
import '../state/rover_operation_state.dart';
import '../viewmodels/rover_operation_viewmodel.dart';
import 'directional_control_pad.dart';
import 'emergency_stop_button.dart';

/// Desktop card grouping directional controls, keyboard hint, and emergency stop button.
class MovementControlCard extends StatelessWidget {
  final RoverOperationLoaded state;
  final RoverOperationViewModel viewModel;

  const MovementControlCard({
    super.key,
    required this.state,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ControlColors.controlCream,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDFBA99), width: 1.5),
        boxShadow: [
          const BoxShadow(
            color: Color(0x26000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with keyboard instructions subtitle
          Row(
            children: [
              const Icon(Icons.open_with_rounded, color: ControlColors.controlBurgundy, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Movement Control',
                      style: AppTypography.interfaceBase.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.background,
                      ),
                    ),
                    Text(
                      'Use on-screen controls or W A S D keys',
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF5A4435),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Directional Pad and Emergency Stop Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Directional Pad
              DirectionalControlPad(
                size: 150,
                activeDirection: state.activeDirection,
                isEmergencyStopped: state.isEmergencyStopped,
                useCreamButtons: false,
                onDirectionDown: viewModel.startMovement,
                onDirectionUp: viewModel.stopMovement,
              ),

              const SizedBox(width: 12),

              // Vertical divider
              Container(
                height: 120,
                width: 1.2,
                color: const Color(0xFFDFBA99),
              ),

              const SizedBox(width: 12),

              // Emergency Stop
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
        ],
      ),
    );
  }
}
