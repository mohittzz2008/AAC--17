import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/control_colors.dart';
import '../state/rover_operation_state.dart';
import '../viewmodels/rover_operation_viewmodel.dart';
import '../widgets/camera_hud_viewport.dart';
import '../widgets/directional_control_pad.dart';
import '../widgets/emergency_stop_button.dart';

/// Desktop Expanded Layout (Design Reference 3).
/// Maximizes camera feed area (>50% screen) while maintaining immediate access
/// to horizontal directional controls, Emergency Stop, and live sensors bar.
class DesktopExpandedLayout extends StatelessWidget {
  final RoverOperationLoaded state;
  final RoverOperationViewModel viewModel;

  const DesktopExpandedLayout({
    super.key,
    required this.state,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top minimal expanded header
          Row(
            children: [
              const Icon(Icons.agriculture_rounded, color: ControlColors.controlCream, size: 22),
              const SizedBox(width: 8),
              Text(
                'RoverControl',
                style: AppTypography.interfaceBase.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: ControlColors.statusGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Connected · Rover Online',
                style: AppTypography.caption.copyWith(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              // Exit expanded button
              TextButton.icon(
                onPressed: viewModel.toggleCameraExpanded,
                icon: const Icon(Icons.fullscreen_exit, color: AppColors.white, size: 18),
                label: Text(
                  'Normal View',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0x33FFFFFF),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dominant Camera Viewport
          CameraHudViewport(
            state: state,
            viewModel: viewModel,
            height: 460,
            isExpandedView: true,
          ),
          const SizedBox(height: 16),

          // Three-column row beneath camera:
          // Rover Status | Directional + E-Stop Capsule | Hardware Health
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Rover Status
              Expanded(
                flex: 6,
                child: Container(
                  height: 130,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F3D3A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.show_chart, color: AppColors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Rover Status',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          const Spacer(),
                          _buildPill('Active', ControlColors.statusGreen),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Connection', style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 11)),
                          Text('Online', style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Motion', style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 11)),
                          Text(state.activeDirection.label, style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Battery', style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 11)),
                          Text('${state.telemetry.batteryPercentage}%', style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // 2. Center Capsule: Directional Controls + Emergency Stop
              Expanded(
                flex: 10,
                child: Container(
                  height: 130,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: ControlColors.controlBurgundy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF9E2A36), width: 1.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DirectionalControlPad(
                        size: 110,
                        activeDirection: state.activeDirection,
                        isEmergencyStopped: state.isEmergencyStopped,
                        useCreamButtons: true,
                        onDirectionDown: viewModel.startMovement,
                        onDirectionUp: viewModel.stopMovement,
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        child: EmergencyStopButton(
                          isEmergencyStopped: state.isEmergencyStopped,
                          onTrigger: viewModel.triggerEmergencyStop,
                          onReset: viewModel.resetEmergencyStop,
                          height: 72,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // 3. Hardware Health
              Expanded(
                flex: 6,
                child: Container(
                  height: 130,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F3D3A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.memory, color: AppColors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Hardware Health',
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                          const Spacer(),
                          _buildPill('All Good', ControlColors.statusGreen),
                        ],
                      ),
                      _buildMiniHealthItem('Camera', 'Online'),
                      _buildMiniHealthItem('Motor Driver', state.isEmergencyStopped ? 'Disabled' : 'OK'),
                      _buildMiniHealthItem('Controller', 'OK'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bottom Bar: Live Sensors Across Width + Overall Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3D3A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.sensors, color: ControlColors.controlCream, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Live Sensors',
                  style: AppTypography.interfaceBase.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: 24),
                _buildSensorsPill('Temp', '${state.telemetry.temperatureCelsius} °C'),
                const SizedBox(width: 18),
                _buildSensorsPill('Humidity', '${state.telemetry.humidityPercentage} %'),
                const SizedBox(width: 18),
                _buildSensorsPill('Ultrasonic', '${state.telemetry.ultrasonicDistanceMeters} m'),
                const SizedBox(width: 18),
                _buildSensorsPill('Light', '${state.telemetry.lightLux} lux'),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.flag_outlined, color: AppColors.secondaryText, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Overall Status',
                      style: AppTypography.caption.copyWith(color: AppColors.secondaryText),
                    ),
                    const SizedBox(width: 8),
                    _buildPill(
                      state.isEmergencyStopped ? 'E-STOP' : 'Operational',
                      state.isEmergencyStopped ? ControlColors.emergencyRed : ControlColors.statusGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildMiniHealthItem(String label, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 11)),
        Row(
          children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: ControlColors.statusGreen, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(status, style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildSensorsPill(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 11),
        ),
        Text(
          value,
          style: AppTypography.telemetryBase.copyWith(color: ControlColors.controlCream, fontWeight: FontWeight.w700, fontSize: 12),
        ),
      ],
    );
  }
}

