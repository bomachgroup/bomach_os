import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/leave_request_controller.dart';
import '../models/leave_request_model.dart';
import 'add_leave_request_dialog.dart';

class ViewLeaveRequestDialog extends StatefulWidget {
  final LeaveRequest request;
  const ViewLeaveRequestDialog({super.key, required this.request});

  @override
  State<ViewLeaveRequestDialog> createState() => _ViewLeaveRequestDialogState();
}

class _ViewLeaveRequestDialogState extends State<ViewLeaveRequestDialog> {
  final ScrollController _scrollController = ScrollController();
  final LeaveRequestController _ctrl = Get.find<LeaveRequestController>();

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
    final r = widget.request;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
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
                      _buildDetailRow('Employee ID', r.employeeId),
                      _buildDetailRow('Leave Type', r.leaveType),
                      _buildDetailRow(
                          'Start Date',
                          r.startDate != null
                              ? r.startDate!.toIso8601String().split('T').first
                              : ''),
                      _buildDetailRow(
                          'End Date',
                          r.endDate != null
                              ? r.endDate!.toIso8601String().split('T').first
                              : ''),
                      _buildDetailRow('Status', r.status ?? ''),
                      _buildDetailRow('Reason', r.reason ?? ''),
                      _buildDetailRow('Approver ID', r.approverId ?? ''),
                      _buildDetailRow(
                          'Approval Date',
                          r.approvalDate != null
                              ? r.approvalDate!
                                  .toIso8601String()
                                  .split('T')
                                  .first
                              : ''),
                      _buildDetailRow(
                          'Rejection Reason', r.rejectionReason ?? ''),

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
              child: Obx(() {
                if (_ctrl.isLoading.value) {
                  return const SizedBox(
                    height: 50,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return Row(
                  children: [
                    MyElevatedButton(
                      bgColor: AppColors.red,
                      child: 'Delete',
                      onTap: () {
                        _showDeleteConfirmation(context);
                      },
                    ),
                    const SizedBox(width: 16),
                    MyElevatedButton(
                      child: 'Edit',
                      onTap: () {
                        _ctrl.populateForm(r);
                        showDialog(
                          context: context,
                          builder: (_) => AddLeaveRequestDialog(request: r),
                        );
                      },
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Leave Request'),
        content: const Text(
            'Are you sure you want to delete this leave request? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _ctrl.deleteRequest(context, widget.request.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}
