import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/constants/shadows.dart';
import 'package:bomach_os/src/model/company_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'controllers/company_controller.dart';
import 'widget/add_compliance_dialog.dart';

class CompliancePage extends StatefulWidget {
  const CompliancePage({super.key});

  @override
  State<CompliancePage> createState() => _CompliancePageState();
}

class _CompliancePageState extends State<CompliancePage> {
  final CompanyController controller = Get.find<CompanyController>();
  final searchController = TextEditingController();

  int _pageSize = 10;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    controller.fetchComplianceRecords();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      header: PageHeader(
        title: 'Compliance register',
        subtitle: 'Track and manage your regulatory documents and licenses.',
        trailing: PermissionGate(
          require: Perms.complianceRecordsCreate,
          child: MyElevatedButton(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            icon: const Icon(Iconsax.add_circle,
                color: AppColors.textOnPrimary, size: 20),
            child: 'New Compliance',
            onTap: () => showDialog(
              context: context,
              builder: (c) => const AddComplianceDialog(),
            ),
          ),
        ),
      ),
      children: [
        _buildToolbar(),
        Obx(() {
            final loading = controller.isComplianceLoading.value &&
                controller.filteredComplianceList.isEmpty;
            final filtered = controller.filteredComplianceList;

            if (loading) {
              return AppCard(
                padding: const EdgeInsets.all(24),
                child: LoadingSkeleton.listRows(count: 6),
              );
            }

            if (controller.complianceErrorMessage.value.isNotEmpty &&
                filtered.isEmpty) {
              return _ComplianceErrorState(
                message: controller.complianceErrorMessage.value,
                onRetry: controller.fetchComplianceRecords,
              );
            }

            if (filtered.isEmpty) {
              return AppCard(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: EmptyState(
                  icon: Iconsax.folder_2,
                  title: 'No compliance records found',
                  subtitle:
                      'Add your first compliance record to start tracking regulatory documents.',
                  action: MyOutlinedButton(
                    child: 'Add Record',
                    icon: const Icon(Iconsax.add_circle,
                        size: 18, color: AppColors.primary),
                    onTap: () => showDialog(
                      context: context,
                      builder: (c) => const AddComplianceDialog(),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: [
                if (controller.complianceErrorMessage.value.isNotEmpty)
                  _ComplianceInlineError(
                    message: controller.complianceErrorMessage.value,
                    onRetry: controller.fetchComplianceRecords,
                  ),
                AppCard(
                  padding: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      _buildComplianceList(filtered),
                      const Divider(height: 1, color: AppColors.borderSubtle),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        child: PaginatorFooter(
                          totalItems: filtered.length,
                          limit: _pageSize,
                          currentPage: _currentPage,
                          onPageChanged: (page) =>
                              setState(() => _currentPage = page),
                          onLimitChanged: (newLimit) => setState(() {
                            _pageSize = newLimit;
                            _currentPage = 1;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        controller: searchController,
        hintText: 'Search by type, reference, or authority...',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: (val) {
          controller.complianceSearchQuery.value = val;
          setState(() => _currentPage = 1);
        },
      ),
    );
  }

  Widget _buildComplianceList(List<Compliance> items) {
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, items.length);
    final pageItems = items.sublist(startIndex, endIndex);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: pageItems.map((item) => _buildMobileCard(item)).toList(),
      ),
    );
  }

  Widget _buildMobileCard(Compliance item) {
    final typeLabel =
        item.complianceType.isNotEmpty ? item.complianceType : 'Untitled';
    final abbreviation = _typeAbbreviation(item.complianceType);
    final status = _complianceStatus(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primarySubtle.withValues(alpha: 0.5),
                  borderRadius: AppRadii.brMd,
                ),
                alignment: Alignment.center,
                child: Text(
                  abbreviation,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusChip(
                label: status.label,
                tone: status.tone,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            typeLabel,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (item.fullName.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              item.fullName,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ref: ${item.referenceNumber.isNotEmpty ? item.referenceNumber : '—'}',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                'Expires: ${_formatDate(item.expiryDate)}',
                style: AppTextStyles.bodySm.copyWith(
                  color: _isExpired(item.expiryDate)
                      ? AppColors.danger
                      : AppColors.textPrimary,
                  fontWeight: _isExpired(item.expiryDate)
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
          if (item.issuingAuthority.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Authority: ${item.issuingAuthority}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PermissionGate(
                require: Perms.complianceRecordsUpdate,
                child: IconButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (c) => AddComplianceDialog(compliance: item),
                  ),
                  icon: const Icon(Iconsax.edit,
                      size: 20, color: AppColors.textSecondary),
                  tooltip: 'Edit record',
                ),
              ),
              PermissionGate(
                require: Perms.complianceRecordsUpdate,
                child: IconButton(
                  onPressed: () => _confirmDelete(item),
                  icon: const Icon(Iconsax.trash,
                      size: 20, color: AppColors.danger),
                  tooltip: 'Delete record',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  bool _isExpired(String date) {
    final expiry = DateTime.tryParse(date);
    if (expiry == null) return false;
    return expiry.isBefore(DateTime.now());
  }

  ({String label, StatusTone tone}) _complianceStatus(Compliance item) {
    final status = item.status.toLowerCase();
    if (status == 'expired') {
      return (label: 'Expired', tone: StatusTone.danger);
    }
    if (status == 'pending') {
      return (label: 'Pending', tone: StatusTone.warning);
    }

    final expiry = DateTime.tryParse(item.expiryDate);
    if (expiry != null) {
      final now = DateTime.now();
      if (expiry.isBefore(now)) {
        return (label: 'Non-compliant', tone: StatusTone.danger);
      }
      final daysLeft = expiry.difference(now).inDays;
      if (daysLeft <= 30) {
        return (label: 'Expiring soon', tone: StatusTone.warning);
      }
    }
    return (label: 'Compliant', tone: StatusTone.success);
  }

  void _confirmDelete(Compliance item) async {
    final confirmed = await DialogScaffold.show<bool>(
      context,
      title: 'Delete compliance record',
      size: DialogSize.sm,
      body: Text(
        'Are you sure you want to delete this record for "${item.complianceType}"? This action cannot be undone.',
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context, false),
        ),
        MyElevatedButton(
          width: 140,
          height: 44,
          child: 'Delete Record',
          icon: const Icon(Iconsax.trash, size: 18, color: AppColors.textOnPrimary),
          onTap: () => Navigator.pop(context, true),
        ),
      ],
    );
    
    if (confirmed == true && mounted) {
      controller.deleteCompliance(context, item.id);
    }
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '—';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('MMM d, yyyy').format(parsed);
  }

  String _typeAbbreviation(String type) {
    switch (type.toLowerCase()) {
      case 'corporate affairs commission':
      case 'cac':
        return 'CAC';
      case 'tax id':
      case 'tax':
        return 'Tax';
      case 'trademark':
        return 'TM';
      case 'certification':
      case 'iso certification':
        return 'Cert';
      case 'license':
        return 'Lic';
      default:
        if (type.isEmpty) return '—';
        return type.length > 4 ? type.substring(0, 4) : type;
    }
  }
}

class _ComplianceErrorState extends StatelessWidget {
  const _ComplianceErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Iconsax.warning_2, color: AppColors.danger, size: 32),
            const SizedBox(height: 12),
            const Text('Compliance records could not be loaded'),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            MyOutlinedButton(child: 'Retry', onTap: onRetry),
          ],
        ),
      );
}

class _ComplianceInlineError extends StatelessWidget {
  const _ComplianceInlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const Icon(Iconsax.warning_2, color: AppColors.danger, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
}
