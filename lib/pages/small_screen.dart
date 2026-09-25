import 'package:bomach_os/components/nav/header.dart';
import 'package:bomach_os/components/nav/side_menu.dart';
import 'package:bomach_os/main.dart' show prefs;
import 'package:bomach_os/pages/shared/embedded_web_view_interaction.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SmallScreenDashboard extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const SmallScreenDashboard({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      onDrawerChanged: embeddedWebViewInteraction.setDrawerOpen,
      drawer: Drawer(
        child: SafeArea(
          child: SideMenu(
            useAvailableHeight: true,
            router: GoRouter.of(context),
            preferences: prefs,
          ),
        ),
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
