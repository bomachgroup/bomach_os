import 'package:bms_front_end/components/button/my_elevated_button.dart'
    show MyElevatedButton;
import 'package:bms_front_end/pages/legal/controllers/compliance_controller.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/pages/legal/detailed_view.dart';
import 'package:bms_front_end/pages/legal/models/compliance_record_model.dart';
import 'package:bms_front_end/pages/legal/widgets/status_tag.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/input/my_textformfield.dart';
import '../../components/text/my_text.dart';
import '../../src/constants/colors.dart';
import '../../src/constants/spaces.dart';
import 'dialogs/add_compliance.dart';

class CompliancePageView extends StatelessWidget {
  const CompliancePageView({super.key});

  void _openDialog(BuildContext context, {ComplianceRecord? record}) {
    showDialog(
      context: context,
      builder: (context) => AddComplianceItemDialog(record: record),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ComplianceController());

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Column(
          children: [
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Compliance Management',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      const Text(
                          'Track regulatory and legal compliance requirements',
                          style:
                              TextStyle(fontSize: 13, color: Colors.black54)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              hintText: 'Search compliance...',
                              leading: Icon(
                                Iconsax.search_normal,
                                color: AppColors.neutral500.withValues(alpha: 0.5),
                              ),
                              onChanged: controller.onSearchChanged,
                            ),
                          ),
                          const SizedBox(width: 8),
                          MyElevatedButton(
                            child: 'Add Compliance Item',
                            onTap: () => _openDialog(context),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Compliance Management',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          SizedBox(height: 2),
                          MyText(
                              'Track regulatory and legal compliance requirements',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 250,
                              child: MyTextFormField(
                                hintText: 'Search compliance...',
                                leading: Icon(
                                  Iconsax.search_normal,
                                  color: AppColors.neutral500.withValues(alpha: 0.5),
                                ),
                                onChanged: controller.onSearchChanged,
                              ),
                            ),
                            const SizedBox(width: 12),
                            MyElevatedButton(
                              child: 'Add Compliance Item',
                              onTap: () => _openDialog(context),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
            kSizedBoxBG,
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.recordList.isEmpty) {
                  return const Center(
                    child: Text('No compliance records found.',
                        style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: controller.recordList.length,
                  itemBuilder: (context, index) {
                    final record = controller.recordList[index];
                    return _ComplianceRecordCard(
                      record: record,
                      onView: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailsViewPage(
                              title: record.fullName,
                              details: {
                                'Full Name': record.fullName,
                                'Email': record.emailAddress,
                                'Phone': record.phoneNumber,
                                'Compliance Type': record.complianceType,
                                'Reference Number':
                                    record.referenceNumber ?? 'N/A',
                                'Issuing Authority': record.issuingAuthority,
                                'Status': record.status,
                                'Priority': record.priorityLevel ?? 'N/A',
                                'Date of Issue': record.dateOfIssue,
                                'Expiry Date': record.expiryDate,
                                'Days Until Expiry':
                                    record.daysUntilExpiry.toString(),
                                'Description': record.description ?? 'N/A',
                                'Contact Person': record.contactPerson ?? 'N/A',
                                'Contact Email': record.contactEmail ?? 'N/A',
                                'Cost': record.cost ?? 'N/A',
                              },
                            ),
                          ),
                        );
                      },
                      onEdit: () => _openDialog(context, record: record),
                      onDelete: () {
                        DialogScaffold.show(
      context,
      title: 'Delete Record',
      size: DialogSize.sm,
      body: Text(
                                'Delete compliance record for "${record.fullName}"?'),
      actions: [TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  controller.deleteRecord(context, record.id);
                                },
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),],
    );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _ComplianceRecordCard extends StatelessWidget {
  final ComplianceRecord record;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ComplianceRecordCard({
    required this.record,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'compliant':
        return Colors.green;
      case 'expired':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _priorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.deepOrange;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Card(
          elevation: 1,
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onView,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            MyText(record.fullName,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            StatusTag(
                                text: record.status,
                                color: _statusColor(record.status)),
                            StatusTag(
                                text: record.complianceType,
                                color: Colors.black),
                            if (record.priorityLevel != null)
                              StatusTag(
                                  text: record.priorityLevel!,
                                  color: _priorityColor(record.priorityLevel)),
                            if (record.isExpired)
                              const StatusTag(
                                  text: 'Expired', color: Colors.red),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildField('Authority', record.issuingAuthority),
                        _buildField('Type', record.complianceType),
                        _buildField(
                            'Reference', record.referenceNumber ?? 'N/A'),
                        _buildField('Expiry', record.expiryDate),
                        _buildField('Days Until Expiry',
                            record.daysUntilExpiry.toString()),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _actionButton(
                                Iconsax.eye, 'View', onView),
                            const SizedBox(width: 8),
                            _actionButton(Iconsax.edit, 'Edit', onEdit),
                            const SizedBox(width: 8),
                            _actionButton(
                                Iconsax.trash, 'Delete', onDelete,
                                color: Colors.red),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  MyText(record.fullName,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(width: 8),
                                  StatusTag(
                                      text: record.status,
                                      color: _statusColor(record.status)),
                                  const SizedBox(width: 8),
                                  StatusTag(
                                      text: record.complianceType,
                                      color: Colors.black),
                                  if (record.priorityLevel != null) ...[
                                    const SizedBox(width: 8),
                                    StatusTag(
                                        text: record.priorityLevel!,
                                        color: _priorityColor(
                                            record.priorityLevel)),
                                  ],
                                  if (record.isExpired) ...[
                                    const SizedBox(width: 8),
                                    const StatusTag(
                                        text: 'Expired', color: Colors.red),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildField('Authority',
                                            record.issuingAuthority),
                                        _buildField(
                                            'Type', record.complianceType),
                                        _buildField('Reference',
                                            record.referenceNumber ?? 'N/A'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildField('Date of Issue',
                                            record.dateOfIssue),
                                        _buildField(
                                            'Expiry Date', record.expiryDate),
                                        _buildField('Days Until Expiry',
                                            record.daysUntilExpiry.toString()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _actionButton(
                                Iconsax.eye, 'View', onView),
                            const SizedBox(width: 8),
                            _actionButton(Iconsax.edit, 'Edit', onEdit),
                            const SizedBox(width: 8),
                            _actionButton(
                                Iconsax.trash, 'Delete', onDelete,
                                color: Colors.red),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onPressed,
      {Color color = Colors.black}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}
