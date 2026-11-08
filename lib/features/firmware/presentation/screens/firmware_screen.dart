import 'package:flutter/material.dart';
import '../../../../core/responsive/screen_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/app_page_header.dart';
import '../../domain/models/device_firmware_info.dart';
import '../../domain/models/firmware_bundle.dart';
import '../state/firmware_state.dart';
import '../viewmodels/firmware_viewmodel.dart';

class FirmwareScreen extends StatefulWidget {
  final FirmwareViewModel viewModel;
  final VoidCallback onBack;

  const FirmwareScreen({
    super.key,
    required this.viewModel,
    required this.onBack,
  });

  @override
  State<FirmwareScreen> createState() => _FirmwareScreenState();
}

class _FirmwareScreenState extends State<FirmwareScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.state is FirmwareInitial) {
        widget.viewModel.loadFirmwareInfo();
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
          FirmwareInitial() || FirmwareLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2.5),
            ),
          FirmwareError(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.burgundy, size: 36),
                  const SizedBox(height: 12),
                  Text('FIRMWARE ERROR', style: AppTypography.alertTitle),
                  const SizedBox(height: 8),
                  Text(message, style: AppTypography.alertSubtitle),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => widget.viewModel.loadFirmwareInfo(),
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            ),
          FirmwareLoaded(:final bundle, :final isCheckingUpdates, :final feedbackMessage) => LayoutBuilder(
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
                            pageTitle: 'Firmware & Maintenance',
                            onBack: widget.onBack,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Controller Firmware, OTA Version Check & Service Records',
                            style: AppTypography.subtitle,
                          ),
                          const SizedBox(height: 16),
                          if (feedbackMessage != null) ...[
                            _buildFeedbackBanner(feedbackMessage),
                            const SizedBox(height: 14),
                          ],
                          if (isDesktop)
                            _buildDesktopLayout(bundle, isCheckingUpdates)
                          else
                            _buildMobileLayout(bundle, isCheckingUpdates),
                          const SizedBox(height: 24),
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

  Widget _buildFeedbackBanner(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(color: AppColors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(FirmwareBundle bundle, bool isChecking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInventoryCard(bundle),
        const SizedBox(height: 16),
        _buildUpdateCard(bundle, isChecking),
        const SizedBox(height: 16),
        _buildMaintenanceCard(bundle),
      ],
    );
  }

  Widget _buildDesktopLayout(FirmwareBundle bundle, bool isChecking) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 13,
          child: _buildInventoryCard(bundle),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUpdateCard(bundle, isChecking),
              const SizedBox(height: 16),
              _buildMaintenanceCard(bundle),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard(FirmwareBundle bundle) {
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
          Text('Device Firmware Inventory', style: AppTypography.sectionHeader),
          const SizedBox(height: 14),
          ...bundle.devices.map((device) => _buildDeviceRow(device)),
        ],
      ),
    );
  }

  Widget _buildDeviceRow(DeviceFirmwareInfo device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  device.deviceName,
                  style: AppTypography.cardTitle.copyWith(fontSize: 13),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.raisedSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'NOT VERIFIED',
                  style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(device.role, style: AppTypography.caption.copyWith(color: AppColors.secondaryText, fontSize: 11)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Version: ${device.currentVersion}',
                style: AppTypography.telemetryBase.copyWith(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              Text(
                'Build: ${device.buildDate}',
                style: AppTypography.telemetryBase.copyWith(color: AppColors.secondaryText, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(FirmwareBundle bundle, bool isChecking) {
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
          Text('Firmware Update', style: AppTypography.sectionHeader),
          const SizedBox(height: 12),
          Text(bundle.updateStatusText, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            bundle.updateDisclaimer,
            style: AppTypography.caption.copyWith(color: AppColors.secondaryText, fontSize: 11),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: isChecking ? null : () => widget.viewModel.checkForUpdates(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.raisedSurface,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: isChecking
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                    )
                  : const Icon(Icons.system_update_rounded, size: 18, color: AppColors.gold),
              label: const Text('CHECK FOR UPDATES', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCard(FirmwareBundle bundle) {
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
          Text('Maintenance History', style: AppTypography.sectionHeader),
          const SizedBox(height: 12),
          Text(
            'No maintenance records available (Demo)',
            style: AppTypography.caption.copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 4),
          Text(
            'Routine inspection logs will be cataloged when hardware is commissioned.',
            style: AppTypography.caption.copyWith(color: AppColors.secondaryText, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
