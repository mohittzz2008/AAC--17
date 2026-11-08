import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/control_colors.dart';
import '../state/rover_operation_state.dart';

/// Card showing the aggregate operational status of the rover.
class OverallStatusCard extends StatelessWidget {
  final RoverOperationLoaded state;

  const OverallStatusCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isOperational = !state.isEmergencyStopped;

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
          Row(
            children: [
              const Icon(Icons.layers_outlined, color: ControlColors.controlCream, size: 20),
              const SizedBox(width: 8),
              Text(
                'Overall Status',
                style: AppTypography.interfaceBase.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isOperational ? const Color(0xFF1E7E34) : ControlColors.emergencyRed,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOperational ? Icons.check_rounded : Icons.warning_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOperational ? 'Rover Operational' : 'Emergency Stop Engaged',
                      style: AppTypography.interfaceBase.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isOperational
                          ? 'All systems are functioning normally.'
                          : 'Drive train locked. Tap Emergency Stop to reset.',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

