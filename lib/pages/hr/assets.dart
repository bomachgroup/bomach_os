import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/section/responsive_widget.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller/assets_controller.dart';
import 'models/assets_model.dart';
import 'widget/add_asset_dialog.dart';
import 'widget/view_asset_dialog.dart';

import 'package:bms_front_end/pages/company/company.dart';

class AssetsPage extends StatelessWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AssetController controller = Get.put(AssetController());

    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const MyText('Company Assets', style: AppText.displayLg),
          const SizedBox(height: 8),
          const Text(
            'Manage company properties across all branches',
            style: TextStyle(color: AppColors.neutral500, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Assets Content
          _AssetsContent(controller: controller),
        ],
      ),
    );

    return ResponsiveWidget(
      largeScreen: body,
      mediumScreen: body,
      smallScreen: body,
    );
  }

}

// ═══════════════════════════════════════════════════════════════════════
//  ASSETS CONTENT
// ═══════════════════════════════════════════════════════════════════════

class _AssetsContent extends StatelessWidget {
  final AssetController controller;
  const _AssetsContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subheader
        ResponsiveSubheader(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText('Assets', style: AppText.h4),
              SizedBox(height: 2),
              Text('Bomach Group of Companies',
                  style: TextStyle(color: AppColors.neutral500, fontSize: 13)),
            ],
          ),
          search: MyTextFormField(
            hintText: 'Search',
            leading: const Icon(Iconsax.search_normal, color: Colors.grey, size: 20),
            onChanged: controller.onSearchChanged,
          ),
          action: MyElevatedButton(
            height: 40,
            icon: const Icon(Iconsax.add, color: Colors.white, size: 18),
            child: 'New Asset',
            onTap: () => showDialog(
              context: context,
              builder: (_) => const AddAssetDialog(),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Table
        Obx(() {
          if (controller.isLoading.value && controller.assetList.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.assetList.isEmpty) {
            return _buildEmptyState(
              context,
              icon: Iconsax.box_1,
              title: 'No assets yet',
              subtitle: 'Create a new asset to get started.',
              buttonLabel: 'New Asset',
              onAdd: () => showDialog(
                context: context,
                builder: (_) => const AddAssetDialog(),
              ),
            );
          }

          return ResponsiveTableWrapper(
            child: Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.neutral200),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      color: AppColors.neutral50,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 40),
                        Expanded(
                          flex: 2,
                          child: Text('Asset Name',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColors.neutral500)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('Type',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColors.neutral500)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text('Branch',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColors.neutral500)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('Purchase Date',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColors.neutral500)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('Value',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColors.neutral500)),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text('Status',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColors.neutral500)),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text('Action',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppColors.neutral500)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ...controller.assetList
                      .map((asset) => _buildAssetRow(context, asset)),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Obx(() => PaginatorFooter(
                          totalItems: controller.totalItems.value,
                          limit: controller.limit.value,
                          currentPage: controller.currentPage.value,
                          onPageChanged: controller.goToPage,
                          onLimitChanged: controller.setLimit,
                        )),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAssetRow(BuildContext context, Asset asset) {
    String displayDate = '';
    try {
      displayDate = DateFormat('MMM d, yyyy').format(asset.purchaseDate);
    } catch (_) {
      displayDate = '–';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: false,
              onChanged: (_) {},
              activeColor: AppColors.primary,
            ),
          ),
          // Asset Name
          Expanded(
            flex: 2,
            child: Text(
              asset.name,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Type
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getTypeColor(asset.assetType).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    width: 0.6,
                    color: _getTypeColor(asset.assetType),
                  ),
                ),
                child: Text(
                  asset.assetType,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getTypeColor(asset.assetType),
                  ),
                ),
              ),
            ),
          ),
          // Branch
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Iconsax.location,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(asset.branch,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          // Purchase Date
          Expanded(
            flex: 1,
            child: Text(displayDate, style: const TextStyle(fontSize: 13)),
          ),
          // Value
          Expanded(
            flex: 1,
            child: Text(
              asset.value.toStringAsFixed(2),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green),
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: _buildStatusBadge(asset.status),
          ),
          // Action menu
          SizedBox(
            width: 48,
            child: _buildActionMenu(context, asset),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Color color = _getStatusColor(status);
    final String display = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : status;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.record_circle, size: 7, color: color),
            const SizedBox(width: 5),
            Text(display,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, Asset asset) {
    return PopupMenuButton<String>(
      icon: const Icon(Iconsax.more, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                title: const Text('Delete Asset'),
                content:
                    Text('Are you sure you want to delete "${asset.name}"?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red))),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              controller.deleteAsset(context, asset.id);
            }
            break;
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'view',
          child: Row(children: [
            Icon(Iconsax.eye, size: 18, color: Colors.grey),
            SizedBox(width: 8),
            Text('View Details'),
          ]),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Iconsax.edit, size: 18, color: Colors.grey),
            SizedBox(width: 8),
            Text('Edit'),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Iconsax.trash, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onAdd,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.neutral400),
            ),
            const SizedBox(height: 20),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(color: AppColors.neutral500, fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            MyElevatedButton(
              child: buttonLabel,
              icon: const Icon(Iconsax.add, size: 18, color: Colors.white),
              onTap: onAdd,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'laptop':
        return Colors.blue;
      case 'vehicle':
        return Colors.purple;
      case 'furniture':
        return Colors.orange;
      case 'equipment':
        return Colors.green;
      case 'printer':
        return Colors.teal;
      case 'it equipment':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'available':
        return Colors.green;
      case 'in-use':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'retired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
