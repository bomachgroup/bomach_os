import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Read-only preview of a compliance record. Mirrors ViewMeetingDialog's
/// summary-banner + grouped-section layout so every "view" modal in the
/// Company module follows the same rhythm.
class ViewComplianceDialog extends StatelessWidget {
  final Map<String, dynamic> record;

  const ViewComplianceDialog({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final String status = (record['status'] ?? '').toString();
    final String statusLabel = _statusLabel(status);
    final String id = (record['id'] ?? '').toString();
    final String type = (record['type'] ?? '').toString();
    final String user = (record['user'] ?? '').toString();
    final String userEmail = (record['userEmail'] ?? '').toString();
    final String dateSubmitted = (record['dateSubmitted'] ?? '').toString();
    final String expiryDate = (record['expiryDate'] ?? '').toString();

    return DialogScaffold(
      title: 'Compliance Record',
      subtitle: type.isEmpty ? 'Compliance details' : type,
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(
            type: type.isEmpty ? 'Compliance record' : type,
            statusLabel: statusLabel,
            statusTone: _statusTone(status),
            id: id,
            expiryDate: expiryDate,
          ),
          const SizedBox(height: 20),
          _buildDetailSection(
            title: 'Record information',
            children: [
              _detailRow('Compliance ID', id),
              _detailRow('Compliance Type', type),
              _detailRow('Date Submitted', dateSubmitted),
              _detailRow('Expiry Date', expiryDate),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailSection(
            title: 'Submitted by',
            children: [
              _buildSubmitter(user: user, email: userEmail),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailSection(
            title: 'Additional information',
            children: [
              _detailRow('Issuing Authority', 'National Compliance Agency'),
              _detailRow(
                'Reference Number',
                id.isEmpty ? '—' : 'REF-$id-2025',
              ),
              _detailRow('Priority Level', 'High'),
              const SizedBox(height: 4),
              Text(
                'Description',
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                'This compliance record contains all necessary documentation '
                'and certifications required by regulatory authorities.',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailSection(
            title: 'Attached documents',
            children: [
              _buildDocumentItem('Certificate.pdf', '2.5 MB'),
              const SizedBox(height: 10),
              _buildDocumentItem('Supporting_Document.pdf', '1.8 MB'),
            ],
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Close',
          height: 44,
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyOutlinedButton(
          child: 'Archive',
          height: 44,
          icon: const Icon(Iconsax.archive_minus,
              size: 18, color: AppColors.danger),
          onTap: () => Navigator.pop(context),
          textColor: AppColors.danger,
          borderColor: AppColors.danger,
        ),
        MyElevatedButton(
          height: 44,
          icon: const Icon(Iconsax.edit,
              size: 18, color: AppColors.textOnPrimary),
          child: 'Edit',
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ── Banner ────────────────────────────────────────────────────────

  Widget _buildSummaryBanner({
    required String type,
    required String statusLabel,
    required StatusTone statusTone,
    required String id,
    required String expiryDate,
  }) {
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
            child: const Icon(Iconsax.shield_tick,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type, style: AppTextStyles.h3),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(label: statusLabel, tone: statusTone),
                    if (id.isNotEmpty)
                      _buildMetaChip(
                        icon: Iconsax.hashtag,
                        label: 'ID $id',
                      ),
                    if (expiryDate.isNotEmpty)
                      _buildMetaChip(
                        icon: Iconsax.calendar_1,
                        label: 'Expires $expiryDate',
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

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
  }) {
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
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sections ──────────────────────────────────────────────────────

  Widget _buildDetailSection({
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
          Text(title, style: AppTextStyles.h4),
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
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitter({required String user, required String email}) {
    final initial = user.isNotEmpty ? user[0].toUpperCase() : '?';
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primarySubtle,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: AppTextStyles.h3.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.isEmpty ? 'Unknown' : user,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (email.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  email,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItem(String name, String size) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brMd,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Iconsax.document_text,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  size,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Download',
            icon: const Icon(Iconsax.document_download, size: 18),
            color: AppColors.primary,
            onPressed: () {
              // Download hook lives here — not implemented in the read-only
              // preview yet.
            },
          ),
        ],
      ),
    );
  }

  // ── Status helpers ───────────────────────────────────────────────

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'expired':
        return 'Expired';
      case 'rejected':
        return 'Rejected';
      default:
        return status.isEmpty
            ? 'Unknown'
            : status[0].toUpperCase() + status.substring(1);
    }
  }

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return StatusTone.success;
      case 'pending':
        return StatusTone.warning;
      case 'expired':
      case 'rejected':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }
}
