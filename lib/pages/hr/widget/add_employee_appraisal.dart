import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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

  static const _periodOptions = [
    'Q1 2025',
    'Q2 2025',
    'Q3 2025',
    'Q4 2025',
    'Q1 2026',
  ];

  @override
  void dispose() {
    _achievementsCtrl.dispose();
    _improvementsCtrl.dispose();
    _developmentCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final overallRating = ((jobKnowledge +
                communication +
                problemSolving +
                teamwork +
                initiative +
                qualityOfWork) /
            6)
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
    return DialogScaffold(
      title: 'Employee Appraisal Form',
      subtitle: 'Rate performance, capture achievements, and outline next steps.',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSection(
            title: 'Review Period',
            child: MyDropdown(
              hintText: 'Select review period',
              items: _periodOptions,
              initialSelection: _selectedPeriod,
              onChanged: (v) {
                if (v != null) setState(() => _selectedPeriod = v);
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Performance Ratings',
            subtitle: 'Tap a star to rate each competency from 1 to 5.',
            child: Column(
              children: [
                _buildRatingRow('Job Knowledge', jobKnowledge,
                    (v) => setState(() => jobKnowledge = v)),
                _buildRatingRow('Communication', communication,
                    (v) => setState(() => communication = v)),
                _buildRatingRow('Problem Solving', problemSolving,
                    (v) => setState(() => problemSolving = v)),
                _buildRatingRow('Teamwork', teamwork,
                    (v) => setState(() => teamwork = v)),
                _buildRatingRow('Initiative', initiative,
                    (v) => setState(() => initiative = v)),
                _buildRatingRow('Quality of Work', qualityOfWork,
                    (v) => setState(() => qualityOfWork = v)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Notes & Plan',
            child: Column(
              children: [
                MyTextFormField(
                  title: 'Key Achievements',
                  controller: _achievementsCtrl,
                  hintText: 'Write the details here',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  title: 'Areas for Improvement',
                  controller: _improvementsCtrl,
                  hintText: 'Write the details here',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                MyTextFormField(
                  title: 'Development Plan',
                  controller: _developmentCtrl,
                  hintText: 'Write the details here',
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),
        Obx(() => MyElevatedButton(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              isLoading: controller.isSaving.value,
              child: 'Add Review',
              onTap: controller.isSaving.value ? null : _onSubmit,
            )),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.h4),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildRatingRow(
      String label, int currentRating, Function(int) onRate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppText.label),
          ),
          Material(
            color: Colors.transparent,
            child: Row(
              children: List.generate(5, (index) {
                return InkWell(
                  borderRadius: AppRadii.brSm,
                  onTap: () => onRate(index + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      index < currentRating ? Iconsax.star1 : Iconsax.star,
                      color: index < currentRating
                          ? AppColors.warning
                          : AppColors.neutral300,
                      size: 22,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
