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
  
  // Set of role IDs that are currently expanded
  final Set<int> _expandedRoleIds = {};

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

          // Build tree structure. Root nodes are roles that do not report to anything
          final rootRoles = _ctrl.roles.where((r) => r.reportsToRoleId == null).toList();

          return AppCard(
            padding: const EdgeInsets.all(24),
            elevation: AppCardElevation.md,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Iconsax.hierarchy, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Role Hierarchy Trees',
                      style: AppTextStyles.h4.copyWith(color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Visual representation of the command chain. Expand entries to see direct reports.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                if (rootRoles.isEmpty && _ctrl.roles.isNotEmpty)
                  // Fallback if all roles have circular or non-null reportsToIds (display all roles as roots to prevent empty page)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _ctrl.roles.length,
                    itemBuilder: (context, index) {
                      return _buildRoleNode(_ctrl.roles[index], 0);
                    },
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rootRoles.length,
                    itemBuilder: (context, index) {
                      return _buildRoleNode(rootRoles[index], 0);
                    },
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRoleNode(Role role, int depth) {
    final children = _ctrl.roles.where((r) => r.reportsToRoleId == role.id).toList();
    final hasChildren = children.isNotEmpty;
    final isExpanded = _expandedRoleIds.contains(role.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 24.0, top: 8.0, bottom: 8.0),
          child: Row(
            children: [
              if (hasChildren)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    setState(() {
                      if (isExpanded) {
                        _expandedRoleIds.remove(role.id);
                      } else {
                        _expandedRoleIds.add(role.id);
                      }
                    });
                  },
                  icon: Icon(
                    isExpanded ? Iconsax.arrow_down_1 : Iconsax.arrow_right_3,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(width: 16),
                ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: depth == 0
                        ? AppColors.primarySubtle.withValues(alpha: 0.2)
                        : AppColors.surfaceMuted,
                    borderRadius: AppRadii.brMd,
                    border: Border.all(
                      color: depth == 0
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : AppColors.borderSubtle,
                      width: depth == 0 ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              role.name,
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (role.departmentName != null || role.unitName != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  [role.departmentName, role.unitName].whereType<String>().join(' • '),
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (hasChildren)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.borderSubtle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${children.length} report(s)',
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
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
        if (hasChildren && isExpanded)
          ...children.map((child) => _buildRoleNode(child, depth + 1)),
      ],
    );
  }
}
