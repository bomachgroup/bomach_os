import 'package:bms_front_end/components/header.dart';
import 'package:bms_front_end/components/side_menue.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LargeScreenDashboard extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
   const LargeScreenDashboard({
    super.key, required this.navigationShell});

  @override
  State<LargeScreenDashboard> createState() => _LargeScreenDashboardState();
}

class _LargeScreenDashboardState extends State<LargeScreenDashboard> {
 

  @override
  Widget build(BuildContext context) {
    return    Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Expanded(child:  SideMenue()),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                   const TopNavigationBar(),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 28),
                    child: widget.navigationShell),
                
                  ],
                ),
              )
            )
          ],
        ),
      );
  }
}