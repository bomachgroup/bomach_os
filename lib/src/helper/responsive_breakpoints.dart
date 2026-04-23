import 'package:flutter/widgets.dart';

/// Canonical responsive breakpoints for Bomach OS.
///
/// Use `Breakpoint.of(context)` to branch layouts instead of hand-rolling
/// width comparisons. Replaces the mix of `600 / 700 / 800 / 1000 / 1100`
/// thresholds scattered across pages.
enum Breakpoint {
  mobile,
  tablet,
  desktop;

  bool get isMobile => this == Breakpoint.mobile;
  bool get isTablet => this == Breakpoint.tablet;
  bool get isDesktop => this == Breakpoint.desktop;
  bool get isMobileOrTablet => this != Breakpoint.desktop;

  static const double mobileMax = 700;
  static const double tabletMax = 1100;

  static Breakpoint of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return fromWidth(width);
  }

  static Breakpoint fromWidth(double width) {
    if (width < mobileMax) return Breakpoint.mobile;
    if (width < tabletMax) return Breakpoint.tablet;
    return Breakpoint.desktop;
  }

  /// Pick a value per breakpoint. `tablet` and `desktop` fall back to the
  /// next lower value if not provided.
  T select<T>({required T mobile, T? tablet, T? desktop}) {
    switch (this) {
      case Breakpoint.mobile:
        return mobile;
      case Breakpoint.tablet:
        return tablet ?? mobile;
      case Breakpoint.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

extension BreakpointContext on BuildContext {
  Breakpoint get breakpoint => Breakpoint.of(this);
  bool get isMobile => breakpoint.isMobile;
  bool get isTablet => breakpoint.isTablet;
  bool get isDesktop => breakpoint.isDesktop;
}
