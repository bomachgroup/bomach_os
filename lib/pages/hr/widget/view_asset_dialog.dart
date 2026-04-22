import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../models/assets_model.dart';

// ═══════════════════════════════════════════════════════════════════════
//  VIEW ASSET DIALOG
// ═══════════════════════════════════════════════════════════════════════

class ViewAssetDialog extends StatelessWidget {
  final Asset asset;
  const ViewAssetDialog({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    String displayDate = '';
    try {
      displayDate = DateFormat('MMM d, yyyy').format(asset.purchaseDate);
    } catch (_) {
      displayDate = '–';
    }

    String warrantyDate = '';
    try {
      warrantyDate = DateFormat('MMM d, yyyy').format(asset.warrantyExpiryDate);
    } catch (_) {
      warrantyDate = '–';
    }

    return DialogScaffold(
      title: asset.name,
      subtitle: asset.assetType.isEmpty ? 'Asset details' : asset.assetType,
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(asset),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Asset information',
            children: [
              _detailRow('Type',
                  asset.assetType.isNotEmpty ? asset.assetType : '—'),
              _detailRow(
                  'Serial Number',
                  asset.serialNumber.isNotEmpty
                      ? asset.serialNumber
                      : '—'),
              _detailRow(
                  'Manufacturer',
                  asset.manufacturer.isNotEmpty
                      ? asset.manufacturer
                      : '—'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Location & assignment',
            children: [
              _detailRow('Branch', asset.branch.isEmpty ? '—' : asset.branch),
              _detailRow(
                  'Assigned To',
                  asset.assignedToId.isNotEmpty
                      ? asset.assignedToId
                      : 'Unassigned'),
              _detailRow(
                  'Department',
                  asset.departmentId.isNotEmpty
                      ? asset.departmentId
                      : '—'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Financial',
            children: [
              _detailRow('Purchase Date', displayDate),
              _detailRow('Value', asset.value.toStringAsFixed(2)),
              _detailRow(
                  'Vendor', asset.vendor.isNotEmpty ? asset.vendor : '—'),
              _detailRow(
                  'Invoice Number',
                  asset.invoiceNumber.isNotEmpty
                      ? asset.invoiceNumber
                      : '—'),
              _detailRow('Warranty Expiry', warrantyDate),
            ],
          ),
          if (asset.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Notes',
              children: [
                Text(
                  asset.notes,
                  style: AppText.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Close',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(Asset asset) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brLg,
            ),
            child: const Icon(Iconsax.box_1,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name, style: AppText.h3),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: _statusLabel(asset.status),
                      tone: _statusTone(asset.status),
                      icon: Iconsax.record_circle,
                    ),
                    if (asset.assetType.isNotEmpty)
                      _metaChip(
                        icon: Iconsax.tag,
                        label: asset.assetType,
                      ),
                    if (asset.branch.isNotEmpty)
                      _metaChip(
                        icon: Iconsax.location,
                        label: asset.branch,
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

  Widget _metaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brPill,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.h4),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style:
                  AppText.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppText.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
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
