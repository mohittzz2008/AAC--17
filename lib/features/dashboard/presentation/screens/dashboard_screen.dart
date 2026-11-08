import 'package:flutter/material.dart';
import '../../../../core/responsive/screen_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../state/dashboard_state.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../widgets/camera_preview_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/distance_sensors_section.dart';
import '../widgets/hardware_overview_grid.dart';
import '../widgets/motion_sensors_section.dart';
import '../widgets/rover_status_alert_banner.dart';

/// The primary ROVER COMMAND inspection and telemetry dashboard screen.
class DashboardScreen extends StatefulWidget {
  final DashboardViewModel viewModel;

  const DashboardScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load telemetry on initial display
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.state is DashboardInitial) {
        widget.viewModel.loadTelemetry();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final state = widget.viewModel.state;

        return switch (state) {
          DashboardInitial() || DashboardLoading() => const _DashboardLoadingView(),
          DashboardError(:final userMessage) => _DashboardErrorView(
              message: userMessage,
              onRetry: () => widget.viewModel.loadTelemetry(),
            ),
          DashboardLoaded(:final data) => _DashboardLoadedView(
              bundle: data,
              onRefresh: () => widget.viewModel.refresh(),
            ),
        };
      },
    );
  }
}

/// Loading state view with gold indicator.
class _DashboardLoadingView extends StatelessWidget {
  const _DashboardLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.gold,
            strokeWidth: 2.5,
          ),
          SizedBox(height: 16),
          Text(
            'LOADING ROVER TELEMETRY...',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state view with retry action.
class _DashboardErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DashboardErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.burgundy,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.raisedSurface, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.white,
                size: 36,
              ),
              const SizedBox(height: 12),
              Text(
                'TELEMETRY INTEGRITY ERROR',
                style: AppTypography.alertTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTypography.alertSubtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('RETRY'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main loaded telemetry dashboard view supporting responsive adaptation.
class _DashboardLoadedView extends StatelessWidget {
  final dynamic bundle;
  final Future<void> Function() onRefresh;

  const _DashboardLoadedView({
    required this.bundle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= ScreenBreakpoints.tabletMax;

        return RefreshIndicator(
          color: AppColors.gold,
          backgroundColor: AppColors.surface,
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1280 : 720,
                ),
                child: isDesktop
                    ? _buildDesktopLayout()
                    : _buildMobileTabletLayout(),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Single-column layout matching the mobile Figma reference (01_dashboard.png).
  Widget _buildMobileTabletLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header
        const DashboardHeader(),
        const SizedBox(height: 16),

        // 2. Rover status alert banner
        RoverStatusAlertBanner(session: bundle.session),
        const SizedBox(height: 16),

        // 3. Hardware overview 2x2 grid
        HardwareOverviewGrid(items: bundle.hardwareOverview),
        const SizedBox(height: 16),

        // 4. Camera preview card
        CameraPreviewCard(camera: bundle.cameraPreview),
        const SizedBox(height: 20),

        // 5. Distance sensors section
        DistanceSensorsSection(sensors: bundle.distanceSensors),
        const SizedBox(height: 20),

        // 6. Motion sensors section
        MotionSensorsSection(sensors: bundle.motionSensors),
        const SizedBox(height: 24),
      ],
    );
  }

  /// 3-column workstation layout for wide desktop viewports.
  Widget _buildDesktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header spanning full width
        const DashboardHeader(),
        const SizedBox(height: 20),

        // 3 Balanced Columns:
        // Column 1: Rover status alert banner & Hardware inventory
        // Column 2: Camera preview
        // Column 3: Distance sensors & Motion sensors
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Column 1: Status & Hardware
            Expanded(
              flex: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RoverStatusAlertBanner(session: bundle.session),
                  const SizedBox(height: 16),
                  HardwareOverviewGrid(items: bundle.hardwareOverview),
                ],
              ),
            ),
            const SizedBox(width: 20),

            // Column 2: Camera Preview
            Expanded(
              flex: 12,
              child: CameraPreviewCard(
                camera: bundle.cameraPreview,
                viewportHeight: 280,
              ),
            ),
            const SizedBox(width: 20),

            // Column 3: Distance & Motion Sensors
            Expanded(
              flex: 11,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DistanceSensorsSection(sensors: bundle.distanceSensors),
                  const SizedBox(height: 16),
                  MotionSensorsSection(sensors: bundle.motionSensors),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

