import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/employees_controller.dart';

class EmployeeAppraisalDialog extends StatefulWidget {
  final String userId;

  const EmployeeAppraisalDialog({super.key, required this.userId});

  @override
  State<EmployeeAppraisalDialog> createState() =>
      _EmployeeAppraisalDialogState();
}

class _EmployeeAppraisalDialogState extends State<EmployeeAppraisalDialog> {
  final EmployeeController controller = Get.find<EmployeeController>();

  // Ratings State
  int jobKnowledge = 0;
  int communication = 0;
  int problemSolving = 0;
  int teamwork = 0;
  int initiative = 0;
  int qualityOfWork = 0;

  final _achievementsCtrl = TextEditingController();
  final _improvementsCtrl = TextEditingController();
  final _developmentCtrl = TextEditingController();
  String _selectedPeriod = 'Q4 2025';

  @override
  void dispose() {
    _achievementsCtrl.dispose();
    _improvementsCtrl.dispose();
    _developmentCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final overallRating =
        ((jobKnowledge + communication + problemSolving + teamwork + initiative + qualityOfWork) / 6)
            .round();

    final data = {
      'review_period': _selectedPeriod,
      'job_knowledge': jobKnowledge,
      'communication': communication,
      'problem_solving': problemSolving,
      'teamwork': teamwork,
      'initiative': initiative,
      'quality_of_work': qualityOfWork,
      'overall_rating': overallRating,
      'rating': overallRating,
      'key_achievements': _achievementsCtrl.text,
      'areas_for_improvement': _improvementsCtrl.text,
      'development_plan': _developmentCtrl.text,
    };

    controller.createReview(context, widget.userId, data);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText('Employee Appraisal Form',
                      size: 18, weight: 700),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                        const Icon(Icons.close, size: 20, color: Colors.grey),
                  )
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Review Period
                    _buildDropdownField("Review Period", _selectedPeriod,
                        ['Q1 2025', 'Q2 2025', 'Q3 2025', 'Q4 2025', 'Q1 2026'],
                        (v) => setState(() => _selectedPeriod = v!)),
                    const SizedBox(height: 24),

                    const MyText('Performance Ratings',
                        size: 14, weight: 600),
                    const SizedBox(height: 16),
                    _buildRatingRow("Job Knowledge", jobKnowledge,
                        (v) => setState(() => jobKnowledge = v)),
                    _buildRatingRow("Communication", communication,
                        (v) => setState(() => communication = v)),
                    _buildRatingRow("Problem Solving", problemSolving,
                        (v) => setState(() => problemSolving = v)),
                    _buildRatingRow("Teamwork", teamwork,
                        (v) => setState(() => teamwork = v)),
                    _buildRatingRow("Initiative", initiative,
                        (v) => setState(() => initiative = v)),
                    _buildRatingRow("Quality of Work", qualityOfWork,
                        (v) => setState(() => qualityOfWork = v)),

                    const SizedBox(height: 24),
                    _buildTextArea("Key Achievements",
                        "Write the details here", _achievementsCtrl),
                    const SizedBox(height: 16),
                    _buildTextArea("Areas for Improvement",
                        "Write the details here", _improvementsCtrl),
                    const SizedBox(height: 16),
                    _buildTextArea("Development Plan",
                        "Write the details here", _developmentCtrl),
                  ],
                ),
              ),
            ),

            const Divider(height: 1),
            // Footer Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: MyOutlinedButton(
                      child: 'Cancel',
                      textColor: const Color(0xFF0055FF),
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Obx(() => MyElevatedButton(
                      child: controller.isSaving.value
                          ? 'Submitting...'
                          : 'Add Review',
                      bgColor: const Color(0xFF0055FF),
                      onTap: controller.isSaving.value ? null : _onSubmit,
                    )),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(label, size: 12, weight: 600, color: Colors.black87),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
          items: items
              .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildRatingRow(
      String label, int currentRating, Function(int) onRate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
              width: 140, child: MyText(label, size: 13, weight: 500)),
          Row(
            children: List.generate(5, (index) {
              return InkWell(
                onTap: () => onRate(index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(
                    index < currentRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildTextArea(
      String label, String hint, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(label, size: 13, weight: 600),
        const SizedBox(height: 8),
        Container(
          height: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: null,
            decoration: InputDecoration.collapsed(
              hintText: hint,
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }
}
