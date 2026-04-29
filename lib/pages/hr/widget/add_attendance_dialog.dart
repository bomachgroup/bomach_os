import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controller/biometrics_controller.dart';

class AddAttendanceDialog extends StatefulWidget {
  final String token;
  const AddAttendanceDialog({super.key, required this.token});

  @override
  State<AddAttendanceDialog> createState() => _AddAttendanceDialogState();
}

class _AddAttendanceDialogState extends State<AddAttendanceDialog> {
  final BiometricsController controller = Get.find<BiometricsController>();
  final _formKey = GlobalKey<FormState>();
  final _employeeIdCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _attendanceType = 'CLOCK_IN';

  static const _typeLabels = {
    'CLOCK_IN': 'Clock In',
    'CLOCK_OUT': 'Clock Out',
  };

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // final combinedTimestamp = DateTime(_selectedDate.year, _selectedDate.month,
    //     _selectedDate.day, _selectedTime.hour, _selectedTime.minute);

    // final record = BiometricAttendanceRecord(
    //   id: 0,
    //   employeeId: _employeeIdCtrl.text,
    //   attendanceType: _attendanceType,
    //   timestamp: combinedTimestamp,
    //   verificationMethod: 'MANUAL',
    //   notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
    // );

    // final success = await controller.createManualAttendance(widget.token, record);

    if (mounted) {
      Navigator.pop(context);
      AppToast.success(context, 'Record added successfully');
    }
  }

  @override
  void dispose() {
    _employeeIdCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Add Manual Entry',
      subtitle: 'Record an attendance entry manually for this employee.',
      size: DialogSize.md,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Employee',
              children: [
                MyTextFormField(
                  title: 'Employee ID',
                  hintText: 'e.g. EMP001',
                  spaceBetweenText: 8,
                  controller: _employeeIdCtrl,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                MyDropdown(
                  title: 'Type',
                  hintText: _typeLabels[_attendanceType] ?? 'Select type',
                  initialSelection: _typeLabels[_attendanceType],
                  spaceBetweenText: 8,
                  items: _typeLabels.values.toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    final key = _typeLabels.entries
                        .firstWhere((e) => e.value == val,
                            orElse: () => const MapEntry('CLOCK_IN', ''))
                        .key;
                    setState(() => _attendanceType = key);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Date & time',
              children: [
                Row(
                  children: [
                    Expanded(
                      child: MyTextFormField(
                        title: 'Date',
                        hintText: 'Select date',
                        spaceBetweenText: 8,
                        controller: TextEditingController(
                          text: DateFormat('yyyy-MM-dd').format(_selectedDate),
                        ),
                        readOnly: true,
                        trailing: const Icon(
                          Iconsax.calendar_1,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) setState(() => _selectedDate = d);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyTextFormField(
                        title: 'Time',
                        hintText: 'Select time',
                        spaceBetweenText: 8,
                        controller: TextEditingController(
                          text: _selectedTime.format(context),
                        ),
                        readOnly: true,
                        trailing: const Icon(
                          Iconsax.clock,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                        onTap: () async {
                          final t = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (t != null) setState(() => _selectedTime = t);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Notes',
              children: [
                MyTextFormField(
                  title: 'Notes (optional)',
                  hintText: 'Add additional context about this entry',
                  spaceBetweenText: 8,
                  controller: _notesCtrl,
                  maxLines: 3,
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          onTap: () => Navigator.pop(context),
        ),
        Obx(() => MyElevatedButton(
              height: 44,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              icon: controller.isLoading.value
                  ? null
                  : const Icon(Iconsax.tick_circle,
                      size: 18, color: AppColors.textOnPrimary),
              child: controller.isLoading.value ? 'Saving...' : 'Save',
              onTap: controller.isLoading.value ? null : _submit,
            )),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
