import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class SendMessageDialog extends StatelessWidget {
  const SendMessageDialog({super.key});

  static void show(BuildContext context) {
    DialogScaffold.show(
      context,
      title: 'Send Message',
      size: DialogSize.sm,
      body: const SendMessageDialog(),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text(
            'Send Message',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildFormLabel('Type'),
                  _buildDropdown(
                    value: 'Message',
                    items: const ['Message', 'Notification', 'Alert'],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildFormLabel('Priority'),
                  _buildDropdown(
                    value: 'Normal',
                    items: const ['Normal', 'High', 'Urgent'],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFormLabel('Client'),
        _buildDropdown(
          value: 'Select Client',
          items: const [
            'Select Client',
            'Lagos State Government',
            'Dangote Group',
            'FCDA'
          ],
        ),
        const SizedBox(height: 16),
        _buildFormLabel('Title *'),
        _buildTextInput(hint: ''),
        const SizedBox(height: 16),
        _buildFormLabel('Message *'),
        _buildMultiLineTextInput(hint: ''),
      ],
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
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

  Widget _buildDropdown({required String value, required List<String> items}) {
    return MyDropdown(
      hintText: value,
      items: items,
      onChanged: (String? newValue) {},
    );
  }
}
