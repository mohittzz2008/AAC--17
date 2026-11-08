import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'application_zoom_controller.dart';
import 'web_zoom_bridge.dart';

class ZoomInIntent extends Intent {
  const ZoomInIntent();
}

class ZoomOutIntent extends Intent {
  const ZoomOutIntent();
}

class ZoomResetIntent extends Intent {
  const ZoomResetIntent();
}

/// Wraps the application workspace with synchronized keyboard, mouse-wheel,
/// and touchpad zoom capabilities, anchored focal-point matrix scaling,
/// and an industrial zoom HUD control pill.
class ApplicationZoomWrapper extends StatefulWidget {
  final Widget child;
  final ApplicationZoomController? controller;

  const ApplicationZoomWrapper({
    super.key,
    required this.child,
    this.controller,
  });

  @override
  State<ApplicationZoomWrapper> createState() => _ApplicationZoomWrapperState();
}

class _ApplicationZoomWrapperState extends State<ApplicationZoomWrapper>
    with SingleTickerProviderStateMixin {
  late final ApplicationZoomController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ApplicationZoomController.instance;
    _controller.initialize(this);
    registerWebZoomBridge(_controller);
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final isCtrl = HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isMetaPressed;
      if (isCtrl) {
        _controller.zoomByWheel(event.position, event.scrollDelta.dy);
      }
    }
  }

  void _handleScaleStart(ScaleStartDetails details) {}

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.scale != 1.0) {
      final effectiveFactor = details.scale;
      _controller.zoomByGesture(details.focalPoint, effectiveFactor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = <ShortcutActivator, Intent>{
      // Ctrl + '+' / '='
      const SingleActivator(LogicalKeyboardKey.equal, control: true): const ZoomInIntent(),
      const SingleActivator(LogicalKeyboardKey.add, control: true): const ZoomInIntent(),
      const SingleActivator(LogicalKeyboardKey.numpadAdd, control: true): const ZoomInIntent(),
      // Meta (Mac) + '+'
      const SingleActivator(LogicalKeyboardKey.equal, meta: true): const ZoomInIntent(),
      const SingleActivator(LogicalKeyboardKey.add, meta: true): const ZoomInIntent(),

      // Ctrl + '-'
      const SingleActivator(LogicalKeyboardKey.minus, control: true): const ZoomOutIntent(),
      const SingleActivator(LogicalKeyboardKey.numpadSubtract, control: true): const ZoomOutIntent(),
      // Meta (Mac) + '-'
      const SingleActivator(LogicalKeyboardKey.minus, meta: true): const ZoomOutIntent(),

      // Ctrl + '0'
      const SingleActivator(LogicalKeyboardKey.digit0, control: true): const ZoomResetIntent(),
      const SingleActivator(LogicalKeyboardKey.numpad0, control: true): const ZoomResetIntent(),
      // Meta (Mac) + '0'
      const SingleActivator(LogicalKeyboardKey.digit0, meta: true): const ZoomResetIntent(),
    };

    final actions = <Type, Action<Intent>>{
      ZoomInIntent: CallbackAction<ZoomInIntent>(
        onInvoke: (_) {
          final renderBox = context.findRenderObject() as RenderBox?;
          final center = renderBox != null
              ? renderBox.size.center(Offset.zero)
              : Offset.zero;
          _controller.zoomIn(focalPoint: center);
          return null;
        },
      ),
      ZoomOutIntent: CallbackAction<ZoomOutIntent>(
        onInvoke: (_) {
          final renderBox = context.findRenderObject() as RenderBox?;
          final center = renderBox != null
              ? renderBox.size.center(Offset.zero)
              : Offset.zero;
          _controller.zoomOut(focalPoint: center);
          return null;
        },
      ),
      ZoomResetIntent: CallbackAction<ZoomResetIntent>(
        onInvoke: (_) {
          _controller.resetZoom();
          return null;
        },
      ),
    };

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: actions,
        child: Focus(
          autofocus: false,
          canRequestFocus: false,
          child: Listener(
            onPointerSignal: _handlePointerSignal,
            child: GestureDetector(
              onScaleStart: _handleScaleStart,
              onScaleUpdate: _handleScaleUpdate,
              behavior: HitTestBehavior.translucent,
              child: Stack(
                children: [
                  // Scaled Application Workspace
                  Positioned.fill(
                    child: ClipRect(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform(
                            transform: _controller.transformMatrix,
                            alignment: Alignment.topLeft,
                            child: child,
                          );
                        },
                        child: widget.child,
                      ),
                    ),
                  ),

                  // Floating Zoom HUD Pill
                  Positioned(
                    right: 18,
                    bottom: 18,
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _isHovered = true),
                      onExit: (_) => setState(() => _isHovered = false),
                      child: AnimatedOpacity(
                        opacity: (_isHovered || !_controller.isDefault) ? 1.0 : 0.82,
                        duration: const Duration(milliseconds: 200),
                        child: _buildZoomHud(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZoomHud() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pct = _controller.scalePercentage;
        final isDefault = _controller.isDefault;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDefault ? AppColors.raisedSurface : AppColors.gold,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
              if (!isDefault)
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.25),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Zoom Out Button
              IconButton(
                icon: const Icon(Icons.remove, size: 16),
                color: AppColors.white,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                splashRadius: 16,
                tooltip: 'Zoom Out (Ctrl + -)',
                onPressed: () {
                  final renderBox = context.findRenderObject() as RenderBox?;
                  final center = renderBox?.size.center(Offset.zero);
                  _controller.zoomOut(focalPoint: center);
                },
              ),

              // Zoom Percentage Label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '$pct%',
                  style: AppTypography.telemetryBase.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDefault ? AppColors.white : AppColors.gold,
                  ),
                ),
              ),

              // Zoom In Button
              IconButton(
                icon: const Icon(Icons.add, size: 16),
                color: AppColors.white,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                splashRadius: 16,
                tooltip: 'Zoom In (Ctrl + +)',
                onPressed: () {
                  final renderBox = context.findRenderObject() as RenderBox?;
                  final center = renderBox?.size.center(Offset.zero);
                  _controller.zoomIn(focalPoint: center);
                },
              ),

              // Reset Button (visible when not 100%)
              if (!isDefault) ...[
                const SizedBox(width: 2),
                InkWell(
                  onTap: () => _controller.resetZoom(),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(
                      'Reset',
                      style: AppTypography.interfaceBase.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
