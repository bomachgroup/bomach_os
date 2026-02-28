import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/loans_model.dart';

class ViewLoanDialog extends StatelessWidget {
  final LoanRequest loan;

  const ViewLoanDialog({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    // Colors from design
    final greenColor = const Color(0xFF00C853);
    final redColor = const Color(0xFFD32F2F);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    'Loan Application',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, color: Colors.grey),
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
                                child: Text(loan.employeeName[0],
                                    style: const TextStyle(
                                        color: Color(0xFF1976D2),
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(loan.employeeName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(loan.employeeRole,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 13)),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Loan Info Box
                          const Text("Loan info",
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
                                _buildGridRow(
                                    "Loan Amount",
                                    NumberFormat.currency(
                                            symbol: '₦', decimalDigits: 0)
                                        .format(loan.amount),
                                    "Repayment Date",
                                    DateFormat('dd/MM/yyyy')
                                        .format(loan.repaymentDate)),
                                const SizedBox(height: 20),
                                _buildGridRow(
                                    "Emergency Contact Name",
                                    "Evelyn Chisom",
                                    "Emergency Contact Phone",
                                    "0803 1265 4789"),
                                const SizedBox(height: 20),
                                // Handover Section (Inside box per design)
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("Handover to",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500)),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                  radius: 12,
                                                  backgroundImage: NetworkImage(
                                                      'https://i.pravatar.cc/150?img=5')),
                                              SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text("Evelyn George",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13)),
                                                  Text("Software Engineer",
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.grey)),
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        child:
                                            Container()), // Spacer for grid alignment
                                  ],
                                )
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Reason Section
                          const Text("Reason For Loan",
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
                              loan.reason,
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
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Loan Approved"),
                                        backgroundColor: Colors.green));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: greenColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  elevation: 0),
                              child: const Text("Approve",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Reject Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Loan Rejected"),
                                        backgroundColor: Colors.red));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: redColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  elevation: 0),
                              child: const Text("Reject",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),

                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 24),

                          // Documents Section
                          const Text("Documents",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: const Color(0xFFE0E0E0))),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFE3F2FD),
                                      borderRadius: BorderRadius.circular(4)),
                                  child: const Center(
                                      child: Text("JPEG",
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1976D2)))),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Resume upload",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                      Text("image file  0.23KB",
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.remove_red_eye_outlined,
                                    size: 18, color: Colors.grey),
                                const SizedBox(width: 8),
                                const Icon(Icons.download_outlined,
                                    size: 18, color: Colors.grey),
                              ],
                            ),
                          )
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
}
