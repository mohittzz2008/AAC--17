import 'package:flutter/material.dart';
import '../../../../core/responsive/screen_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/app_page_header.dart';
import '../../domain/models/connection_history_entry.dart';
import '../../domain/models/discovered_device.dart';
import '../state/device_connection_state.dart';
import '../viewmodels/device_connection_viewmodel.dart';

class DeviceConnectionScreen extends StatefulWidget {
  final DeviceConnectionViewModel viewModel;
  final VoidCallback onBack;

  const DeviceConnectionScreen({
    super.key,
    required this.viewModel,
    required this.onBack,
  });

  @override
  State<DeviceConnectionScreen> createState() => _DeviceConnectionScreenState();
}

class _DeviceConnectionScreenState extends State<DeviceConnectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.state is DeviceConnectionInitial) {
        widget.viewModel.initialize();
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
          DeviceConnectionInitial() || DeviceConnectionDiscovering() => const Center(
              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2.5),
            ),
          DeviceConnectionLoaded() => LayoutBuilder(
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
                            pageTitle: 'Device Connection',
                            onBack: widget.onBack,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pairing, Discovery & Network Setup',
                            style: AppTypography.subtitle,
                          ),
                          const SizedBox(height: 16),
                          if (state.feedbackMessage != null) ...[
                            _buildFeedbackBanner(state.feedbackMessage!),
                            const SizedBox(height: 16),
                          ],
                          if (isDesktop)
                            _buildDesktopLayout(state)
                          else
                            _buildMobileLayout(state),
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

  Widget _buildFeedbackBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.raisedSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(color: AppColors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(DeviceConnectionLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildConnectionStatusCard(state),
        const SizedBox(height: 16),
        _buildConnectionMethodCard(),
        const SizedBox(height: 16),
        _buildDiscoverySection(state),
        const SizedBox(height: 20),
        _buildHistorySection(state),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildDesktopLayout(DeviceConnectionLoaded state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Status, Methods, Discovery
        Expanded(
          flex: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConnectionStatusCard(state),
              const SizedBox(height: 16),
              _buildConnectionMethodCard(),
              const SizedBox(height: 16),
              _buildDiscoverySection(state),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Right Column: Available Devices & History
        Expanded(
          flex: 11,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHistorySection(state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionStatusCard(DeviceConnectionLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.burgundy,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.link_off_rounded, color: AppColors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection Status',
                  style: AppTypography.fieldLabel,
                ),
                const SizedBox(height: 4),
                Text(
                  state.status.displayLabel,
                  style: AppTypography.cardTitle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  'No physical rover device connected',
                  style: AppTypography.caption.copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionMethodCard() {
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
          Text('Connection Method', style: AppTypography.sectionHeader),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMethodChip(Icons.wifi, 'Wi-Fi (Planned)', true),
              _buildMethodChip(Icons.usb, 'USB Serial (Planned)', false),
              _buildMethodChip(Icons.bluetooth, 'Bluetooth (Planned)', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodChip(IconData icon, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.raisedSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? AppColors.gold : AppColors.raisedSurface,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? AppColors.gold : AppColors.secondaryText),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.white : AppColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverySection(DeviceConnectionLoaded state) {
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
              Text('Device Discovery', style: AppTypography.sectionHeader),
              ElevatedButton.icon(
                onPressed: () => widget.viewModel.startDiscovery(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.search, size: 16),
                label: const Text('DISCOVER', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text('Available Devices (${state.availableDevices.length})', style: AppTypography.fieldLabel),
          const SizedBox(height: 8),
          ...state.availableDevices.map((device) => _buildDeviceItem(device, state.isConnecting)),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(DiscoveredDevice device, bool isConnecting) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.smart_toy_outlined, color: AppColors.gold, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name, style: AppTypography.cardTitle.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(device.hardwareType, style: AppTypography.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: isConnecting ? null : () => widget.viewModel.connectToDevice(device.deviceId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.raisedSurface,
              foregroundColor: AppColors.white,
            ),
            child: isConnecting
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                  )
                : const Text('CONNECT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(DeviceConnectionLoaded state) {
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
          Text('Connection History', style: AppTypography.sectionHeader),
          const SizedBox(height: 12),
          ...state.history.map((entry) => _buildHistoryRow(entry)),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(ConnectionHistoryEntry entry) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: entry.isSuccess ? AppColors.gold : AppColors.burgundy,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            entry.timestamp,
            style: AppTypography.telemetryBase.copyWith(color: AppColors.secondaryText, fontSize: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.event,
              style: AppTypography.interfaceBase.copyWith(color: AppColors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
