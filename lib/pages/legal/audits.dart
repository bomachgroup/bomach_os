import 'package:bomach_os/pages/legal/detailed_view.dart'
    show DetailsViewPage;
import 'package:flutter/material.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';

import '../../components/button/my_elevated_button.dart';
import '../../components/input/my_textformfield.dart';
import '../../components/text/my_text.dart';
import '../../src/constants/colors.dart';
import 'controllers/audit_controller.dart';
import 'dialogs/new_audit.dart';
import 'models/audit_model.dart';

class AuditsPageView extends StatelessWidget {
  const AuditsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuditController());

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Compliance Audits',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        const MyText(
                            'Monitor and manage compliance audits and assessments',
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: MyTextFormField(
                                hintText: 'Search audits...',
                                leading: Icon(
                                  Iconsax.search_normal,
                                  color: AppColors.neutral500.withValues(alpha: 0.5),
                                ),
                                onChanged: controller.onSearchChanged,
                              ),
                            ),
                            const SizedBox(width: 8),
                            MyElevatedButton(
                              child: 'Schedule Audit',
                              onTap: () {
                                CreateNewAuditDialog.show(context);
                              },
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
                            Text('Compliance Audits',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                            SizedBox(height: 2),
                            MyText(
                                'Monitor and manage compliance audits and assessments',
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
                                  hintText: 'Search audits...',
                                  leading: Icon(
                                    Iconsax.search_normal,
                                    color:
                                        AppColors.neutral500.withValues(alpha: 0.5),
                                  ),
                                  onChanged: controller.onSearchChanged,
                                ),
                              ),
                              const SizedBox(width: 12),
                              MyElevatedButton(
                                child: 'Schedule Audit',
                                onTap: () {
                                  CreateNewAuditDialog.show(context);
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.auditList.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Iconsax.task_square,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text("No audits found",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                          SizedBox(height: 4),
                          Text("Schedule a new audit to get started",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                return AuditsTable(
                  isMobile: isMobile,
                  audits: controller.auditList,
                  controller: controller,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class AuditsTable extends StatelessWidget {
  final bool isMobile;
  final List<Audit> audits;
  final AuditController controller;
  const AuditsTable({
    super.key,
    this.isMobile = false,
    required this.audits,
    required this.controller,
  });

  Widget _buildMobileCard(Audit data, BuildContext context) {
    Color statusColor;
    switch (data.statusDisplay.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'in progress':
        statusColor = Colors.orange;
        break;
      case 'scheduled':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    Color scoreColor = Colors.green;
    if (data.score != null) {
      if (data.score! < 80) scoreColor = Colors.orange;
      if (data.score! < 60) scoreColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.auditTypeDisplay,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  data.statusDisplay,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.auditName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Auditor: ${data.auditorName}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              if (data.score != null)
                Text(
                  'Score: ${data.scorePercentage}',
                  style: TextStyle(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Date: ${data.auditDate}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Iconsax.eye, size: 18, color: Colors.black),
                onPressed: () {
                  final Map<String, String> auditDetails = {
                    'Audit Name': data.auditName,
                    'Audit Type': data.auditTypeDisplay,
                    'Audit Number': data.auditNumber ?? 'N/A',
                    'Status': data.statusDisplay,
                    'Score': data.score != null
                        ? '${data.scorePercentage} (${data.scoreCategory})'
                        : 'N/A',
                    'Auditor': data.auditorName,
                    'Auditor Title': data.auditorTitle,
                    'Organization': data.auditorOrganization,
                    'Department': data.department,
                    'Description': data.description,
                    'Findings': data.findings,
                    'Recommendations': data.recommendations,
                    'Audit Date': data.auditDate,
                    'Start Date': data.startDate ?? 'N/A',
                    'End Date': data.endDate ?? 'N/A',
                  };

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetailsViewPage(
                          title: data.auditName, details: auditDetails),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Iconsax.edit, size: 18, color: Colors.black),
                onPressed: () {
                  CreateNewAuditDialog.show(context);
                },
              ),
              IconButton(
                icon: const Icon(Iconsax.trash, size: 18, color: Colors.red),
                onPressed: () {
                  DialogScaffold.show(
                    context,
                    title: "Delete Audit",
                    size: DialogSize.sm,
                    body: Text(
                        "Are you sure you want to delete '${data.auditName}'?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          controller.deleteAudit(context, data.id);
                        },
                        child: const Text("Delete",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: audits.map((e) => _buildMobileCard(e, context)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
