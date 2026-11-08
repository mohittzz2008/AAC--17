import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/camera_telemetry.dart';

class CameraInfoCard extends StatelessWidget {
  final CameraTelemetry telemetry;

  const CameraInfoCard({super.key, required this.telemetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CAMERA INFORMATION',
            style: AppTypography.fieldLabel.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          _buildRow('Module', telemetry.moduleTitle, isMono: true),
          const Divider(color: AppColors.raisedSurface, height: 20),
          _buildRow(
            'Connection',
            telemetry.connectionStatus.displayLabel,
            badgeColor: AppColors.burgundy,
          ),
          const Divider(color: AppColors.raisedSurface, height: 20),
          _buildRow('Resolution', telemetry.resolution ?? '--', isMono: true),
          const Divider(color: AppColors.raisedSurface, height: 20),
          _buildRow('Frame Rate', telemetry.frameRate != null ? '${telemetry.frameRate} fps' : '--', isMono: true),
          const Divider(color: AppColors.raisedSurface, height: 20),
          _buildRow('Stream Health', telemetry.streamHealth ?? '--', isMono: true),
          const Divider(color: AppColors.raisedSurface, height: 20),
          _buildRow('Last Update', telemetry.lastUpdate != null ? '${telemetry.lastUpdate}' : '--', isMono: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isMono = false, Color? badgeColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.secondaryText,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (badgeColor != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          Text(
            value,
            style: isMono
                ? AppTypography.telemetryBase.copyWith(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  )
                : AppTypography.interfaceBase.copyWith(
                    color: AppColors.white,
                    fontSize: 12,
                  ),
          ),
      ],
    );
  }
}
