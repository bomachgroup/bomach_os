import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/company/controllers/roles_controller.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class OrgChartPage extends StatefulWidget {
  const OrgChartPage({super.key});

  @override
  State<OrgChartPage> createState() => _OrgChartPageState();
}

class _OrgChartPageState extends State<OrgChartPage> {
  final RolesController _ctrl = Get.put(RolesController());
  final Set<int> _expandedRoleIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_ctrl.roles.isNotEmpty) {
        setState(() {
          for (final r in _ctrl.roles) {
            _expandedRoleIds.add(r.id);
          }
        });
      }
    });
  }

  void _toggle(int roleId) {
    setState(() {
      if (_expandedRoleIds.contains(roleId)) {
        _expandedRoleIds.remove(roleId);
      } else {
        _expandedRoleIds.add(roleId);
      }
    });
  }

  void _expandAll() {
    setState(() {
      for (final r in _ctrl.roles) {
        _expandedRoleIds.add(r.id);
      }
    });
  }

  void _collapseAll() {
    setState(() => _expandedRoleIds.clear());
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1200,
      header: const PageHeader(
        title: 'Organizational Chart',
        subtitle: 'Reporting hierarchy structure across role templates',
      ),
      children: [
        Obx(() {
          if (_ctrl.isLoading.value && _ctrl.roles.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (_ctrl.roles.isEmpty) {
            return const AppCard(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No roles defined to display in hierarchy.'),
              ),
            );
          }

          final rootRoles =
              _ctrl.roles.where((r) => r.reportsToRoleId == null).toList();
          final allExpanded =
              rootRoles.every((r) => _expandedRoleIds.contains(r.id));

          return AppCard(
            padding: const EdgeInsets.all(24),
            elevation: AppCardElevation.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.hierarchy,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Role Hierarchy Trees',
                      style: AppTextStyles.h4
                          .copyWith(color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: allExpanded ? _collapseAll : _expandAll,
                      icon: Icon(
                        allExpanded ? Iconsax.minus_cirlce : Iconsax.add_circle,
                        size: 16,
                      ),
                      label: Text(
                        allExpanded ? 'Collapse All' : 'Expand All',
                        style: AppTextStyles.bodySm,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Visual representation of the command chain. Click arrows to expand or collapse.',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                if (rootRoles.isEmpty && _ctrl.roles.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ctrl.roles.length,
                    itemBuilder: (context, index) => _RoleTreeNode(
                      role: _ctrl.roles[index],
                      depth: 0,
                      expandedIds: _expandedRoleIds,
                      onToggle: _toggle,
                      allRoles: _ctrl.roles,
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rootRoles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => _RoleTreeNode(
                      role: rootRoles[index],
                      depth: 0,
                      expandedIds: _expandedRoleIds,
                      onToggle: _toggle,
                      allRoles: _ctrl.roles,
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _RoleTreeNode extends StatelessWidget {
  final Role role;
  final int depth;
  final Set<int> expandedIds;
  final ValueChanged<int> onToggle;
  final List<Role> allRoles;

  const _RoleTreeNode({
    required this.role,
    required this.depth,
    required this.expandedIds,
    required this.onToggle,
    required this.allRoles,
  });

  static const _depthColors = [
    AppColors.primary,
    Color(0xFF7C3AED),
    Color(0xFF0891B2),
    Color(0xFF059669),
    Color(0xFFD97706),
  ];

  static const _depthBg = [
    Color(0xFFF0F4FF),
    Color(0xFFF5F0FF),
    Color(0xFFF0FAFF),
    Color(0xFFF0FFF4),
    Color(0xFFFFFBF0),
  ];

  @override
  Widget build(BuildContext context) {
    final children = allRoles.where((r) => r.reportsToRoleId == role.id).toList();
    final hasChildren = children.isNotEmpty;
    final isExpanded = expandedIds.contains(role.id);

    final color = _depthColors[depth % _depthColors.length];
    final bgColor = _depthBg[depth % _depthBg.length];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: depth == 0 ? bgColor : AppColors.surfaceMuted,
            borderRadius: AppRadii.brMd,
            border: Border.all(
              color: depth == 0
                  ? color.withValues(alpha: 0.3)
                  : AppColors.borderSubtle,
              width: depth == 0 ? 1.5 : 1,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        if (hasChildren)
                          GestureDetector(
                            onTap: () => onToggle(role.id),
                            child: AnimatedRotation(
                              turns: isExpanded ? 0.25 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Iconsax.arrow_right_3,
                                size: 16,
                                color: color,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 24),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            depth == 0 ? Iconsax.crown : Iconsax.user,
                            size: 18,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                role.name,
                                style: AppTextStyles.bodyMd.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (role.departmentName != null ||
                                  role.unitName != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    [
                                      role.departmentName,
                                      role.unitName
                                    ].whereType<String>().join(' • '),
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (hasChildren)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: color.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              '${children.length} report${children.length == 1 ? '' : 's'}',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (hasChildren && isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vertical connector line
                Container(
                  width: 1,
                  margin: const EdgeInsets.only(top: 0),
                  child: CustomPaint(
                    painter: _ConnectorPainter(
                      color: color.withValues(alpha: 0.25),
                    ),
                    child: SizedBox(
                      height: (children.length * 80.0) + 20,
                    ),
                  ),
                ),
                const SizedBox(width: 19),
                Expanded(
                  child: Column(
                    children: [
                      for (int i = 0; i < children.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Horizontal connector
                              Container(
                                width: 20,
                                height: 1,
                                margin: const EdgeInsets.only(top: 28),
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: color.withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _RoleTreeNode(
                                  role: children[i],
                                  depth: depth + 1,
                                  expandedIds: expandedIds,
                                  onToggle: onToggle,
                                  allRoles: allRoles,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  final Color color;

  _ConnectorPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw vertical line
    canvas.drawLine(
      const Offset(0, 0),
      Offset(0, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
