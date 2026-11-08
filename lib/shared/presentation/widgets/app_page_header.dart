import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Standard top header used across all ROVER COMMAND pages.
/// Displays the brand title, subtitle, DEMO MODE badge, optional large section title,
/// and optional back button for secondary navigation.
class AppPageHeader extends StatelessWidget {
  final String? pageTitle;
  final VoidCallback? onBack;
  final bool showBrandHeader;

  const AppPageHeader({
    super.key,
    this.pageTitle,
    this.onBack,
    this.showBrandHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showBrandHeader) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
          ),
          const SizedBox(height: 12),
        ],
        if (pageTitle != null) ...[
          Row(
            children: [
              if (onBack != null) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.white, size: 22),
                  onPressed: onBack,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                pageTitle!,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

