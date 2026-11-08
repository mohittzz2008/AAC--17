import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/control_colors.dart';
import '../state/rover_operation_state.dart';
import '../viewmodels/rover_operation_viewmodel.dart';
import '../widgets/camera_hud_viewport.dart';
import '../widgets/directional_control_pad.dart';
import '../widgets/emergency_stop_button.dart';

/// Mobile Landscape Expanded Layout (Design Reference 1).
/// Features a side-by-side arrangement where the camera occupies >50% of screen width,
/// with touch directional controls, Emergency Stop, and interactive status tabs on the right.
class MobileLandscapeExpandedLayout extends StatelessWidget {
  final RoverOperationLoaded state;
  final RoverOperationViewModel viewModel;

  const MobileLandscapeExpandedLayout({
    super.key,
    required this.state,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ControlColors.controlBurgundy,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // LEFT: Dominant Camera Viewport (> 50% width)
          Expanded(
            flex: 12,
            child: CameraHudViewport(
              state: state,
              viewModel: viewModel,
              height: double.infinity,
              isExpandedView: true,
            ),
          ),
          const SizedBox(width: 12),

          // RIGHT: Controls, Emergency Stop, and Status Tabs
          Expanded(
            flex: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Right Header
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: ControlColors.controlCream,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.agriculture_rounded, color: ControlColors.controlBurgundy, size: 16),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rover Control',
                          style: AppTypography.interfaceBase.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          'Remote Operation',
                          style: AppTypography.caption.copyWith(color: AppColors.secondaryText, fontSize: 9),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3D3A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(width: 5, height: 5, decoration: const BoxDecoration(color: ControlColors.statusGreen, shape: BoxShape.circle)),
                          const SizedBox(width: 4),
                          Text('Online', style: AppTypography.caption.copyWith(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Exit Expanded View',
                      onPressed: viewModel.toggleCameraExpanded,
                      icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Interactive Status Indicator Tabs
                Row(
                  children: [
                    _buildTabButton(
                      tab: OperationStatusTab.liveSensors,
                      icon: Icons.show_chart,
                      label: 'Live Sensors',
                    ),
                    const SizedBox(width: 6),
                    _buildTabButton(
                      tab: OperationStatusTab.hardwareHealth,
                      icon: Icons.memory,
                      label: 'Hardware Health',
                    ),
                    const SizedBox(width: 6),
                    _buildTabButton(
                      tab: OperationStatusTab.overallStatus,
                      icon: Icons.layers_outlined,
                      label: 'Overall Status',
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Center area: Directional Pad + Emergency Stop
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Directional Pad
                      DirectionalControlPad(
                        size: 130,
                        activeDirection: state.activeDirection,
                        isEmergencyStopped: state.isEmergencyStopped,
                        useCreamButtons: false,
                        onDirectionDown: viewModel.startMovement,
                        onDirectionUp: viewModel.stopMovement,
                      ),
                      const SizedBox(width: 8),

                      // Emergency Stop
                      Flexible(
                        child: EmergencyStopButton(
                          isEmergencyStopped: state.isEmergencyStopped,
                          onTrigger: viewModel.triggerEmergencyStop,
                          onReset: viewModel.resetEmergencyStop,
                          height: 60,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Bottom 3-item sensor metrics bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F3D3A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(child: _buildMiniMetric('Temp', '${state.telemetry.temperatureCelsius} °C')),
                      Flexible(child: _buildMiniMetric('Battery', '${state.telemetry.batteryPercentage}%')),
                      Flexible(child: _buildMiniMetric('Signal', 'Strong')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required OperationStatusTab tab,
    required IconData icon,
    required String label,
  }) {
    final isSelected = state.activeStatusTab == tab;

    return Expanded(
      child: InkWell(
        onTap: () => viewModel.selectStatusTab(tab),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? ControlColors.controlCream : const Color(0xFF0F3D3A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.white12,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? ControlColors.controlBurgundy : AppColors.white,
                size: 13,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                  color: isSelected ? ControlColors.controlBurgundy : AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value) {
    return Text.rich(
      TextSpan(
        text: '$label: ',
        style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 10),
        children: [
          TextSpan(
            text: value,
            style: AppTypography.telemetryBase.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
