import 'package:bms_front_end/components/nav/side_menu.dart';
import 'package:bms_front_end/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Width the sidebar occupies when fully expanded (labels + search + sections).
const double kSidebarExpandedWidth = 300;

/// Width the sidebar occupies when collapsed to an icon-only rail.
const double kSidebarCollapsedWidth = 72;

class LargeScreenDashboard extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  const LargeScreenDashboard({super.key, required this.navigationShell});

  @override
  State<LargeScreenDashboard> createState() => _LargeScreenDashboardState();
}

class _LargeScreenDashboardState extends State<LargeScreenDashboard> {
  late bool _sidebarCollapsed;

  @override
  void initState() {
    super.initState();
    _sidebarCollapsed = prefs.getBool('sidebarCollapsed') ?? false;
  }

  void _toggleSidebar() {
    setState(() => _sidebarCollapsed = !_sidebarCollapsed);
    prefs.setBool('sidebarCollapsed', _sidebarCollapsed);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final double sidebarWidth =
        _sidebarCollapsed ? kSidebarCollapsedWidth : kSidebarExpandedWidth;

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOutCubic,
            width: sidebarWidth,
            child: SideMenu(
              isCollapsed: _sidebarCollapsed,
              onToggleCollapse: _toggleSidebar,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: media.width - sidebarWidth,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 28),
                    child: widget.navigationShell,
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
