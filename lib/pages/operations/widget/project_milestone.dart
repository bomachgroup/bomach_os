import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_date_field.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/pages/operations/controllers/milestone_controller.dart';
import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProjectMilestone extends StatefulWidget {
  final int projectId;
  const ProjectMilestone({super.key, required this.projectId});

  @override
  State<ProjectMilestone> createState() => _ProjectMilestoneState();
}

class _ProjectMilestoneState extends State<ProjectMilestone> {
  final ScrollController _scrollController = ScrollController();
  late final MilestoneController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MilestoneController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMilestones(context, projectId: widget.projectId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isLoading.value;
      final milestones = controller.milestones;

      return AppCard(
        padding: EdgeInsets.zero,
        elevation: AppCardElevation.sm,
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
                        const Text('Milestones', style: AppTextStyles.h3),
                        const SizedBox(height: 4),
                        Text(
                          loading
                              ? 'Loading milestones...'
                              : '${milestones.length} milestone${milestones.length == 1 ? '' : 's'} tracked',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const StatusChip(
                    label: 'Timeline',
                    tone: StatusTone.primary,
                    icon: Iconsax.flag,
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
            else if (milestones.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: EmptyState(
                  icon: Iconsax.flag,
                  title: 'No milestones yet',
                  subtitle:
                      'Milestones help track major deliverables for this project.',
                ),
              )
            else
              _buildTable(milestones),
          ],
        ),
      );
    });
  }

  Widget _buildTable(List<Milestone> milestones) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(milestones.length, (index) => _buildMobileCard(milestones[index], index)),
      ),
    );
  }

  Widget _buildMobileCard(Milestone m, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'S/N: ${index + 1}',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              StatusChip(
                label: _statusLabel(m.status),
                tone: _statusTone(m.status),
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            m.name,
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                m.budget.isEmpty ? 'Budget: —' : 'Budget: ${m.budget}',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              ),
              StatusChip(
                label: m.priority.isEmpty ? '—' : m.priority,
                tone: _priorityTone(m.priority),
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadii.brSm,
                  onTapDown: (details) async {
                    final selected = await showMenu<String>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                      ),
                      items: const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    );
                    if (!mounted) return;
                    if (selected == 'edit') {
                      showDialog(
                        context: context,
                        builder: (_) => AddMileStoneDialog(
                          projectId: widget.projectId,
                          milestone: m,
                        ),
                      );
                    } else if (selected == 'delete') {
                      controller.deleteMilestone(
                          context, m.id, widget.projectId);
                    }
                  },
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.brSm,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(Iconsax.more,
                        size: 16, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {double? width, int? flex}) {
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

  Widget _buildMilestoneRow(Milestone m, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '${index + 1}',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              m.name,
              style: AppTextStyles.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 140,
            child: Text(
              m.budget.isEmpty ? '—' : m.budget,
              style: AppTextStyles.bodyMd,
            ),
          ),
          SizedBox(
            width: 120,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: m.priority.isEmpty ? '—' : m.priority,
                tone: _priorityTone(m.priority),
                dense: true,
              ),
            ),
          ),
          SizedBox(
            width: 140,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: _statusLabel(m.status),
                tone: _statusTone(m.status),
                dense: true,
              ),
            ),
          ),
          SizedBox(
            width: 64,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadii.brSm,
                  onTapDown: (details) async {
                    final selected = await showMenu<String>(
                      context: context,
                      position: RelativeRect.fromLTRB(
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                        details.globalPosition.dx,
                        details.globalPosition.dy,
                      ),
                      items: const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    );
                    if (!mounted) return;
                    if (selected == 'edit') {
                      showDialog(
                        context: context,
                        builder: (_) => AddMileStoneDialog(
                          projectId: widget.projectId,
                          milestone: m,
                        ),
                      );
                    } else if (selected == 'delete') {
                      controller.deleteMilestone(
                          context, m.id, widget.projectId);
                    }
                  },
                  onTap: () {},
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.brSm,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(Iconsax.more,
                        size: 16, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  StatusTone _priorityTone(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return StatusTone.danger;
      case 'medium':
        return StatusTone.warning;
      case 'low':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }

  StatusTone _statusTone(String status) {
    final s = status.toLowerCase().replaceAll('_', ' ').trim();
    switch (s) {
      case 'pending':
        return StatusTone.neutral;
      case 'in progress':
        return StatusTone.primary;
      case 'completed':
        return StatusTone.success;
      case 'at risk':
        return StatusTone.warning;
      case 'overdue':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }

  String _statusLabel(String status) {
    if (status.isEmpty) return '—';
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty
            ? w
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}

class AddMileStoneDialog extends StatefulWidget {
  final int projectId;
  final Milestone? milestone;
  const AddMileStoneDialog(
      {super.key, required this.projectId, this.milestone});

  @override
  State<AddMileStoneDialog> createState() => _AddMileStoneDialogState();
}

class _AddMileStoneDialogState extends State<AddMileStoneDialog> {
  late final MilestoneController controller;

  late TextEditingController nameCtrl;
  late TextEditingController budgetCtrl;
  late TextEditingController startDateCtrl;
  late TextEditingController endDateCtrl;
  late TextEditingController descCtrl;

  String selectedStatus = 'Pending';
  String selectedPriority = 'Medium';

  @override
  void initState() {
    super.initState();
    controller = Get.find<MilestoneController>();
    final m = widget.milestone;
    nameCtrl = TextEditingController(text: m?.name ?? '');
    budgetCtrl = TextEditingController(text: m?.budget ?? '');
    startDateCtrl = TextEditingController(text: m?.startDate ?? '');
    endDateCtrl = TextEditingController(text: m?.endDate ?? '');
    descCtrl = TextEditingController(text: m?.description ?? '');
    if (m != null) {
      if (m.status.isNotEmpty) selectedStatus = m.status;
      if (m.priority.isNotEmpty) selectedPriority = m.priority;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    budgetCtrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.milestone != null;

    return DialogScaffold(
      title: isEdit ? 'Edit Milestone' : 'Create Milestone',
      subtitle:
          'Track a major deliverable with budget, timeline and priority.',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: MyTextFormField(
                controller: nameCtrl,
                title: 'Milestone Title*',
                hintText: 'Enter title',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MyTextFormField(
                controller: budgetCtrl,
                title: 'Budget',
                hintText: '0.00',
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: MyDropdown(
                title: 'Priority',
                items: const ['Low', 'Medium', 'High'],
                hintText: 'Select',
                controller: TextEditingController(text: selectedPriority),
                onChanged: (val) =>
                    setState(() => selectedPriority = val!),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MyDropdown(
                title: 'Status*',
                items: const ['Pending', 'In Progress', 'Completed'],
                hintText: 'Select',
                controller: TextEditingController(text: selectedStatus),
                onChanged: (val) => setState(() => selectedStatus = val!),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
              child: MyDateField(
                controller: startDateCtrl,
                title: 'Start Date',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MyDateField(
                controller: endDateCtrl,
                title: 'End Date',
              ),
            ),
          ]),
          const SizedBox(height: 20),
          MyTextFormField(
            controller: descCtrl,
            title: 'Description',
            maxLines: 3,
            hintText: 'Milestone details...',
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
        Obx(
          () => controller.isActionLoading.value
              ? const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : MyElevatedButton(
                  icon: SvgPicture.asset(
                    'assets/svg/check.svg',
                    colorFilter: const ColorFilter.mode(
                        AppColors.white, BlendMode.srcIn),
                  ),
                  child: isEdit ? 'Update' : 'Save',
                  onTap: _save,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
        ),
      ],
    );
  }

  void _save() {
    if (nameCtrl.text.isEmpty) return;

    final m = Milestone(
      id: widget.milestone?.id ?? 0,
      projectId: widget.projectId,
      name: nameCtrl.text,
      description: descCtrl.text,
      priority: selectedPriority,
      status: selectedStatus,
      budget: budgetCtrl.text,
      progress: widget.milestone?.progress ?? 0,
      startDate: startDateCtrl.text,
      endDate: endDateCtrl.text,
      createdAt: widget.milestone?.createdAt ?? '',
      updatedAt: '',
    );

    if (widget.milestone == null) {
      controller.createMilestone(context, m);
    } else {
      controller.updateMilestone(context, m.id, m);
    }
  }
}
