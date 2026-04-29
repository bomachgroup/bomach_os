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
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/work_site_controller.dart';
import 'models/models.dart';
import 'widget/add_worksite_dialog.dart';
import 'worksite_detail.dart';

class WorkSite extends StatefulWidget {
  const WorkSite({super.key});

  @override
  State<WorkSite> createState() => _WorkSiteState();
}

class _WorkSiteState extends State<WorkSite> {
  final WorksiteController controller = Get.put(WorksiteController());
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchWorksites(context);
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
        title: 'Worksites',
        subtitle: 'Manage field worksites, locations, and operational status.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Worksite',
          onTap: () => showDialog(
            context: context,
            builder: (_) => const AddWorksiteDialog(),
          ),
        ),
      ),
      children: [
        _buildToolbar(),
        Obx(() {
          final loading = controller.isLoading.value && controller.worksites.isEmpty;
          final isEmpty = !loading && controller.worksites.isEmpty;
          final total = controller.totalCount.value;
          final currentPage =
              (controller.currentOffset.value ~/ controller.currentLimit.value) + 1;

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
            totalLabel:
                '$total worksite${total == 1 ? '' : 's'} on record',
            body: _buildTable(context, controller.worksites),
            footer: (!loading && controller.worksites.isNotEmpty)
                ? _tablePaginator(
                    PaginatorFooter(
                      totalItems: total,
                      limit: controller.currentLimit.value,
                      currentPage: currentPage,
                      onPageChanged: (page) {
                        controller.currentOffset.value =
                            (page - 1) * controller.currentLimit.value;
                        controller.fetchWorksites(context);
                      },
                      onLimitChanged: (newLimit) {
                        controller.currentLimit.value = newLimit;
                        controller.currentOffset.value = 0;
                        controller.fetchWorksites(context);
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
        hintText: 'Search worksites by name or location',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: (val) => controller.fetchWorksites(context, search: val),
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
                      const Text('Worksite directory', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        loading ? 'Loading worksites...' : totalLabel,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Field operations',
                  tone: StatusTone.primary,
                  icon: Iconsax.buildings_2,
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
                icon: Iconsax.buildings_2,
                title: 'No worksites found',
                subtitle:
                    'Add a new worksite to start tracking field operations.',
                action: MyElevatedButton(
                  child: 'New Worksite',
                  icon: const Icon(Iconsax.add_circle,
                      size: 18, color: AppColors.textOnPrimary),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => const AddWorksiteDialog(),
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

  Widget _buildTable(BuildContext context, List<Worksite> worksites) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Site Name', flex: 3),
              _buildHeaderCell('Location', flex: 3),
              _buildHeaderCell('Status', flex: 2),
              _buildHeaderCell('Description', flex: 4),
              _buildHeaderCell('', width: 48),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...worksites.map((site) => _buildWorksiteRow(context, site)),
      ],
    );
  }

  Widget _buildWorksiteRow(BuildContext context, Worksite site) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorksiteDetailPage(worksite: site),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
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
                      Iconsax.buildings_2,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      site.name.isEmpty ? '—' : site.name,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                site.location.isEmpty ? '—' : site.location,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(
                  label: site.status.isEmpty ? 'Unknown' : site.status,
                  tone: _worksiteStatusTone(site.status),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Text(
                site.description.isEmpty ? '—' : site.description,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 48,
              child: PopupMenuButton<String>(
                icon: const Icon(Iconsax.more,
                    size: 18, color: AppColors.textSecondary),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.brMd,
                ),
                onSelected: (value) async {
                  if (value == 'view') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorksiteDetailPage(worksite: site),
                      ),
                    );
                  } else if (value == 'edit') {
                    showDialog(
                      context: context,
                      builder: (_) => AddWorksiteDialog(worksite: site),
                    );
                  } else if (value == 'delete') {
                    final confirmed = await DialogScaffold.show<bool>(
                      context,
                      title: 'Delete Worksite',
                      size: DialogSize.sm,
                      body: Text(
                        'Are you sure you want to delete "${site.name}"?',
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
                      controller.deleteWorksite(context, site.id, site.projectId);
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

  StatusTone _worksiteStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return StatusTone.success;
      case 'paused':
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
