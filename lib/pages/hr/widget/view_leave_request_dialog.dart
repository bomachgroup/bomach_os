import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class ViewLeaveRequestDialog extends StatefulWidget {
  const ViewLeaveRequestDialog({super.key});

  @override
  State<ViewLeaveRequestDialog> createState() => _ViewLeaveRequestDialogState();
}

class _ViewLeaveRequestDialogState extends State<ViewLeaveRequestDialog> {
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
                    'Leave Request Details',
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
                      _buildDetailRow('Employee ID', 'K997KD'),
                      _buildDetailRow('Employee Name', 'John Michael'),
                      _buildDetailRow('Leave Type', 'Sick Leave'),
                      _buildDetailRow('Start Date', '15, July 2025'),
                      _buildDetailRow('End Date', '15, July 2025'),
                      _buildDetailRow('Status', 'Pending'),

                      _buildDetailRow('Reason',
                          'This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. '),

                      _buildDetailRow('', 'All Employees'),

                      Row(
                        children: [
                          SizedBox(
                            width: 200,
                            child: MyText(
                              "Approver ID",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  width: 36,
                                  height: 36,
                                  child: Image.asset(
                                      'assets/icons/profile-icon.png'),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText(
                                      "Darlene Robertson",
                                      size: 16,
                                      weight: 400,
                                      isSelectable: false,
                                    ),
                                    MyText("Jenny group of company",
                                        size: 14, weight: 300)
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _buildDetailRow('Rejection Reason',
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
                            Navigator.pop(context);
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
