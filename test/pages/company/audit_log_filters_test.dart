import 'package:bomach_os/pages/company/audit_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('audit toolbar exposes all supported server filters',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuditLogFilterBar(
            onChanged: (_, __, ___, ____, _____) {},
            onApply: () {},
          ),
        ),
      ),
    );

    expect(find.text('User ID'), findsOneWidget);
    expect(find.text('Audit type'), findsOneWidget);
    expect(find.text('Audit status'), findsOneWidget);
    expect(find.text('Start date'), findsOneWidget);
    expect(find.text('End date'), findsOneWidget);
    expect(find.text('Apply filters'), findsOneWidget);
  });
}
