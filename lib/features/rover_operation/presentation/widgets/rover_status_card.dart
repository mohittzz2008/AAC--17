import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/control_colors.dart';
import '../state/rover_operation_state.dart';

/// Card presenting Rover connection, motion, system condition, and battery metrics.
class RoverStatusCard extends StatelessWidget {
  final RoverOperationLoaded state;
  final bool isBurgundyTheme;

  const RoverStatusCard({
    super.key,
    required this.state,
    this.isBurgundyTheme = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isBurgundyTheme
        ? ControlColors.controlBurgundy
        : ControlColors.controlDarkSurface;
    final borderColor = isBurgundyTheme
        ? const Color(0xFF9E2A36)
        : AppColors.raisedSurface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Rover Status + Operational Badge
          Row(
            children: [
              const Icon(Icons.show_chart, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Rover Status',
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.interfaceBase.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: state.isEmergencyStopped
                      ? ControlColors.emergencyRed
                      : const Color(0xFF1E7E34),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      state.isEmergencyStopped ? 'E-STOP' : 'Operational',
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
          const SizedBox(height: 14),

          // 4-item status grid / row
          Row(
            children: [
              // Battery
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.battery_charging_full,
                  label: 'Battery',
                  value: '${state.telemetry.batteryPercentage}%',
                ),
              ),
              const SizedBox(width: 8),

              // Link / Latency
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.wifi,
                  label: 'Link',
                  value: '${state.telemetry.latencyMs} ms',
                ),
              ),
              const SizedBox(width: 8),

              // Motion
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.directions_run,
                  label: 'Motion',
                  value: state.isEmergencyStopped
                      ? 'Halted'
                      : (state.activeDirection.label),
                ),
              ),
              const SizedBox(width: 8),

              // Temp
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.thermostat,
                  label: 'Temp',
                  value: '${state.telemetry.temperatureCelsius} °C',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0x33000000),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ControlColors.controlCream, size: 13),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.telemetryBase.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
