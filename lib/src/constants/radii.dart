import 'package:flutter/material.dart';

/// Border radius tokens.
///
/// `md` (12) is the default for cards, inputs, and buttons. `lg` (16) is for
/// larger surfaces like dialogs and featured cards. `pill` (999) is for chips
/// and fully rounded pills.
class AppRadii {
  AppRadii._();

  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;

  // BorderRadius convenience values.
  static const BorderRadius brXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));
}
