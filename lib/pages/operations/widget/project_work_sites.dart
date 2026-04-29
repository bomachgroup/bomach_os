import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/pages/operations/controllers/work_site_controller.dart';
import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:bomach_os/pages/operations/widget/project_task_table.dart';
import 'package:bomach_os/pages/operations/widget/site_equipment_table.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProjectWorkSite extends StatefulWidget {
  final int projectId;
  const ProjectWorkSite({super.key, required this.projectId});

  @override
  State<ProjectWorkSite> createState() => _ProjectWorkSiteState();
}

class _ProjectWorkSiteState extends State<ProjectWorkSite> {
  int selectionStepperState = 0;
  Worksite? selectedWorksite;
  late final WorksiteController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<WorksiteController>()
        ? Get.find<WorksiteController>()
        : Get.put(WorksiteController());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchWorksites(context, projectId: widget.projectId);
      if (controller.worksites.isNotEmpty) {
        setState(() => selectedWorksite = controller.worksites.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.worksites.isEmpty) {
        return const EmptyState(
          icon: Iconsax.location,
          title: 'No worksites yet',
          subtitle: 'Add a worksite to track equipment and site-level tasks.',
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Worksite selector card
          AppCard(
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: isWide ? 3 : 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Worksite',
                          style: AppTextStyles.overline,
                        ),
                        const SizedBox(height: 8),
                        MyDropdown(
                          hintText: 'Select a worksite',
                          items: controller.worksites
                              .map((ws) => '${ws.name} — ${ws.location}')
                              .toList(),
                          initialSelection: selectedWorksite == null
                              ? null
                              : '${selectedWorksite!.name} — ${selectedWorksite!.location}',
                          onChanged: (val) {
                            if (val == null) return;
                            final match = controller.worksites.firstWhereOrNull(
                              (w) => '${w.name} — ${w.location}' == val,
                            );
                            if (match != null) {
                              setState(() => selectedWorksite = match);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: isWide ? 20 : 0, height: isWide ? 0 : 16),
                  if (selectedWorksite != null)
                    Expanded(
                      flex: isWide ? 2 : 0,
                      child: Align(
                        alignment: isWide
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: StatusChip(
                          label: selectedWorksite!.status.isEmpty
                              ? 'Active'
                              : selectedWorksite!.status,
                          tone: _worksiteTone(selectedWorksite!.status),
                          icon: Iconsax.location,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
          const SizedBox(height: 20),

          // Sub-tab selector
          _buildSubTabs(),
          const SizedBox(height: 20),

          // Sub-tab content
          _buildSubTabContent(),
        ],
      );
    });
  }

  Widget _buildSubTabs() {
    const tabs = [
      (icon: Iconsax.people, label: 'Employees'),
      (icon: Iconsax.setting_2, label: 'Site Equipment'),
      (icon: Iconsax.task_square, label: 'Site Tasks'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(tabs.length, (index) {
        final tab = tabs[index];
        final selected = selectionStepperState == index;
        return _SubTabChip(
          icon: tab.icon,
          label: tab.label,
          isActive: selected,
          onTap: () => setState(() => selectionStepperState = index),
        );
      }),
    );
  }

  Widget _buildSubTabContent() {
    if (selectionStepperState == 0) {
      return const EmptyState(
        icon: Iconsax.people,
        title: 'No site employees yet',
        subtitle: 'Employees assigned to this worksite will appear here.',
      );
    }
    if (selectionStepperState == 1) {
      if (selectedWorksite == null) {
        return const EmptyState(
          icon: Iconsax.setting_2,
          title: 'Select a worksite first',
          subtitle: 'Pick an active worksite above to view its equipment.',
          compact: true,
        );
      }
      return SiteEquipmentTable(worksiteId: selectedWorksite!.id);
    }
    return ProjectTaskTable(projectId: widget.projectId);
  }

  StatusTone _worksiteTone(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return StatusTone.success;
      case 'paused':
        return StatusTone.warning;
      case 'hazard':
        return StatusTone.danger;
      case 'closed':
        return StatusTone.neutral;
      default:
        return StatusTone.success;
    }
  }
}

class _SubTabChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SubTabChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isActive ? AppColors.primarySubtle : AppColors.surface;
    final fg = isActive ? AppColors.primary : AppColors.textSecondary;
    final border = isActive ? AppColors.primary : AppColors.borderSubtle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.brMd,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadii.brMd,
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodyMd.copyWith(
                  color: fg,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialog used from the Add Worksite button on the Work site tab
class CreateWorkSiteReport extends StatelessWidget {
  final int projectId;
  const CreateWorkSiteReport({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // redirected — use AddWorksiteDialog
  }
}
