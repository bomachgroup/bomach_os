import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/nav/three_dot_pop.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/section/responsive_stat_row.dart';
import 'package:bomach_os/pages/hr/widget/add_program_dialog.dart';
import 'package:bomach_os/pages/hr/widget/view_program_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/constants/shadows.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'controller/training_program_controller.dart';

class TrainingProgramPage extends StatefulWidget {
  const TrainingProgramPage({super.key});

  @override
  State<TrainingProgramPage> createState() => TrainingProgramPageState();
}

class TrainingProgramPageState extends State<TrainingProgramPage> {
  final ScrollController _scrollController = ScrollController();
  final TrainingProgramController _ctrl = Get.put(TrainingProgramController());
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.fetchData();
    });
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
        title: 'Training & Development',
        subtitle:
            'Enhance employee skills through structured programs and assessments.',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyOutlinedButton(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: "Training Policy",
              onTap: () {},
            ),
            const SizedBox(width: 12),
            PermissionGate(
              require: Perms.trainingProgramsCreate,
              child: MyElevatedButton(
                icon: const Icon(Iconsax.add_circle,
                    color: AppColors.white, size: 20),
                child: "Create Program",
                onTap: () async {
                  final token = await _storage.read(key: 'access_token');
                  if (token != null && context.mounted) {
                    String cleanToken = token
                        .replaceAll('"', '')
                        .replaceAll('Bearer ', '')
                        .trim();
                    showDialog(
                      context: context,
                      builder: (context) => AddProgramDialog(token: cleanToken),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      children: [
        // --- 2. Stats Cards ---
        Obx(() => ResponsiveStatRow(
              cards: [
                _StatCard(
                  title: 'Total Programs',
                  count: _ctrl.stats['totalPrograms'].toString(),
                  icon: Iconsax.teacher,
                  accent: AppColors.primary,
                ),
                _StatCard(
                  title: 'Programs on this page',
                  count: _ctrl.programList.length.toString(),
                  icon: Iconsax.teacher,
                  accent: AppColors.success,
                ),
              ],
            )),
        const SizedBox(height: 32),

        // --- 3. Tabs ---
        Obx(() => const Row(
              children: [
                Text('Training Programs', style: AppTextStyles.h3),
              ],
            )),
        const SizedBox(height: 24),

        // --- 4. Main Content Area (Filters + Table) ---
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // Filters
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 300,
                      child: MyTextFormField(
                        controller: _ctrl.searchController,
                        hintText: 'Search...',
                        leading: Icon(Iconsax.search_normal,
                            color: AppColors.textMuted.withValues(alpha: 0.5)),
                      ),
                    ),
                    Row(
                      children: [
                        _buildDropdownFilter("All Departments"),
                        const SizedBox(width: 12),
                        _buildStatusFilter(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Table
              Obx(() {
                if (_ctrl.isLoading.value) {
                  return const SizedBox(
                      height: 300,
                      child: Center(child: CircularProgressIndicator()));
                }

                if (_ctrl.errorMessage.value.isNotEmpty) {
                  return SizedBox(
                    height: 220,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Unable to load training programs',
                            style: AppTextStyles.h4,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _ctrl.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.danger),
                          ),
                          const SizedBox(height: 16),
                          MyOutlinedButton(
                            child: 'Retry',
                            onTap: _ctrl.fetchData,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (_ctrl.totalCount.value == 0) {
                  return const SizedBox(
                      height: 200,
                      child: Center(
                          child: Text("No records found.",
                              style: AppTextStyles.bodyMd)));
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildProgramsMobileCards(),
                );
              }),

              const Divider(height: 1, color: AppColors.borderSubtle),
              const SizedBox(height: 12),

              // --- 5. Pagination ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Obx(() => PaginatorFooter(
                      totalItems: _ctrl.totalCount.value,
                      limit: _ctrl.itemsPerPage.value,
                      currentPage: _ctrl.currentPage.value,
                      onPageChanged: (newPage) => _ctrl.changePage(newPage),
                      onLimitChanged: (newLimit) => _ctrl.changeLimit(newLimit),
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- UI Components ---

  Widget _buildProgramsMobileCards() {
    return Column(
      children: _ctrl.programList.map((program) {
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
                  StatusChip.fromStatus(program.status),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                program.programName,
                style:
                    AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                '${program.durationDays} days  •  ${program.targetAudience}',
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textMuted),
                      ),
                      Text(
                        program.startDate != null
                            ? DateFormat('dd MMM yyyy')
                                .format(program.startDate!)
                            : '-',
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'End Date',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textMuted),
                      ),
                      Text(
                        program.endDate != null
                            ? DateFormat('dd MMM yyyy').format(program.endDate!)
                            : '-',
                        style: AppTextStyles.bodySm,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    program.provider.isEmpty
                        ? 'Provider not specified'
                        : program.provider,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  ThreeDotPop(
                    onTapView: () async {
                      final token = await _storage.read(key: 'access_token');
                      if (token != null && context.mounted) {
                        String cleanToken = token
                            .replaceAll('"', '')
                            .replaceAll('Bearer ', '')
                            .trim();
                        showDialog(
                          context: context,
                          builder: (context) => ViewProgramDialog(
                            program: program,
                            token: cleanToken,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
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
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textPrimary),
              onChanged: (val) => _ctrl.updateStatusFilter(val),
              items: _ctrl.statusOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          )),
    );
  }

  Widget _buildDropdownFilter(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brMd,
      ),
      child: Row(
        children: [
          Text(text,
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          const Icon(Iconsax.arrow_down_1,
              size: 18, color: AppColors.textSecondary)
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
