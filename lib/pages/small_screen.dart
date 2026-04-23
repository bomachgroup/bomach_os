import 'package:bms_front_end/components/nav/header.dart';
import 'package:bms_front_end/components/nav/side_menu.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SmallScreenDashboard extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const SmallScreenDashboard({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(
        child: SideMenu(),
      ),
      body: Column(
        children: [
          const TopNavigationBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultSpace, vertical: 20),
              child: navigationShell,
            ),
          ),
        ],
      ),
    );
  }
}
