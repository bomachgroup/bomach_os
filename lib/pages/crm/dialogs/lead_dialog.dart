import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/crm_controller.dart';

class AddNewLeadDialog extends StatefulWidget {
  const AddNewLeadDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddNewLeadDialog(),
    );
  }

  @override
  State<AddNewLeadDialog> createState() => _AddNewLeadDialogState();
}

class _AddNewLeadDialogState extends State<AddNewLeadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _servicesCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _source = 'other';

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _companyCtrl.dispose();
    _servicesCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final controller = Get.find<CrmController>();
    controller.createLead(context, {
      'email': _emailCtrl.text.trim(),
      'first_name': _firstNameCtrl.text.trim(),
      'last_name': _lastNameCtrl.text.trim(),
      'phone_number':
          _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      'company_name':
          _companyCtrl.text.trim().isEmpty ? null : _companyCtrl.text.trim(),
      'interested_services': _servicesCtrl.text.trim(),
      'source': _source,
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final double dialogWidth = isMobile ? screenWidth * 0.9 : 450;

    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Add New Lead',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 16.0, 16.0),
      actionsPadding: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('First Name *'),
                          _input(_firstNameCtrl, 'First name', required: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Last Name *'),
                          _input(_lastNameCtrl, 'Last name', required: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Email *'),
                          _input(_emailCtrl, 'email@example.com',
                              required: true,
                              keyboardType: TextInputType.emailAddress),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Phone'),
                          _input(_phoneCtrl, '+234...',
                              keyboardType: TextInputType.phone),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Company'),
                          _input(_companyCtrl, 'Company name'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyDropdown(
                        title: 'Source',
                        hintText: _source.isEmpty ? 'Select Source' : _source,
                        items: const [
                          'website',
                          'referral',
                          'cold_call',
                          'event',
                          'social_media',
                          'other'
                        ],
                        onChanged: (val) =>
                            setState(() => _source = val ?? 'other'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _label('Interested Services *'),
                _input(_servicesCtrl, 'e.g. Land Survey, Building Design',
                    required: true),
                const SizedBox(height: 16),
                _label('Notes'),
                _multiInput(_notesCtrl),
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
          final controller = Get.find<CrmController>();
          return ElevatedButton(
            onPressed: controller.isSaving.value ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
            ),
            child: controller.isSaving.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Add Lead', style: TextStyle(color: Colors.white)),
          );
        }),
      ],
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      );

  Widget _input(TextEditingController ctrl, String hint,
      {bool required = false,
      TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
          : null,
      decoration: InputDecoration(
        hintText: hint,
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _multiInput(TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      maxLines: 4,
      minLines: 3,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
