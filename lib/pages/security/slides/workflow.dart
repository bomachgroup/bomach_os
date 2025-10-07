import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../dialogs/workflow_approval.dart';
import '../model.dart';

class Workflows extends StatelessWidget {
  final bool isMobile;
  const Workflows({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.people_alt_outlined,
                              color: Colors.black, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: MyText(
                              'Approval Workflows (${mockWorkflows.length})',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      MyText(
                        'Configure automated approval processes',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (!isMobile)
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const CreateApprovalWorkflowDialog();
                        },
                      );
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Create Workflow',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  )
                else
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const CreateApprovalWorkflowDialog();
                        },
                      );
                    },
                    icon: const Icon(Icons.add, size: 20),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                  )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mockWorkflows.length,
              itemBuilder: (context, index) {
                return WorkflowTile(workflow: mockWorkflows[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WorkflowTile extends StatelessWidget {
  final ApprovalWorkflow workflow;

  const WorkflowTile({super.key, required this.workflow});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Inactive':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(workflow.status);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: MyText(
                        workflow.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusTag(workflow.status, statusColor),
                  ],
                ),
                const SizedBox(height: 6),
                MyText(
                  workflow.description,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 6),
                MyText(
                  'Approver: ${workflow.approver}  •  Condition: ${workflow.condition}  •  Created: ${workflow.createdDate}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.4),
                            width: 1),
                        borderRadius: BorderRadius.circular(7))),
                icon: const Icon(Icons.settings_outlined, size: 20),
                onPressed: () {},
                tooltip: 'Settings',
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.4),
                            width: 1),
                        borderRadius: BorderRadius.circular(7))),
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {},
                tooltip: 'Edit Workflow',
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.4),
                            width: 1),
                        borderRadius: BorderRadius.circular(7))),
                icon: const Icon(CupertinoIcons.trash, size: 20),
                onPressed: () {},
                tooltip: 'Delete Workflow',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
