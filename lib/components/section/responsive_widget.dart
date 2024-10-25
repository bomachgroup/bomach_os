import 'package:flutter/material.dart';

const int largeScreenSize = 1366;
const int mediumScreenSize = 768;
const int smallScreenSize = 360;
// const int customScreenSize=1100;

class ResponsiveWidget extends StatelessWidget {
  //  final StatefulNavigationShell navigationShell;
  final Widget largeScreen;
  final Widget? mediumScreen;
  final Widget? smallScreen;
  const ResponsiveWidget(
      {super.key,
      required this.largeScreen,
       this.mediumScreen,
       this.smallScreen, 
      //  required this.navigationShell
       });

       static bool isSmallScreen(BuildContext context)=>
       MediaQuery.of(context).size.width<mediumScreenSize;

       static bool ismediumScreen(BuildContext context)=>
       MediaQuery.of(context).size.width>=mediumScreenSize &&
         MediaQuery.of(context).size.width<largeScreenSize;

       static bool islargeScreen(BuildContext context)=>
       MediaQuery.of(context).size.width>=largeScreenSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context,contraints){
      double width= contraints.maxHeight;
      if(width>=largeScreenSize){
        return largeScreen;
      }
      else if(width< largeScreenSize && width>=mediumScreenSize){
        return mediumScreen??largeScreen;
      }
      else {
        return smallScreen ??largeScreen;
      }
       
    });
  }
}
