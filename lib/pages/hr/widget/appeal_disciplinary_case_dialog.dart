import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/models/disciplinary_process_models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class AppealDisciplinaryCaseDialog extends StatefulWidget {
  final DisciplinaryCaseRecord caseRecord;
  final Function(DisciplinaryCaseRecord) onSubmit;

  const AppealDisciplinaryCaseDialog({
    super.key,
    required this.caseRecord,
    required this.onSubmit,
  });

  @override
  State<AppealDisciplinaryCaseDialog> createState() =>
      _AppealDisciplinaryCaseDialogState();
}

class _AppealDisciplinaryCaseDialogState
    extends State<AppealDisciplinaryCaseDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _appealReasonController =
      TextEditingController();
  final TextEditingController _additionalDetailsController =
      TextEditingController();
  final TextEditingController _evidenceController = TextEditingController();
  String? _selectedAppealGrounds;

  final List<String> _appealGrounds = [
    'Procedural Irregularity',
    'Insufficient Evidence',
    'Disproportionate Punishment',
    'Mitigating Circumstances',
    'Factual Error',
    'New Evidence',
    'Discrimination',
    'Other',
  ];

  @override
  void dispose() {
    _appealReasonController.dispose();
    _additionalDetailsController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  void _submitAppeal() {
    if (_formKey.currentState!.validate() &&
        _selectedAppealGrounds != null) {
      final updatedCase = DisciplinaryCaseRecord(
        caseId: widget.caseRecord.caseId,
        employeeId: widget.caseRecord.employeeId,
        employeeName: widget.caseRecord.employeeName,
        employeeEmail: widget.caseRecord.employeeEmail,
        department: widget.caseRecord.department,
        position: widget.caseRecord.position,
        branch: widget.caseRecord.branch,
        actionType: widget.caseRecord.actionType,
        violation: widget.caseRecord.violation,
        description: widget.caseRecord.description,
        dateOfViolation: widget.caseRecord.dateOfViolation,
        dateInitiated: widget.caseRecord.dateInitiated,
        effectiveDate: widget.caseRecord.effectiveDate,
        status: 'Appealed',
        suspensionStartDate: widget.caseRecord.suspensionStartDate,
        suspensionEndDate: widget.caseRecord.suspensionEndDate,
        suspensionDays: widget.caseRecord.suspensionDays,
        terminationReason: widget.caseRecord.terminationReason,
        severancePaymentDue: widget.caseRecord.severancePaymentDue,
        severanceAmount: widget.caseRecord.severanceAmount,
        investigationDetails: widget.caseRecord.investigationDetails,
        investigatedBy: widget.caseRecord.investigatedBy,
        approvedBy: widget.caseRecord.approvedBy,
        approvalDate: widget.caseRecord.approvalDate,
        employeeStatement: widget.caseRecord.employeeStatement,
        witnessStatements: widget.caseRecord.witnessStatements,
        appealFiled: true,
        appealReason: _appealReasonController.text,
        appealStatus: 'Pending',
      );

      widget.onSubmit(updatedCase);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: MyText('Appeal submitted successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText(
                    'Appeal Disciplinary Case',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Case Information Section
                        const MyText(
                          'Case Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.greyBg,
                            border: Border.all(color: AppColors.grey5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const MyText(
                                    'Case ID:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.grey1,
                                    ),
                                  ),
                                  MyText(
                                    widget.caseRecord.caseId,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const MyText(
                                    'Violation:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.grey1,
                                    ),
                                  ),
                                  MyText(
                                    widget.caseRecord.violation,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const MyText(
                                    'Action Type:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.grey1,
                                    ),
                                  ),
                                  MyText(
                                    widget.caseRecord.actionType.displayName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const MyText(
                                    'Current Status:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.grey1,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.caseRecord.status ==
                                              'Completed'
                                          ? AppColors.red.withValues(alpha: 0.15)
                                          : AppColors.green
                                              .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: MyText(
                                      widget.caseRecord.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: widget.caseRecord.status ==
                                                'Completed'
                                            ? AppColors.red
                                            : AppColors.green,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Appeal Grounds Section
                        const MyText(
                          'Appeal Grounds',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const MyText(
                          'Select the primary reason for your appeal',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: 'Select appeal grounds',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          value: _selectedAppealGrounds,
                          items: _appealGrounds
                              .map((ground) => DropdownMenuItem<String>(
                                    value: ground,
                                    child: MyText(ground),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedAppealGrounds = value);
                          },
                          validator: (value) =>
                              value == null ? 'Please select appeal grounds' : null,
                        ),
                        const SizedBox(height: 24),

                        // Appeal Details Section
                        const MyText(
                          'Appeal Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        MyTextFormField(
                          hintText: 'Primary reason for appeal',
                          controller: _appealReasonController,
                          maxLines: 3,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please provide your appeal reason'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        MyTextFormField(
                          hintText:
                              'Additional details or supporting information',
                          controller: _additionalDetailsController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        MyTextFormField(
                          hintText:
                              'Evidence or documentation (describe any attachments)',
                          controller: _evidenceController,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),

                        // Important Notice
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withValues(alpha: 0.1),
                            border: Border.all(color: AppColors.orange),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                'Important Notice',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.orange,
                                ),
                              ),
                              SizedBox(height: 8),
                              MyText(
                                'By submitting this appeal, you acknowledge that all information provided is true and accurate. False or misleading statements may result in further disciplinary action. Your appeal will be reviewed by the appropriate management and a decision will be communicated within 7 business days.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Checkbox for acknowledgment
                        Row(
                          children: [
                            Checkbox(
                              value: true,
                              onChanged: (value) {},
                              side: const BorderSide(
                                color: AppColors.grey3,
                              ),
                            ),
                            const Expanded(
                              child: MyText(
                                'I acknowledge that the information provided is true and accurate',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Footer
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 12,
                children: [
                  MyOutlinedButton(
                    child: 'Cancel',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  MyElevatedButton(
                    child: 'Submit Appeal',
                    onTap: _submitAppeal,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
