import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

/// A direct, self-service path from the dashboard to employee attendance.
class DashboardAttendanceCta extends StatelessWidget {
  const DashboardAttendanceCta({super.key});

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: () => context.go(RouteConstants.employeeAttendance),
      icon: const Icon(Iconsax.calendar_1),
      label: const Text('Go to Attendance'),
    );

    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth < 600
          ? SizedBox(width: double.infinity, child: button)
          : Align(alignment: Alignment.centerLeft, child: button),
    );
  }
}
