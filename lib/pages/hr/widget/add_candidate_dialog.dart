import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    "Application Info"
  ];

  // Controllers (Step 1)
  final _fullNameCtrl = TextEditingController(); // Split into First/Last logic
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController(); // Not in model, maybe notes?
  final _linkedinCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();

  // Controllers (Step 2)
  final _currentRoleCtrl = TextEditingController(); // Not in model directly
  final _skillsCtrl = TextEditingController(); // Not in model directly
  final _institutionCtrl = TextEditingController(); // Not in model

  // Controllers (Step 3)
  final _jobIdCtrl = TextEditingController(); // Required
  final _expectedSalaryCtrl = TextEditingController(); // Not in model
  final _coverLetterCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.applicant != null) {
      _populateFields(widget.applicant!);
    }
  }

  void _populateFields(Applicant app) {
    _fullNameCtrl.text = "${app.firstName} ${app.lastName}";
    _emailCtrl.text = app.email;
    _phoneCtrl.text = app.phone;
    _linkedinCtrl.text = app.linkedinUrl ?? '';
    _portfolioCtrl.text = app.portfolioUrl ?? '';
    _coverLetterCtrl.text = app.coverLetter ?? '';
    _jobIdCtrl.text = app.jobPostingId;
    // Map other fields if backend supports them later
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
    controller.jobIdController.text = _jobIdCtrl.text; // Ensure Job ID is set

    // Save
    await controller.saveApplicant(context, id: widget.applicant?.id);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 700,
        height: 700,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                          widget.applicant == null
                              ? 'Add New Candidate'
                              : 'Edit Candidate',
                          size: 20,
                          weight: 700),
                      const SizedBox(height: 4),
                      MyText(
                          widget.applicant == null
                              ? 'Manually add an applicant to the pipeline.'
                              : 'Update applicant details.',
                          size: 13,
                          color: Colors.grey.shade600),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isActive = index == _currentStep;
                  return GestureDetector(
                    onTap: () => setState(() => _currentStep = index),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24.0),
                      child: Column(
                        children: [
                          Text(
                            _tabs[index],
                            style: TextStyle(
                              color: isActive
                                  ? const Color(0xFF0055FF)
                                  : Colors.grey.shade600,
                              fontWeight:
                                  isActive ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (isActive)
                            Container(
                                height: 2,
                                width: 30,
                                color: const Color(0xFF0055FF))
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentStep > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: MyOutlinedButton(
                        child: 'Previous',
                        textColor: Colors.black87,
                        onTap: () => setState(() => _currentStep--),
                      ),
                    ),
                  MyOutlinedButton(
                    child: 'Cancel',
                    textColor: Colors.black87,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => MyElevatedButton(
                        width: 160,
                        bgColor: const Color(0xFF0055FF),
                        child: controller.isSaving.value
                            ? 'Saving...'
                            : (_currentStep == 2
                                ? (widget.applicant == null
                                    ? 'Submit Application'
                                    : 'Update Candidate')
                                : 'Next Step'),
                        onTap: controller.isSaving.value ? null : _nextStep,
                      )),
                ],
              ),
            )
          ],
        ),
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

  // Step 1: Personal Info
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText('Contact Details', weight: 700, size: 14),
        const SizedBox(height: 16),
        MyTextFormField(
            title: 'Full Name', hintText: 'Type', controller: _fullNameCtrl),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: MyTextFormField(
                    title: 'Email', hintText: 'Type', controller: _emailCtrl)),
            const SizedBox(width: 16),
            Expanded(
                child: MyTextFormField(
                    title: 'Phone Number',
                    hintText: 'Type',
                    controller: _phoneCtrl)),
          ],
        ),
        const SizedBox(height: 16),
        MyTextFormField(
            title: 'Address/Location',
            hintText: 'Type',
            controller: _addressCtrl),
        const SizedBox(height: 24),
        const MyText('Social Presence', weight: 700, size: 14),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: MyTextFormField(
                    title: 'LinkedIn Profile',
                    hintText: 'Type',
                    controller: _linkedinCtrl)),
            const SizedBox(width: 16),
            Expanded(
                child: MyTextFormField(
                    title: 'Portfolio/Website',
                    hintText: 'Type',
                    controller: _portfolioCtrl)),
          ],
        ),
      ],
    );
  }

  // Step 2: Professional Info (Visual Only for now as API doesn't support these fields)
  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText('Experience & Skills', weight: 700, size: 14),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: MyTextFormField(
                    title: 'Current Job Title',
                    hintText: 'Type',
                    controller: _currentRoleCtrl)),
            const SizedBox(width: 16),
            Expanded(child: _buildDropdown('Years of Experience', 'Select')),
          ],
        ),
        const SizedBox(height: 16),
        MyTextFormField(
            title: 'Key Skills (Comma separated)',
            hintText: 'Type',
            controller: _skillsCtrl),
        const SizedBox(height: 24),
        const MyText('Education', weight: 700, size: 14),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildDropdown('Highest Qualification', 'Select')),
            const SizedBox(width: 16),
            Expanded(
                child: MyTextFormField(
                    title: 'Institution',
                    hintText: 'Type',
                    controller: _institutionCtrl)),
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
        const MyText('Application Details', weight: 700, size: 14),
        const SizedBox(height: 16),
        // Important: Needs real Job ID for API
        MyTextFormField(
            title: 'Job Posting ID *',
            hintText: 'Enter valid Job ID (e.g. 101)',
            controller: _jobIdCtrl),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildDropdown('Source', 'Select')),
            const SizedBox(width: 16),
            Expanded(
                child: MyTextFormField(
                    title: 'Expected Salary',
                    hintText: 'Type',
                    controller: _expectedSalaryCtrl)),
          ],
        ),
        const SizedBox(height: 16),
        MyTextFormField(
            title: 'Cover Letter / Notes',
            hintText: 'Type',
            maxLines: 3,
            controller: _coverLetterCtrl),
      ],
    );
  }

  Widget _buildDropdown(String title, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(title, size: 13, weight: 600),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hint,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }
}
