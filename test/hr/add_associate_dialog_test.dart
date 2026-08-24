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

  testWidgets('success shows generated credentials and closes both dialogs '
      'on acknowledge', (tester) async {
    final controller = FakeAssociatesController()..nextResult = true;
    registerTestController(controller);

    await pumpDialog(tester);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'First Name*').first, 'Ada');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Last Name*').first, 'Lovelace');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email*'), 'ada@x.com');
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
        find.widgetWithText(TextFormField, 'First Name*').first, 'Bo');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Last Name*').first, 'B');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email*'), 'bo@x.com');
    await tester.tap(find.text('Select role'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('surveyor-associate').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Associate'));
    await tester.pumpAndSettle();

    expect(find.text('New Associate'), findsOneWidget,
        reason: 'form stays open on failure');
    expect(find.byType(SnackBar), findsOneWidget);
    expect(controller.lastGeneratedPassword, isNull,
        reason: 'no credentials dialog on failure');
  });
}

