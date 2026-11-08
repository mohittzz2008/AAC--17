import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/rover_session_status.dart';

/// Burgundy status banner displaying rover session and verification warning.
class RoverStatusAlertBanner extends StatelessWidget {
  final RoverSessionStatus session;

  const RoverStatusAlertBanner({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.burgundy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                session.roverId,
                style: AppTypography.alertTitle,
              ),
              Text(
                session.verification.displayLabel,
                style: AppTypography.statusTagGold.copyWith(
                  color: AppColors.white,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            session.sessionDescription,
            style: AppTypography.alertSubtitle,
          ),
        ],
      ),
    );
  }
}

