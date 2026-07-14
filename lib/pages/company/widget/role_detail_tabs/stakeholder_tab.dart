import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/stakeholder_controller.dart';
import '../stakeholder_dialog.dart';

class StakeholderTab extends StatelessWidget {
  final int roleId;
  const StakeholderTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StakeholderController>(
      tag: 'stake_$roleId',
      init: StakeholderController()..fetchStakeholders(roleId),
      builder: (ctrl) {
        if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator());
        final items = ctrl.stakeholders;

        if (items.isEmpty) {
          return Center(
            child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Iconsax.people, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text('No stakeholders defined.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 16),
              MyElevatedButton(height: 40, child: 'Add Stakeholder',
                icon: const Icon(Iconsax.add, size: 16, color: AppColors.textOnPrimary),
                onTap: () => showDialog(context: context, builder: (_) => CreateEditStakeholderDialog(ctrl: ctrl, roleId: roleId))),
            ])),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: items.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == items.length) {
              return Center(
                child: TextButton.icon(onPressed: () => showDialog(context: context, builder: (_) => CreateEditStakeholderDialog(ctrl: ctrl, roleId: roleId)),
                  icon: const Icon(Icons.add, size: 16), label: const Text('Add Stakeholder')),
              );
            }
            final s = items[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
                  color: (s.type == 'internal' ? AppColors.info : AppColors.success).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(s.type == 'internal' ? Iconsax.profile_2user : Iconsax.building, size: 20,
                    color: s.type == 'internal' ? AppColors.info : AppColors.success)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(s.name, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600))),
                    PopupMenuButton<String>(
                      icon: const Icon(Iconsax.more, size: 18, color: AppColors.textSecondary),
                      onSelected: (v) {
                        if (v == 'edit') showDialog(context: context, builder: (_) => CreateEditStakeholderDialog(ctrl: ctrl, roleId: roleId, stakeholder: s));
                        else if (v == 'delete') _confirmDelete(context, ctrl, s);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Wrap(spacing: 6, runSpacing: 4, children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(
                      color: (s.type == 'internal' ? AppColors.info : AppColors.success).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(s.type == 'internal' ? 'Internal' : 'External', style: TextStyle(fontSize: 11,
                        color: s.type == 'internal' ? AppColors.info : AppColors.success, fontWeight: FontWeight.w600))),
                    if (s.organization != null && s.organization!.isNotEmpty)
                      Text(s.organization!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  ]),
                  if (s.communicationProtocol != null && s.communicationProtocol!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      const Icon(Iconsax.message, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Flexible(child: Text(s.communicationProtocol!, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted))),
                    ]),
                  ],
                ])),
              ]),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, StakeholderController ctrl, dynamic s) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Stakeholder'), content: Text('Remove "${s.name}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () { Navigator.pop(ctx); ctrl.deleteStakeholder(s.id); }, child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
      ],
    ));
  }
}
