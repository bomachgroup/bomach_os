import 'package:bomach_os/pages/hr/widget/add_associate_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../helpers/test_controllers.dart';

/// Spec (V2 UX, Batch 1d) — the hardcoded-password fix:
///
/// On successful creation the dialog must show a "credentials created"
/// dialog containing a GENERATED password (never the old hardcoded
/// default), with copy affordances, and only after acknowledgement close
/// everything. The controller receives the generated password through
/// `createAssociate(..., password: ...)`.
void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues(const {});
  });
  tearDown(unregisterTestControllers);

  Future<void> pumpDialog(WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(
      scaffoldMessengerKey: testMessengerKey,
      home: Scaffold(body: Builder(builder: (context) {
        return Center(
          child: ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const AddAssociateDialog(token: 'tok'),
            ),
            child: const Text('open'),
          ),
        );
      })),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('success shows generated credentials and closes both dialogs '
      'on acknowledge', (tester) async {
    final controller = FakeAssociatesController()..nextResult = true;
    registerTestController(controller);

    await pumpDialog(tester);

    // MyTextFormField renders its title as a sibling Text, so target the
    // raw TextFormField widgets by their hintText.
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter first name'), 'Ada');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter last name'), 'Lovelace');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'email@example.com'),
        'ada@x.com');
    // Open role dropdown and pick the first associate role.
    await tester.tap(find.text('Select role'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('surveyor-associate').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Associate'));
    await tester.pumpAndSettle();

    // Credentials dialog appeared with a generated (non-default) password.
    expect(find.textContaining('shown once'), findsWidgets,
        reason: 'show-once warning must be visible');
    expect(controller.lastGeneratedPassword ?? '', isNot('Password123!'));
    expect((controller.lastGeneratedPassword ?? '').length, greaterThanOrEqualTo(12));

    // Acknowledge → both dialogs closed.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('New Associate'), findsNothing);
    expect(find.textContaining('shown once'), findsNothing);

    expect(controller.createdAssociate?.email, 'ada@x.com');
    expect(controller.createdAssociate?.employmentType, 'surveyor-associate');
  });

  testWidgets('failure keeps the form open with an error toast',
      (tester) async {
    final controller = FakeAssociatesController()..nextResult = false;
    registerTestController(controller);

    await pumpDialog(tester);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter first name'), 'Bo');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter last name'), 'B');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'email@example.com'), 'bo@x.com');
    await tester.tap(find.text('Select role'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('surveyor-associate').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Associate'));
    await tester.pumpAndSettle();

    expect(find.text('New Associate'), findsOneWidget,
        reason: 'form stays open on failure');
    expect(find.byType(SnackBar), findsOneWidget);
    // The credentials dialog must NOT appear on failure (the password may
    // have been generated for the API call, but nothing shows it).
    expect(find.textContaining('shown once'), findsNothing);
  });
}

