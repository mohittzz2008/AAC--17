import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/responsive/screen_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../desktop/desktop_expanded_layout.dart';
import '../desktop/desktop_normal_layout.dart';
import '../mobile/mobile_landscape_expanded_layout.dart';
import '../mobile/mobile_portrait_layout.dart';
import '../state/rover_operation_state.dart';
import '../tablet/tablet_operation_layout.dart';
import '../viewmodels/rover_operation_viewmodel.dart';

/// The dedicated Rover Operation screen providing remote rover directional control,
/// live camera viewing, emergency stop priority, keyboard W/A/S/D and touch interaction,
/// and responsive layout adaptation across Desktop, Tablet, and Mobile.
class RoverOperationScreen extends StatefulWidget {
  final RoverOperationViewModel viewModel;

  const RoverOperationScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<RoverOperationScreen> createState() => _RoverOperationScreenState();
}

class _RoverOperationScreenState extends State<RoverOperationScreen>
    with WidgetsBindingObserver {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    widget.viewModel.initialize();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.viewModel.handleFocusLost();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      widget.viewModel.handleAppPaused();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    widget.viewModel.handleFocusLost();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    // 1. Never intercept browser zoom shortcuts (Ctrl+Plus, Ctrl+Minus, Ctrl+0, Meta/Cmd)
    if (HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed) {
      return;
    }

    // 2. Protect text input: If an EditableText is focused, do not intercept WASD, arrows, or space
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus != null &&
        primaryFocus.context != null &&
        primaryFocus.context!.findAncestorWidgetOfExactType<EditableText>() != null) {
      return;
    }

    final logicalKey = event.logicalKey;
    final keyLabel = logicalKey.keyLabel;

    if (event is KeyDownEvent) {
      if (logicalKey == LogicalKeyboardKey.space) {
        widget.viewModel.handleKeyDown(' ');
      } else if (logicalKey == LogicalKeyboardKey.arrowUp) {
        widget.viewModel.handleKeyDown('ARROW UP');
      } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
        widget.viewModel.handleKeyDown('ARROW DOWN');
      } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
        widget.viewModel.handleKeyDown('ARROW LEFT');
      } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
        widget.viewModel.handleKeyDown('ARROW RIGHT');
      } else if (keyLabel.isNotEmpty) {
        widget.viewModel.handleKeyDown(keyLabel);
      }
    } else if (event is KeyUpEvent) {
      if (logicalKey == LogicalKeyboardKey.space) {
        widget.viewModel.handleKeyUp(' ');
      } else if (logicalKey == LogicalKeyboardKey.arrowUp) {
        widget.viewModel.handleKeyUp('ARROW UP');
      } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
        widget.viewModel.handleKeyUp('ARROW DOWN');
      } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
        widget.viewModel.handleKeyUp('ARROW LEFT');
      } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
        widget.viewModel.handleKeyUp('ARROW RIGHT');
      } else if (keyLabel.isNotEmpty) {
        widget.viewModel.handleKeyUp(keyLabel);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onTap: () {
          if (!_focusNode.hasFocus) {
            _focusNode.requestFocus();
          }
        },
        behavior: HitTestBehavior.translucent,
        child: AnimatedBuilder(
          animation: widget.viewModel,
          builder: (context, _) {
            final state = widget.viewModel.state;

            return switch (state) {
              RoverOperationInitial() ||
              RoverOperationLoading() =>
                const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              RoverOperationError(:final message) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.burgundy, size: 48),
                        const SizedBox(height: 14),
                        Text(
                          'Operation Subsystem Error',
                          style: AppTypography.cardTitle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: AppTypography.subtitle,
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: () => widget.viewModel.initialize(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry Connection'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              RoverOperationLoaded() => LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = constraints.maxHeight;
                    final isLandscape = width > height;

                    // 1. Mobile Landscape (Expanded)
                    if (width < ScreenBreakpoints.desktop &&
                        isLandscape &&
                        (state.isCameraExpanded || width < 900)) {
                      return MobileLandscapeExpandedLayout(
                        state: state,
                        viewModel: widget.viewModel,
                      );
                    }

                    // 2. Mobile Portrait Normal
                    if (width < ScreenBreakpoints.tablet) {
                      return MobilePortraitLayout(
                        state: state,
                        viewModel: widget.viewModel,
                      );
                    }

                    // 3. Tablet Adaptive
                    if (width < ScreenBreakpoints.desktop) {
                      return TabletOperationLayout(
                        state: state,
                        viewModel: widget.viewModel,
                        isLandscape: isLandscape,
                      );
                    }

                    // 4. Desktop Modes
                    if (state.isCameraExpanded) {
                      return DesktopExpandedLayout(
                        state: state,
                        viewModel: widget.viewModel,
                      );
                    }

                    return DesktopNormalLayout(
                      state: state,
                      viewModel: widget.viewModel,
                    );
                  },
                ),
            };
          },
        ),
      ),
    );
  }
}

