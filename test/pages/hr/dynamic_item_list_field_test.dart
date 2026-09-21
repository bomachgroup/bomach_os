import 'package:bomach_os/pages/hr/widget/dynamic_item_list_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax/iconsax.dart';

void main() {
  group('WorkReportFormatUtils', () {
    test('serializeItems correctly trims items, eliminates empty/whitespace, and joins with \\n', () {
      final controllers = [
        TextEditingController(text: '  Task 1  '),
        TextEditingController(text: '   '),
        TextEditingController(text: 'Task 2'),
        TextEditingController(text: ''),
      ];

      final serialized = WorkReportFormatUtils.serializeItems(controllers);
      expect(serialized, 'Task 1\nTask 2');
    });

    test('serializeItems returns null when all fields are empty or whitespace', () {
      final controllers = [
        TextEditingController(text: '   '),
        TextEditingController(text: ''),
        TextEditingController(text: ' \t\n '),
      ];

      final serialized = WorkReportFormatUtils.serializeItems(controllers);
      expect(serialized, isNull);
    });

    test('parseItems correctly splits by \\n, trims, and discards empty lines', () {
      const raw = 'Task A \n\n   \n Task B\nTask C   ';
      final parsed = WorkReportFormatUtils.parseItems(raw);

      expect(parsed, ['Task A', 'Task B', 'Task C']);
    });

    test('parseItems returns empty list for null or whitespace string', () {
      expect(WorkReportFormatUtils.parseItems(null), isEmpty);
      expect(WorkReportFormatUtils.parseItems('   '), isEmpty);
      expect(WorkReportFormatUtils.parseItems(''), isEmpty);
    });
  });

  group('DynamicItemListField Widget', () {
    testWidgets('renders item row with number badge and input field', (tester) async {
      final controllers = [TextEditingController(text: 'Initial achievement')];
      bool addCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: false,
            splashFactory: InkRipple.splashFactory,
          ),
          home: Scaffold(
            body: DynamicItemListField(
              title: 'Things Achieved',
              subtitle: 'Completed tasks',
              hintText: 'Enter achievement',
              controllers: controllers,
              onAdd: () => addCalled = true,
              onRemove: (_) {},
              maxItems: 5,
            ),
          ),
        ),
      );

      expect(find.text('Things Achieved'), findsOneWidget);
      expect(find.text('Completed tasks'), findsOneWidget);
      expect(find.text('1/5'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Initial achievement'), findsOneWidget);

      // Add button is present on the single (and last) field
      final addButton = find.byIcon(Iconsax.add_circle);
      expect(addButton, findsOneWidget);

      // Remove button is NOT present when count == 1
      final removeButton = find.byIcon(Iconsax.trash);
      expect(removeButton, findsNothing);

      await tester.tap(addButton);
      expect(addCalled, isTrue);
    });

    testWidgets('renders remove button when items > 1 and calls onRemove with correct index', (tester) async {
      final controllers = [
        TextEditingController(text: 'Item 1'),
        TextEditingController(text: 'Item 2'),
      ];
      int? removedIndex;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: false,
            splashFactory: InkRipple.splashFactory,
          ),
          home: Scaffold(
            body: DynamicItemListField(
              title: 'Problems Faced',
              hintText: 'Enter problem',
              controllers: controllers,
              onAdd: () {},
              onRemove: (idx) => removedIndex = idx,
              maxItems: 5,
            ),
          ),
        ),
      );

      expect(find.text('2/5'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Two remove buttons (one per row)
      final removeButtons = find.byIcon(Iconsax.trash);
      expect(removeButtons, findsNWidgets(2));

      // Tap remove on the first row
      await tester.tap(removeButtons.first);
      expect(removedIndex, 0);

      // Tap remove on the second row
      await tester.tap(removeButtons.at(1));
      expect(removedIndex, 1);
    });

    testWidgets('does not show add button when maxItems is reached', (tester) async {
      final controllers = [
        TextEditingController(text: 'Item 1'),
        TextEditingController(text: 'Item 2'),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: false,
            splashFactory: InkRipple.splashFactory,
          ),
          home: Scaffold(
            body: DynamicItemListField(
              title: 'Tasks',
              hintText: 'Enter task',
              controllers: controllers,
              onAdd: () {},
              onRemove: (_) {},
              maxItems: 2,
            ),
          ),
        ),
      );

      expect(find.text('2/2'), findsOneWidget);
      // Add button should not be present when length == maxItems
      expect(find.byIcon(Iconsax.add_circle), findsNothing);
    });
  });
}
