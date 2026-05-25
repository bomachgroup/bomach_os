import 'package:bomach_os/components/nav/header.dart';
import 'package:bomach_os/components/nav/side_menu.dart';
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
            child: navigationShell,
          ),
        ],
      ),
    );
  }
}
