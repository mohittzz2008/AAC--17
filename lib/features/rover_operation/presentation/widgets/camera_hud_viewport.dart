import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/camera_colors.dart';
import '../state/rover_operation_state.dart';
import '../viewmodels/rover_operation_viewmodel.dart';

/// Camera viewport with interactive HUD reticle, latency indicator,
/// resolution/fps overlay, snapshot/recording controls, and expand toggle.
class CameraHudViewport extends StatelessWidget {
  final RoverOperationLoaded state;
  final RoverOperationViewModel viewModel;
  final double? height;
  final bool isExpandedView;

  const CameraHudViewport({
    super.key,
    required this.state,
    required this.viewModel,
    this.height,
    this.isExpandedView = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: CameraColors.viewportBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.raisedSurface, width: 1.5),
        ),
        child: Stack(
          children: [
            // Realistic simulated Mars landscape & horizon viewport background
            Positioned.fill(
              child: CustomPaint(
                painter: _SimulatedViewportPainter(
                  isSnapshotActive: state.isSnapshotActive,
                ),
              ),
            ),

            // Top HUD Bar
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 500;

                  return Row(
                    children: [
                      // LIVE BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xB3101014),
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
                                color: CameraColors.liveIndicator,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'LIVE',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: AppColors.white,
                                fontSize: 10,
                              ),
                            ),
                            if (!isCompact) ...[
                              const SizedBox(width: 5),
                              Text(
                                'Camera Feed',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.secondaryText,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // RESOLUTION & FPS PILL
                      if (!isCompact || constraints.maxWidth > 300)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xB3101014),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isCompact
                                ? state.telemetry.cameraResolution
                                : '${state.telemetry.cameraResolution} · ${state.telemetry.cameraFps} FPS',
                            style: AppTypography.telemetryBase.copyWith(
                              fontSize: 10,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      const Spacer(),

                      // SNAPSHOT BUTTON
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        tooltip: 'Capture Snapshot',
                        onPressed: viewModel.captureSnapshot,
                        icon: const Icon(Icons.camera_alt_outlined, color: AppColors.white, size: 17),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0x99101014),
                          shape: const CircleBorder(),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // RECORD BUTTON (only on wider viewports)
                      if (!isCompact) ...[
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          tooltip: state.isRecording ? 'Stop Recording' : 'Start Recording',
                          onPressed: viewModel.toggleRecording,
                          icon: Icon(
                            state.isRecording ? Icons.videocam : Icons.videocam_outlined,
                            color: state.isRecording ? CameraColors.liveIndicator : AppColors.white,
                            size: 17,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0x99101014),
                            shape: const CircleBorder(),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],

                      // EXPAND TOGGLE
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        tooltip: state.isCameraExpanded ? 'Exit Expanded View' : 'Expand Camera',
                        onPressed: viewModel.toggleCameraExpanded,
                        icon: Icon(
                          state.isCameraExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                          color: AppColors.white,
                          size: 18,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0x99101014),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // CENTER RETICLE HUD
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: SizedBox(
                    width: 140,
                    height: 100,
                    child: CustomPaint(
                      painter: _ReticlePainter(),
                    ),
                  ),
                ),
              ),
            ),

            // BOTTOM-LEFT LATENCY BADGE
            Positioned(
              bottom: 12,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xB3101014),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.signal_cellular_alt, color: CameraColors.signalGood, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${state.telemetry.latencyMs} ms',
                      style: AppTypography.telemetryBase.copyWith(
                        fontSize: 11,
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM CENTER SIMULATED NOTICE
            Positioned(
              bottom: 12,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xCC0F3D3A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 0.8),
                ),
                child: Text(
                  'DEMO STREAM · HARDWARE STANDBY',
                  style: AppTypography.telemetryBase.copyWith(
                    fontSize: 10,
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter rendering procedural Martian terrain, sky gradient, and rover chassis horizon.
class _SimulatedViewportPainter extends CustomPainter {
  final bool isSnapshotActive;

  _SimulatedViewportPainter({required this.isSnapshotActive});

  @override
  void paint(Canvas canvas, Size size) {
    if (isSnapshotActive) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0x66FFFFFF),
      );
      return;
    }

    // Sky gradient (warm Martian atmosphere)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2B1410), Color(0xFF6B301F), Color(0xFFA65233)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.55));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.55), skyPaint);

    // Distant mountain ranges
    final mountainPaint = Paint()..color = const Color(0xFF87381E);
    final mPath = Path()
      ..moveTo(0, size.height * 0.45)
      ..lineTo(size.width * 0.25, size.height * 0.38)
      ..lineTo(size.width * 0.5, size.height * 0.44)
      ..lineTo(size.width * 0.78, size.height * 0.35)
      ..lineTo(size.width, size.height * 0.42)
      ..lineTo(size.width, size.height * 0.55)
      ..lineTo(0, size.height * 0.55)
      ..close();
    canvas.drawPath(mPath, mountainPaint);

    // Ground terrain gradient (red dusty surface)
    final groundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF9E4426), Color(0xFF5E2211), Color(0xFF381207)],
      ).createShader(Rect.fromLTWH(0, size.height * 0.42, size.width, size.height * 0.58));
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.42, size.width, size.height * 0.58), groundPaint);

    // Center tire tracks
    final trackPaint = Paint()
      ..color = const Color(0x99280B03)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final leftTrack = Path()
      ..moveTo(size.width * 0.47, size.height * 0.43)
      ..lineTo(size.width * 0.32, size.height);
    final rightTrack = Path()
      ..moveTo(size.width * 0.53, size.height * 0.43)
      ..lineTo(size.width * 0.68, size.height);

    canvas.drawPath(leftTrack, trackPaint);
    canvas.drawPath(rightTrack, trackPaint);

    // Foreground Rover Wheels/Chassis silhouette
    final chassisPaint = Paint()..color = const Color(0xFF151518);
    // Left wheel silhouette
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.16, size.height * 0.72, size.width * 0.14, size.height * 0.35),
        const Radius.circular(16),
      ),
      chassisPaint,
    );
    // Right wheel silhouette
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.70, size.height * 0.72, size.width * 0.14, size.height * 0.35),
        const Radius.circular(16),
      ),
      chassisPaint,
    );
    // Center chassis plate
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.35, size.height * 0.82, size.width * 0.30, size.height * 0.25),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF202026),
    );
  }

  @override
  bool shouldRepaint(covariant _SimulatedViewportPainter oldDelegate) =>
      oldDelegate.isSnapshotActive != isSnapshotActive;
}

/// Painter for the HUD center reticle bracket and crosshair.
class _ReticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xD9FFFFFF)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    const cornerLen = 16.0;

    // Top-left corner
    canvas.drawLine(Offset.zero, const Offset(cornerLen, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, cornerLen), paint);

    // Top-right corner
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLen, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLen), paint);

    // Bottom-left corner
    canvas.drawLine(Offset(0, size.height), Offset(cornerLen, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLen), paint);

    // Bottom-right corner
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLen, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLen), paint);

    // Center Crosshair '+'
    const cSize = 9.0;
    final cX = size.width / 2;
    final cY = size.height / 2;
    canvas.drawLine(Offset(cX - cSize, cY), Offset(cX + cSize, cY), paint);
    canvas.drawLine(Offset(cX, cY - cSize), Offset(cX, cY + cSize), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
