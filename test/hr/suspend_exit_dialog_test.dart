import 'package:bomach_os/pages/hr/widget/exit_employee_dialog.dart';
import 'package:bomach_os/pages/hr/widget/suspend_employee_dialog.dart';
import 'package:bomach_os/src/model/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_controllers.dart';

/// Spec (B5 fix, Batch 7b) — the silent-failure dialog bug:
///
/// `suspendEmployee` / `exitEmployee` return `Future<bool>` (no
/// BuildContext parameter). The dialogs pop ONLY on success; on failure
/// the form STAYS OPEN and an error toast is shown. Previously `.then`
/// popped whatever dialog was topmost — including the error dialog pushed
/// by the controller — leaving the user with zero feedback.
void main() {
  tearDown(unregisterTestControllers);

  final employee = Employee(
    id: '42',
    email: 'e@x.com',
    firstName: 'Test',
    lastName: 'Employee',
  );

  Future<void> pumpDialog(
    WidgetTester tester, {
    required Widget Function() builder,
  }) async {
    await tester.pumpWidget(MaterialApp(
      scaffoldMessengerKey: testMessengerKey,
      home: Scaffold(body: Builder(builder: (context) {
        return Center(
          child: ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => builder(),
            ),
            child: const Text('open'),
          ),
        );
      })),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  group('SuspendEmployeeDialog', () {
    testWidgets('success pops the form', (tester) async {
      final controller = FakeEmployeeController()..nextResult = true;
      registerTestController(controller);

      await pumpDialog(tester,
          builder: () => SuspendEmployeeDialog(employee: employee));

      await tester.enterText(find.byType(TextField), 'policy breach');
      // The title also reads "Suspend Employee" — target the button.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Suspend Employee'));
      await tester.pumpAndSettle();

      expect(find.text('Suspension Notice'), findsNothing,
          reason: 'form should be closed after success');
      expect(controller.lastSuspendedUserId, '42');
      expect(controller.lastSuspendReason, 'policy breach');
    });

    testWidgets('failure keeps the form open and surfaces an error toast',
        (tester) async {
      final controller = FakeEmployeeController()..nextResult = false;
      registerTestController(controller);

      await pumpDialog(tester,
          builder: () => SuspendEmployeeDialog(employee: employee));

      await tester.enterText(find.byType(TextField), 'oops');
      // The title also reads "Suspend Employee" — target the button.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Suspend Employee'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // THE AUDITED SCENARIO: form still present (not silently closed),
      // and an error snackbar is visible.
      expect(find.text('Suspension Notice'), findsOneWidget,
          reason: 'form must stay open on failure');
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('ExitEmployeeDialog', () {
    testWidgets('success pops the form', (tester) async {
      final controller = FakeEmployeeController()..nextResult = true;
      registerTestController(controller);

      await pumpDialog(tester,
          builder: () => ExitEmployeeDialog(employee: employee));

      // The reason field is required by the form validator.
      await tester.enterText(find.byType(TextField).last, 'contract end');

      final submitFinder =
          find.widgetWithText(ElevatedButton, 'Confirm Exit');
      expect(submitFinder, findsOneWidget);
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      expect(controller.lastExitedUserId, '42');
      expect(controller.lastExitDate, isNotEmpty);
    });

    testWidgets('failure keeps the form open with visible feedback',
        (tester) async {
      final controller = FakeEmployeeController()..nextResult = false;
      registerTestController(controller);

      await pumpDialog(tester,
          builder: () => ExitEmployeeDialog(employee: employee));

      // The reason field is required by the form validator.
      await tester.enterText(find.byType(TextField).last, 'contract end');

      final submitFinder =
          find.widgetWithText(ElevatedButton, 'Confirm Exit');
      expect(submitFinder, findsOneWidget);
      await tester.tap(submitFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(SnackBar), findsOneWidget,
          reason: 'error toast must be visible');
      expect(controller.errorMessage.value, isNotEmpty,
          reason: 'controller exposes a clean message for the toast');
      expect(find.byType(ExitEmployeeDialog), findsOneWidget,
          reason: 'exit form stays open after failure');
    });
  });
}

