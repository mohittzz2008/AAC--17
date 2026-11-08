import 'package:flutter/material.dart';
import '../../../../core/responsive/screen_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/domain/enums/subsystem_health_status.dart';
import '../../../../shared/presentation/widgets/app_page_header.dart';
import '../../domain/models/diagnostic_issue.dart';
import '../../domain/models/diagnostics_bundle.dart';
import '../state/diagnostics_state.dart';
import '../viewmodels/diagnostics_viewmodel.dart';

class DiagnosticsScreen extends StatefulWidget {
  final DiagnosticsViewModel viewModel;
  final VoidCallback onBack;
  final VoidCallback? onOpenLogs;

  const DiagnosticsScreen({
    super.key,
    required this.viewModel,
    required this.onBack,
    this.onOpenLogs,
  });

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.state is DiagnosticsInitial) {
        widget.viewModel.loadDiagnostics();
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
          DiagnosticsInitial() || DiagnosticsLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2.5),
            ),
          DiagnosticsError(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.burgundy, size: 36),
                  const SizedBox(height: 12),
                  Text('DIAGNOSTICS ERROR', style: AppTypography.alertTitle),
                  const SizedBox(height: 8),
                  Text(message, style: AppTypography.alertSubtitle),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => widget.viewModel.loadDiagnostics(),
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            ),
          DiagnosticsLoaded(:final data, :final isRunningCheck) => LayoutBuilder(
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
                          AppPageHeader(
                            pageTitle: 'Diagnostics & Health',
                            onBack: widget.onBack,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'System Check, Fault Analysis & Hardware State',
                            style: AppTypography.subtitle,
                          ),
                          const SizedBox(height: 16),
                          if (isDesktop)
                            _buildDesktopLayout(data, isRunningCheck)
                          else
                            _buildMobileLayout(data, isRunningCheck),
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

  Widget _buildOverallHealthBanner(DiagnosticsBundle data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.burgundy,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Health',
                style: AppTypography.fieldLabel.copyWith(color: AppColors.secondaryText),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.raisedSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'DEMO MODE',
                  style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.gold, size: 24),
              const SizedBox(width: 8),
              Text(
                data.overallHealth.displayLabel,
                style: AppTypography.alertTitle.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(data.statusSubtitle, style: AppTypography.alertSubtitle.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSubsystemHealthCard(DiagnosticsBundle data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Subsystem Health', style: AppTypography.sectionHeader),
          const SizedBox(height: 14),
          _buildSubsystemRow('Controller', data.controllerHealth),
          const Divider(color: AppColors.raisedSurface, height: 16),
          _buildSubsystemRow('Camera', data.cameraHealth),
          const Divider(color: AppColors.raisedSurface, height: 16),
          _buildSubsystemRow('Sensors', data.sensorHealth),
          const Divider(color: AppColors.raisedSurface, height: 16),
          _buildSubsystemRow('Communication', data.communicationHealth),
          const Divider(color: AppColors.raisedSurface, height: 16),
          _buildSubsystemRow('Power', data.powerHealth),
        ],
      ),
    );
  }

  Widget _buildSubsystemRow(String name, SubsystemHealthStatus status) {
    Color badgeBg;
    Color badgeFg;

    switch (status) {
      case SubsystemHealthStatus.operational:
        badgeBg = AppColors.raisedSurface;
        badgeFg = AppColors.gold;
        break;
      case SubsystemHealthStatus.warning:
        badgeBg = AppColors.raisedSurface;
        badgeFg = AppColors.secondaryText;
        break;
      case SubsystemHealthStatus.error:
        badgeBg = AppColors.burgundy;
        badgeFg = AppColors.white;
        break;
      case SubsystemHealthStatus.unknown:
      case SubsystemHealthStatus.unavailable:
        badgeBg = AppColors.raisedSurface;
        badgeFg = AppColors.secondaryText;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(name, style: AppTypography.cardTitle.copyWith(fontSize: 13)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status.displayLabel,
            style: TextStyle(color: badgeFg, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildRunDiagnosticsButton(bool isRunning) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isRunning ? null : () => widget.viewModel.runDiagnostics(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: isRunning
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
              )
            : const Icon(Icons.play_arrow_rounded, size: 20),
        label: Text(
          isRunning ? 'RUNNING SELF-TEST...' : 'RUN DIAGNOSTICS',
          style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8),
        ),
      ),
    );
  }

  Widget _buildActiveIssuesSection(DiagnosticsBundle data) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Text('Active Issues (${data.activeIssues.length})', style: AppTypography.sectionHeader),
              if (widget.onOpenLogs != null)
                TextButton(
                  onPressed: widget.onOpenLogs,
                  child: const Text('View Logs', style: TextStyle(color: AppColors.gold, fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...data.activeIssues.map((issue) => _buildIssueCard(issue)),
        ],
      ),
    );
  }

  Widget _buildIssueCard(DiagnosticIssue issue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: AppColors.burgundy, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(issue.title, style: AppTypography.cardTitle.copyWith(fontSize: 13)),
                const SizedBox(height: 4),
                Text(issue.description, style: AppTypography.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(DiagnosticsBundle data, bool isRunning) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOverallHealthBanner(data),
        const SizedBox(height: 16),
        _buildSubsystemHealthCard(data),
        const SizedBox(height: 16),
        _buildRunDiagnosticsButton(isRunning),
        const SizedBox(height: 20),
        _buildActiveIssuesSection(data),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDesktopLayout(DiagnosticsBundle data, bool isRunning) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverallHealthBanner(data),
              const SizedBox(height: 16),
              _buildSubsystemHealthCard(data),
              const SizedBox(height: 16),
              _buildRunDiagnosticsButton(isRunning),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActiveIssuesSection(data),
            ],
          ),
        ),
      ],
    );
  }
}
