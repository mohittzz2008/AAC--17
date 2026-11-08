import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/control_colors.dart';
import '../../domain/models/movement_direction.dart';

/// Directional movement control pad supporting press-and-hold touch events,
/// pointer release and cancellation, and visual feedback for active movement.
class DirectionalControlPad extends StatelessWidget {
  final MovementDirection activeDirection;
  final bool isEmergencyStopped;
  final ValueChanged<MovementDirection> onDirectionDown;
  final VoidCallback onDirectionUp;
  final bool useCreamButtons;
  final double size;

  const DirectionalControlPad({
    super.key,
    required this.activeDirection,
    required this.isEmergencyStopped,
    required this.onDirectionDown,
    required this.onDirectionUp,
    this.useCreamButtons = false,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size * 0.28;
    final centerSize = size * 0.28;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center Rover Tile
          Container(
            width: centerSize,
            height: centerSize,
            decoration: BoxDecoration(
              color: useCreamButtons ? ControlColors.controlBurgundy : ControlColors.controlCream,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: useCreamButtons ? ControlColors.controlCream : ControlColors.controlGreen,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x4D000000),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.agriculture_rounded,
              color: useCreamButtons ? ControlColors.controlCream : ControlColors.controlBurgundy,
              size: centerSize * 0.55,
            ),
          ),

          // UP / FORWARD
          Positioned(
            top: 4,
            child: _buildDirectionButton(
              direction: MovementDirection.forward,
              icon: Icons.keyboard_arrow_up_rounded,
              size: buttonSize,
            ),
          ),

          // DOWN / BACKWARD
          Positioned(
            bottom: 4,
            child: _buildDirectionButton(
              direction: MovementDirection.backward,
              icon: Icons.keyboard_arrow_down_rounded,
              size: buttonSize,
            ),
          ),

          // LEFT / TURN LEFT
          Positioned(
            left: 4,
            child: _buildDirectionButton(
              direction: MovementDirection.left,
              icon: Icons.keyboard_arrow_left_rounded,
              size: buttonSize,
            ),
          ),

          // RIGHT / TURN RIGHT
          Positioned(
            right: 4,
            child: _buildDirectionButton(
              direction: MovementDirection.right,
              icon: Icons.keyboard_arrow_right_rounded,
              size: buttonSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionButton({
    required MovementDirection direction,
    required IconData icon,
    required double size,
  }) {
    final isActive = activeDirection == direction && !isEmergencyStopped;

    Color bgColor;
    Color iconColor;

    if (useCreamButtons) {
      bgColor = isActive ? ControlColors.creamActive : ControlColors.controlCream;
      iconColor = AppColors.background;
    } else {
      bgColor = isActive ? ControlColors.greenActive : ControlColors.controlGreen;
      iconColor = ControlColors.controlCream;
    }

    if (isEmergencyStopped) {
      bgColor = bgColor.withValues(alpha: 0.4);
      iconColor = iconColor.withValues(alpha: 0.4);
    }

    return Listener(
      onPointerDown: (_) {
        if (!isEmergencyStopped) {
          onDirectionDown(direction);
        }
      },
      onPointerUp: (_) => onDirectionUp(),
      onPointerCancel: (_) => onDirectionUp(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(useCreamButtons ? size / 2 : 14),
          border: Border.all(
            color: isActive ? ControlColors.controlCream : Colors.black26,
            width: isActive ? 2 : 1,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: ControlColors.controlCream.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 1,
              )
            else
              const BoxShadow(
                color: Color(0x59000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.70,
        ),
      ),
    );
  }
}
