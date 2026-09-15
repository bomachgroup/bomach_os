import 'package:bomach_os/pages/hr/widget/clock_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClockConfirmDialog widget tests', () {
    testWidgets('Clock In dialog displays correctly and confirming returns true',
        (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await ClockConfirmDialog.show(
                    context,
                    isClockIn: true,
                    workspaceName: 'Enugu Main Office',
                    currentTime: DateTime.utc(2026, 9, 15, 7, 30), // 08:30 WAT
                  );
                },
                child: const Text('Trigger Clock In'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger Clock In'));
      await tester.pumpAndSettle();

      // Check header and content
      expect(find.text('Confirm Clock In'), findsOneWidget);
      expect(
        find.text(
            'Are you sure you want to clock in now? Your attendance, time, and location will be recorded.'),
        findsOneWidget,
      );
      expect(find.text('Enugu Main Office'), findsOneWidget);
      expect(find.text('08:30 AM'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Clock In'), findsOneWidget);

      // Tap Confirm Clock In
      await tester.tap(find.widgetWithText(ElevatedButton, 'Clock In'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.byType(ClockConfirmDialog), findsNothing);
    });

    testWidgets('Clock In dialog cancelling returns false', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await ClockConfirmDialog.show(
                    context,
                    isClockIn: true,
                    workspaceName: 'Lagos Hub',
                  );
                },
                child: const Text('Trigger Clock In'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger Clock In'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(find.byType(ClockConfirmDialog), findsNothing);
    });

    testWidgets('Clock Out dialog displays correctly and confirming returns true',
        (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: NoSplash.splashFactory),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await ClockConfirmDialog.show(
                    context,
                    isClockIn: false,
                    currentTime: DateTime.utc(2026, 9, 15, 16, 0), // 17:00 WAT
                  );
                },
                child: const Text('Trigger Clock Out'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger Clock Out'));
      await tester.pumpAndSettle();

      // Check header and content
      expect(find.text('Confirm Clock Out'), findsOneWidget);
      expect(
        find.text(
            'Are you sure you want to clock out now? This will record your departure time and end your shift for today.'),
        findsOneWidget,
      );
      expect(find.text('05:00 PM'), findsOneWidget);
      expect(find.text('Clock Out'), findsOneWidget);

      // Tap Confirm Clock Out
      await tester.tap(find.widgetWithText(ElevatedButton, 'Clock Out'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(find.byType(ClockConfirmDialog), findsNothing);
    });
  });
}
