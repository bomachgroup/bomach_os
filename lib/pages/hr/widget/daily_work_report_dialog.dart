import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/work_report_controller.dart';
import '../models/work_report_model.dart';


class DailyWorkReportDialog extends StatefulWidget {
  final WorkReport? existingReport;
  final String token;

  const DailyWorkReportDialog({
    super.key,
    this.existingReport,
    required this.token,
  });

  @override
  State<DailyWorkReportDialog> createState() => _DailyWorkReportDialogState();
}

class _DailyWorkReportDialogState extends State<DailyWorkReportDialog> {
  final WorkReportController controller = Get.find();

  late TextEditingController _challengesController;
  late TextEditingController _achievementsController;
  late TextEditingController _nextDayPlanController;
  late TextEditingController _employeeIdController;
  late TextEditingController _hoursWorkedController;

  String _selectedMood = 'neutral';
  DateTime _reportDate = DateTime.now();

  // API accepts: happy, neutral, sad, stressed, tired, frustrated
  final Map<String, String> _moodOptions = {
    'Happy': 'happy',
    'Neutral': 'neutral',
    'Sad': 'sad',
    'Stressed': 'stressed',
    'Tired': 'tired',
    'Frustrated': 'frustrated',
  };

  @override
  void initState() {
    super.initState();
    final r = widget.existingReport;
    _challengesController = TextEditingController(text: r?.challenges ?? '');
    _achievementsController = TextEditingController(text: r?.achievements ?? '');
    _nextDayPlanController = TextEditingController(text: r?.planNextDay ?? '');
    _employeeIdController = TextEditingController(text: r?.employeeId ?? '');
    _hoursWorkedController = TextEditingController(text: r?.hoursWorked.toString() ?? '');
    
    _selectedMood = r?.mood.isNotEmpty == true ? r!.mood.toLowerCase() : 'neutral';
    _reportDate = r?.day ?? DateTime.now();
  }

  @override
  void dispose() {
    _challengesController.dispose();
    _achievementsController.dispose();
    _nextDayPlanController.dispose();
    _employeeIdController.dispose();
    _hoursWorkedController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _reportDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _reportDate) {
      setState(() {
        _reportDate = picked;
      });
    }
  }

  void _handleSubmit() async {
    if (_employeeIdController.text.isEmpty || _hoursWorkedController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Employee ID and Hours are required"), backgroundColor: Colors.red));
      return;
    }

    final report = WorkReport(
      id: widget.existingReport?.id ?? '',
      employeeId: _employeeIdController.text,
      day: _reportDate,
      hoursWorked: double.tryParse(_hoursWorkedController.text) ?? 0.0,
      mood: _selectedMood,
      challenges: _challengesController.text,
      achievements: _achievementsController.text,
      planNextDay: _nextDayPlanController.text,
      status: 'submitted',
      rating: widget.existingReport?.rating ?? 0,
      feedback: widget.existingReport?.feedback,
    );

    bool success;
    if (widget.existingReport != null) {
      success = await controller.updateReport(widget.token, widget.existingReport!.id, report);
    } else {
      success = await controller.createReport(widget.token, report);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report submitted"), backgroundColor: Colors.green));
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to submit"), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   MyText(widget.existingReport == null ? 'New Work Report' : 'Edit Work Report', style: AppText.black_500_20),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: MyTextFormField(title: 'Employee ID *', controller: _employeeIdController)),
                        const SizedBox(width: 16),
                        Expanded(child: MyTextFormField(title: 'Hours Worked *', controller: _hoursWorkedController, keyboardType: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                         Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const MyText('Report Date', style: AppText.black_600_14),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _selectDate,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0XFFD5D5D5)),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey.shade50,
                                    ),
                                    child: MyText(DateFormat('MMM dd, yyyy').format(_reportDate), style: AppText.black_400_14),
                                  ),
                                ),
                              ],
                            ),
                         ),
                         const SizedBox(width: 16),
                         Expanded(
                            child: MyDropdown(
                              title: 'Mood',
                              items: _moodOptions.keys.toList(),
                              hintText: _moodOptions.entries
                                  .firstWhere((e) => e.value == _selectedMood,
                                      orElse: () => const MapEntry('Neutral', 'neutral'))
                                  .key,
                              onChanged: (val) => setState(() =>
                                  _selectedMood = _moodOptions[val] ?? 'neutral'),
                            ),
                         ),
                      ],
                    ),
                    kSizedBox,
                    MyTextFormField(title: 'Challenges', controller: _challengesController, maxLines: 3),
                    kSizedBox,
                    MyTextFormField(title: 'Achievements', controller: _achievementsController, maxLines: 3),
                    kSizedBox,
                    MyTextFormField(title: 'Next Day Plan', controller: _nextDayPlanController, maxLines: 3),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    child: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => MyElevatedButton(
                    child: controller.isSaving.value ? 'Submitting...' : 'Submit',
                    onTap: controller.isSaving.value ? () {} : _handleSubmit,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}