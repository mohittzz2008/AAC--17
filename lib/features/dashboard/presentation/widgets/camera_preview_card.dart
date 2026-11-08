import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/camera_preview_telemetry.dart';

/// Camera preview card matching the Figma reference layout.
class CameraPreviewCard extends StatelessWidget {
  final CameraPreviewTelemetry camera;
  final double viewportHeight;

  const CameraPreviewCard({
    super.key,
    required this.camera,
    this.viewportHeight = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CAMERA PREVIEW',
                style: AppTypography.fieldLabel.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                camera.verification.displayLabel,
                style: AppTypography.statusTagGold,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Black Viewport
          Container(
            width: double.infinity,
            height: viewportHeight,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.videocam_outlined,
                  color: AppColors.gold,
                  size: 38,
                ),
                const SizedBox(height: 12),
                Text(
                  camera.moduleTitle,
                  style: AppTypography.interfaceBase.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  camera.statusHeadline,
                  style: AppTypography.telemetryBase.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  camera.streamDisclaimer,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
