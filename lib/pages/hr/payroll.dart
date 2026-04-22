import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/pages/hr/widget/add_payroll_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_payroll_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'controller/pay_roll_controller.dart';
import 'models/payroll_model.dart';

class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  @override
  State<PayrollPage> createState() => PayrollPageState();
}

class PayrollPageState extends State<PayrollPage> {
  final PayrollController controller = Get.put(PayrollController());
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Payroll> _filtered(List<Payroll> items) {
    if (_searchQuery.isEmpty) return items;
    final q = _searchQuery.toLowerCase();
    return items.where((p) {
      return p.employeeId.toLowerCase().contains(q) ||
          p.payrollPeriod.toLowerCase().contains(q) ||
          p.status.toLowerCase().contains(q);
    }).toList();
  }

  StatusTone _statusTone(String status) {
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

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Payroll',
        subtitle: 'Manage employee payroll records and disbursements.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Payroll',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const AddPayRollDialog(),
            );
          },
        ),
      ),
      children: [
        _buildToolbar(),
        Obx(() {
          final loading =
              controller.isLoading.value && controller.payrollList.isEmpty;
          final filtered = _filtered(controller.payrollList);
          final isEmpty = !loading && filtered.isEmpty;

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
            filtered: filtered,
            body: _buildTable(filtered),
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
        hintText: 'Search by employee, period or status',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
    );
  }

  Widget _buildTableCard({
    required bool loading,
    required bool isEmpty,
    required List<Payroll> filtered,
    required Widget body,
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
                      const Text('Payroll ledger', style: AppText.h3),
                      const SizedBox(height: 4),
                      Text(
                        loading
                            ? 'Loading payroll records...'
                            : '${filtered.length} record${filtered.length == 1 ? '' : 's'} on file',
                        style: AppText.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Finance pipeline',
                  tone: StatusTone.primary,
                  icon: Iconsax.money_recive,
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
          else if (controller.errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.warning_2,
                title: 'Unable to load payroll',
                subtitle: controller.errorMessage.value,
              ),
            )
          else if (isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.money_recive,
                title: 'No payroll records yet',
                subtitle:
                    'Add a payroll entry to begin tracking employee compensation.',
              ),
            )
          else
            body,
        ],
      ),
    );
  }

  Widget _buildTable(List<Payroll> items) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Employee ID', flex: 2),
              _buildHeaderCell('Period', flex: 2),
              _buildHeaderCell('Disbursement', flex: 2),
              _buildHeaderCell('Gross Salary', flex: 2),
              _buildHeaderCell('Net Salary', flex: 2),
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
      style: AppText.bodySm.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
    if (width != null) return SizedBox(width: width, child: content);
    return Expanded(flex: flex ?? 1, child: content);
  }

  Widget _buildDataRow(Payroll payroll) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => ViewPayrollDialog(payroll: payroll),
                );
              },
              child: Text(
                payroll.employeeId,
                style: AppText.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              payroll.payrollPeriod,
              style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              payroll.disbursementDate != null
                  ? DateFormat('dd MMM yyyy').format(payroll.disbursementDate!)
                  : '—',
              style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              payroll.grossSalary.toStringAsFixed(2),
              style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              payroll.netSalary.toStringAsFixed(2),
              style: AppText.bodyMd.copyWith(
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
                label: payroll.status,
                tone: _statusTone(payroll.status),
                dense: true,
              ),
            ),
          ),
          const SizedBox(
            width: 48,
            child: Align(
              alignment: Alignment.centerRight,
              child: ThreeDotPop(),
            ),
          ),
        ],
      ),
    );
  }
}
