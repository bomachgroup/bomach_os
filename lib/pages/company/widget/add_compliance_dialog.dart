import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../src/model/company_model.dart';
import '../controllers/company_controller.dart';

class AddComplianceDialog extends StatefulWidget {
  final Compliance? compliance;

  const AddComplianceDialog({super.key, this.compliance});

  @override
  State<AddComplianceDialog> createState() => _AddComplianceDialogState();
}

class _AddComplianceDialogState extends State<AddComplianceDialog> {
  final CompanyController controller = Get.find<CompanyController>();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController fullNameCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController phoneCtrl;
  late final TextEditingController departmentCtrl;
  late final TextEditingController typeCtrl;
  late final TextEditingController refNumberCtrl;
  late final TextEditingController issueDateDisplayCtrl;
  late final TextEditingController expiryDateDisplayCtrl;
  late final TextEditingController issuingAuthCtrl;
  late final TextEditingController descriptionCtrl;
  late final TextEditingController contactPersonCtrl;
  late final TextEditingController contactEmailCtrl;
  late final TextEditingController costCtrl;
  late final TextEditingController priorityCtrl;

  String _issueDateApi = '';
  String _expiryDateApi = '';

  bool get isEditing => widget.compliance != null;

  static final _displayFormat = DateFormat('MMM d, yyyy');
  static final _apiFormat = DateFormat('yyyy-MM-dd');

  static const _complianceTypeMap = {
    'Real Estate License': 'real_estate_license',
    'Broker License': 'broker_license',
    'Property Manager License': 'property_manager_license',
    'Fair Housing Certification': 'fair_housing_certification',
    'Continuing Education': 'continuing_education',
  };

  static final _complianceTypeReverseMap = {
    for (final e in _complianceTypeMap.entries) e.value: e.key,
  };

  @override
  void initState() {
    super.initState();
    final c = widget.compliance;
    fullNameCtrl = TextEditingController(text: c?.fullName ?? '');
    emailCtrl = TextEditingController(text: c?.emailAddress ?? '');
    phoneCtrl = TextEditingController(text: c?.phoneNumber ?? '');
    departmentCtrl = TextEditingController(text: c?.departmentId ?? '');
    typeCtrl = TextEditingController(
        text: c != null
            ? (_complianceTypeReverseMap[c.complianceType] ?? c.complianceType)
            : '');
    refNumberCtrl = TextEditingController(text: c?.referenceNumber ?? '');
    issuingAuthCtrl = TextEditingController(text: c?.issuingAuthority ?? '');
    descriptionCtrl = TextEditingController(text: c?.description ?? '');
    contactPersonCtrl = TextEditingController(text: c?.contactPerson ?? '');
    contactEmailCtrl = TextEditingController(text: c?.contactEmail ?? '');
    costCtrl =
        TextEditingController(text: c != null && c.cost > 0 ? '${c.cost}' : '');
    priorityCtrl = TextEditingController(text: c?.priorityLevel ?? '');

    if (c != null) {
      _issueDateApi = c.dateOfIssue;
      _expiryDateApi = c.expiryDate;
      issueDateDisplayCtrl =
          TextEditingController(text: _toDisplay(c.dateOfIssue));
      expiryDateDisplayCtrl =
          TextEditingController(text: _toDisplay(c.expiryDate));
    } else {
      issueDateDisplayCtrl = TextEditingController();
      expiryDateDisplayCtrl = TextEditingController();
    }
  }

  String _toDisplay(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      return _displayFormat.format(_apiFormat.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    departmentCtrl.dispose();
    typeCtrl.dispose();
    refNumberCtrl.dispose();
    issueDateDisplayCtrl.dispose();
    expiryDateDisplayCtrl.dispose();
    issuingAuthCtrl.dispose();
    descriptionCtrl.dispose();
    contactPersonCtrl.dispose();
    contactEmailCtrl.dispose();
    costCtrl.dispose();
    priorityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: isEditing
          ? 'Edit Compliance/Registration'
          : 'New Compliance/Registration',
      subtitle: 'Complete the form below to track regulatory documents.',
      size: DialogSize.lg,
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Type
            MyDropdown(
              title: 'Type',
              hintText: 'Select document type',
              controller: typeCtrl,
              items: _complianceTypeMap.keys.toList(),
              onChanged: (val) => typeCtrl.text = val ?? '',
              validator: (val) =>
                  (val == null || val.isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Full Name + Email
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MyTextFormField(
                    controller: fullNameCtrl,
                    title: 'Full Name',
                    hintText: 'Enter full name',
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyTextFormField(
                    controller: emailCtrl,
                    title: 'Email Address',
                    hintText: 'email@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Phone + Department
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MyTextFormField(
                    controller: phoneCtrl,
                    title: 'Phone Number',
                    hintText: '+234...',
                    keyboardType: TextInputType.phone,
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyTextFormField(
                    controller: departmentCtrl,
                    title: 'Department ID',
                    hintText: 'Enter department',
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reference Number + Issuing Authority
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MyTextFormField(
                    controller: refNumberCtrl,
                    title: 'Reference Number',
                    hintText: 'e.g. RC 123456',
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyTextFormField(
                    controller: issuingAuthCtrl,
                    title: 'Issuing Authority',
                    hintText: 'e.g. CAC Nigeria',
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dates
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildDatePicker(
                    issueDateDisplayCtrl,
                    'Date of Issue',
                    (apiDate) => _issueDateApi = apiDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDatePicker(
                    expiryDateDisplayCtrl,
                    'Expiry Date',
                    (apiDate) => _expiryDateApi = apiDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Contact Person + Contact Email
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MyTextFormField(
                    controller: contactPersonCtrl,
                    title: 'Contact Person',
                    hintText: 'Enter name',
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyTextFormField(
                    controller: contactEmailCtrl,
                    title: 'Contact Email',
                    hintText: 'contact@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Cost + Priority
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MyTextFormField(
                    controller: costCtrl,
                    title: 'Cost',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyDropdown(
                    title: 'Priority Level',
                    hintText: 'Select priority',
                    controller: priorityCtrl,
                    items: const ['low', 'medium', 'high'],
                    onChanged: (val) => priorityCtrl.text = val ?? '',
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            MyTextFormField(
              controller: descriptionCtrl,
              title: 'Description',
              hintText: 'Enter additional details...',
              maxLines: 3,
              validator: (val) =>
                  (val == null || val.isEmpty) ? 'Required' : null,
            ),
          ],
        ),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context),
        ),
        Obx(() => MyElevatedButton(
              width: 120,
              height: 44,
              child: controller.isSaving.value ? 'Saving...' : 'Save Record',
              onTap: controller.isSaving.value ? null : _onSave,
            )),
      ],
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final compliance = Compliance(
      id: widget.compliance?.id ?? '',
      fullName: fullNameCtrl.text.trim(),
      emailAddress: emailCtrl.text.trim(),
      phoneNumber: phoneCtrl.text.trim(),
      departmentId: departmentCtrl.text.trim(),
      complianceType: _complianceTypeMap[typeCtrl.text] ?? typeCtrl.text,
      referenceNumber: refNumberCtrl.text.trim(),
      dateOfIssue: _issueDateApi,
      expiryDate: _expiryDateApi,
      issuingAuthority: issuingAuthCtrl.text.trim(),
      status: widget.compliance?.status ?? 'active',
      description: descriptionCtrl.text.trim(),
      contactPerson: contactPersonCtrl.text.trim(),
      contactEmail: contactEmailCtrl.text.trim(),
      cost: num.tryParse(costCtrl.text) ?? 0,
      priorityLevel: priorityCtrl.text,
      documents: widget.compliance?.documents ?? [],
    );

    if (isEditing) {
      controller.updateCompliance(context, widget.compliance!.id, compliance);
    } else {
      controller.createCompliance(context, compliance);
    }
  }

  Widget _buildDatePicker(
    TextEditingController displayCtrl,
    String label,
    void Function(String apiDate) onDatePicked,
  ) {
    return InkWell(
      onTap: () async {
        DateTime initial = DateTime.now();
        if (displayCtrl.text.isNotEmpty) {
          try {
            initial = _displayFormat.parse(displayCtrl.text);
          } catch (_) {
            try {
              initial = _apiFormat.parse(displayCtrl.text);
            } catch (_) {}
          }
        }
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            displayCtrl.text = _displayFormat.format(picked);
            onDatePicked(_apiFormat.format(picked));
          });
        }
      },
      child: IgnorePointer(
        child: MyTextFormField(
          controller: displayCtrl,
          title: label,
          hintText: 'Select date',
          trailing: const Icon(Iconsax.calendar_1,
              color: AppColors.textMuted, size: 20),
        ),
      ),
    );
  }
}
