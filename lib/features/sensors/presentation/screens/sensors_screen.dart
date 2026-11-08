import 'package:flutter/material.dart';
import '../../../../core/responsive/screen_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/app_page_header.dart';
import '../../../../shared/presentation/widgets/custom_telemetry_chart.dart';
import '../../../dashboard/domain/models/rover_session_status.dart';
import '../../domain/models/sensors_telemetry_bundle.dart';
import '../state/sensors_state.dart';
import '../viewmodels/sensors_viewmodel.dart';
import '../widgets/sensor_metrics_summary_card.dart';
import '../widgets/sensor_system_health_card.dart';
import '../widgets/sensors_distance_card.dart';
import '../widgets/sensors_motion_card.dart';
import '../widgets/sensors_recent_activity_card.dart';

class SensorsScreen extends StatefulWidget {
  final SensorsViewModel viewModel;

  const SensorsScreen({super.key, required this.viewModel});

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.state is SensorsInitial) {
        widget.viewModel.loadSensors();
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
          SensorsInitial() || SensorsLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2.5),
            ),
          SensorsError(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.burgundy, size: 36),
                  const SizedBox(height: 12),
                  Text('SENSORS ERROR', style: AppTypography.alertTitle),
                  const SizedBox(height: 8),
                  Text(message, style: AppTypography.alertSubtitle),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => widget.viewModel.loadSensors(),
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            ),
          SensorsLoaded(:final data) => LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= ScreenBreakpoints.tabletMax;

                return RefreshIndicator(
                  color: AppColors.gold,
                  backgroundColor: AppColors.surface,
                  onRefresh: () => widget.viewModel.refresh(),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppPageHeader(pageTitle: 'Sensors'),
                            const SizedBox(height: 14),
                            _buildSessionBanner(data.session),
                            const SizedBox(height: 16),
                            if (isDesktop)
                              _buildDesktopLayout(data)
                            else
                              _buildMobileLayout(data),
                          ],
                        ),
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

  Widget _buildSessionBanner(RoverSessionStatus session) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.smart_toy_outlined, color: AppColors.gold, size: 20),
                    const SizedBox(width: 8),
                    Text(session.roverId, style: AppTypography.cardTitle),
                  ],
                ),
              ),
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
          const SizedBox(height: 6),
          Text(session.sessionDescription, style: AppTypography.caption),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(SensorsTelemetryBundle data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SensorMetricsSummaryCard(summary: data.summary),
        const SizedBox(height: 20),
        _buildSectionHeader('Distance', '02 SENSORS'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: SensorsDistanceCard(sensor: data.distanceSensors[0])),
            const SizedBox(width: 12),
            Expanded(child: SensorsDistanceCard(sensor: data.distanceSensors[1])),
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('Motion', '02 SENSORS'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: SensorsMotionCard(sensor: data.motionSensors[0])),
            const SizedBox(width: 12),
            Expanded(child: SensorsMotionCard(sensor: data.motionSensors[1])),
          ],
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('Sensor History (Demo)', 'TIMESTAMPED'),
        const SizedBox(height: 10),
        CustomTelemetryChart(
          series1: data.historyPoints.map((p) => p.d1Distance).toList(),
          series2: data.historyPoints.map((p) => p.d2Distance).toList(),
          label1: 'HC-SR04 / 01',
          label2: 'HC-SR04 / 02',
          height: 130,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('Sensor system health', 'UNVERIFIED'),
        const SizedBox(height: 10),
        SensorSystemHealthCard(
          streamStatus: data.streamStatus,
          lastSampleTime: data.lastSampleTime,
        ),
        const SizedBox(height: 20),
        _buildSectionHeader('Recent activity', 'SYSTEM / DEMO'),
        const SizedBox(height: 10),
        const SensorsRecentActivityCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDesktopLayout(SensorsTelemetryBundle data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SensorMetricsSummaryCard(summary: data.summary),
              const SizedBox(height: 20),
              _buildSectionHeader('Distance', '02 SENSORS'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: SensorsDistanceCard(sensor: data.distanceSensors[0])),
                  const SizedBox(width: 12),
                  Expanded(child: SensorsDistanceCard(sensor: data.distanceSensors[1])),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('Motion', '02 SENSORS'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: SensorsMotionCard(sensor: data.motionSensors[0])),
                  const SizedBox(width: 12),
                  Expanded(child: SensorsMotionCard(sensor: data.motionSensors[1])),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Sensor History (Demo)', 'TIMESTAMPED'),
              const SizedBox(height: 10),
              CustomTelemetryChart(
                series1: data.historyPoints.map((p) => p.d1Distance).toList(),
                series2: data.historyPoints.map((p) => p.d2Distance).toList(),
                label1: 'HC-SR04 / 01',
                label2: 'HC-SR04 / 02',
                height: 160,
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('Sensor system health', 'UNVERIFIED'),
              const SizedBox(height: 10),
              SensorSystemHealthCard(
                streamStatus: data.streamStatus,
                lastSampleTime: data.lastSampleTime,
              ),
              const SizedBox(height: 20),
              _buildSectionHeader('Recent activity', 'SYSTEM / DEMO'),
              const SizedBox(height: 10),
              const SensorsRecentActivityCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String countLabel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTypography.sectionHeader,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          countLabel,
          style: AppTypography.fieldLabel.copyWith(
            color: AppColors.secondaryText,
            fontSize: 10,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
