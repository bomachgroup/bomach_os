import 'package:flutter/material.dart';

// Keep the responsive shell aligned with the app's canonical tablet/desktop
// breakpoint. This also lets the embedded web app reach desktop mode at the
// width users typically get from a maximized tablet-sized web view.
const int largeScreenSize = 1100;
const int mediumScreenSize = 700;
const int smallScreenSize = 360;

bool isSmallScreen(BuildContext context) =>
    MediaQuery.of(context).size.width < mediumScreenSize;

bool isMediumScreen(BuildContext context) =>
    MediaQuery.of(context).size.width >= mediumScreenSize &&
    MediaQuery.of(context).size.width < largeScreenSize;

bool isLargeScreen(BuildContext context) =>
    MediaQuery.of(context).size.width >= largeScreenSize;
