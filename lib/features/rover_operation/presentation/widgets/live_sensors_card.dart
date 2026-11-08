import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/control_colors.dart';
import '../state/rover_operation_state.dart';

/// Card presenting active telemetry snapshot from sensors:
/// Ultrasonic distance, temperature, humidity, ambient light, and orientation.
class LiveSensorsCard extends StatelessWidget {
  final RoverOperationLoaded state;
  final bool isCreamTheme;

  const LiveSensorsCard({
    super.key,
    required this.state,
    this.isCreamTheme = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isCreamTheme
        ? ControlColors.controlCream
        : ControlColors.controlGreen;
    final primaryTextColor = isCreamTheme
        ? AppColors.background
        : AppColors.white;
    final secondaryTextColor = isCreamTheme
        ? const Color(0xFF6A5545)
        : ControlColors.controlCream;
    final iconColor = isCreamTheme
        ? ControlColors.controlBurgundy
        : ControlColors.controlCream;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCreamTheme ? const Color(0xFFDFBA99) : Colors.white12,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.sensors, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Live Sensors',
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.interfaceBase.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: primaryTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Last updated: 1 s ago',
                style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 Sensor Items Row
          Row(
            children: [
              Expanded(
                child: _buildSensorItem(
                  icon: Icons.water_drop_outlined,
                  label: 'Humidity',
                  value: '${state.telemetry.humidityPercentage}%',
                  iconColor: iconColor,
                  labelColor: secondaryTextColor,
                  valueColor: primaryTextColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSensorItem(
                  icon: Icons.thermostat_outlined,
                  label: 'Temperature',
                  value: '${state.telemetry.temperatureCelsius} °C',
                  iconColor: iconColor,
                  labelColor: secondaryTextColor,
                  valueColor: primaryTextColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSensorItem(
                  icon: Icons.radar_outlined,
                  label: 'Distance',
                  value: '${state.telemetry.ultrasonicDistanceMeters} m',
                  iconColor: iconColor,
                  labelColor: secondaryTextColor,
                  valueColor: primaryTextColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSensorItem(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Light',
                  value: '${state.telemetry.lightLux} lx',
                  iconColor: iconColor,
                  labelColor: secondaryTextColor,
                  valueColor: primaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color labelColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: isCreamTheme ? const Color(0x33FFFFFF) : const Color(0x33000000),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: labelColor,
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
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
