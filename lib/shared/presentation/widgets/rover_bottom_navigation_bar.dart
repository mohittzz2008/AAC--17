import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../shell/shell_destination.dart';

/// Floating rounded bottom navigation bar capsule matching the approved Figma design.
class RoverBottomNavigationBar extends StatelessWidget {
  final ShellDestination currentDestination;
  final ValueChanged<ShellDestination> onDestinationSelected;

  const RoverBottomNavigationBar({
    super.key,
    required this.currentDestination,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ShellDestination.values.map((destination) {
          return _BottomNavDestinationItem(
            destination: destination,
            isSelected: destination == currentDestination,
            onDestinationSelected: onDestinationSelected,
          );
        }).toList(),
      ),
    );
  }
}

class _BottomNavDestinationItem extends StatefulWidget {
  final ShellDestination destination;
  final bool isSelected;
  final ValueChanged<ShellDestination> onDestinationSelected;

  const _BottomNavDestinationItem({
    required this.destination,
    required this.isSelected,
    required this.onDestinationSelected,
  });

  @override
  State<_BottomNavDestinationItem> createState() =>
      _BottomNavDestinationItemState();
}

class _BottomNavDestinationItemState extends State<_BottomNavDestinationItem> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final color = isSelected
        ? AppColors.gold
        : (_isFocused ? AppColors.white : AppColors.secondaryText);
    final textStyle = isSelected
        ? AppTypography.navLabelSelected
        : AppTypography.navLabelUnselected;

    return Expanded(
      child: FocusableActionDetector(
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => widget.onDestinationSelected(widget.destination),
          ),
        },
        child: InkWell(
          onTap: () => widget.onDestinationSelected(widget.destination),
          borderRadius: BorderRadius.circular(14),
          focusColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _isFocused
                  ? AppColors.raisedSurface.withValues(alpha: 0.5)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isFocused ? AppColors.gold : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.35),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.destination.icon,
                  size: 20,
                  color: color,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.destination.label,
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

