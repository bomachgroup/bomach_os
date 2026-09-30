import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/nav/three_dot_pop.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'controller/benefits_controller.dart';
import 'models/benefits_model.dart';

class BenefitsPage extends StatefulWidget {
  const BenefitsPage({super.key});

  @override
  State<BenefitsPage> createState() => _BenefitsPageState();
}

class _BenefitsPageState extends State<BenefitsPage> {
  final BenefitsController _ctrl = Get.put(BenefitsController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.fetchBenefits(context);
    });
  }

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'paid':
        return StatusTone.success;
      case 'rejected':
      case 'failed':
        return StatusTone.danger;
      case 'pending':
      case 'processing':
        return StatusTone.warning;
      default:
        return StatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Benefits & Welfare',
        subtitle: 'Manage staff benefits enrollment and welfare programs.',
        trailing: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MyOutlinedButton(
              height: 48,
              icon: const Icon(Iconsax.task_square,
                  color: AppColors.primary, size: 18),
              child: 'Manage Benefits',
              onTap: () => _showAllBenefitsDialog(context),
            ),
            MyElevatedButton(
              height: 48,
              icon: const Icon(Iconsax.add_circle,
                  color: AppColors.textOnPrimary, size: 18),
              child: 'Add Staff to Benefits',
              onTap: () {
                if (_ctrl.employeeList.isNotEmpty) {
                  _showEditStaffBenefitsDialog(
                      context, _ctrl.employeeList.first);
                } else {
                  AppToast.error(context, 'No employees available');
                }
              },
            ),
          ],
        ),
      ),
      children: [
        _buildToolbar(),
        Obx(() {
          final loading =
              _ctrl.isLoading.value && _ctrl.employeeList.isEmpty;
          final isEmpty = !loading && _ctrl.employeeList.isEmpty;

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
            body: _buildTable(_ctrl.employeeList),
            footer: (!loading && _ctrl.employeeList.isNotEmpty)
                ? _tablePaginator(
                    Obx(() => PaginatorFooter(
                          totalItems: _ctrl.totalCount.value,
                          limit: _ctrl.itemsPerPage.value,
                          currentPage: _ctrl.currentPage.value,
                          onPageChanged: (p) => _ctrl.changePage(p, context),
                          onLimitChanged: (l) => _ctrl.changeLimit(l, context),
                        )),
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
        controller: _ctrl.searchController,
        hintText: 'Search by employee name or role',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: (_) => _ctrl.fetchBenefits(context, refresh: true),
      ),
    );
  }

  Widget _buildTableCard({
    required bool loading,
    required bool isEmpty,
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
                      const Text('Staff benefits', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            loading
                                ? 'Loading benefits...'
                                : '${_ctrl.totalCount.value} enrolled employee${_ctrl.totalCount.value == 1 ? '' : 's'}',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Welfare program',
                  tone: StatusTone.primary,
                  icon: Iconsax.heart,
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
            const Padding(
              padding: EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.heart,
                title: 'No staff benefits enrolled',
                subtitle:
                    'Once staff are enrolled in benefits, their records will appear here.',
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

  Widget _buildTable(List<BenefitRecord> items) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Employee', flex: 3),
              _buildHeaderCell('Active Benefits', flex: 4),
              _buildHeaderCell('Start Date', flex: 2),
              _buildHeaderCell('Status', flex: 2),
              _buildHeaderCell('', width: 48),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...items.map(_buildDataRow),
      ],
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

  Widget _buildDataRow(BenefitRecord record) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primarySubtle,
                  child: Text(
                    record.employeeName.isNotEmpty
                        ? record.employeeName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.employeeName,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.employeeRole,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              record.activeBenefits.isEmpty
                  ? '—'
                  : record.activeBenefits.join(', '),
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('dd-MM-yyyy').format(record.startDate),
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: record.status,
                tone: _statusTone(record.status),
                dense: true,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Align(
              alignment: Alignment.centerRight,
              child: ThreeDotPop(
                onTapView: () => _showViewStaffDialog(context, record),
                onTapEdit: () => _showEditStaffBenefitsDialog(context, record),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Dialogs ---

  void _showAllBenefitsDialog(BuildContext context) {
    DialogScaffold.show(
      context,
      title: 'Request Benefit',
      subtitle: 'Manage benefit categories available to staff.',
      size: DialogSize.sm,
      body: Obx(() {
        if (_ctrl.availableBenefits.isEmpty) {
          return const EmptyState(
            icon: Iconsax.heart,
            title: 'No benefits configured',
            subtitle: 'Add benefit categories to make them available to staff.',
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _ctrl.availableBenefits.map((b) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: AppRadii.brMd,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.tick_square,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      b,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _ctrl.removeBenefitType(b),
                    borderRadius: AppRadii.brSm,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Iconsax.trash,
                          color: AppColors.danger, size: 16),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      }),
      actions: [
        MyOutlinedButton(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: 'Close',
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 12),
        MyElevatedButton(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'Add Benefit',
          onTap: () {
            Navigator.of(context).pop();
            _showAddBenefitDialog(context);
          },
        ),
      ],
    );
  }

  void _showAddBenefitDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    DialogScaffold.show<void>(
      context,
      title: 'Add Benefit',
      subtitle: 'Create a new benefit category staff can be enrolled in.',
      size: DialogSize.sm,
      body: MyTextFormField(
        title: 'Benefit Name',
        controller: nameCtrl,
        hintText: 'e.g. Data Allowance',
      ),
      actions: [
        MyOutlinedButton(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: 'Cancel',
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 12),
        MyElevatedButton(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: 'Save',
          onTap: () {
            final success = _ctrl.addBenefitType(nameCtrl.text.trim());
            if (success) {
              Navigator.of(context).pop();
              AppToast.success(context, 'Benefit added successfully');
            } else {
              AppToast.error(context, 'Benefit name is empty or already exists');
            }
          },
        ),
      ],
    );
  }

  void _showViewStaffDialog(BuildContext context, BenefitRecord record) {
    DialogScaffold.show<void>(
      context,
      title: 'Benefits Checklist',
      subtitle: 'Review the benefits assigned to this staff member.',
      size: DialogSize.sm,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEmployeeBanner(record),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: AppRadii.brLg,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Active benefits', style: AppTextStyles.h4),
                const SizedBox(height: 12),
                if (record.activeBenefits.isEmpty)
                  Text(
                    'No active benefits assigned.',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  ...record.activeBenefits.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Iconsax.tick_circle,
                                size: 16, color: AppColors.success),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                b,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: 'Close',
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 12),
        MyElevatedButton(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          icon: const Icon(Iconsax.edit,
              color: AppColors.textOnPrimary, size: 18),
          child: 'Edit',
          onTap: () {
            Navigator.of(context).pop();
            _showEditStaffBenefitsDialog(context, record);
          },
        ),
      ],
    );
  }

  void _showEditStaffBenefitsDialog(
      BuildContext context, BenefitRecord record) {
    final selected = Set<String>.from(record.activeBenefits);
    DialogScaffold.show<void>(
      context,
      title: 'Edit Staff Benefits',
      subtitle: 'Toggle the benefits this staff member should receive.',
      size: DialogSize.md,
      body: StatefulBuilder(builder: (ctx, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmployeeBanner(record),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: AppRadii.brLg,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available benefits', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  if (_ctrl.availableBenefits.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No benefits configured yet.',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: SingleChildScrollView(
                        child: Column(
                          children: _ctrl.availableBenefits.map((b) {
                            final isSelected = selected.contains(b);
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              title: Text(
                                b,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: isSelected,
                              activeColor: AppColors.primary,
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    selected.add(b);
                                  } else {
                                    selected.remove(b);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      }),
      actions: [
        MyOutlinedButton(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: 'Cancel',
          onTap: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 12),
        MyElevatedButton(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: 'Save',
          onTap: () {
            _ctrl.updateEmployeeBenefits(record.id, selected.toList());
            Navigator.of(context).pop();
            AppToast.success(context, 'Updated successfully');
          },
        ),
      ],
    );
  }

  Widget _buildEmployeeBanner(BenefitRecord record) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.surface,
            child: Text(
              record.employeeName.isNotEmpty
                  ? record.employeeName[0].toUpperCase()
                  : '?',
              style: AppTextStyles.h4.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.employeeName,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.employeeId} • ${record.employeeRole}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          StatusChip(
            label: record.status,
            tone: _statusTone(record.status),
            dense: true,
          ),
        ],
      ),
    );
  }
}
