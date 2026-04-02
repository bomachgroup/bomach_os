import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class CreateNewLegalCaseDialog extends StatelessWidget {
  const CreateNewLegalCaseDialog({super.key});

// Found new way of calling the dialogs
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateNewLegalCaseDialog(),
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
        'Create New Legal Case',
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
              _buildFormLabel('Case Title'),
              _buildTextInput(hint: 'e.g Land Surveying'),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildFormLabel('Case Type'),
                        MyDropdown(
                          hintText: 'Legal',
                          items: const [
                            'Legal',
                            'Civil',
                            'Criminal',
                            'Regulatory'
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
                        _buildFormLabel('Priority'),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildFormLabel('Court Name'),
                        _buildTextInput(hint: ''),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildFormLabel('Jurisdiction'),
                        _buildTextInput(hint: ''),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFormLabel('Status'),
              MyDropdown(
                hintText: 'Open',
                items: const ['Open', 'Pending', 'Closed', 'Archived'],
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
            backgroundColor: AppColors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
          ),
          child:
              const Text('Create Case', style: TextStyle(color: Colors.white)),
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
}
