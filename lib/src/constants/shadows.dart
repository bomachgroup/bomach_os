import 'package:flutter/material.dart';

/// Elevation / shadow tokens — soft, enterprise-clean.
///
/// `sm` = subtle card lift. `md` = raised / hover state. `lg` = dialog / modal.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A0F172A), // neutral900 @ 4%
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0F0F172A), // neutral900 @ 6%
      offset: Offset(0, 2),
      blurRadius: 8,
    ),
    BoxShadow(
      color: Color(0x080F172A), // neutral900 @ 3%
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x140F172A), // neutral900 @ 8%
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
    BoxShadow(
      color: Color(0x0A0F172A), // neutral900 @ 4%
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  /// Focus ring — used around focused inputs, buttons, tiles.
  static const List<BoxShadow> focusRing = [
    BoxShadow(
      color: Color(0x332563EB), // primary @ 20%
      offset: Offset.zero,
      blurRadius: 0,
      spreadRadius: 3,
    ),
  ];
}
