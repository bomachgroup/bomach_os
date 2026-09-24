import 'package:bomach_os/pages/dashboad/widgets/dashboard_attendance_cta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  for (final size in [const Size(375, 800), const Size(1280, 800)]) {
    testWidgets('dashboard Attendance CTA navigates at ${size.width}px',
        (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const Scaffold(
              body: Center(child: DashboardAttendanceCta()),
            ),
          ),
          GoRoute(
            path: '/employee/attendance',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Employee Attendance destination')),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Go to Attendance'));
      await tester.pumpAndSettle();

      expect(find.text('Employee Attendance destination'), findsOneWidget);
    });
  }
}
