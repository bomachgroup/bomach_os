import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/utils/app_date_format.dart';
import 'package:bomach_os/pages/operations/engineering_site_reports.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/work_site_controller.dart';
import 'models/models.dart';
import 'widget/add_worksite_dialog.dart';

class WorksiteDetailPage extends StatelessWidget {
  final Worksite? worksite;
  const WorksiteDetailPage({super.key, this.worksite});

  @override
  Widget build(BuildContext context) {
    final WorksiteController controller = Get.find<WorksiteController>();

    final Worksite? ws =
        worksite ?? ModalRoute.of(context)?.settings.arguments as Worksite?;
    final canOpenReports = Get.isRegistered<PermissionService>() &&
        Get.find<PermissionService>().hasAny(const [
          Perms.engineeringSiteReportsCreate,
          Perms.engineeringSiteReportsList,
          Perms.engineeringSiteReportsListOwn,
          Perms.engineeringSiteReportsView,
          Perms.engineeringSiteReportsViewOwn,
        ]);

    if (ws == null) {
      return const PageScaffold(
        children: [
          Center(
            child: MyText('Worksite not found', style: AppTextStyles.bodyLg),
          ),
        ],
      );
    }

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: ws.name.isEmpty ? 'Worksite' : ws.name,
        subtitle: 'Worksite location and operational status.',
        trailing: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (canOpenReports)
              MyOutlinedButton(
                height: 48,
                icon: const Icon(Iconsax.document_text,
                    size: 18, color: AppColors.primary),
                child: 'Site Reports',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => EngineeringSiteReportsPage(
                        initialWorksiteId: ws.id,
                        initialProjectId:
                            ws.projectId == 0 ? null : ws.projectId))),
              ),
            MyOutlinedButton(
              height: 48,
              icon:
                  const Icon(Iconsax.edit, size: 18, color: AppColors.primary),
              child: 'Edit',
              onTap: () => showDialog(
                context: context,
                builder: (_) => AddWorksiteDialog(worksite: ws),
              ),
            ),
            MyElevatedButton(
              height: 48,
              bgColor: AppColors.danger,
              child: 'Delete',
              icon: const Icon(Iconsax.trash, size: 18, color: Colors.white),
              onTap: () => _confirmDelete(context, controller, ws),
            ),
          ],
        ),
      ),
      children: [
        _buildOverviewHeader(ws),
        _buildDetailsCard(ws),
        _buildDescriptionCard(ws),
      ],
    );
  }

  Widget _buildOverviewHeader(Worksite ws) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.md,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brMd,
            ),
            child: const Icon(
              Iconsax.buildings_2,
              size: 26,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ws.name.isEmpty ? 'Worksite' : ws.name,
                  style: AppTextStyles.h3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(
                      label: ws.status.isEmpty ? 'Unknown' : ws.status,
                      tone: _getStatusTone(ws.status),
                    ),
                    if (ws.location.isNotEmpty)
                      StatusChip(
                        label: ws.location,
                        tone: StatusTone.neutral,
                        icon: Iconsax.location,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Worksite ws) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Text('Worksite Overview', style: AppTextStyles.h3),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                _detailRow('Site Name', ws.name.isEmpty ? '—' : ws.name),
                _detailRow('Location', ws.location.isEmpty ? '—' : ws.location),
                _detailRowChip(
                  'Status',
                  StatusChip(
                    label: ws.status.isEmpty ? 'Unknown' : ws.status,
                    tone: _getStatusTone(ws.status),
                  ),
                ),
                _detailRow(
                    'Created At',
                    ws.createdAt.isEmpty
                        ? '—'
                        : formatAppDateValue(ws.createdAt,
                            fallback: ws.createdAt)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(Worksite ws) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Text('Description', style: AppTextStyles.h3),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Text(
              ws.description.isEmpty
                  ? 'No description provided.'
                  : ws.description,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRowChip(String label, Widget chip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: chip),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WorksiteController controller,
    Worksite ws,
  ) async {
    final confirmed = await DialogScaffold.show<bool>(
      context,
      title: 'Delete Worksite',
      size: DialogSize.sm,
      body: Text(
        'Are you sure you want to delete "${ws.name}"?',
        style: AppTextStyles.bodyMd,
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context, false),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          width: 120,
          height: 44,
          child: 'Delete',
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    );
    if (confirmed == true && context.mounted) {
      controller.deleteWorksite(context, ws.id, ws.projectId);
    }
  }

  StatusTone _getStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return StatusTone.success;
      case 'paused':
      case 'pending':
      case 'on hold':
        return StatusTone.warning;
      case 'closed':
      case 'inactive':
      case 'completed':
        return StatusTone.neutral;
      case 'hazard':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }
}
