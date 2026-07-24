import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/succession_plan_controller.dart';
import '../succession_plan_dialog.dart';

class SuccessionPlanTab extends StatelessWidget {
  final int roleId;
  const SuccessionPlanTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    final tag = 'succ_$roleId';
    if (!Get.isRegistered<SuccessionPlanController>(tag: tag)) {
      Get.put(SuccessionPlanController(), tag: tag);
      Get.find<SuccessionPlanController>(tag: tag).fetchPlans(roleId);
    }

    return GetBuilder<SuccessionPlanController>(
      tag: tag,
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator());
        final plans = ctrl.plans;

        if (plans.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Iconsax.user_octagon, size: 48, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text('No succession plans defined.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 16),
                MyElevatedButton(height: 40, child: 'Add Succession Plan',
                  icon: const Icon(Iconsax.add, size: 16, color: AppColors.textOnPrimary),
                  onTap: () => showDialog(context: context, builder: (_) => CreateEditSuccessionPlanDialog(ctrl: ctrl, roleId: roleId))),
              ]),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: plans.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == plans.length) {
              return Center(
                child: TextButton.icon(
                  onPressed: () => showDialog(context: context, builder: (_) => CreateEditSuccessionPlanDialog(ctrl: ctrl, roleId: roleId)),
                  icon: const Icon(Icons.add, size: 16), label: const Text('Add Succession Plan')),
              );
            }
            final p = plans[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: _readinessColor(p.readiness).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Iconsax.user_octagon, color: _readinessColor(p.readiness), size: 20)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(p.primarySuccessorName ?? 'No primary successor', style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600))),
                    PopupMenuButton<String>(
                      icon: const Icon(Iconsax.more, size: 18, color: AppColors.textSecondary),
                      onSelected: (v) {
                        if (v == 'edit') showDialog(context: context, builder: (_) => CreateEditSuccessionPlanDialog(ctrl: ctrl, roleId: roleId, plan: p));
                        else if (v == 'delete') _confirmDelete(context, ctrl, p);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _readinessChip(p.readiness),
                  if (p.backupSuccessorName != null && p.backupSuccessorName!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Iconsax.user, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text('Backup: ${p.backupSuccessorName}', style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                    ]),
                  ],
                  if (p.developmentPlan != null && p.developmentPlan!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(p.developmentPlan!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ],
                ])),
              ]),
            );
          },
        );
      });
    },
  );
}

  Color _readinessColor(String r) {
    switch (r) { case 'ready_now': return AppColors.success; case 'ready_1yr': return AppColors.warning; default: return AppColors.textMuted; }
  }

  Widget _readinessChip(String r) {
    final color = _readinessColor(r);
    final labels = {'ready_now': 'Ready Now', 'ready_1yr': 'Ready in 1yr', 'pipeline': 'Pipeline'};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(labels[r] ?? r, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
    );
  }

  void _confirmDelete(BuildContext context, SuccessionPlanController ctrl, dynamic p) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Plan'), content: Text('Remove succession plan for "${p.primarySuccessorName ?? 'this role'}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () { Navigator.pop(ctx); ctrl.deletePlan(p.id); }, child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
      ],
    ));
  }
}
