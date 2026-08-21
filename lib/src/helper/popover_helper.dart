import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A self-contained anchored popover built around a [LayerLink].
///
/// Used by widgets that own their widget tree (e.g. [MyDateField],
/// [MyTimeField]). Wrap the trigger in [anchor] so the popover can
/// align itself below the field.
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
              child: _popoverShell(builder),
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

/// Show a popover anchored below the widget identified by [anchor].
///
/// Uses **global coordinates** ([RenderBox.localToGlobal]) — no
/// [CompositedTransformTarget] is needed. Returns an [OverlayEntry]
/// that the caller must dismiss.
OverlayEntry showGlobalPopover({
  required BuildContext anchor,
  required WidgetBuilder builder,
  double? width,
  double verticalOffset = 6,
  VoidCallback? onDismiss,
}) {
  final renderBox = anchor.findRenderObject() as RenderBox;
  final globalPos = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;
  final overlay = Overlay.of(anchor);
  final overlayRenderBox = overlay.context.findRenderObject() as RenderBox?;
  final overlaySize = overlayRenderBox?.size ?? MediaQuery.of(anchor).size;

  final popoverWidth = width ?? size.width;
  double left = globalPos.dx;
  if (left + popoverWidth > overlaySize.width - 16) {
    left = overlaySize.width - popoverWidth - 16;
  }
  if (left < 16) left = 16;

  const estimatedHeight = 360.0;
  double top = globalPos.dy + size.height + verticalOffset;
  if (top + estimatedHeight > overlaySize.height - 16 &&
      globalPos.dy - estimatedHeight - verticalOffset >= 16) {
    top = globalPos.dy - estimatedHeight - verticalOffset;
  } else if (top + estimatedHeight > overlaySize.height - 16) {
    top = (overlaySize.height - estimatedHeight - 16).clamp(16.0, double.infinity);
  }

  // Declared before the entry so the builder closure can capture it
  // and resolve the real reference at runtime (after insertion).
  OverlayEntry? entryRef;

  final entry = OverlayEntry(
    builder: (ctx) {
      void dismiss() {
        entryRef?.remove();
        onDismiss?.call();
      }

      return Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: dismiss,
              behavior: HitTestBehavior.translucent,
            ),
          ),
          Positioned(
            left: left,
            top: top,
            width: popoverWidth,
            child: KeyboardListener(
              focusNode: FocusNode()..requestFocus(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.escape) {
                  dismiss();
                }
              },
              child: _popoverShell(builder),
            ),
          ),
        ],
      );
    },
  );

  entryRef = entry;
  overlay.insert(entry);
  return entry;
}

/// Material shell shared by both popover variants.
Widget _popoverShell(WidgetBuilder builder) {
  return Material(
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
  );
}
