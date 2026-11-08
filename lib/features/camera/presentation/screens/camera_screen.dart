import 'package:flutter/material.dart';
import '../../../../core/responsive/screen_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/app_page_header.dart';
import '../../domain/models/camera_telemetry.dart';
import '../state/camera_state.dart';
import '../viewmodels/camera_viewmodel.dart';
import '../widgets/camera_info_card.dart';
import '../widgets/camera_stream_viewport.dart';

class CameraScreen extends StatefulWidget {
  final CameraViewModel viewModel;
  final VoidCallback? onOpenDiagnostics;

  const CameraScreen({
    super.key,
    required this.viewModel,
    this.onOpenDiagnostics,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.state is CameraInitial) {
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
          CameraInitial() || CameraConnecting() => const Center(
              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2.5),
            ),
          CameraError(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.burgundy, size: 36),
                  const SizedBox(height: 12),
                  Text('CAMERA ERROR', style: AppTypography.alertTitle),
                  const SizedBox(height: 8),
                  Text(message, style: AppTypography.alertSubtitle),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => widget.viewModel.retryConnection(),
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            ),
          CameraLoaded(:final telemetry) => LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= ScreenBreakpoints.tabletMax;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1200 : 720,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppPageHeader(pageTitle: 'Camera'),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'ESP32-CAM Monitoring',
                                  style: AppTypography.subtitle,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.burgundy,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'NOT VERIFIED',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (isDesktop)
                            _buildDesktopContent(telemetry)
                          else
                            _buildMobileContent(telemetry),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        };
      },
    );
  }

  Widget _buildMobileContent(CameraTelemetry telemetry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CameraStreamViewport(telemetry: telemetry, height: 260),
        const SizedBox(height: 16),
        CameraInfoCard(telemetry: telemetry),
        const SizedBox(height: 20),
        _buildActionButtons(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDesktopContent(CameraTelemetry telemetry) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 13,
          child: CameraStreamViewport(telemetry: telemetry, height: 380),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CameraInfoCard(telemetry: telemetry),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => widget.viewModel.retryConnection(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text(
              'RETRY CONNECTION',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8),
            ),
          ),
        ),
        if (widget.onOpenDiagnostics != null) ...[
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: widget.onOpenDiagnostics,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.white,
                side: const BorderSide(color: AppColors.raisedSurface, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.monitor_heart_outlined, size: 18, color: AppColors.gold),
              label: const Text(
                'OPEN DIAGNOSTICS',
                style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
