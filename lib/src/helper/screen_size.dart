import 'package:flutter/material.dart';

const int largeScreenSize = 1200;
const int mediumScreenSize = 700;
const int smallScreenSize = 360;

bool isSmallScreen(BuildContext context) =>
    MediaQuery.of(context).size.width < mediumScreenSize;

bool isMediumScreen(BuildContext context) =>
    MediaQuery.of(context).size.width >= mediumScreenSize &&
    MediaQuery.of(context).size.width < largeScreenSize;

bool isLargeScreen(BuildContext context) =>
    MediaQuery.of(context).size.width >= largeScreenSize;
