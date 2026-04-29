import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
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
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 0,
          ),
          child: const Text('Send Message'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _DropdownWithLabel(
                label: 'Type',
                value: 'Message',
                items: ['Message', 'Notification', 'Alert'],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _DropdownWithLabel(
                label: 'Priority',
                value: 'Normal',
                items: ['Normal', 'High', 'Urgent'],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _DropdownWithLabel(
          label: 'Client',
          value: 'Select Client',
          items: [
            'Select Client',
            'Lagos State Government',
            'Dangote Group',
            'FCDA'
          ],
        ),
        SizedBox(height: 16),
        MyTextFormField(
          title: 'Title *',
          hintText: 'Enter message title',
        ),
        SizedBox(height: 16),
        MyTextFormField(
          title: 'Message *',
          hintText: 'Type your message here...',
          maxLines: 4,
        ),
      ],
    );
  }
}

class _DropdownWithLabel extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;

  const _DropdownWithLabel({
    required this.label,
    required this.value,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        MyDropdown(
          hintText: value,
          items: items,
          onChanged: (String? newValue) {},
        ),
      ],
    );
  }
}
