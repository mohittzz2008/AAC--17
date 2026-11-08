import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../shell/shell_destination.dart';

/// Industrial left navigation rail for desktop and wide workstation layouts.
class RoverNavigationRail extends StatelessWidget {
  final ShellDestination currentDestination;
  final ValueChanged<ShellDestination> onDestinationSelected;

  const RoverNavigationRail({
    super.key,
    required this.currentDestination,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.raisedSurface, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // App Mark
          Text(
            'ROVER',
            style: AppTypography.interfaceBase.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: AppColors.white,
            ),
          ),
          Text(
            'COMMAND',
            style: AppTypography.interfaceBase.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 32),
          const Divider(color: AppColors.raisedSurface, height: 1),
          const SizedBox(height: 16),
          // Destinations
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: ShellDestination.values.map((destination) {
                return _RailDestinationItem(
                  destination: destination,
                  isSelected: destination == currentDestination,
                  onDestinationSelected: onDestinationSelected,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailDestinationItem extends StatefulWidget {
  final ShellDestination destination;
  final bool isSelected;
  final ValueChanged<ShellDestination> onDestinationSelected;

  const _RailDestinationItem({
    required this.destination,
    required this.isSelected,
    required this.onDestinationSelected,
  });

  @override
  State<_RailDestinationItem> createState() => _RailDestinationItemState();
}

class _RailDestinationItemState extends State<_RailDestinationItem> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final color = isSelected
        ? AppColors.gold
        : (_isFocused ? AppColors.white : AppColors.secondaryText);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: FocusableActionDetector(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => widget.onDestinationSelected(widget.destination),
          ),
        },
        child: InkWell(
          onTap: () => widget.onDestinationSelected(widget.destination),
          borderRadius: BorderRadius.circular(10),
          focusColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.raisedSurface
                  : (_isFocused
                      ? AppColors.raisedSurface.withValues(alpha: 0.5)
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isFocused
                    ? AppColors.gold
                    : (isSelected
                        ? AppColors.gold.withValues(alpha: 0.4)
                        : Colors.transparent),
                width: 2,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.destination.icon,
                  size: 24,
                  color: color,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.destination.label,
                  style: isSelected
                      ? AppTypography.navLabelSelected
                      : AppTypography.navLabelUnselected,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

