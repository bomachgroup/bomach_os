import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';

import '../controller/biometrics_controller.dart';
import '../models/attendance_models.dart';

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

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final combinedTimestamp = DateTime(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, _selectedTime.hour, _selectedTime.minute);

    final record = BiometricAttendanceRecord(
      id: 0,
      employeeId: _employeeIdCtrl.text,
      attendanceType: _attendanceType,
      timestamp: combinedTimestamp,
      verificationMethod: 'MANUAL',
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
    );

    // final success = await controller.createManualAttendance(widget.token, record);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Record added successfully"),
          backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MyText('Add Manual Entry', size: 20, weight: 600),
              const SizedBox(height: 24),

              MyTextFormField(
                title: 'Employee ID',
                controller: _employeeIdCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              const MyText('Type', size: 14, weight: 500),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _attendanceType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'CLOCK_IN', child: Text('Clock In')),
                  DropdownMenuItem(
                      value: 'CLOCK_OUT', child: Text('Clock Out')),
                ],
                onChanged: (val) => setState(() => _attendanceType = val!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now());
                        if (d != null) setState(() => _selectedDate = d);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Date', border: OutlineInputBorder()),
                        child: Text(
                            DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final t = await showTimePicker(
                            context: context, initialTime: _selectedTime);
                        if (t != null) setState(() => _selectedTime = t);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Time', border: OutlineInputBorder()),
                        child: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: 'Notes (Optional)',
                controller: _notesCtrl,
                maxLines: 2,
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                      child: 'Cancel', onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  Obx(() => MyElevatedButton(
                        child:
                            controller.isLoading.value ? 'Saving...' : 'Save',
                        onTap: controller.isLoading.value ? null : _submit,
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
