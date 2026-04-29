import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:flutter/material.dart';

/// Consistent outer wrapper for module pages.
///
/// Handles responsive padding, optional max-content-width clamp, and scroll
/// behavior so individual pages stop hand-rolling it. Compose with
/// [PageHeader] at the top of `children` for the canonical module layout.
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    this.header,
    required this.children,
    this.padding,
    this.maxContentWidth = 1440,
    this.scrollable = true,
    this.gap = 24,
    this.bottomAction,
  });

  /// Optional header rendered above `children` with the same horizontal
  /// padding (commonly a [PageHeader]).
  final Widget? header;

  /// Body content — rendered vertically with [gap] between entries.
  final List<Widget> children;

  /// Override the responsive default padding.
  final EdgeInsetsGeometry? padding;

  /// Clamp the content width on very wide screens. Set `double.infinity` to
  /// disable.
  final double maxContentWidth;

  /// Wrap contents in a [SingleChildScrollView]. Disable for pages that
  /// manage their own scrolling (e.g. a full-screen [ListView]).
  final bool scrollable;

  /// Vertical gap between `children`.
  final double gap;

  /// Optional sticky bottom action row (mobile-first patterns).
  final Widget? bottomAction;

  @override
  Widget build(BuildContext context) {
    final bp = context.breakpoint;
    final horizontal = bp.select<double>(
      mobile: 16,
      tablet: 24,
      desktop: 32,
    );
    final vertical = bp.select<double>(
      mobile: 16,
      tablet: 20,
      desktop: 24,
    );

    final effectivePadding = padding ??
        EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) ...[
          header!,
          SizedBox(height: gap),
        ],
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1) SizedBox(height: gap),
        ],
      ],
    );

    final constrained = maxContentWidth.isFinite
        ? Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: body,
            ),
          )
        : body;

    final padded = Padding(padding: effectivePadding, child: constrained);

    final scroll = scrollable
        ? SingleChildScrollView(
            primary: true,
            padding: EdgeInsets.zero,
            child: padded,
          )
        : padded;

    if (bottomAction == null) return scroll;

    return Column(
      children: [
        Expanded(child: scroll),
        SafeArea(top: false, child: bottomAction!),
      ],
    );
  }
}
