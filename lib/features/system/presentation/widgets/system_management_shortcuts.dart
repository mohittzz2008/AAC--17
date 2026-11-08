import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/shell/system_sub_destination.dart';

class SystemManagementShortcuts extends StatelessWidget {
  final ValueChanged<SystemSubDestination> onSelectDestination;

  const SystemManagementShortcuts({
    super.key,
    required this.onSelectDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Column(
        children: [
          _buildTile(
            SystemSubDestination.deviceConnection,
            'Device Connection',
            'Pairing, discovery and transport configuration',
            Icons.link_rounded,
            isFirst: true,
          ),
          const Divider(color: AppColors.raisedSurface, height: 1),
          _buildTile(
            SystemSubDestination.diagnostics,
            'Diagnostics & Health',
            'Subsystem health checks, faults and diagnostics runner',
            Icons.monitor_heart_outlined,
          ),
          const Divider(color: AppColors.raisedSurface, height: 1),
          _buildTile(
            SystemSubDestination.activityLogs,
            'Activity & Event Logs',
            'Telemetry event timeline, search and multi-criteria filters',
            Icons.receipt_long_outlined,
          ),
          const Divider(color: AppColors.raisedSurface, height: 1),
          _buildTile(
            SystemSubDestination.configuration,
            'Configuration & Calibration',
            'Network settings, device preferences and sensor calibration',
            Icons.tune_rounded,
          ),
          const Divider(color: AppColors.raisedSurface, height: 1),
          _buildTile(
            SystemSubDestination.firmware,
            'Firmware & Maintenance',
            'Firmware inventory, OTA update status and maintenance log',
            Icons.system_update_alt_rounded,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    SystemSubDestination destination,
    String title,
    String subtitle,
    IconData icon, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () => onSelectDestination(destination),
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(14) : Radius.zero,
        bottom: isLast ? const Radius.circular(14) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.raisedSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.gold, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.cardTitle.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.secondaryText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.secondaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

