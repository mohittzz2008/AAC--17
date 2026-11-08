import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/control_colors.dart';
import '../state/rover_operation_state.dart';
import '../viewmodels/rover_operation_viewmodel.dart';
import '../widgets/camera_hud_viewport.dart';
import '../widgets/hardware_health_card.dart';
import '../widgets/live_sensors_card.dart';
import '../widgets/movement_control_card.dart';
import '../widgets/overall_status_card.dart';
import '../widgets/rover_status_card.dart';

/// Desktop Normal Layout (Design Reference 4).
/// Provides side-by-side camera viewport and remote operation control panels,
/// keyboard instruction legend, and comprehensive telemetry cards.
class DesktopNormalLayout extends StatelessWidget {
  final RoverOperationLoaded state;
  final RoverOperationViewModel viewModel;

  const DesktopNormalLayout({
    super.key,
    required this.state,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Rover Control Title + Subtitle
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: ControlColors.controlBurgundy,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF9E2A36), width: 1.5),
                ),
                child: const Icon(
                  Icons.sports_esports_outlined,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rover Control',
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.interfaceBase.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 0.5,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Live view, remote operation and real-time system monitoring',
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Quick connection status capsule
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3D3A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: ControlColors.statusGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rover Connected · 48 ms',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Notice banner (e.g. Emergency stop or snapshot notice)
          if (state.noticeMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: state.isEmergencyStopped
                    ? ControlColors.controlBurgundy
                    : ControlColors.controlGreen,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: state.isEmergencyStopped ? Colors.white30 : Colors.white12,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    state.isEmergencyStopped ? Icons.warning_rounded : Icons.info_outline,
                    color: AppColors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.noticeMessage!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Main 2-Column Content Area
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN: Large Camera Viewport + Subsystem Health
              Expanded(
                flex: 11,
                child: Column(
                  children: [
                    // Camera Viewport
                    CameraHudViewport(
                      state: state,
                      viewModel: viewModel,
                      height: 400,
                    ),
                    const SizedBox(height: 18),

                    // Health and Overall Status
                    LayoutBuilder(
                      builder: (context, colConstraints) {
                        if (colConstraints.maxWidth < 560) {
                          return Column(
                            children: [
                              HardwareHealthCard(state: state),
                              const SizedBox(height: 14),
                              OverallStatusCard(state: state),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: HardwareHealthCard(state: state)),
                            const SizedBox(width: 16),
                            Expanded(child: OverallStatusCard(state: state)),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // RIGHT COLUMN: Movement Controls, Rover Status, Live Sensors
              Expanded(
                flex: 9,
                child: Column(
                  children: [
                    // Movement Control Card (Cream background)
                    MovementControlCard(
                      state: state,
                      viewModel: viewModel,
                    ),
                    const SizedBox(height: 16),

                    // Rover Status Card (Burgundy background)
                    RoverStatusCard(
                      state: state,
                      isBurgundyTheme: true,
                    ),
                    const SizedBox(height: 16),

                    // Live Sensors Card (Cream background)
                    LiveSensorsCard(
                      state: state,
                      isCreamTheme: true,
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
