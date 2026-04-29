import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controller/pay_roll_controller.dart';
import '../models/payroll_model.dart';
import 'add_payroll_dialog.dart';

class ViewPayrollDialog extends StatelessWidget {
  final Payroll payroll;
  const ViewPayrollDialog({super.key, required this.payroll});

  @override
  Widget build(BuildContext context) {
    final PayrollController controller = Get.find();

    return DialogScaffold(
      title: 'Payroll Details',
      subtitle: payroll.payrollPeriod.isNotEmpty
          ? 'Period: ${payroll.payrollPeriod}'
          : 'Payroll record details',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(payroll),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Employee & Period',
            children: [
              _detailRow('Employee ID', payroll.employeeId),
              _detailRow(
                  'Payroll Period',
                  payroll.payrollPeriod.isNotEmpty
                      ? payroll.payrollPeriod
                      : '—'),
              _detailRow(
                'Disbursement Date',
                payroll.disbursementDate != null
                    ? DateFormat('MMM d, yyyy')
                        .format(payroll.disbursementDate!)
                    : 'N/A',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Salary Breakdown',
            children: [
              _detailRow('Gross Salary', payroll.grossSalary.toStringAsFixed(2)),
              _detailRow(
                  'Total Allowances',
                  payroll.totalAllowances.toStringAsFixed(2)),
              _detailRow(
                  'Total Deductions',
                  payroll.totalDeductions.toStringAsFixed(2)),
              _detailRow('Net Salary', payroll.netSalary.toStringAsFixed(2)),
            ],
          ),
          if (payroll.additions != null &&
              payroll.additions!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Allowances Included',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: payroll.additions!.keys
                      .map((k) => StatusChip(
                            label: k,
                            tone: StatusTone.primary,
                            icon: Iconsax.tick_circle,
                          ))
                      .toList(),
                ),
              ],
            ),
          ],
          if (payroll.deductions != null &&
              payroll.deductions!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(
              title: 'Deductions Included',
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: payroll.deductions!.keys
                      .map((k) => StatusChip(
                            label: k,
                            tone: StatusTone.warning,
                            icon: Iconsax.minus_cirlce,
                          ))
                      .toList(),
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
          child: 'Delete',
          onTap: () async {
            final confirm = await DialogScaffold.show<bool>(
              context,
              title: 'Delete Payroll',
              size: DialogSize.sm,
              body: const Text(
                'Are you sure you want to delete this payroll record? This action cannot be undone.',
                style: AppTextStyles.bodyMd,
              ),
              actions: [
                MyOutlinedButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  textColor: AppColors.textSecondary,
                  borderColor: AppColors.borderStrong,
                  child: 'No',
                  onTap: () => Navigator.pop(context, false),
                ),
                MyElevatedButton(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 12),
                  bgColor: AppColors.danger,
                  child: 'Yes, Delete',
                  onTap: () => Navigator.pop(context, true),
                ),
              ],
            );

            if (confirm == true) {
              await controller.deletePayroll(payroll.id);
              if (context.mounted) {
                Navigator.pop(context);
                AppToast.error(context, 'Payroll deleted');
              }
            }
          },
        ),
        MyElevatedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: 'Edit',
          onTap: () {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (c) => AddPayRollDialog(payrollToEdit: payroll),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryBanner(Payroll p) {
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
            child: const Icon(Iconsax.wallet_money,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Net Salary: ${p.netSalary.toStringAsFixed(2)}',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: _statusLabel(p.status),
                      tone: _payrollTone(p.status),
                      icon: Iconsax.record_circle,
                    ),
                    if (p.payrollPeriod.isNotEmpty)
                      _metaChip(
                        icon: Iconsax.calendar_1,
                        label: p.payrollPeriod,
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
            width: 180,
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

  StatusTone _payrollTone(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return StatusTone.success;
      case 'processing':
        return StatusTone.info;
      case 'pending':
        return StatusTone.warning;
      case 'failed':
        return StatusTone.danger;
      case 'scheduled':
        return StatusTone.primary;
      default:
        return StatusTone.neutral;
    }
  }
}
