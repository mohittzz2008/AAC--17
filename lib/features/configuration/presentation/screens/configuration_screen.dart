import 'package:flutter/material.dart';
import '../../../../core/responsive/screen_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/presentation/widgets/app_page_header.dart';
import '../state/configuration_state.dart';
import '../viewmodels/configuration_viewmodel.dart';

class ConfigurationScreen extends StatefulWidget {
  final ConfigurationViewModel viewModel;
  final VoidCallback onBack;

  const ConfigurationScreen({
    super.key,
    required this.viewModel,
    required this.onBack,
  });

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  int _selectedTab = 0; // 0: General, 1: Network, 2: Sensors, 3: Camera
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ssidController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.state is ConfigurationInitial) {
        widget.viewModel.loadConfiguration();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ssidController.dispose();
    super.dispose();
  }

  void _syncControllers(ConfigurationLoaded state) {
    if (_nameController.text != state.currentConfig.deviceName) {
      _nameController.text = state.currentConfig.deviceName;
    }
    if (_ssidController.text != state.currentConfig.ssid) {
      _ssidController.text = state.currentConfig.ssid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final state = widget.viewModel.state;

        return switch (state) {
          ConfigurationInitial() || ConfigurationLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2.5),
            ),
          ConfigurationError(:final message) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.burgundy, size: 36),
                  const SizedBox(height: 12),
                  Text('CONFIGURATION ERROR', style: AppTypography.alertTitle),
                  const SizedBox(height: 8),
                  Text(message, style: AppTypography.alertSubtitle),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => widget.viewModel.loadConfiguration(),
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            ),
          ConfigurationLoaded() => _buildLoadedView(state),
        };
      },
    );
  }

  Widget _buildLoadedView(ConfigurationLoaded state) {
    _syncControllers(state);

    return LayoutBuilder(
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
                    pageTitle: 'Configuration & Calibration',
                    onBack: widget.onBack,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Device Settings, Sensor Tuning & Polling Options',
                    style: AppTypography.subtitle,
                  ),
                  const SizedBox(height: 16),
                  if (state.hasUnsavedChanges) ...[
                    _buildUnsavedChangesBanner(),
                    const SizedBox(height: 14),
                  ],
                  if (state.feedbackMessage != null) ...[
                    _buildFeedbackBanner(state.feedbackMessage!),
                    const SizedBox(height: 14),
                  ],
                  _buildTabs(),
                  const SizedBox(height: 16),
                  if (isDesktop)
                    _buildDesktopLayout(state)
                  else
                    _buildMobileLayout(state),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnsavedChangesBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold, width: 1),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.gold, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'You have unsaved configuration changes.',
              style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.raisedSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.raisedSurface, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.gold, size: 18),
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

  Widget _buildTabs() {
    const tabs = ['General', 'Network', 'Sensors', 'Camera'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.gold : AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.gold : AppColors.raisedSurface,
                    width: 1,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: isSelected ? AppColors.black : AppColors.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMobileLayout(ConfigurationLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildActiveTabContent(state),
        const SizedBox(height: 20),
        _buildActionButtons(state),
      ],
    );
  }

  Widget _buildDesktopLayout(ConfigurationLoaded state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 14,
          child: _buildActiveTabContent(state),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCalibrationCard(),
              const SizedBox(height: 16),
              _buildActionButtons(state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTabContent(ConfigurationLoaded state) {
    switch (_selectedTab) {
      case 0:
        return _buildGeneralSettingsCard(state);
      case 1:
        return _buildNetworkSettingsCard(state);
      case 2:
        return _buildSensorSettingsCard(state);
      case 3:
        return _buildCameraSettingsCard(state);
      default:
        return _buildGeneralSettingsCard(state);
    }
  }

  Widget _buildGeneralSettingsCard(ConfigurationLoaded state) {
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
          Text('General Settings', style: AppTypography.sectionHeader),
          const SizedBox(height: 16),
          _buildTextField('Device Name', _nameController, (val) {
            widget.viewModel.updateDeviceName(val);
          }),
          const SizedBox(height: 14),
          _buildReadOnlyRow('Operating Mode', state.currentConfig.operatingMode),
          const Divider(color: AppColors.raisedSurface, height: 24),
          _buildDropdownRow(
            'Telemetry Polling Interval',
            '${state.currentConfig.telemetryIntervalSeconds}s',
            ['1s', '3s', '5s', '10s'],
            (val) {
              if (val != null) {
                final sec = int.tryParse(val.replaceAll('s', '')) ?? 5;
                widget.viewModel.updateInterval(sec);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkSettingsCard(ConfigurationLoaded state) {
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
          Text('Network Configuration', style: AppTypography.sectionHeader),
          const SizedBox(height: 16),
          _buildReadOnlyRow('Network Mode', state.currentConfig.networkMode),
          const SizedBox(height: 14),
          _buildTextField('SSID / Access Point', _ssidController, (val) {
            widget.viewModel.updateSsid(val);
          }),
          const SizedBox(height: 14),
          _buildReadOnlyRow('Security Key', state.currentConfig.maskedPassword),
        ],
      ),
    );
  }

  Widget _buildSensorSettingsCard(ConfigurationLoaded state) {
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
          Text('Sensor Configuration', style: AppTypography.sectionHeader),
          const SizedBox(height: 16),
          _buildDropdownRow(
            'Distance Units',
            state.currentConfig.distanceUnit,
            ['cm', 'inches'],
            (val) {
              if (val != null) widget.viewModel.updateDistanceUnit(val);
            },
          ),
          const Divider(color: AppColors.raisedSurface, height: 24),
          _buildReadOnlyRow('HC-SR04 Trigger / Echo Pins', 'Unverified / Hardware pending'),
          const Divider(color: AppColors.raisedSurface, height: 24),
          _buildReadOnlyRow('RCWL-0516 Sensitivity', 'Hardware default (fixed)'),
        ],
      ),
    );
  }

  Widget _buildCameraSettingsCard(ConfigurationLoaded state) {
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
          Text('Camera Configuration', style: AppTypography.sectionHeader),
          const SizedBox(height: 16),
          _buildReadOnlyRow('Module', 'ESP32-CAM (OV2640)'),
          const Divider(color: AppColors.raisedSurface, height: 24),
          _buildReadOnlyRow('Target Resolution', state.currentConfig.cameraResolution),
          const Divider(color: AppColors.raisedSurface, height: 24),
          _buildReadOnlyRow('Video Codec', 'MJPEG / Frame-by-Frame (Planned)'),
        ],
      ),
    );
  }

  Widget _buildCalibrationCard() {
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
          Text('Calibration Records', style: AppTypography.sectionHeader),
          const SizedBox(height: 12),
          Text(
            'No physical sensor calibration records recorded.',
            style: AppTypography.caption.copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 6),
          Text(
            'Calibration requires verified hardware connection to rover sensors.',
            style: AppTypography.caption.copyWith(color: AppColors.secondaryText, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ConfigurationLoaded state) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: (state.hasUnsavedChanges && !state.isSaving)
                ? () => widget.viewModel.saveChanges()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: state.isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
                  )
                : const Icon(Icons.save_rounded, size: 20),
            label: const Text('SAVE CHANGES', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.8)),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton(
            onPressed: state.isSaving ? null : () => _confirmReset(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.white,
              side: const BorderSide(color: AppColors.raisedSurface, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('RESET TO DEFAULTS', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.raisedSurface, width: 1),
          ),
          title: const Text('Reset Configuration?', style: TextStyle(color: AppColors.white)),
          content: const Text(
            'This will revert all options to the default demo settings.',
            style: TextStyle(color: AppColors.secondaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL', style: TextStyle(color: AppColors.secondaryText)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.viewModel.resetToDefaults();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.burgundy),
              child: const Text('RESET'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.fieldLabel),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.raisedSurface),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.raisedSurface),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.secondaryText)),
        Text(
          value,
          style: AppTypography.interfaceBase.copyWith(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDropdownRow(String label, String currentVal, List<String> items, ValueChanged<String?> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.secondaryText)),
        DropdownButton<String>(
          value: items.contains(currentVal) ? currentVal : items.first,
          dropdownColor: AppColors.surface,
          underline: const SizedBox(),
          style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 12),
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

