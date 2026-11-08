import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/camera_telemetry.dart';

class CameraStreamViewport extends StatelessWidget {
  final CameraTelemetry telemetry;
  final double height;

  const CameraStreamViewport({
    super.key,
    required this.telemetry,
    this.height = 260,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.videocam_outlined,
            color: AppColors.gold,
            size: 44,
          ),
          const SizedBox(height: 14),
          Text(
            '${telemetry.moduleTitle} preview',
            style: AppTypography.interfaceBase.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'NO VIDEO FEED / NOT CONNECTED',
            style: AppTypography.telemetryBase.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              telemetry.disclaimer,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                fontSize: 11,
                color: AppColors.secondaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

