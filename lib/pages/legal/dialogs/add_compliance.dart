import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/pages/legal/controllers/compliance_controller.dart';
import 'package:bms_front_end/pages/legal/models/compliance_record_model.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddComplianceItemDialog extends StatefulWidget {
  final ComplianceRecord? record;

  const AddComplianceItemDialog({super.key, this.record});

  @override
  State<AddComplianceItemDialog> createState() =>
      _AddComplianceItemDialogState();
}

class _AddComplianceItemDialogState extends State<AddComplianceItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _authorityCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _referenceCtrl;
  late final TextEditingController _contactPersonCtrl;
  late final TextEditingController _contactEmailCtrl;
  late final TextEditingController _costCtrl;

  String _complianceType = '';
  String _priorityLevel = 'Medium';
  String _status = 'active';
  DateTime? _dateOfIssue;
  DateTime? _expiryDate;

  bool get _isEdit => widget.record != null;

  @override
  void initState() {
    super.initState();
    final r = widget.record;
    _fullNameCtrl = TextEditingController(text: r?.fullName ?? '');
    _emailCtrl = TextEditingController(text: r?.emailAddress ?? '');
    _phoneCtrl = TextEditingController(text: r?.phoneNumber ?? '');
    _authorityCtrl = TextEditingController(text: r?.issuingAuthority ?? '');
    _descriptionCtrl = TextEditingController(text: r?.description ?? '');
    _referenceCtrl = TextEditingController(text: r?.referenceNumber ?? '');
    _contactPersonCtrl = TextEditingController(text: r?.contactPerson ?? '');
    _contactEmailCtrl = TextEditingController(text: r?.contactEmail ?? '');
    _costCtrl = TextEditingController(text: r?.cost ?? '');
    _complianceType = r?.complianceType ?? '';
    _priorityLevel = r?.priorityLevel ?? 'Medium';
    _status = r?.status ?? 'active';

    if (r != null) {
      _dateOfIssue = DateTime.tryParse(r.dateOfIssue);
      _expiryDate = DateTime.tryParse(r.expiryDate);
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _authorityCtrl.dispose();
    _descriptionCtrl.dispose();
    _referenceCtrl.dispose();
    _contactPersonCtrl.dispose();
    _contactEmailCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isIssueDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isIssueDate) {
          _dateOfIssue = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'Select date';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfIssue == null || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both dates')),
      );
      return;
    }

    final controller = Get.find<ComplianceController>();

    final data = {
      'full_name': _fullNameCtrl.text.trim(),
      'email_address': _emailCtrl.text.trim(),
      'phone_number': _phoneCtrl.text.trim(),
      'department_id': 1,
      'compliance_type': _complianceType,
      'reference_number': _referenceCtrl.text.trim().isEmpty
          ? null
          : _referenceCtrl.text.trim(),
      'date_of_issue': _formatDate(_dateOfIssue),
      'expiry_date': _formatDate(_expiryDate),
      'issuing_authority': _authorityCtrl.text.trim(),
      'status': _status,
      'description': _descriptionCtrl.text.trim().isEmpty
          ? null
          : _descriptionCtrl.text.trim(),
      'contact_person': _contactPersonCtrl.text.trim().isEmpty
          ? null
          : _contactPersonCtrl.text.trim(),
      'contact_email': _contactEmailCtrl.text.trim().isEmpty
          ? null
          : _contactEmailCtrl.text.trim(),
      'cost': _costCtrl.text.trim().isEmpty ? null : _costCtrl.text.trim(),
      'priority_level': _priorityLevel,
      'documents': <String>[],
    };

    if (_isEdit) {
      controller.updateRecord(context, widget.record!.id, data);
    } else {
      controller.createRecord(context, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final double dialogWidth = isMobile ? screenWidth * 0.9 : 550;

    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        _isEdit ? 'Edit Compliance Item' : 'Add Compliance Item',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 16.0, 16.0),
      actionsPadding: const EdgeInsets.all(16.0),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
      content: SingleChildScrollView(
        child: SizedBox(
          width: dialogWidth,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormLabel('Full Name *'),
                _buildTextInput(
                    controller: _fullNameCtrl, hint: 'Full name'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel('Email *'),
                          _buildTextInput(
                              controller: _emailCtrl,
                              hint: 'email@example.com'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel('Phone *'),
                          _buildTextInput(
                              controller: _phoneCtrl,
                              hint: '+234...'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel('Type'),
                          MyDropdown(
                            hintText: _complianceType.isEmpty
                                ? 'Select type'
                                : _complianceType,
                            items: const [
                              'Legal',
                              'Safety',
                              'Environmental',
                              'Financial',
                              'Regulatory',
                            ],
                            onChanged: (val) =>
                                setState(() => _complianceType = val ?? ''),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel('Priority Level'),
                          MyDropdown(
                            hintText: _priorityLevel,
                            items: const [
                              'Critical',
                              'High',
                              'Medium',
                              'Low'
                            ],
                            onChanged: (val) =>
                                setState(() => _priorityLevel = val ?? 'Medium'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormLabel('Issuing Authority *'),
                _buildTextInput(
                    controller: _authorityCtrl,
                    hint: 'Regulatory Authority'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel('Date of Issue *'),
                          _buildDateField(_dateOfIssue, () => _pickDate(true)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel('Expiry Date *'),
                          _buildDateField(
                              _expiryDate, () => _pickDate(false)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel('Status'),
                          MyDropdown(
                            hintText: _status,
                            items: const [
                              'active',
                              'expired',
                              'pending',
                              'revoked'
                            ],
                            onChanged: (val) =>
                                setState(() => _status = val ?? 'active'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel('Cost'),
                          _buildTextInput(
                              controller: _costCtrl, hint: '0.00'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFormLabel('Reference Number'),
                _buildTextInput(
                    controller: _referenceCtrl, hint: 'REF-001'),
                const SizedBox(height: 12),
                _buildFormLabel('Description'),
                _buildMultiLineTextInput(controller: _descriptionCtrl),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel('Contact Person'),
                          _buildTextInput(
                              controller: _contactPersonCtrl,
                              hint: 'Name'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormLabel('Contact Email'),
                          _buildTextInput(
                              controller: _contactEmailCtrl,
                              hint: 'email@example.com'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        Obx(() {
          final controller = Get.find<ComplianceController>();
          return ElevatedButton(
            onPressed: controller.isSaving.value ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
            ),
            child: controller.isSaving.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    _isEdit ? 'Update' : 'Add Compliance Item',
                    style: const TextStyle(color: Colors.white),
                  ),
          );
        }),
      ],
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _buildTextInput(
      {required TextEditingController controller, String? hint}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildMultiLineTextInput(
      {required TextEditingController controller}) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      minLines: 3,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildDateField(DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          _formatDate(date),
          style: TextStyle(
              color: date == null ? Colors.grey : Colors.black),
        ),
      ),
    );
  }
}
