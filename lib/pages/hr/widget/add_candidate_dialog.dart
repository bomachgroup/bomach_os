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

import '../controller/applicant_controller.dart';
import '../models/applicant_model.dart';

class AddCandidateDialog extends StatefulWidget {
  final Applicant? applicant; // Optional for Edit Mode
  const AddCandidateDialog({super.key, this.applicant});

  @override
  State<AddCandidateDialog> createState() => _AddCandidateDialogState();
}

class _AddCandidateDialogState extends State<AddCandidateDialog> {
  final ApplicantController controller = Get.find<ApplicantController>();
  int _currentStep = 0;
  final List<String> _tabs = [
    "Personal Info",
    "Professional Info",
    "Application Info",
  ];

  // Controllers (Step 1)
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();

  // Controllers (Step 2)
  final _currentRoleCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _institutionCtrl = TextEditingController();

  // Controllers (Step 3)
  final _jobIdCtrl = TextEditingController();
  final _expectedSalaryCtrl = TextEditingController();
  final _coverLetterCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.applicant != null) {
      _populateFields(widget.applicant!);
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _linkedinCtrl.dispose();
    _portfolioCtrl.dispose();
    _currentRoleCtrl.dispose();
    _skillsCtrl.dispose();
    _institutionCtrl.dispose();
    _jobIdCtrl.dispose();
    _expectedSalaryCtrl.dispose();
    _coverLetterCtrl.dispose();
    super.dispose();
  }

  void _populateFields(Applicant app) {
    _fullNameCtrl.text = "${app.firstName} ${app.lastName}";
    _emailCtrl.text = app.email;
    _phoneCtrl.text = app.phone;
    _linkedinCtrl.text = app.linkedinUrl ?? '';
    _portfolioCtrl.text = app.portfolioUrl ?? '';
    _coverLetterCtrl.text = app.coverLetter ?? '';
    _jobIdCtrl.text = app.jobPostingId;
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    // Basic Split Name Logic
    final nameParts = _fullNameCtrl.text.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    // Update Controller Fields
    controller.firstNameController.text = firstName;
    controller.lastNameController.text = lastName;
    controller.emailController.text = _emailCtrl.text;
    controller.phoneController.text = _phoneCtrl.text;
    controller.linkedinController.text = _linkedinCtrl.text;
    controller.portfolioController.text = _portfolioCtrl.text;
    controller.coverLetterController.text = _coverLetterCtrl.text;
    controller.jobIdController.text = _jobIdCtrl.text;

    await controller.saveApplicant(context, id: widget.applicant?.id);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.applicant != null;

    return DialogScaffold(
      title: isEditing ? 'Edit Candidate' : 'New Candidate',
      subtitle: isEditing
          ? 'Update applicant details.'
          : 'Manually add an applicant to the pipeline.',
      size: DialogSize.lg,
      bodyPadding: EdgeInsets.zero,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabBar(),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildStepContent(),
          ),
        ],
      ),
      actions: [
        if (_currentStep > 0)
          MyOutlinedButton(
            child: 'Previous',
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            onTap: () => setState(() => _currentStep--),
            textColor: AppColors.textSecondary,
            borderColor: AppColors.borderStrong,
          ),
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        Obx(() => MyElevatedButton(
              height: 44,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              isLoading: controller.isSaving.value,
              icon: _currentStep == 2
                  ? const Icon(Iconsax.tick_circle,
                      size: 18, color: AppColors.textOnPrimary)
                  : const Icon(Iconsax.arrow_right_3,
                      size: 18, color: AppColors.textOnPrimary),
              child: _currentStep == 2
                  ? (isEditing ? 'Update Candidate' : 'Submit Application')
                  : 'Next Step',
              onTap: controller.isSaving.value ? () {} : _nextStep,
            )),
      ],
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isActive = index == _currentStep;
          return Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: InkWell(
              onTap: () => setState(() => _currentStep = index),
              borderRadius: AppRadii.brSm,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _tabs[index],
                      style: AppTextStyles.bodyMd.copyWith(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 2,
                      width: 30,
                      color: isActive
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(label, style: AppTextStyles.h4),
    );
  }

  // Step 1: Personal Info
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Contact Details'),
        MyTextFormField(
          title: 'Full Name',
          hintText: 'Enter full name',
          controller: _fullNameCtrl,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MyTextFormField(
                title: 'Email',
                hintText: 'email@example.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MyTextFormField(
                title: 'Phone Number',
                hintText: '+234...',
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        MyTextFormField(
          title: 'Address/Location',
          hintText: 'Street, city, state',
          controller: _addressCtrl,
        ),
        const SizedBox(height: 24),
        _sectionLabel('Social Presence'),
        Row(
          children: [
            Expanded(
              child: MyTextFormField(
                title: 'LinkedIn Profile',
                hintText: 'https://linkedin.com/in/...',
                controller: _linkedinCtrl,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MyTextFormField(
                title: 'Portfolio/Website',
                hintText: 'https://...',
                controller: _portfolioCtrl,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Step 2: Professional Info
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Experience & Skills'),
        Row(
          children: [
            Expanded(
              child: MyTextFormField(
                title: 'Current Job Title',
                hintText: 'e.g. Senior Developer',
                controller: _currentRoleCtrl,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: MyDropdown(
                title: 'Years of Experience',
                hintText: 'Select',
                items: ['0-1', '1-3', '3-5', '5-10', '10+'],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        MyTextFormField(
          title: 'Key Skills (Comma separated)',
          hintText: 'e.g. Flutter, Dart, Firebase',
          controller: _skillsCtrl,
        ),
        const SizedBox(height: 24),
        _sectionLabel('Education'),
        Row(
          children: [
            const Expanded(
              child: MyDropdown(
                title: 'Highest Qualification',
                hintText: 'Select',
                items: [
                  'High School',
                  "Bachelor's",
                  "Master's",
                  'PhD',
                  'Other'
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MyTextFormField(
                title: 'Institution',
                hintText: 'University / School name',
                controller: _institutionCtrl,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Step 3: Application Info
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Application Details'),
        MyTextFormField(
          title: 'Job Posting ID*',
          hintText: 'Enter valid Job ID (e.g. 101)',
          controller: _jobIdCtrl,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: MyDropdown(
                title: 'Source',
                hintText: 'Select',
                items: [
                  'Internal',
                  'Referral',
                  'Job Board',
                  'Social',
                  'Other'
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MyTextFormField(
                title: 'Expected Salary',
                hintText: 'e.g. 500000',
                controller: _expectedSalaryCtrl,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        MyTextFormField(
          title: 'Cover Letter / Notes',
          hintText: 'Add a cover letter or notes',
          maxLines: 4,
          controller: _coverLetterCtrl,
        ),
      ],
    );
  }
}
