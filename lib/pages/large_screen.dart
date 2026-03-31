import 'package:bms_front_end/components/nav/header.dart';
import 'package:bms_front_end/components/nav/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LargeScreenDashboard extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const LargeScreenDashboard({super.key, required this.navigationShell});

  @override
  State<LargeScreenDashboard> createState() => _LargeScreenDashboardState();
}

class _LargeScreenDashboardState extends State<LargeScreenDashboard> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 300,
            child: SideMenu(),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const TopNavigationBar(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: media.width - 300,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 28),
                      child: widget.navigationShell,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
