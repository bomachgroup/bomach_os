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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/contract_controller.dart';
import 'models/models.dart';
import 'widget/add_contract_dialog.dart';

class ContractDetailPage extends StatelessWidget {
  final Contract? cont;

  const ContractDetailPage({super.key, this.cont});

  @override
  Widget build(BuildContext context) {
    final ContractController controller = Get.find<ContractController>();

    final Contract? contract =
        cont ?? ModalRoute.of(context)?.settings.arguments as Contract?;

    if (contract == null) {
      return const PageScaffold(
        children: [
          Center(
            child: MyText('Contract not found', style: AppTextStyles.bodyLg),
          ),
        ],
      );
    }

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: contract.name.isEmpty ? 'Contract' : contract.name,
        subtitle: 'Contract details, value, and scheduling.',
        trailing: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MyOutlinedButton(
              height: 48,
              icon: const Icon(Iconsax.edit, size: 18, color: AppColors.primary),
              child: 'Edit',
              onTap: () => showDialog(
                context: context,
                builder: (_) => AddContractDialog(contract: contract),
              ),
            ),
            MyElevatedButton(
              height: 48,
              bgColor: AppColors.danger,
              child: 'Delete',
              icon: const Icon(Iconsax.trash, size: 18, color: Colors.white),
              onTap: () => _confirmDelete(context, controller, contract),
            ),
          ],
        ),
      ),
      children: [
        _buildOverviewHeader(contract),
        _buildContractInfoCard(contract),
        _buildScheduleCard(contract),
      ],
    );
  }

  Widget _buildOverviewHeader(Contract contract) {
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
              Iconsax.document_text,
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
                  contract.name.isEmpty ? 'Contract' : contract.name,
                  style: AppTextStyles.h3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(
                      label: contract.status.isEmpty ? 'Unknown' : contract.status,
                      tone: _getStatusTone(contract.status),
                    ),
                    if (contract.contractType.isNotEmpty)
                      StatusChip(
                        label: contract.contractType,
                        tone: _typeTone(contract.contractType),
                        icon: Iconsax.category_2,
                      ),
                    if (contract.contractNumber.isNotEmpty)
                      StatusChip(
                        label: contract.contractNumber,
                        tone: StatusTone.neutral,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Contract Value',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                '₦${contract.value.toStringAsFixed(2)}',
                style: AppTextStyles.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContractInfoCard(Contract contract) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Text('Contract Information', style: AppTextStyles.h3),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                _detailRow('Contract Name',
                    contract.name.isEmpty ? '—' : contract.name),
                _detailRow(
                    'Contract Number',
                    contract.contractNumber.isEmpty
                        ? '—'
                        : contract.contractNumber),
                _detailRow(
                    'Contract Type',
                    contract.contractType.isEmpty
                        ? '—'
                        : contract.contractType),
                _detailRow('Value',
                    '₦${contract.value.toStringAsFixed(2)}'),
                _detailRowChip(
                  'Status',
                  StatusChip(
                    label:
                        contract.status.isEmpty ? 'Unknown' : contract.status,
                    tone: _getStatusTone(contract.status),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(Contract contract) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Text('Schedule & References', style: AppTextStyles.h3),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                _detailRow('Start Date',
                    contract.startDate.isEmpty ? '—' : contract.startDate),
                _detailRow('End Date',
                    contract.endDate.isEmpty ? '—' : contract.endDate),
                _detailRow('Project ID', '#${contract.projectId}'),
                _detailRow('Created At',
                    contract.createdAt.isEmpty ? '—' : contract.createdAt),
              ],
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
    ContractController controller,
    Contract contract,
  ) async {
    final confirmed = await DialogScaffold.show<bool>(
      context,
      title: 'Delete Contract',
      size: DialogSize.sm,
      body: Text(
        'Are you sure you want to delete "${contract.name}"?',
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
      controller.deleteContract(context, contract.id, contract.projectId);
    }
  }

  StatusTone _getStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'signed':
        return StatusTone.success;
      case 'pending':
      case 'pending_review':
      case 'pending review':
      case 'draft':
        return StatusTone.warning;
      case 'terminated':
      case 'expired':
        return StatusTone.danger;
      case 'renewed':
        return StatusTone.primary;
      default:
        return StatusTone.neutral;
    }
  }

  StatusTone _typeTone(String type) {
    switch (type.toLowerCase()) {
      case 'service':
        return StatusTone.primary;
      case 'vendor':
        return StatusTone.info;
      case 'lease':
        return StatusTone.warning;
      case 'employment':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }
}
