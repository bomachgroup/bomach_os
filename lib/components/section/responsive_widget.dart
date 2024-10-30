import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget largeScreen;
  final Widget? mediumScreen;
  final Widget? smallScreen;
  const ResponsiveWidget({
    super.key,
    required this.largeScreen,
    this.mediumScreen,
    this.smallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, contraints) {
      double width = contraints.maxWidth;
      if (width >= largeScreenSize) {
        return largeScreen;
      } else if (width < largeScreenSize && width >= mediumScreenSize) {
        return mediumScreen ?? largeScreen;
      } else {
        return smallScreen ?? largeScreen;
      }
    });
  }
}
