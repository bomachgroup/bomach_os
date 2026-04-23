import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/pages/hr/widget/add_loan_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_loans_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controller/loans_controller.dart';

class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  final LoanController _ctrl = Get.put(LoanController());

  StatusTone _statusTone(String status) {
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

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Loans',
        subtitle: 'Review staff loan requests, approvals and repayments.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Loan Application',
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => const AddLoanDialog(),
            );
          },
        ),
      ),
      children: [
        _buildTabs(),
        _buildToolbar(),
        Obx(() {
          final loading =
              _ctrl.isLoading.value && _ctrl.displayedLoans.isEmpty;
          final isEmpty = !loading && _ctrl.displayedLoans.isEmpty;

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
            body: _buildTable(),
            footer: (!loading && _ctrl.displayedLoans.isNotEmpty)
                ? _tablePaginator(
                    Obx(() => PaginatorFooter(
                          totalItems: _ctrl.totalCount.value,
                          limit: _ctrl.itemsPerPage.value,
                          currentPage: _ctrl.currentPage.value,
                          onPageChanged: (page) =>
                              _ctrl.changePage(page, context),
                          onLimitChanged: (limit) =>
                              _ctrl.changeLimit(limit, context),
                        )),
                  )
                : null,
          );
        }),
      ],
    );
  }

  Widget _buildTabs() {
    return Obx(() => Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildTabButton('All', _ctrl.activeTab.value == 'All'),
            _buildTabButton(
              'Pending Approvals',
              _ctrl.activeTab.value == 'Pending Approvals',
            ),
            _buildTabButton('History', _ctrl.activeTab.value == 'History'),
          ],
        ));
  }

  Widget _buildTabButton(String text, bool isActive) {
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadii.brPill,
      child: InkWell(
        onTap: () => _ctrl.setActiveTab(text, context),
        borderRadius: AppRadii.brPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.surface,
            borderRadius: AppRadii.brPill,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.borderSubtle,
            ),
          ),
          child: Text(
            text,
            style: AppTextStyles.bodyMd.copyWith(
              color: isActive
                  ? AppColors.textOnPrimary
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final search = MyTextFormField(
          controller: _ctrl.searchController,
          hintText: 'Search loans by employee or reason',
          height: 48,
          leading: const Icon(Iconsax.search_normal,
              size: 18, color: AppColors.textMuted),
          onChanged: (_) => _ctrl.update(),
        );

        final filter = SizedBox(
          width: isWide ? 220 : double.infinity,
          child: Obx(() => MyDropdown(
                hintText: _ctrl.selectedStatusFilter.value,
                initialSelection: _ctrl.statusOptions
                        .contains(_ctrl.selectedStatusFilter.value)
                    ? _ctrl.selectedStatusFilter.value
                    : null,
                items: _ctrl.statusOptions,
                onChanged: (val) => _ctrl.updateStatusFilter(val, context),
              )),
        );

        if (isWide) {
          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 12),
              filter,
            ],
          );
        }
        return Column(
          children: [
            search,
            const SizedBox(height: 12),
            filter,
          ],
        );
      }),
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
                      const Text('Loan applications', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            loading
                                ? 'Loading loan applications...'
                                : '${_ctrl.totalCount.value} application${_ctrl.totalCount.value == 1 ? '' : 's'} on file',
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
                  icon: Iconsax.wallet_money,
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
                icon: Iconsax.wallet_money,
                title: 'No loan applications found',
                subtitle:
                    'Loan requests submitted by staff will appear here for approval.',
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

  Widget _buildTable() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Employee', flex: 3),
              _buildHeaderCell('Loan Amount', flex: 2),
              _buildHeaderCell('Repayment Date', flex: 2),
              _buildHeaderCell('Reason', flex: 3),
              _buildHeaderCell('Status', flex: 2),
              _buildHeaderCell('', width: 48),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ..._ctrl.displayedLoans.map(_buildDataRow),
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

  Widget _buildDataRow(loan) {
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
                    loan.employeeName.isNotEmpty
                        ? loan.employeeName[0].toUpperCase()
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
                        loan.employeeName,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        loan.jobTitle,
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
            flex: 2,
            child: Text(
              '₦${loan.loanAmount}',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              loan.repaymentDate,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              loan.reason,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: loan.status,
                tone: _statusTone(loan.status),
                dense: true,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Align(
              alignment: Alignment.centerRight,
              child: ThreeDotPop(
                onTapView: () {
                  showDialog(
                    context: context,
                    builder: (_) => ViewLoanDialog(loan: loan),
                  );
                },
                onTapEdit: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AddLoanDialog(loanToEdit: loan),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
