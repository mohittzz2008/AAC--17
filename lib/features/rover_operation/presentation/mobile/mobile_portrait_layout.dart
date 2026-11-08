import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/control_colors.dart';
import '../state/rover_operation_state.dart';
import '../viewmodels/rover_operation_viewmodel.dart';
import '../widgets/camera_hud_viewport.dart';
import '../widgets/directional_control_pad.dart';
import '../widgets/emergency_stop_button.dart';

/// Mobile Portrait Layout (Design Reference 2).
/// Optimized for one-handed and two-handed touch operation, prominent camera viewport,
/// large diamond touch pad, full-width emergency stop, and compact telemetry tiles.
class MobilePortraitLayout extends StatelessWidget {
  final RoverOperationLoaded state;
  final RoverOperationViewModel viewModel;

  const MobilePortraitLayout({
    super.key,
    required this.state,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top Mobile Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: ControlColors.controlCream,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.agriculture_rounded,
                  color: ControlColors.controlBurgundy,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rover Control',
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.interfaceBase.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Remote Operation',
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3D3A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: ControlColors.statusGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Connected',
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Camera Viewport
          CameraHudViewport(
            state: state,
            viewModel: viewModel,
            height: 220,
          ),
          const SizedBox(height: 12),

          // Rover Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3D3A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.agriculture_rounded, color: AppColors.white, size: 15),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Rover Status',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: state.isEmergencyStopped
                        ? ControlColors.emergencyRed
                        : const Color(0xFF1E7E34),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    state.isEmergencyStopped ? 'E-STOP' : 'Operational',
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.signal_cellular_alt, color: ControlColors.statusGreen, size: 13),
                const SizedBox(width: 2),
                Text(
                  '${state.telemetry.latencyMs}ms',
                  style: AppTypography.telemetryBase.copyWith(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(Icons.battery_charging_full, color: ControlColors.statusGreen, size: 13),
                const SizedBox(width: 2),
                Text(
                  '${state.telemetry.batteryPercentage}%',
                  style: AppTypography.telemetryBase.copyWith(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Large Touch-friendly Directional Control Pad
          DirectionalControlPad(
            size: 210,
            activeDirection: state.activeDirection,
            isEmergencyStopped: state.isEmergencyStopped,
            useCreamButtons: false,
            onDirectionDown: viewModel.startMovement,
            onDirectionUp: viewModel.stopMovement,
          ),
          const SizedBox(height: 16),

          // Full-Width Emergency Stop Button
          EmergencyStopButton(
            isEmergencyStopped: state.isEmergencyStopped,
            onTrigger: viewModel.triggerEmergencyStop,
            onReset: viewModel.resetEmergencyStop,
            isFullWidth: true,
            height: 52,
          ),
          const SizedBox(height: 16),

          // Bottom 3 Sensor Cards
          Row(
            children: [
              Expanded(
                child: _buildSensorTile(
                  icon: Icons.thermostat,
                  label: 'Temp',
                  value: '${state.telemetry.temperatureCelsius} °C',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSensorTile(
                  icon: Icons.radar,
                  label: 'Distance',
                  value: '${state.telemetry.ultrasonicDistanceMeters} m',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSensorTile(
                  icon: Icons.battery_std,
                  label: 'Battery',
                  value: '${state.telemetry.batteryPercentage}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSensorTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3D3A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.white, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 10),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: ControlColors.statusGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.telemetryBase.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
