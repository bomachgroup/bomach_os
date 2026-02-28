import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/leave_request_controller.dart';
import '../models/leave_request_model.dart';

class ViewLeaveRequestDialog extends StatefulWidget {
  final LeaveRequest request;
  const ViewLeaveRequestDialog({super.key, required this.request});

  @override
  State<ViewLeaveRequestDialog> createState() => _ViewLeaveRequestDialogState();
}

class _ViewLeaveRequestDialogState extends State<ViewLeaveRequestDialog> {
  final LeaveRequestController _ctrl = Get.find<LeaveRequestController>();

  void _confirmReject(BuildContext context, int requestId) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reject Request"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Are you sure you want to reject this request?"),
            const SizedBox(height: 16),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: "Reason for rejection (Optional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close confirmation dialog
              _ctrl.updateLeaveStatus(context, requestId, 'rejected',
                  rejectionReason: reasonCtrl.text);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F)),
            child: const Text("Reject", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;

    // Colors from design
    final greenColor = const Color(0xFF00C853);
    final redColor = const Color(0xFFD32F2F);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxWidth: 950, maxHeight: 600),
        child: Column(
          children: [
            // --- Header ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Leave Application',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            // --- Body (Two Columns) ---
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Left Column: Info ---
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFE3F2FD),
                                child: Text(
                                    r.employeeId.isNotEmpty
                                        ? r.employeeId[0].toUpperCase()
                                        : "U",
                                    style: const TextStyle(
                                        color: Color(0xFF1976D2),
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.employeeId,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const Text(
                                    "Senior Software Engineer",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 13),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Leave Info
                          const Text("Leave info",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFEEEEEE))),
                            child: Column(
                              children: [
                                _buildGridRow("Leave Type", r.leaveType,
                                    "Start Date", _fmtDate(r.startDate)),
                                const SizedBox(height: 20),
                                _buildGridRow(
                                    "Emergency Contact Name",
                                    "Evelyn Chisom",
                                    "Emergency Contact Phone",
                                    "0803 1265 4789"),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Reason
                          const Text("Reason For Leave",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xFFEEEEEE))),
                            child: Text(
                              r.reason ?? "No reason provided.",
                              style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Vertical Divider
                  Container(width: 1, color: const Color(0xFFEEEEEE)),

                  // --- Right Column: Actions ---
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      color: const Color(0xFFFAFBFC),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Actions",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 16),

                          // Approve Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: Obx(() => ElevatedButton(
                                  onPressed:
                                      _ctrl.isSaving.value || r.id == null
                                          ? null
                                          : () => _ctrl.updateLeaveStatus(
                                              context, r.id!, 'approved'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: greenColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      elevation: 0),
                                  child: _ctrl.isSaving.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2))
                                      : const Text("Approve",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                )),
                          ),
                          const SizedBox(height: 12),

                          // Reject Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: Obx(() => ElevatedButton(
                                  onPressed: _ctrl.isSaving.value ||
                                          r.id == null
                                      ? null
                                      : () => _confirmReject(context, r.id!),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: redColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      elevation: 0),
                                  child: _ctrl.isSaving.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2))
                                      : const Text("Reject",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                )),
                          ),
                        ],
                      ),
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

  Widget _buildGridRow(String l1, String v1, String l2, String v2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l1,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(v1,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l2,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(v2,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return "-";
    return DateFormat('dd/MM/yyyy').format(d);
  }
}
