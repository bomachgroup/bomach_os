import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/utils/number_formatting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../controller/loans_controller.dart';
import '../models/loans_model.dart';

class ViewLoanDialog extends StatelessWidget {
  final LoanRequest loan;

  const ViewLoanDialog({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final LoanController controller = Get.find();

    return DialogScaffold(
      title: 'Loan Application',
      subtitle:
          loan.employeeName.isNotEmpty ? loan.employeeName : 'Loan request',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(loan),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Loan Information',
            children: [
              _detailRow('Loan Amount', loan.loanAmount.toNaira()),
              _detailRow(
                  'Repayment Date',
                  loan.repaymentDate.isNotEmpty ? loan.repaymentDate : '—'),
              _detailRow(
                'Status',
                loan.status.isNotEmpty
                    ? loan.status[0].toUpperCase() + loan.status.substring(1)
                    : '—',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Emergency Contact',
            children: [
              _detailRow(
                'Contact Name',
                loan.emergencyContactName.isNotEmpty
                    ? loan.emergencyContactName
                    : '—',
              ),
              _detailRow(
                'Contact Phone',
                loan.emergencyContactPhone.isNotEmpty
                    ? loan.emergencyContactPhone
                    : '—',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Reason For Loan',
            children: [
              Text(
                loan.reason.isNotEmpty ? loan.reason : 'No reason provided',
                style: AppTextStyles.bodyMd,
              ),
            ],
          ),
          if (loan.attachment.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Attachment',
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.brSm,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: AppRadii.brSm,
                        ),
                        child: const Center(
                          child: Icon(
                            Iconsax.document,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loan.attachment,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: AppRadii.brSm,
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Iconsax.eye,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: AppRadii.brSm,
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Iconsax.document_download,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        MyOutlinedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.danger,
          borderColor: AppColors.danger,
          child: 'Reject',
          onTap: loan.id != null
              ? () => controller.rejectLoan(context, loan.id!)
              : () {},
        ),
        MyElevatedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          bgColor: AppColors.success,
          child: 'Approve',
          onTap: loan.id != null
              ? () => controller.approveLoan(context, loan.id!)
              : () {},
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(LoanRequest loan) {
    final initial = loan.employeeName.isNotEmpty
        ? loan.employeeName[0].toUpperCase()
        : '?';
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
            child: Center(
              child: Text(
                initial,
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.employeeName.isNotEmpty
                      ? loan.employeeName
                      : 'Unknown employee',
                  style: AppTextStyles.h3,
                ),
                if (loan.jobTitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    loan.jobTitle,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: _statusLabel(loan.status),
                      tone: _loanTone(loan.status),
                      icon: Iconsax.record_circle,
                    ),
                    _metaChip(
                      icon: Iconsax.money,
                      label: loan.loanAmount.toNaira(),
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
            style: AppTextStyles.bodySm.copyWith(
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

  String _statusLabel(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1);
  }

  StatusTone _loanTone(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return StatusTone.success;
      case 'pending':
        return StatusTone.warning;
      case 'rejected':
        return StatusTone.danger;
      case 'repaid':
        return StatusTone.primary;
      case 'defaulted':
        return StatusTone.danger;
      case 'active':
        return StatusTone.info;
      default:
        return StatusTone.neutral;
    }
  }
}
