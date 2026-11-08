import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/control_colors.dart';
import '../state/rover_operation_state.dart';

/// Card showing the health checks for key rover modules:
/// Camera, Motor Driver, IMU / Controllers, and Communication bus.
class HardwareHealthCard extends StatelessWidget {
  final RoverOperationLoaded state;

  const HardwareHealthCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ControlColors.controlDarkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.raisedSurface, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.memory, color: ControlColors.controlCream, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hardware Health',
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.interfaceBase.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E7E34),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  state.isEmergencyStopped ? 'E-STOP' : 'All Systems OK',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Subsystem items
          _buildHealthRow(
            icon: Icons.camera_alt_outlined,
            title: 'Camera',
            status: state.telemetry.cameraHealthText,
            isHealthy: true,
          ),
          const SizedBox(height: 8),
          _buildHealthRow(
            icon: Icons.settings_suggest_outlined,
            title: 'Motor Driver',
            status: state.isEmergencyStopped ? 'Disabled' : state.telemetry.motorDriverHealthText,
            isHealthy: !state.isEmergencyStopped,
          ),
          const SizedBox(height: 8),
          _buildHealthRow(
            icon: Icons.developer_board_outlined,
            title: 'Controller (ESP32)',
            status: state.telemetry.controllerHealthText,
            isHealthy: true,
          ),
          const SizedBox(height: 8),
          _buildHealthRow(
            icon: Icons.sensors_outlined,
            title: 'Sensor Modules',
            status: state.telemetry.sensorModulesHealthText,
            isHealthy: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRow({
    required IconData icon,
    required String title,
    required String status,
    required bool isHealthy,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.secondaryText, size: 15),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryText,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isHealthy ? ControlColors.statusGreen : ControlColors.emergencyRed,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            status,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.telemetryBase.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 10,
              color: isHealthy ? ControlColors.statusGreen : ControlColors.emergencyRed,
            ),
          ),
        ),
      ],
    );
  }
}
