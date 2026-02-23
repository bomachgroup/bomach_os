import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/model/branch_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/branch_controller.dart';
import 'add_branch_dialog.dart';

class ViewBranchDialog extends StatefulWidget {
  const ViewBranchDialog({super.key});

  @override
  State<ViewBranchDialog> createState() => _ViewBranchDialogState();
}

class _ViewBranchDialogState extends State<ViewBranchDialog> {
  final BranchController controller = Get.find<BranchController>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
        child: Obx(() {
          if (controller.isLoadingDetail.value) {
            return const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final branch = controller.currentBranch.value;
          if (branch == null) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Text("No branch data available"),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            branch.branchName,
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildStatusTag(branch.operationalStatusDisplay),
                              const SizedBox(width: 8),
                              MyText(
                                "ID: #${branch.id}",
                                size: 12,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // --- Body ---
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Core Details
                      _buildSectionTitle("Branch Details"),
                      const SizedBox(height: 16),
                      _buildInfoRow("Type", branch.branchRoleDisplay),
                      const SizedBox(height: 12),
                      _buildInfoRow("Branch ID (System)", branch.branchId),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                          "Status",
                          branch.isOperational
                              ? "Operational"
                              : "Non-Operational"),
                      const SizedBox(height: 12),
                      _buildInfoRow("Notes",
                          branch.notes.isNotEmpty ? branch.notes : "N/A"),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Section 2: Location & Contact
                      _buildSectionTitle("Location & Contact"),
                      const SizedBox(height: 16),
                      _buildInfoRow("Address", branch.officeAddress),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                          "LGA / State", "${branch.lga}, ${branch.stateName}"),
                      const SizedBox(height: 12),
                      _buildInfoRow("Country", branch.countryName),
                      const SizedBox(height: 12),
                      _buildInfoRow("Email", branch.contactEmail),
                      const SizedBox(height: 12),
                      _buildInfoRow("Phone", branch.contactPhone),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Section 3: Management
                      _buildSectionTitle("Management"),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                branch.managerName.isNotEmpty
                                    ? branch.managerName
                                    : "Unassigned",
                                weight: 600,
                                size: 14,
                              ),
                              const MyText("Branch Manager",
                                  size: 12, color: Colors.grey),
                            ],
                          )
                        ],
                      ),

                      // Section 4: Performance (Optional, if data exists)
                      if (controller.currentPerformance.value != null) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        _buildSectionTitle("Performance Overview"),
                        const SizedBox(height: 16),
                        _buildPerformanceMetrics(
                            controller.currentPerformance.value!),
                      ]
                    ],
                  ),
                ),
              ),

              // --- Footer ---
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyElevatedButton(
                      width: 120,
                      child: "Edit Branch",
                      onTap: () {
                        Navigator.pop(context);
                        controller
                            .loadFilterResources(); // Reload resources for edit form
                        showDialog(
                          context: context,
                          builder: (_) => AddBranchDialog(branchToEdit: branch),
                        );
                      },
                    ),
                  ],
                ),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : "-",
            style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag(String status) {
    Color color = Colors.grey;
    if (status.toLowerCase().contains('active') ||
        status.toLowerCase().contains('operational')) {
      color = Colors.green;
    } else if (status.toLowerCase().contains('inactive') ||
        status.toLowerCase().contains('closed')) {
      color = Colors.red;
    } else if (status.toLowerCase().contains('maintenance')) {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BranchPerformance performance) {
    // Check if metrics map is empty or valid
    final metrics = performance.metrics;
    if (metrics.isEmpty)
      return const Text("No metrics available",
          style: TextStyle(color: Colors.grey));

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: metrics.entries.map((e) {
        return Container(
          padding: const EdgeInsets.all(12),
          width: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.key.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "${e.value}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
