import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/decision_matrix_controller.dart';
import '../decision_matrix_dialog.dart';

class DecisionMatrixTab extends StatelessWidget {
  final int roleId;

  const DecisionMatrixTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    final tag = 'decision_matrix_$roleId';
    if (!Get.isRegistered<DecisionMatrixController>(tag: tag)) {
      Get.put(DecisionMatrixController(), tag: tag);
      Get.find<DecisionMatrixController>(tag: tag).fetchEntries(roleId);
    }

    return GetBuilder<DecisionMatrixController>(
      tag: tag,
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = ctrl.entries;

          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.category,
                        size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('No decision matrix entries defined.',
                        style: AppTextStyles.bodyMd
                            .copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 16),
                    MyElevatedButton(
                      height: 40,
                      child: 'Add Decision Entry',
                      icon: const Icon(Iconsax.add,
                          size: 16, color: AppColors.textOnPrimary),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => CreateEditDecisionMatrixEntryDialog(
                          ctrl: ctrl,
                          roleId: roleId,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Table header
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                child: const Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text('Decision', style: AppTextStyles.label)),
                    Expanded(
                        flex: 2,
                        child: Text('Authority', style: AppTextStyles.label)),
                    Expanded(
                        flex: 2,
                        child: Text('Approval', style: AppTextStyles.label)),
                    Expanded(
                        flex: 2,
                        child: Text('Escalation', style: AppTextStyles.label)),
                    SizedBox(width: 40),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: entries.length + 1,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.borderSubtle),
                  itemBuilder: (context, index) {
                    if (index == entries.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: TextButton.icon(
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => CreateEditDecisionMatrixEntryDialog(
                                ctrl: ctrl,
                                roleId: roleId,
                              ),
                            ),
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('Add Decision Entry'),
                          ),
                        ),
                      );
                    }

                    final e = entries[index];
                    return _buildEntryRow(context, ctrl, e);
                  },
                ),
              ),
            ],
          );
        });
      },
    );
  }

  Widget _buildEntryRow(
      BuildContext context, DecisionMatrixController ctrl, dynamic e) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.decisionType,
                    style: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w600)),
                if (e.description != null && e.description!.isNotEmpty)
                  Text(e.description!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: e.canDecideAlone
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Sole Authority',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600)),
                  )
                : Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Needs Approval',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600)),
                  ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              e.requiresApprovalFrom?.isNotEmpty == true
                  ? e.requiresApprovalFrom!
                  : '—',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              e.escalationPath?.isNotEmpty == true ? e.escalationPath! : '—',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 40,
            child: PopupMenuButton<String>(
              icon: const Icon(Iconsax.more,
                  size: 18, color: AppColors.textSecondary),
              onSelected: (value) {
                if (value == 'edit') {
                  showDialog(
                    context: context,
                    builder: (_) => CreateEditDecisionMatrixEntryDialog(
                      ctrl: ctrl,
                      roleId: roleId,
                      entry: e,
                    ),
                  );
                } else if (value == 'delete') {
                  _confirmDelete(context, ctrl, e);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete',
                        style: TextStyle(color: AppColors.danger))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, DecisionMatrixController ctrl, dynamic entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Remove "${entry.decisionType}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.deleteEntry(entry.id);
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
