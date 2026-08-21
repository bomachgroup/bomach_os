import 'dart:async';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/popover_helper.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:intl/intl.dart';

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

  final effectiveFirstDate = firstDate ?? DateTime(1920);
  final effectiveLastDate = lastDate ?? DateTime(2100);

  DateTime focused = initialDate ?? DateTime.now();
  if (focused.isBefore(effectiveFirstDate)) focused = effectiveFirstDate;
  if (focused.isAfter(effectiveLastDate)) focused = effectiveLastDate;

  DateTime? selected = initialDate;
  bool showYearMonthPicker = false;

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
          final monthName = DateFormat('MMMM yyyy').format(focused);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom Header with Month & Year dropdown toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Iconsax.arrow_left_2, size: 16),
                      splashRadius: 18,
                      onPressed: () {
                        setPopState(() {
                          final prevMonth =
                              DateTime(focused.year, focused.month - 1, 1);
                          if (!prevMonth.isBefore(DateTime(
                              effectiveFirstDate.year,
                              effectiveFirstDate.month,
                              1))) {
                            focused = prevMonth;
                          }
                        });
                      },
                    ),
                    InkWell(
                      onTap: () {
                        setPopState(() {
                          showYearMonthPicker = !showYearMonthPicker;
                        });
                      },
                      borderRadius: AppRadii.brSm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              monthName,
                              style: AppTextStyles.bodyMd
                                  .copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              showYearMonthPicker
                                  ? Iconsax.arrow_up_2
                                  : Iconsax.arrow_down_1,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.arrow_right_3, size: 16),
                      splashRadius: 18,
                      onPressed: () {
                        setPopState(() {
                          final nextMonth =
                              DateTime(focused.year, focused.month + 1, 1);
                          if (!nextMonth.isAfter(DateTime(
                              effectiveLastDate.year,
                              effectiveLastDate.month,
                              1))) {
                            focused = nextMonth;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),
              if (showYearMonthPicker)
                _YearMonthSelector(
                  focused: focused,
                  firstDate: effectiveFirstDate,
                  lastDate: effectiveLastDate,
                  onSelect: (newFocused) {
                    setPopState(() {
                      focused = newFocused;
                      showYearMonthPicker = false;
                    });
                  },
                )
              else
                TableCalendar(
                  firstDay: effectiveFirstDate,
                  lastDay: effectiveLastDate,
                  focusedDay: focused,
                  selectedDayPredicate: (day) => isSameDay(selected, day),
                  headerVisible: false,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
                    weekendStyle: AppTextStyles.caption
                        .copyWith(color: AppColors.textMuted),
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
                  onPageChanged: (newFocused) {
                    setPopState(() {
                      focused = newFocused;
                    });
                  },
                ),
              const Divider(height: 1, color: AppColors.borderSubtle),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        final today = DateTime.now();
                        if (!today.isBefore(effectiveFirstDate) &&
                            !today.isAfter(effectiveLastDate)) {
                          setPopState(() {
                            focused = today;
                            selected = today;
                            showYearMonthPicker = false;
                          });
                        }
                      },
                      child: const Text('Today', style: TextStyle(fontSize: 13)),
                    ),
                    TextButton(
                      onPressed: () {
                        finish(null);
                        entry?.remove();
                      },
                      child:
                          const Text('Cancel', style: TextStyle(fontSize: 13)),
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

class _YearMonthSelector extends StatefulWidget {
  final DateTime focused;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onSelect;

  const _YearMonthSelector({
    required this.focused,
    required this.firstDate,
    required this.lastDate,
    required this.onSelect,
  });

  @override
  State<_YearMonthSelector> createState() => _YearMonthSelectorState();
}

class _YearMonthSelectorState extends State<_YearMonthSelector> {
  late int _selectedYear;
  late int _selectedMonth;
  bool _pickingMonth = false;
  late ScrollController _scrollController;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.focused.year;
    _selectedMonth = widget.focused.month;

    final years = [
      for (int y = widget.firstDate.year; y <= widget.lastDate.year; y++) y
    ];
    final yearIndex = years.indexOf(_selectedYear);
    final initialOffset = yearIndex >= 0 ? (yearIndex / 4) * 40.0 : 0.0;

    _scrollController = ScrollController(
      initialScrollOffset: initialOffset.clamp(0.0, double.infinity),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_pickingMonth) {
      return SizedBox(
        height: 250,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Year: $_selectedYear',
                    style: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _pickingMonth = false),
                    child: const Text('Change Year',
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final monthNum = index + 1;
                    final isSelected = monthNum == _selectedMonth;
                    return InkWell(
                      onTap: () {
                        final newDate = DateTime(_selectedYear, monthNum, 1);
                        widget.onSelect(newDate);
                      },
                      borderRadius: AppRadii.brSm,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceMuted,
                          borderRadius: AppRadii.brSm,
                        ),
                        child: Text(
                          _months[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    final years = [
      for (int y = widget.firstDate.year; y <= widget.lastDate.year; y++) y
    ];

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0, left: 2.0),
              child: Text(
                'Select Year',
                style:
                    AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              ),
            ),
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years[index];
                  final isSelected = year == _selectedYear;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedYear = year;
                        _pickingMonth = true;
                      });
                    },
                    borderRadius: AppRadii.brSm,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceMuted,
                        borderRadius: AppRadii.brSm,
                      ),
                      child: Text(
                        year.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
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