import 'package:flutter/material.dart';
import '../../../../core/responsive/screen_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/shell/system_sub_destination.dart';
import '../../../../shared/presentation/widgets/app_page_header.dart';
import '../../../dashboard/presentation/widgets/rover_status_alert_banner.dart';
import '../../domain/models/system_telemetry_bundle.dart';
import '../state/system_state.dart';
import '../viewmodels/system_viewmodel.dart';
import '../widgets/system_controllers_card.dart';
import '../widgets/system_drive_hardware_card.dart';
import '../widgets/system_management_shortcuts.dart';
import '../widgets/system_power_card.dart';

class SystemScreen extends StatefulWidget {
  final SystemViewModel viewModel;
  final ValueChanged<SystemSubDestination> onSelectSubDestination;

  const SystemScreen({
    super.key,
    required this.viewModel,
    required this.onSelectSubDestination,
  });

  @override
  State<SystemScreen> createState() => _SystemScreenState();
}

class _SystemScreenState extends State<SystemScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.state is SystemInitial) {
        widget.viewModel.loadSystem();
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
          SystemInitial() || SystemLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2.5),
            ),
          SystemError(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.burgundy, size: 36),
                  const SizedBox(height: 12),
                  Text('SYSTEM ERROR', style: AppTypography.alertTitle),
                  const SizedBox(height: 8),
                  Text(message, style: AppTypography.alertSubtitle),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => widget.viewModel.loadSystem(),
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            ),
          SystemLoaded(:final data) => LayoutBuilder(
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
                            const AppPageHeader(pageTitle: 'System'),
                            const SizedBox(height: 14),
                            RoverStatusAlertBanner(session: data.session),
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

  Widget _buildMobileLayout(SystemTelemetryBundle data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Controllers', 'HARDWARE INVENTORY'),
        const SizedBox(height: 10),
        const SystemControllersCard(),
        const SizedBox(height: 20),

        _buildSectionHeader('Power', 'NOT VERIFIED'),
        const SizedBox(height: 10),
        SystemPowerCard(power: data.power),
        const SizedBox(height: 20),

        _buildSectionHeader('Drive hardware', 'NOT VERIFIED'),
        const SizedBox(height: 10),
        const SystemDriveHardwareCard(),
        const SizedBox(height: 20),

        _buildSectionHeader('Management', '5 MODULES'),
        const SizedBox(height: 10),
        SystemManagementShortcuts(
          onSelectDestination: widget.onSelectSubDestination,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDesktopLayout(SystemTelemetryBundle data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Controllers', 'HARDWARE INVENTORY'),
              const SizedBox(height: 10),
              const SystemControllersCard(),
              const SizedBox(height: 20),
              _buildSectionHeader('Power', 'NOT VERIFIED'),
              const SizedBox(height: 10),
              SystemPowerCard(power: data.power),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Drive hardware', 'NOT VERIFIED'),
              const SizedBox(height: 10),
              const SystemDriveHardwareCard(),
              const SizedBox(height: 20),
              _buildSectionHeader('Management', '5 MODULES'),
              const SizedBox(height: 10),
              SystemManagementShortcuts(
                onSelectDestination: widget.onSelectSubDestination,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String tag) {
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
          tag,
          style: AppTypography.fieldLabel.copyWith(
            color: AppColors.secondaryText,
            fontSize: 10,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
