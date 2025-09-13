import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/dialog/confirm_delete_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class ViewAttendanceDialog extends StatefulWidget {
  const ViewAttendanceDialog({super.key});

  @override
  State<ViewAttendanceDialog> createState() => _ViewAttendanceDialogState();
}

class _ViewAttendanceDialogState extends State<ViewAttendanceDialog> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildDetailRow(String label, String value, {bool isBlue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isBlue ? const Color(0xFF007AFF) : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),

        // width: MediaQuery.of(context).size.width * 0.9,
        // height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Attendance Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 24,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE5E5E5)),

            // Scrollable Content
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Employee ID', 'GHjHJGJ'),
                      _buildDetailRow('Employee Name', 'John Mick'),
                      _buildDetailRow('Email', 'johnmick@gmail.com'),
                      _buildDetailRow('Date', '15, July 2025'),

                      _buildDetailRow('Check-in Time', '08:15:13'),
                      _buildDetailRow('Check-out Time', '08:15:13'),
                      _buildDetailRow('Status', 'Present'),

                      _buildDetailRow('Notes',
                          'This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. '),

                      const SizedBox(height: 100), // Space for bottom buttons
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      alignment: WrapAlignment.end,
                      children: [
                        MyElevatedButton(
                          bgColor: AppColors.red,
                          child: 'Delete',
                          onTap: () {
                            showDeleteDialog(context);
                          },
                        ),
                        MyElevatedButton(
                          child: 'Edit',
                          onTap: () {},
                        ),
                      ],
                    ),
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
