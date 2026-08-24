import 'package:bomach_os/src/app_routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Spec (B12 fix, Batch 9c) — the blank-pane bug:
///
/// `/company/roles/detail` and the estate detail routes previously mapped
/// to `Container()` and relied on in-memory router extras; refresh or a
/// direct URL rendered a permanently blank content pane. The fix ships
/// public fallback widgets that explain how to reach the page and offer a
/// way back.
///
/// These smoke tests pin the public widget contract; builder wiring is
/// covered by manual E2E.
void main() {
  group('RoleDetailUnavailable', () {
    testWidgets('renders an explanatory message', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: RoleDetailUnavailable()),
      ));
      expect(find.byType(Container), findsNothing);
      expect(
        find.textContaining('Roles'),
        findsWidgets,
        reason: 'message must mention where to open role details from',
      );
    });

    testWidgets('offers a way back (button affordance)', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: RoleDetailUnavailable()),
      ));
      expect(find.byType(TextButton).evaluate().isNotEmpty ||
          find.byType(ElevatedButton).evaluate().isNotEmpty ||
          find.byType(OutlinedButton).evaluate().isNotEmpty ||
          find.byType(IconButton).evaluate().isNotEmpty,
          isTrue,
          reason: 'fallback must provide a navigation affordance');
    });
  });

  group('EstateDetailUnavailable', () {
    testWidgets('renders an explanatory message', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: EstateDetailUnavailable()),
      ));
      expect(find.byType(Container), findsNothing);
      expect(find.textContaining('estate'), findsWidgets);
    });

    testWidgets('offers a way back (button affordance)', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: EstateDetailUnavailable()),
      ));
      expect(find.byType(TextButton).evaluate().isNotEmpty ||
          find.byType(ElevatedButton).evaluate().isNotEmpty ||
          find.byType(OutlinedButton).evaluate().isNotEmpty ||
          find.byType(IconButton).evaluate().isNotEmpty,
          isTrue,
          reason: 'fallback must provide a navigation affordance');
    });
  });
}
