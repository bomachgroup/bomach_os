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
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'controller/assets_controller.dart';
import 'asset_action_permissions.dart';
import 'models/assets_model.dart';
import 'widget/add_asset_dialog.dart';
import 'widget/view_asset_dialog.dart';

class AssetsPage extends StatelessWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AssetController controller = Get.put(AssetController());

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Company Assets',
        subtitle: 'Manage company properties across all branches.',
        trailing: PermissionGate(
          require: Perms.assetsCreate,
          child: MyElevatedButton(
            height: 48,
            icon: const Icon(Iconsax.add_circle,
                color: AppColors.textOnPrimary, size: 18),
            child: 'New Asset',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const AddAssetDialog(),
            ),
          ),
        ),
      ),
      children: [
        _AssetsToolbar(controller: controller),
        _AssetsTableCard(controller: controller),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  TOOLBAR
// ═══════════════════════════════════════════════════════════════════════

class _AssetsToolbar extends StatelessWidget {
  final AssetController controller;
  const _AssetsToolbar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: MyTextFormField(
        hintText: 'Search assets by name, serial or branch',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: controller.onSearchChanged,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
//  TABLE CARD
// ═══════════════════════════════════════════════════════════════════════

class _AssetsTableCard extends StatelessWidget {
  final AssetController controller;
  const _AssetsTableCard({required this.controller});

  Widget _buildMobileCards(BuildContext context) {
    return Column(
      children: controller.assetList.map((asset) {
        String displayDate = '';
        try {
          displayDate = DateFormat('dd-MM-yyyy').format(asset.purchaseDate);
        } catch (_) {
          displayDate = '—';
        }

        final statusTone = asset.status == 'available'
            ? StatusTone.success
            : asset.status == 'in-use'
                ? StatusTone.primary
                : asset.status == 'maintenance'
                    ? StatusTone.warning
                    : StatusTone.danger;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderSubtle, width: 0.6),
          ),
          color: AppColors.surface,
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => ViewAssetDialog(asset: asset),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          asset.name,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      StatusChip(
                        label: asset.status,
                        tone: statusTone,
                        dense: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Type',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          StatusChip(
                            label: asset.assetType.isEmpty ? '—' : asset.assetType,
                            tone: StatusTone.info,
                            dense: true,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Value',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₦${NumberFormat('#,##0.00').format(asset.value)}',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.borderSubtle),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Iconsax.location,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            asset.branch.isEmpty ? '—' : asset.branch,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Iconsax.calendar,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            displayDate,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PermissionGate(
                        require: Perms.assetsUpdate,
                        child: TextButton.icon(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (_) => AddAssetDialog(asset: asset),
                          ),
                          icon: const Icon(Iconsax.edit, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(60, 30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PermissionGate(
                        require: Perms.assetsDelete,
                        child: TextButton.icon(
                          onPressed: () async {
                            final confirmed = await DialogScaffold.show<bool>(
                              context,
                              title: 'Delete asset',
                              size: DialogSize.sm,
                              body: Text(
                                  'Are you sure you want to delete "${asset.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                            if (confirmed == true) {
                              controller.deleteAsset(context, asset.id);
                            }
                          },
                          icon: const Icon(Iconsax.trash, size: 16),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(60, 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isLoading.value && controller.assetList.isEmpty;
      final hasError = controller.errorMessage.value.isNotEmpty;
      final isEmpty = !controller.isLoading.value && controller.assetList.isEmpty;
      final showMobile = context.isMobile;

      if (hasError) {
        return AppCard(
          padding: const EdgeInsets.all(24),
          elevation: AppCardElevation.md,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.warning_2, size: 42, color: AppColors.warning),
              const SizedBox(height: 12),
              const Text('Error loading assets', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: controller.fetchAssets,
                icon: const Icon(Iconsax.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (showMobile && !loading && !isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMobileCards(context),
            const SizedBox(height: 16),
            Obx(() => PaginatorFooter(
                  totalItems: controller.totalItems.value,
                  limit: controller.limit.value,
                  currentPage: controller.currentPage.value,
                  onPageChanged: controller.goToPage,
                  onLimitChanged: controller.setLimit,
                )),
          ],
        );
      }

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
                        const Text('Assets', style: AppTextStyles.h3),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                              loading
                                  ? 'Loading assets...'
                                  : '${controller.totalItems.value} asset${controller.totalItems.value == 1 ? '' : 's'} on record',
                              style: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            )),
                      ],
                    ),
                  ),
                  const StatusChip(
                    label: 'Bomach Group',
                    tone: StatusTone.primary,
                    icon: Iconsax.building,
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
                  icon: Iconsax.box_1,
                  title: 'No assets yet',
                  subtitle: 'Create a new asset to get started.',
                  action: MyElevatedButton(
                    icon: const Icon(Iconsax.add_circle,
                        size: 18, color: AppColors.textOnPrimary),
                    child: 'New Asset',
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => const AddAssetDialog(),
                    ),
                  ),
                ),
              )
            else ...[
              _buildTable(context),
              const Divider(height: 1, color: AppColors.borderSubtle),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Obx(() => PaginatorFooter(
                      totalItems: controller.totalItems.value,
                      limit: controller.limit.value,
                      currentPage: controller.currentPage.value,
                      onPageChanged: controller.goToPage,
                      onLimitChanged: controller.setLimit,
                    )),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildTable(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _headerCell('Asset Name', flex: 3),
              _headerCell('Type', flex: 2),
              _headerCell('Branch', flex: 3),
              _headerCell('Purchase Date', flex: 2),
              _headerCell('Value', flex: 2),
              _headerCell('Status', flex: 2),
              _headerCell('', width: 56),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...controller.assetList.map((a) => _buildRow(context, a)),
      ],
    );
  }

  Widget _headerCell(String label, {int? flex, double? width}) {
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

  Widget _buildRow(BuildContext context, Asset asset) {
    String displayDate = '';
    try {
      displayDate = DateFormat('dd-MM-yyyy').format(asset.purchaseDate);
    } catch (_) {
      displayDate = '—';
    }

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
            child: Text(
              asset.name,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: asset.assetType.isEmpty ? '—' : asset.assetType,
                tone: StatusTone.info,
                dense: true,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(Iconsax.location,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    asset.branch.isEmpty ? '—' : asset.branch,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              displayDate,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              asset.value.toStringAsFixed(2),
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: _statusLabel(asset.status),
                tone: _statusTone(asset.status),
                dense: true,
              ),
            ),
          ),
          SizedBox(
            width: 56,
            child: _buildActionMenu(context, asset),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, Asset asset) {
    final permissions = Get.find<PermissionService>();
    return Obx(() {
      final _ = permissions.version;
      final actions = visibleAssetActions(
        canEdit: permissions.has(Perms.assetsUpdate),
        canDelete: permissions.has(Perms.assetsDelete),
      );

      return Material(
        color: Colors.transparent,
        child: PopupMenuButton<String>(
          icon: const Icon(Iconsax.more, size: 20, color: AppColors.textSecondary),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
          color: AppColors.surface,
          elevation: 6,
          onSelected: (value) async {
            switch (value) {
              case 'view':
                showDialog(
                  context: context,
                  builder: (_) => ViewAssetDialog(asset: asset),
                );
                break;
              case 'edit':
                showDialog(
                  context: context,
                  builder: (_) => AddAssetDialog(asset: asset),
                );
                break;
              case 'delete':
                final confirmed = await DialogScaffold.show<bool>(
                  context,
                  title: 'Delete asset',
                  size: DialogSize.sm,
                  body: Text(
                    'Are you sure you want to delete "${asset.name}"? This action cannot be undone.',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  actions: [
                    MyOutlinedButton(
                      child: 'Cancel',
                      height: 44,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      textColor: AppColors.textSecondary,
                      borderColor: AppColors.borderStrong,
                      onTap: () => Navigator.pop(context, false),
                    ),
                    MyElevatedButton(
                      child: 'Delete',
                      height: 44,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      bgColor: AppColors.danger,
                      onTap: () => Navigator.pop(context, true),
                    ),
                  ],
                );
                if (confirmed == true && context.mounted) {
                  controller.deleteAsset(context, asset.id);
                }
                break;
            }
          },
          itemBuilder: (_) => actions.map((action) {
            switch (action) {
              case 'view':
                return const PopupMenuItem(
                  value: 'view',
                  child: Row(children: [
                    Icon(Iconsax.eye, size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ]),
                );
              case 'edit':
                return const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Iconsax.edit, size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ]),
                );
              case 'delete':
                return const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Iconsax.trash, size: 18, color: AppColors.danger),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.danger)),
                  ]),
                );
              default:
                return const PopupMenuItem<String>(enabled: false, child: SizedBox.shrink());
            }
          }).toList(),
        ),
      );
    });
  }

  String _statusLabel(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1);
  }

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'in_use':
      case 'in-use':
        return StatusTone.primary;
      case 'available':
      case 'active':
        return StatusTone.success;
      case 'damaged':
      case 'lost':
        return StatusTone.danger;
      case 'maintenance':
        return StatusTone.warning;
      case 'retired':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }
}
