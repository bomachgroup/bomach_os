import 'package:bms_front_end/components/header.dart';
import 'package:bms_front_end/components/side_menue.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SmallScreenDashboard extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const SmallScreenDashboard({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      drawer: const Drawer(
        child: SideMenue(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const TopNavigationBar(),
            navigationShell
          ],
        ),
      ),
    );
  }
}