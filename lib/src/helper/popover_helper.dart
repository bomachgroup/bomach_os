import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A self-contained anchored popover built around a [LayerLink].
///
/// Wrap the trigger in [anchor]. Call [show] (passing the trigger's
/// [BuildContext]) to display the popover directly below the trigger,
/// offset by [verticalOffset]. Adds outside-tap and Escape dismissal.
///
/// The same instance must be used for both [anchor] and [show] so the
/// follower can locate the target via the shared [LayerLink].
class AnchoredPopover {
  AnchoredPopover() : _link = LayerLink();

  final LayerLink _link;
  OverlayEntry? _entry;
  VoidCallback? _onDismiss;

  /// Wraps [child] in the [CompositedTransformTarget] the follower anchors to.
  Widget anchor(Widget child) =>
      CompositedTransformTarget(link: _link, child: child);

  void show({
    required BuildContext target,
    required WidgetBuilder builder,
    double? width,
    double verticalOffset = 6,
    VoidCallback? onDismiss,
  }) {
    _onDismiss = onDismiss;
    final renderBox = target.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent barrier that closes the popover on outside tap.
          Positioned.fill(
            child: GestureDetector(
              onTap: dismiss,
              behavior: HitTestBehavior.translucent,
            ),
          ),
          Positioned(
            width: width ?? size.width,
            child: CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + verticalOffset),
              child: KeyboardListener(
                focusNode: FocusNode()..requestFocus(),
                onKeyEvent: (event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.escape) {
                    dismiss();
                  }
                },
                child: Material(
                  elevation: 6,
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                  borderRadius: AppRadii.brMd,
                  color: AppColors.surface,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderSubtle),
                      borderRadius: AppRadii.brMd,
                    ),
                    child: Builder(builder: builder),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(target).insert(_entry!);
  }

  void dismiss() {
    _entry?.remove();
    _entry = null;
    _onDismiss?.call();
  }

  bool get isOpen => _entry != null;
}
