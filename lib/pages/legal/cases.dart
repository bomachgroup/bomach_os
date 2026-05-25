import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/paginate/responsive_table.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../components/button/my_elevated_button.dart';
import '../../components/input/my_textformfield.dart';
import '../../src/constants/colors.dart';
import 'controllers/legal_case_controller.dart';
import 'detailed_view.dart';
import 'dialogs/legal_dialog.dart';
import 'models/legal_case_model.dart';

class CasesPageView extends StatelessWidget {
  const CasesPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LegalCaseController());

    return PageScaffold(
      header: PageHeader(
        title: 'Legal Cases',
        subtitle: 'Manage litigation, disputes, and legal proceedings',
        trailing: MyElevatedButton(
          child: 'Create Case',
          onTap: () {
            CreateNewLegalCaseDialog.show(context);
          },
        ),
      ),
      children: [
        // Search bar
        SizedBox(
          width: context.isMobile ? double.infinity : 350,
          child: MyTextFormField(
            hintText: 'Search for cases...',
            leading: const Icon(
              Iconsax.search_normal_1,
              size: 18,
              color: AppColors.textMuted,
            ),
            onChanged: controller.onSearchChanged,
          ),
        ),
        const SizedBox(height: 24),

        Obx(() {
          if (controller.isLoading.value) {
            return AppCard(
              padding: const EdgeInsets.all(20),
              child: LoadingSkeleton.listRows(count: 5),
            );
          }

          if (controller.caseList.isEmpty) {
            return const AppCard(
              padding: EdgeInsets.all(32),
              child: EmptyState(
                icon: Iconsax.judge,
                title: 'No legal cases found',
                subtitle: 'Create a new case to get started.',
              ),
            );
          }

          return CasesTable(
            cases: controller.caseList,
            controller: controller,
          );
        }),
      ],
    );
  }
}

class CasesTable extends StatelessWidget {
  final bool isMobile;
  final List<LegalCase> cases;
  final LegalCaseController controller;
  const CasesTable({
    super.key,
    this.isMobile = false,
    required this.cases,
    required this.controller,
  });

  DataRow _buildDataRow(LegalCase data, BuildContext context) {
    return DataRow(
      cells: [
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 180 : 300),
            child: Text(
              data.caseName,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 90 : 140),
            child: StatusChip(
              label: data.caseTypeDisplay,
              tone: StatusTone.neutral,
              dense: isMobile,
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 90 : 140),
            child: StatusChip.fromStatus(data.statusDisplay, dense: isMobile),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 70 : 100),
            child: Text(
              data.exposure ?? 'N/A',
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.danger),
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 80 : 120),
            child: Text(
              data.nextHearing ?? 'N/A',
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildActionButton(
                context,
                icon: Iconsax.eye,
                label: 'View',
                color: AppColors.textPrimary,
                onPressed: () {
                  final Map<String, String> legalCaseDetails = {
                    'Case Number': data.caseNumber ?? 'N/A',
                    'Case Title': data.caseName,
                    'Case Type': data.caseTypeDisplay,
                    'Status': data.statusDisplay,
                    'Exposure': data.exposure ?? 'N/A',
                    'Description': data.description,
                    'Next Hearing': data.nextHearing ?? 'N/A',
                    'Date Filed': data.dateFiled ?? 'N/A',
                    'Date Closed': data.dateClosed ?? 'N/A',
                  };

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetailsViewPage(
                          title: data.caseName, details: legalCaseDetails),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              _buildActionButton(
                context,
                icon: Iconsax.edit,
                label: 'Edit',
                color: AppColors.textPrimary,
                onPressed: () {
                  CreateNewLegalCaseDialog.show(context);
                },
              ),
              const SizedBox(width: 4),
              _buildActionButton(
                context,
                icon: Iconsax.trash,
                label: 'Delete',
                color: AppColors.danger,
                onPressed: () {
                  DialogScaffold.show<void>(
                    context,
                    title: 'Delete Case',
                    size: DialogSize.sm,
                    body: Text(
                      "Are you sure you want to delete '${data.caseName}'? This action cannot be undone.",
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: AppColors.textOnPrimary,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          controller.deleteCase(context, data.id);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: isMobile ? 14 : 16),
      label: Text(
        label,
        style: AppTextStyles.bodySm.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: color == AppColors.danger
              ? AppColors.danger
              : AppColors.borderSubtle,
        ),
        minimumSize: Size(isMobile ? 40 : 60, 32),
        padding:
            EdgeInsets.symmetric(horizontal: isMobile ? 6 : 12, vertical: 4),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadii.brSm,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveTable<LegalCase>(
      items: cases,
      columns: const [
        DataColumn(label: Text('Case')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Exposure')),
        DataColumn(label: Text('Next Hearing')),
        DataColumn(label: Text('Actions')),
      ],
      rowBuilder: (data, index) => _buildDataRow(data, context),
      mobileCardBuilder: (data, index) => AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: MyText(data.caseName,
                      weight: 700, size: 15, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 8),
                StatusChip.fromStatus(data.statusDisplay, dense: true),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                StatusChip(
                  label: data.caseTypeDisplay,
                  tone: StatusTone.neutral,
                  dense: true,
                ),
                const Spacer(),
                MyText(data.exposure ?? 'N/A',
                    size: 13, weight: 600, color: AppColors.danger),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MyText('Next Hearing',
                        size: 11, color: AppColors.textSecondary),
                    const SizedBox(height: 4),
                    MyText(data.nextHearing ?? 'N/A',
                        size: 13, weight: 600, color: AppColors.textPrimary),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        final Map<String, String> legalCaseDetails = {
                          'Case Number': data.caseNumber ?? 'N/A',
                          'Case Title': data.caseName,
                          'Case Type': data.caseTypeDisplay,
                          'Status': data.statusDisplay,
                          'Exposure': data.exposure ?? 'N/A',
                          'Description': data.description,
                          'Next Hearing': data.nextHearing ?? 'N/A',
                          'Date Filed': data.dateFiled ?? 'N/A',
                          'Date Closed': data.dateClosed ?? 'N/A',
                        };

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DetailsViewPage(
                                title: data.caseName,
                                details: legalCaseDetails),
                          ),
                        );
                      },
                      icon: const Icon(Iconsax.eye, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.neutral100,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        CreateNewLegalCaseDialog.show(context);
                      },
                      icon: const Icon(Iconsax.edit, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.neutral100,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
