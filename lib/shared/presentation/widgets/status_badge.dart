import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum BadgeStyle {
  burgundy,
  gold,
  surface,
}

/// Standardized pill status badge conforming strictly to the 8-color design system.
class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeStyle style;
  final bool hasPrefixBar;

  const StatusBadge({
    super.key,
    required this.label,
    this.style = BadgeStyle.surface,
    this.hasPrefixBar = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Border? border;

    switch (style) {
      case BadgeStyle.burgundy:
        bg = AppColors.burgundy;
        fg = AppColors.white;
        border = Border.all(color: AppColors.raisedSurface, width: 1);
        break;
      case BadgeStyle.gold:
        bg = AppColors.gold;
        fg = AppColors.black;
        break;
      case BadgeStyle.surface:
        bg = AppColors.raisedSurface;
        fg = AppColors.secondaryText;
        border = Border.all(color: AppColors.surface, width: 1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasPrefixBar) ...[
            Container(
              width: 3,
              height: 10,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: AppColors.burgundy,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}
