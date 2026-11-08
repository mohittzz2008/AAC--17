import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Top header of the ROVER COMMAND Dashboard including brand and DEMO MODE badge.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App title and inspection subhead
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ROVER COMMAND',
                style: AppTypography.appTitle,
              ),
              const SizedBox(height: 2),
              Text(
                'INSPECTION & MONITORING',
                style: AppTypography.appSubtitle,
              ),
            ],
          ),
        ),
        // DEMO MODE badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'DEMO MODE',
            style: AppTypography.demoBadge,
          ),
        ),
      ],
    );
  }
}

