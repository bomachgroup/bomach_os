import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
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
  int? jobKnowledge;
  int? communication;
  int? problemSolving;
  int? teamwork;
  int? initiative;
  int? qualityOfWork;

  final _achievementsCtrl = TextEditingController();
  final _improvementsCtrl = TextEditingController();
  final _developmentCtrl = TextEditingController();
  late int _quarter;
  late int _year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _quarter = ((now.month - 1) ~/ 3) + 1;
    _year = now.year;
  }

  @override
  void dispose() {
    _achievementsCtrl.dispose();
    _improvementsCtrl.dispose();
    _developmentCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final data = {
      'quarter': _quarter,
      'year': _year,
      if (jobKnowledge != null) 'job_knowledge': jobKnowledge,
      if (communication != null) 'communication': communication,
      if (problemSolving != null) 'problem_solving': problemSolving,
      if (teamwork != null) 'teamwork': teamwork,
      if (initiative != null) 'initiative': initiative,
      if (qualityOfWork != null) 'quality_of_work': qualityOfWork,
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
            child: Row(
              children: [
                Expanded(
                  child: MyDropdown(
                    hintText: 'Quarter',
                    items: const ['1', '2', '3', '4'],
                    initialSelection: _quarter.toString(),
                    onChanged: (v) {
                      if (v != null) setState(() => _quarter = int.parse(v));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MyDropdown(
                    hintText: 'Year',
                    items: List.generate(5, (index) => '${DateTime.now().year - 2 + index}'),
                    initialSelection: _year.toString(),
                    onChanged: (v) {
                      if (v != null) setState(() => _year = int.parse(v));
                    },
                  ),
                ),
              ],
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
          Text(title, style: AppTextStyles.h4),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildRatingRow(
      String label, int? currentRating, Function(int) onRate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.label),
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
                      index < (currentRating ?? 0) ? Iconsax.star1 : Iconsax.star,
                      color: index < (currentRating ?? 0)
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
