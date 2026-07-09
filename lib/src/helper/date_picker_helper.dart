import 'dart:async';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/popover_helper.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';

/// Drop-in replacement for [showDatePicker] that renders an anchored
/// calendar popover below [context] (web-friendly) instead of a centered
/// modal. Resolves with the chosen [DateTime] or `null` when dismissed.
Future<DateTime?> showDatePopover(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final completer = Completer<DateTime?>();

  DateTime focused = initialDate ?? DateTime.now();
  DateTime? selected = initialDate;

  void finish(DateTime? value) {
    if (!completer.isCompleted) completer.complete(value);
  }

  OverlayEntry? entry;
  entry = showGlobalPopover(
    anchor: context,
    width: 320,
    onDismiss: () => finish(null),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setPopState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TableCalendar(
                firstDay: firstDate ?? DateTime(2000),
                lastDay: lastDate ?? DateTime(2100),
                focusedDay: focused,
                selectedDayPredicate: (day) => isSameDay(selected, day),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon: const Icon(Iconsax.arrow_left_2, size: 16),
                  rightChevronIcon: const Icon(Iconsax.arrow_right_3, size: 16),
                  titleTextStyle:
                      AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
                  headerPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle:
                      AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  weekendStyle:
                      AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                ),
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(color: Colors.white),
                  todayTextStyle: TextStyle(color: AppColors.primary),
                  cellMargin: EdgeInsets.all(4),
                ),
                onDaySelected: (picked, newFocused) {
                  setPopState(() {
                    selected = picked;
                    focused = newFocused;
                  });
                  finish(picked);
                  entry?.remove();
                },
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        finish(null);
                        entry?.remove();
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );

  return completer.future;
}

/// Drop-in replacement for [showTimePicker] that renders an anchored dropdown
/// clock popover below [context]. Resolves with the chosen [TimeOfDay] or
/// `null` when dismissed.
Future<TimeOfDay?> showTimePopover(
  BuildContext context, {
  TimeOfDay? initialTime,
}) async {
  final completer = Completer<TimeOfDay?>();

  int hour = initialTime?.hour ?? TimeOfDay.now().hour;
  int minute = initialTime?.minute ?? TimeOfDay.now().minute;
  minute = (minute ~/ 5) * 5;

  void finish(TimeOfDay? value) {
    if (!completer.isCompleted) completer.complete(value);
  }

  OverlayEntry? entry;
  entry = showGlobalPopover(
    anchor: context,
    width: 240,
    onDismiss: () => finish(null),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setPopState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildScrollColumn(
                        label: 'Hour',
                        value: hour,
                        min: 0,
                        max: 23,
                        onChanged: (v) => setPopState(() => hour = v),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(':', style: TextStyle(fontSize: 20)),
                    ),
                    Expanded(
                      child: _buildScrollColumn(
                        label: 'Minute',
                        value: minute,
                        min: 0,
                        max: 59,
                        step: 5,
                        onChanged: (v) => setPopState(() => minute = v),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        finish(TimeOfDay(hour: hour, minute: minute));
                        entry?.remove();
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    },
  );

  return completer.future;
}

Widget _buildScrollColumn({
  required String label,
  required int value,
  required int min,
  required int max,
  required ValueChanged<int> onChanged,
  int step = 1,
}) {
  final items = <int>[];
  for (int i = min; i <= max; i += step) {
    items.add(i);
  }
  return Column(
    children: [
      Text(label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
      const SizedBox(height: 6),
      SizedBox(
        height: 160,
        child: ListView.builder(
          itemExtent: 36,
          itemCount: items.length,
          controller: ScrollController(
            initialScrollOffset:
                (items.indexOf(value) * 36).toDouble().clamp(0, double.infinity),
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = item == value;
            return InkWell(
              onTap: () => onChanged(item),
              child: Container(
                alignment: Alignment.center,
                decoration: isSelected
                    ? const BoxDecoration(
                        color: AppColors.primarySubtle,
                        borderRadius: AppRadii.brSm,
                      )
                    : null,
                child: Text(
                  item.toString().padLeft(2, '0'),
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}