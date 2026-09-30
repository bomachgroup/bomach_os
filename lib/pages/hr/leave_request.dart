import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/nav/three_dot_pop.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/section/responsive_stat_row.dart';
import 'package:bomach_os/pages/hr/widget/add_leave_request_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/constants/shadows.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';

import 'controller/leave_request_controller.dart';
import 'models/leave_request_model.dart';
import 'widget/view_leave_request_dialog.dart';

class LeaveRequestPage extends StatefulWidget {
  const LeaveRequestPage({super.key});

  @override
  State<LeaveRequestPage> createState() => LeaveRequestPageState();
}

class LeaveRequestPageState extends State<LeaveRequestPage> {
  final ScrollController _scrollController = ScrollController();
  final LeaveRequestController _ctrl = Get.put(LeaveRequestController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.fetchLeaveRequests(context);
    });
    _ctrl.searchController.addListener(() => _ctrl.onSearchChanged(context));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      header: PageHeader(
        title: 'Leave Management',
        subtitle: 'Track and manage employee leave requests and policies.',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyOutlinedButton(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: 'Leave Policy',
              onTap: () {},
            ),
            const SizedBox(width: 12),
            MyElevatedButton(
              height: 48,
              icon: const Icon(
                Iconsax.add_circle,
                color: AppColors.textOnPrimary,
                size: 20,
              ),
              child: "Leave Application",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddLeaveRequestDialog(),
                );
              },
            ),
          ],
        ),
      ),
      children: [
        // --- 2. Stats Cards Section ---
        Obx(() => ResponsiveStatRow(
              cards: [
                _StatCard(
                  title: 'Pending Requests',
                  count: _ctrl.stats['pending'].toString(),
                  icon: Iconsax.timer,
                  accent: AppColors.warning,
                ),
                _StatCard(
                  title: 'On Leave Today',
                  count: _ctrl.stats['onLeave'].toString(),
                  icon: Iconsax.user_tag,
                  accent: AppColors.primary,
                ),
                _StatCard(
                  title: 'Approved This Month',
                  count: _ctrl.stats['approved'].toString(),
                  icon: Iconsax.tick_circle,
                  accent: AppColors.success,
                ),
                _StatCard(
                  title: 'Rejected',
                  count: _ctrl.stats['rejected'].toString(),
                  icon: Iconsax.close_circle,
                  accent: AppColors.danger,
                ),
              ],
            )),
        const SizedBox(height: 32),

        // --- 3. Tabs Section ---
        Obx(() => Row(
              children: [
                _buildTabButton('All', _ctrl.activeTab.value == 'All'),
                const SizedBox(width: 12),
                _buildTabButton('Pending Approvals',
                    _ctrl.activeTab.value == 'Pending Approvals'),
                const SizedBox(width: 12),
                _buildTabButton('History', _ctrl.activeTab.value == 'History'),
              ],
            )),
        const SizedBox(height: 24),

        // --- 4. Filters & Table Section ---
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filters Row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- Search Field ---
                    SizedBox(
                      width: 300,
                      child: MyTextFormField(
                        controller: _ctrl.searchController,
                        hintText: 'Search...',
                        leading: Icon(
                          Iconsax.search_normal,
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                        ),
                      ),
                    ),

                    // --- Status Filter (Dropdown) ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: AppRadii.brMd,
                          border: Border.all(color: AppColors.borderSubtle)),
                      child: Obx(() => DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _ctrl.selectedStatusFilter.value,
                              icon: const Icon(Iconsax.arrow_down_1,
                                  size: 18, color: AppColors.textSecondary),
                              elevation: 4,
                              style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textPrimary),
                              onChanged: (String? newValue) {
                                _ctrl.updateStatusFilter(newValue, context);
                              },
                              items: _ctrl.filterStatusOptions
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Data Table
              Obx(() {
                if (_ctrl.isLoading.value) {
                  return const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (_ctrl.hasError.value) {
                  return Center(
                    child: Column(
                      children: [
                        const Icon(Iconsax.danger,
                            size: 48, color: AppColors.danger),
                        const SizedBox(height: 8),
                        Text(_ctrl.errorMessage.value, style: AppTextStyles.bodyMd),
                        TextButton(
                            onPressed: () => _ctrl.fetchLeaveRequests(context),
                            child: const Text("Retry"))
                      ],
                    ),
                  );
                }

                if (_ctrl.leaveList.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: Text("No records found", style: AppTextStyles.bodyMd)),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _ctrl.leaveList.map((r) => _buildMobileCard(context, r)).toList(),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // --- 5. Pagination Footer ---
              const Divider(height: 1, color: AppColors.borderSubtle),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Obx(() => PaginatorFooter(
                      totalItems: _ctrl.totalCount.value,
                      limit: _ctrl.itemsPerPage.value,
                      currentPage: _ctrl.currentPage.value,
                      onPageChanged: (newPage) {
                        _ctrl.changePage(newPage, context);
                      },
                      onLimitChanged: (newLimit) {
                        _ctrl.changeLimit(newLimit, context);
                      },
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildTabButton(String text, bool isActive) {
    return InkWell(
      onTap: () => _ctrl.setActiveTab(text, context),
      borderRadius: AppRadii.brPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: AppRadii.brPill,
          border: Border.all(
              color: isActive ? AppColors.primary : AppColors.borderSubtle),
        ),
        child: Text(
          text,
          style: AppTextStyles.bodySm.copyWith(
            color: isActive ? AppColors.textOnPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context, LeaveRequest r) {
    final duration = r.durationDays ??
        (r.endDate != null && r.startDate != null
            ? r.endDate!.difference(r.startDate!).inDays + 1
            : 0);
    final status = r.status?.toLowerCase() ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                toBeginningOfSentenceCase(r.leaveType.replaceAll('_', ' ')) ??
                    r.leaveType,
                style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
              StatusChip.fromStatus(status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.surfaceMuted,
                radius: 16,
                child: Icon(Iconsax.profile_circle,
                    color: AppColors.textMuted, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.employeeId,
                      style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "Software Engineer",
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
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
                    'Duration',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  ),
                  Text(
                    '$duration Day${duration != 1 ? 's' : ''}',
                    style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Dates',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  ),
                  Text(
                    '${r.startDate != null ? DateFormat('dd-MM-yyyy').format(r.startDate!) : ''} - ${r.endDate != null ? DateFormat('dd-MM-yyyy').format(r.endDate!) : ''}',
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ],
          ),
          if (r.reason != null && r.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Reason: ${r.reason!}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ThreeDotPop(
              onTapView: () {
                showDialog(
                  context: context,
                  builder: (context) => ViewLeaveRequestDialog(request: r),
                );
              },
              onTapEdit: () {
                _ctrl.populateForm(r);
                showDialog(
                    context: context,
                    builder: (_) => AddLeaveRequestDialog(request: r));
              },
            ),
          ),
        ],
      ),
    );
  }


}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: AppRadii.brSm,
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
