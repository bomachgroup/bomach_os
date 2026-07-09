import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/popover_helper.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

/// A time-picker-backed text field for web.
///
/// Tapping the field opens a dropdown clock popover anchored below the field
/// (instead of the centered Material time picker dialog). The chosen time is
/// written back to [controller] using [format].
class MyTimeField extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final String hintText;

  /// Output format written into [controller]. Defaults to 24h `HH:mm`.
  final String format;

  final TimeOfDay? initialTime;

  const MyTimeField({
    super.key,
    required this.controller,
    required this.title,
    this.hintText = 'HH:mm',
    this.format = 'HH:mm',
    this.initialTime,
  });

  @override
  State<MyTimeField> createState() => _MyTimeFieldState();
}

class _MyTimeFieldState extends State<MyTimeField> {
  final AnchoredPopover _popover = AnchoredPopover();
  late int _hour;
  late int _minute;

  @override
  void initState() {
    super.initState();
    final parsed = _parse(widget.controller.text);
    _hour = parsed?.hour ?? widget.initialTime?.hour ?? TimeOfDay.now().hour;
    _minute =
        parsed?.minute ?? widget.initialTime?.minute ?? TimeOfDay.now().minute;
    // Snap minutes to the nearest 5 for cleaner scrolling defaults.
    _minute = (_minute ~/ 5) * 5;
  }

  TimeOfDay? _parse(String text) {
    if (text.isEmpty) return null;
    try {
      final dt = DateFormat(widget.format).parse(text);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return null;
    }
  }

  void _openPicker(BuildContext context) {
    _popover.show(
      target: context,
      width: 240,
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
                          value: _hour,
                          min: 0,
                          max: 23,
                          onChanged: (v) => setPopState(() => _hour = v),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(':', style: TextStyle(fontSize: 20)),
                      ),
                      Expanded(
                        child: _buildScrollColumn(
                          label: 'Minute',
                          value: _minute,
                          min: 0,
                          max: 59,
                          step: 5,
                          onChanged: (v) => setPopState(() => _minute = v),
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
                        onPressed: () {
                          final time = TimeOfDay(hour: _hour, minute: _minute);
                          final now = DateTime.now();
                          final dt = DateTime(now.year, now.month, now.day,
                              time.hour, time.minute);
                          widget.controller.text =
                              DateFormat(widget.format).format(dt);
                          _popover.dismiss();
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
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
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

  @override
  Widget build(BuildContext context) {
    return _popover.anchor(
      MyTextFormField(
        controller: widget.controller,
        title: widget.title,
        hintText: widget.hintText,
        readOnly: true,
        trailing: const Icon(Iconsax.clock, size: 18),
        onTap: () => _openPicker(context),
      ),
    );
  }
}
