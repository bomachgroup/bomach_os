import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/icons.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:flutter/material.dart';

/// Responsive width presets for [DialogScaffold].
///
/// * [sm]  — 480 px on tablet+ (compact forms, confirmations).
/// * [md]  — 640 px on desktop (default — most forms and detail previews).
/// * [lg]  — 800 px on desktop (wide forms, side-by-side layouts).
/// * [xl]  — 960 px on desktop (data tables, multi-column wizards).
///
/// All sizes collapse to a full-screen sheet on mobile.
enum DialogSize { sm, md, lg, xl }

/// Canonical modal scaffold: header (title + close button) / body / footer.
///
/// Replaces bespoke `Dialog(...)` and `AlertDialog(...)` bodies across the app
/// with one consistent surface — matching the new radii, neutrals, and type.
/// Responsive by default: mobile is a full-screen sheet, tablet/desktop clamp
/// to the [DialogSize] preset.
///
/// Open with the `show()` static helper:
///
/// ```dart
/// DialogScaffold.show<bool>(
///   context,
///   title: 'Delete employee',
///   size: DialogSize.sm,
///   body: const Text('This action cannot be undone.'),
///   actions: [
///     TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
///     FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
///   ],
/// );
/// ```
class DialogScaffold extends StatelessWidget {
  const DialogScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions,
    this.size = DialogSize.md,
    this.showCloseButton = true,
    this.scrollable = true,
    this.bodyPadding,
  });

  final String title;
  final String? subtitle;
  final Widget body;

  /// Footer action buttons rendered right-aligned. Pass an empty list or null
  /// to hide the footer entirely.
  final List<Widget>? actions;

  final DialogSize size;
  final bool showCloseButton;

  /// Wrap [body] in a [SingleChildScrollView]. Disable for bodies that manage
  /// their own scrolling (e.g. a [ListView]).
  final bool scrollable;

  /// Override the default 20 px body padding.
  final EdgeInsetsGeometry? bodyPadding;

  /// Convenience wrapper over [showDialog] that returns the result when the
  /// dialog is popped.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget body,
    String? subtitle,
    List<Widget>? actions,
    DialogSize size = DialogSize.md,
    bool showCloseButton = true,
    bool barrierDismissible = true,
    bool scrollable = true,
    EdgeInsetsGeometry? bodyPadding,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => DialogScaffold(
        title: title,
        subtitle: subtitle,
        body: body,
        actions: actions,
        size: size,
        showCloseButton: showCloseButton,
        scrollable: scrollable,
        bodyPadding: bodyPadding,
      ),
    );
  }

  double _maxWidthFor(DialogSize size) {
    switch (size) {
      case DialogSize.sm:
        return 480;
      case DialogSize.md:
        return 640;
      case DialogSize.lg:
        return 800;
      case DialogSize.xl:
        return 960;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final maxWidth = isMobile ? double.infinity : _maxWidthFor(size);
    final effectivePadding = bodyPadding ?? const EdgeInsets.all(20);

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppTextStyles.h3),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showCloseButton)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(AppIcons.close, size: 20),
              color: AppColors.textSecondary,
              tooltip: 'Close',
              splashRadius: 20,
            ),
        ],
      ),
    );

    final paddedBody = Padding(padding: effectivePadding, child: body);
    final bodyWidget = scrollable
        ? Flexible(child: SingleChildScrollView(child: paddedBody))
        : Flexible(child: paddedBody);

    final hasActions = actions != null && actions!.isNotEmpty;
    final footer = hasActions
        ? Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderSubtle),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 12,
              runSpacing: 8,
              children: actions!,
            ),
          )
        : null;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
        bodyWidget,
        if (footer != null) footer,
      ],
    );

    if (isMobile) {
      return Dialog.fullscreen(
        backgroundColor: AppColors.surface,
        child: SafeArea(child: content),
      );
    }

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.brLg),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      ),
    );
  }
}
