import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

import '../../../src/constants/colors.dart';

class CreateNewAuditDialog extends StatelessWidget {
  const CreateNewAuditDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateNewAuditDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final double dialogWidth = isMobile ? screenWidth * 0.9 : 450;
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Create New Audit',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 16.0, 16.0),
      actionsPadding: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
      content: SingleChildScrollView(
        child: SizedBox(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildFormLabel('Audit Name'),
              _buildTextInput(hint: ''),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildFormLabel('Audit Type'),
                        MyDropdown(
                          hintText: 'Legal',
                          items: const [
                            'Legal',
                            'Financial',
                            'Safety',
                            'Operational'
                          ],
                          onChanged: (String? newValue) {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildFormLabel('Risk Level'),
                        MyDropdown(
                          hintText: 'Medium',
                          items: const ['Critical', 'High', 'Medium', 'Low'],
                          onChanged: (String? newValue) {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFormLabel('Lead Auditor'),
              _buildTextInput(hint: ''),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildFormLabel('Planned Start Date'),
                        _buildDateInput(date: 'mm/dd/yyyy', context: context),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildFormLabel('Planned End Date'),
                        _buildDateInput(date: 'mm/dd/yyyy', context: context),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFormLabel('Status'),
              MyDropdown(
                hintText: 'Planned',
                items: const [
                  'Planned',
                  'In Progress',
                  'Completed',
                  'Canceled'
                ],
                onChanged: (String? newValue) {},
              ),
              const SizedBox(height: 16),
              _buildFormLabel('Case Description'),
              _buildMultiLineTextInput(hint: ''),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
          ),
          child:
              const Text('Create Audit', style: TextStyle(color: Colors.white)),
        ),
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

  Widget _buildTextInput({String? hint, String? initialValue}) {
    return TextFormField(
      initialValue: initialValue,
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

  Widget _buildMultiLineTextInput({String? hint}) {
    return TextFormField(
      maxLines: 4,
      minLines: 3,
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

  Widget _buildDateInput(
      {required String date, required BuildContext context}) {
    return TextFormField(
      readOnly: true,
      initialValue: date,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: const Icon(Iconsax.calendar_1, size: 20),
          onPressed: () async {
            await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
            );
          },
        ),
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
}
