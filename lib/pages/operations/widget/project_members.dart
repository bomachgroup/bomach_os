import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/pages/operations/controllers/project_controller.dart';
import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class ProjectMembers extends StatefulWidget {
  final int projectId;
  const ProjectMembers({super.key, required this.projectId});

  @override
  State<ProjectMembers> createState() => _ProjectMembersState();
}

class _ProjectMembersState extends State<ProjectMembers> {
  final ScrollController _scrollController = ScrollController();
  late final ProjectController controller;

  static const _avatarColors = [
    AppColors.primary,
    AppColors.success,
    AppColors.warning,
    AppColors.info,
    Color(0xFF7C3AED),
    Color(0xFFC026D3),
  ];

  Color _avatarColor(int index) => _avatarColors[index % _avatarColors.length];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ProjectController>()
        ? Get.find<ProjectController>()
        : Get.put(ProjectController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProjectEmployees(context, widget.projectId);
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
      final loading = controller.isLoadingEmployees.value;
      final members = controller.projectEmployees;

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
                        const Text('Project Members',
                            style: AppTextStyles.h3),
                        const SizedBox(height: 4),
                        Text(
                          loading
                              ? 'Loading members...'
                              : '${members.length} member${members.length == 1 ? '' : 's'} assigned to this project',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const StatusChip(
                    label: 'Team',
                    tone: StatusTone.primary,
                    icon: Iconsax.people,
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
            else if (members.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: EmptyState(
                  icon: Iconsax.people,
                  title: 'No members assigned',
                  subtitle:
                      'Add members to this project to collaborate on tasks and milestones.',
                ),
              )
            else
              _buildTable(members),
          ],
        ),
      );
    });
  }

  Widget _buildTable(List<ProjectEmployee> members) {
    if (context.isMobile) {
      return Column(
        children: members.asMap().entries.map((e) => _buildMobileCard(e.value, e.key)).toList(),
      );
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 900),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                color: AppColors.surfaceMuted,
                child: Row(
                  children: [
                    _headerCell('Employee ID', width: 140),
                    _headerCell('Employee Name', flex: 3),
                    _headerCell('Department', flex: 2),
                    _headerCell('Designation', flex: 2),
                    _headerCell('Type', width: 140),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),
              ...members
                  .asMap()
                  .entries
                  .map((e) => _buildMemberRow(e.value, e.key)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCard(ProjectEmployee emp, int index) {
    final color = _avatarColor(index);
    final initials = emp.fullName.isNotEmpty
        ? emp.fullName.trim().substring(0, 1).toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
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
                emp.employeeId.isEmpty ? '—' : emp.employeeId,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                ),
              ),
              StatusChip(
                label: emp.employmentType.isEmpty ? '—' : emp.employmentType,
                tone: _roleTone(emp.position),
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text(
                  initials,
                  style: AppTextStyles.label.copyWith(
                    color: color,
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
                      emp.fullName.isEmpty ? '—' : emp.fullName,
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (emp.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        emp.email,
                        style: AppTextStyles.bodySm,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
                    'Department',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  ),
                  Text(
                    emp.departmentName.isEmpty ? '—' : emp.departmentName,
                    style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Designation',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                  ),
                  Text(
                    emp.position.isEmpty ? '—' : emp.position,
                    style: AppTextStyles.bodySm.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
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

  Widget _buildMemberRow(ProjectEmployee emp, int index) {
    final color = _avatarColor(index);
    final initials = emp.fullName.isNotEmpty
        ? emp.fullName.trim().substring(0, 1).toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              emp.employeeId.isEmpty ? '—' : emp.employeeId,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text(
                    initials,
                    style: AppTextStyles.label.copyWith(
                      color: color,
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
                        emp.fullName.isEmpty ? '—' : emp.fullName,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (emp.email.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          emp.email,
                          style: AppTextStyles.bodySm,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              emp.departmentName.isEmpty ? '—' : emp.departmentName,
              style: AppTextStyles.bodyMd,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              emp.position.isEmpty ? '—' : emp.position,
              style: AppTextStyles.bodyMd,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 140,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: emp.employmentType.isEmpty ? '—' : emp.employmentType,
                tone: _roleTone(emp.position),
                dense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  StatusTone _roleTone(String role) {
    final r = role.toLowerCase();
    if (r.contains('manager') || r.contains('lead')) return StatusTone.primary;
    return StatusTone.neutral;
  }
}
