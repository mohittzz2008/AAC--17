import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/control_colors.dart';

/// High-priority Emergency Stop button with visual glow, siren/warning icon,
/// stop engaged lock indication, and reset interaction.
class EmergencyStopButton extends StatelessWidget {
  final bool isEmergencyStopped;
  final VoidCallback onTrigger;
  final VoidCallback onReset;
  final bool isFullWidth;
  final double? height;

  const EmergencyStopButton({
    super.key,
    required this.isEmergencyStopped,
    required this.onTrigger,
    required this.onReset,
    this.isFullWidth = false,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEmergencyStopped ? onReset : onTrigger,
        borderRadius: BorderRadius.circular(28),
        splashColor: Colors.white24,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: height,
          width: isFullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: isEmergencyStopped ? const Color(0xFF8B0000) : ControlColors.emergencyRed,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isEmergencyStopped ? Colors.white : const Color(0xFFFF6B6B),
              width: isEmergencyStopped ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: ControlColors.emergencyGlow,
                blurRadius: isEmergencyStopped ? 16 : 10,
                spreadRadius: isEmergencyStopped ? 3 : 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isEmergencyStopped ? Icons.warning_rounded : Icons.report_problem_outlined,
                color: AppColors.white,
                size: 24,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  isEmergencyStopped ? 'STOP ENGAGED (TAP TO RESET)' : 'EMERGENCY STOP',
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.interfaceBase.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

