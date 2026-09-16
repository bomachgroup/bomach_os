import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/utils/number_formatting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/contract_controller.dart';
import 'models/models.dart';
import 'widget/add_contract_dialog.dart';

class ContractPage extends StatefulWidget {
  final int? projectId; // Optional: to filter by project
  const ContractPage({super.key, this.projectId});

  @override
  State<ContractPage> createState() => ContractPageState();
}

class ContractPageState extends State<ContractPage> {
  final ContractController controller = Get.put(ContractController());
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchContracts(context, projectId: widget.projectId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Contracts',
        subtitle: 'Manage legal contracts, agreements, and obligations.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Contract',
          onTap: () => showDialog(
            context: context,
            builder: (_) => const AddContractDialog(),
          ),
        ),
      ),
      children: [
        _buildToolbar(),
        Obx(() {
          final loading = controller.isLoading.value && controller.contracts.isEmpty;
          final isEmpty = !loading && controller.contracts.isEmpty;
          final total = controller.totalCount.value;
          final currentPage =
              (controller.currentOffset.value ~/ controller.currentLimit.value) + 1;

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
            totalLabel: '$total contract${total == 1 ? '' : 's'} on record',
            body: _buildTable(context, controller.contracts),
            footer: (!loading && controller.contracts.isNotEmpty)
                ? _tablePaginator(
                    PaginatorFooter(
                      totalItems: total,
                      limit: controller.currentLimit.value,
                      currentPage: currentPage,
                      onPageChanged: (page) {
                        controller.currentOffset.value =
                            (page - 1) * controller.currentLimit.value;
                        controller.fetchContracts(context,
                            projectId: widget.projectId);
                      },
                      onLimitChanged: (newLimit) {
                        controller.currentLimit.value = newLimit;
                        controller.currentOffset.value = 0;
                        controller.fetchContracts(context,
                            projectId: widget.projectId);
                      },
                    ),
                  )
                : null,
          );
        }),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: MyTextFormField(
        controller: _searchController,
        hintText: 'Search contracts by name, number or type',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: (val) => controller.fetchContracts(context,
            projectId: widget.projectId, search: val),
      ),
    );
  }

  Widget _buildTableCard({
    required bool loading,
    required bool isEmpty,
    required String totalLabel,
    required Widget body,
    Widget? footer,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Contracts register', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        loading ? 'Loading contracts...' : totalLabel,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Agreements',
                  tone: StatusTone.primary,
                  icon: Iconsax.document_text,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          if (loading)
            Padding(
              padding: const EdgeInsets.all(20),
              child: LoadingSkeleton.listRows(count: 5),
            )
          else if (isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.document_text,
                title: 'No contracts found',
                subtitle: 'Create a new contract to manage agreements.',
                action: MyElevatedButton(
                  child: 'New Contract',
                  icon: const Icon(Iconsax.add_circle,
                      size: 18, color: AppColors.textOnPrimary),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => const AddContractDialog(),
                  ),
                ),
              ),
            )
          else
            body,
          if (footer != null) ...[
            const Divider(height: 1, color: AppColors.borderSubtle),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _tablePaginator(Widget child) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: child,
    );
  }

  Widget _buildHeaderCell(String label, {double? width, int? flex}) {
    final content = Text(
      label,
      style: AppTextStyles.bodySm.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
    if (width != null) return SizedBox(width: width, child: content);
    return Expanded(flex: flex ?? 1, child: content);
  }

  Widget _buildTable(BuildContext context, List<Contract> contracts) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Contract', flex: 4),
              _buildHeaderCell('Type', flex: 2),
              _buildHeaderCell('Value', flex: 2),
              _buildHeaderCell('Duration', flex: 3),
              _buildHeaderCell('Status', flex: 2),
              _buildHeaderCell('', width: 48),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...contracts.map((c) => _buildContractRow(context, c)),
      ],
    );
  }

  Widget _buildContractRow(BuildContext context, Contract contract) {
    return InkWell(
      onTap: () => context.push(
        RouteConstants.operationsContractDetail,
        extra: contract,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: AppRadii.brSm,
                    ),
                    child: const Icon(
                      Iconsax.document_text,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contract.name.isEmpty ? '—' : contract.name,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (contract.contractNumber.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            contract.contractNumber,
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                contract.contractType.isEmpty ? '—' : contract.contractType,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                contract.value.toNaira(),
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contract.startDate.isEmpty ? '—' : contract.startDate,
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.textPrimary),
                  ),
                  if (contract.endDate.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'to ${contract.endDate}',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(
                  label: contract.status.isEmpty ? 'Unknown' : contract.status,
                  tone: _getStatusTone(contract.status),
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: PopupMenuButton<String>(
                icon: const Icon(Iconsax.more,
                    size: 18, color: AppColors.textSecondary),
                shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
                onSelected: (value) async {
                  if (value == 'view') {
                    context.push(
                      RouteConstants.operationsContractDetail,
                      extra: contract,
                    );
                  } else if (value == 'edit') {
                    showDialog(
                      context: context,
                      builder: (_) => AddContractDialog(contract: contract),
                    );
                  } else if (value == 'delete') {
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
                      controller.deleteContract(
                          context, contract.id, contract.projectId);
                    }
                  }
                },
                itemBuilder: (_) => [
                  _menuItem(
                      value: 'view', icon: Iconsax.eye, label: 'View Details'),
                  _menuItem(value: 'edit', icon: Iconsax.edit, label: 'Edit'),
                  _menuItem(
                      value: 'delete',
                      icon: Iconsax.trash,
                      label: 'Delete',
                      destructive: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem({
    required String value,
    required IconData icon,
    required String label,
    bool destructive = false,
  }) {
    final color = destructive ? AppColors.danger : AppColors.textSecondary;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: destructive ? AppColors.danger : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
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
