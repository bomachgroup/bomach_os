import 'package:bomach_os/src/helper/screen_size.dart';
import 'package:flutter/material.dart';

/// Spacing scale on a 4 px grid. Use `AppSpacing.*` in new code.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Vertical gap — `SizedBox(height: n)`.
  static SizedBox gap(double n) => SizedBox(height: n);

  /// Horizontal gap — `SizedBox(width: n)`.
  static SizedBox hGap(double n) => SizedBox(width: n);
}

// ─── Legacy constants (kept for backward compatibility) ───────────────────
const double kDefaultSpaceTiny = 5;
const double kDefaultSpaceSM = 10;
const double kDefaultSpace = 20;
const double kDefaultSpaceBG = 30;

double bodySpace(BuildContext context) {
  if (isLargeScreen(context)) {
    return MediaQuery.sizeOf(context).width - 462;
  }
  return MediaQuery.sizeOf(context).width;
}

const kSizedBoxTiny = SizedBox(height: kDefaultSpaceTiny);
const kSizedBoxSM = SizedBox(height: kDefaultSpaceSM);
const kSizedBox = SizedBox(height: kDefaultSpace);
const kSizedBoxBG = SizedBox(height: kDefaultSpace * 2);

const kSizedBoxWidthTiny = SizedBox(width: kDefaultSpaceTiny);
const kSizedBoxWidthSM = SizedBox(width: kDefaultSpaceSM);
const kSizedBoxWidth = SizedBox(width: kDefaultSpace);
const kSizedBoxWidthBG = SizedBox(width: kDefaultSpace * 2);
