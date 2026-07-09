import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/popover_helper.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

/// A date-picker-backed text field for web.
///
/// Tapping the field opens a calendar in a popover anchored directly below
/// the field (instead of a centered modal dialog), which matches the
/// `<input type="date">` behaviour web users expect.
class MyDateField extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final String hintText;

  /// Output format written into [controller]. Defaults to ISO `yyyy-MM-dd`.
  final String format;

  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;

  const MyDateField({
    super.key,
    required this.controller,
    required this.title,
    this.hintText = 'YYYY-MM-DD',
    this.format = 'yyyy-MM-dd',
    this.firstDate,
    this.lastDate,
    this.initialDate,
  });

  @override
  State<MyDateField> createState() => _MyDateFieldState();
}

class _MyDateFieldState extends State<MyDateField> {
  final AnchoredPopover _popover = AnchoredPopover();
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;

  @override
  void initState() {
    super.initState();
    _firstDay = widget.firstDate ?? DateTime(2000);
    _lastDay = widget.lastDate ?? DateTime(2100);
    _selectedDay = _parse(widget.controller.text) ?? widget.initialDate;
    _focusedDay = _selectedDay ?? widget.initialDate ?? DateTime.now();
  }

  DateTime? _parse(String text) {
    if (text.isEmpty) return null;
    try {
      return DateFormat(widget.format).parse(text);
    } catch (_) {
      return DateTime.tryParse(text);
    }
  }

  void _openPicker(BuildContext context) {
    _popover.show(
      target: context,
      width: 320,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setPopState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableCalendar(
                  firstDay: _firstDay,
                  lastDay: _lastDay,
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon:
                        const Icon(Iconsax.arrow_left_2, size: 16),
                    rightChevronIcon:
                        const Icon(Iconsax.arrow_right_3, size: 16),
                    titleTextStyle: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w600),
                    headerPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
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
                  onDaySelected: (selected, focused) {
                    setPopState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                    widget.controller.text =
                        DateFormat(widget.format).format(selected);
                    _popover.dismiss();
                  },
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          widget.controller.clear();
                          _popover.dismiss();
                        },
                        child: const Text('Clear'),
                      ),
                      TextButton(
                        onPressed: _popover.dismiss,
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
  }

  @override
  Widget build(BuildContext context) {
    return _popover.anchor(
      MyTextFormField(
        controller: widget.controller,
        title: widget.title,
        hintText: widget.hintText,
        readOnly: true,
        trailing: const Icon(Iconsax.calendar_1, size: 18),
        onTap: () => _openPicker(context),
      ),
    );
  }
}
