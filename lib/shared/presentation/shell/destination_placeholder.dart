import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'shell_destination.dart';

/// Neutral placeholder view for uninitialized shell destinations.
class DestinationPlaceholder extends StatelessWidget {
  final ShellDestination destination;

  const DestinationPlaceholder({
    super.key,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            destination.icon,
            size: 48,
            color: AppColors.secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            destination.label,
            style: AppTypography.interfaceBase.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

