import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_daily_routine_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/daily_routine_controller.dart';

class DailyRoutineTab extends StatelessWidget {
  final int roleId;

  const DailyRoutineTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    final tag = 'role_detail_$roleId';
    if (!Get.isRegistered<DailyRoutineController>(tag: tag)) {
      Get.put(DailyRoutineController(), tag: tag)
        ..scopedRoleId = roleId
        ..fetchData(roleId: roleId);
    }

    return GetBuilder<DailyRoutineController>(
      tag: tag,
      builder: (ctrl) => Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.errorMessage.value.isNotEmpty) {
          return _ErrorState(
            message: ctrl.errorMessage.value,
            onRetry: () => ctrl.fetchData(roleId: roleId),
          );
        }

        if (ctrl.items.isEmpty) {
          return _EmptyState(
            onAdd: () => _showEditor(context, ctrl),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          itemCount: ctrl.items.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == ctrl.items.length) {
              return Align(
                alignment: Alignment.center,
                child: PermissionGate(
                  require: Perms.rolesUpdate,
                  child: TextButton.icon(
                    onPressed: () => _showEditor(context, ctrl),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add routine item'),
                  ),
                ),
              );
            }

            final item = ctrl.items[index];
            return _RoutineCard(
              item: item,
              onEdit: () => _showEditor(context, ctrl, item: item),
              onDelete: () => _confirmDelete(context, ctrl, item),
            );
          },
        );
      }),
    );
  }

  Future<void> _showEditor(
    BuildContext context,
    DailyRoutineController ctrl, {
    RoleDailyRoutineItem? item,
  }) async {
    final title = TextEditingController(text: item?.title ?? '');
    final description = TextEditingController(text: item?.description ?? '');
    final time = TextEditingController(text: item?.timeOfDay ?? '');
    final minutes =
        TextEditingController(text: item?.estimatedMinutes?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(item == null ? 'Add routine item' : 'Edit routine item'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Title is required'
                        : null,
                  ),
                  TextFormField(
                    controller: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  TextFormField(
                    controller: time,
                    decoration: const InputDecoration(
                        labelText: 'Time of day (HH:MM:SS)'),
                  ),
                  TextFormField(
                    controller: minutes,
                    decoration:
                        const InputDecoration(labelText: 'Estimated minutes'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          MyOutlinedButton(
            height: 40,
            child: 'Cancel',
            onTap: () => Navigator.pop(dialogContext, false),
          ),
          MyElevatedButton(
            height: 40,
            child: 'Save',
            onTap: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final parsedMinutes = int.tryParse(minutes.text.trim());
              final result = item == null
                  ? await ctrl.createRoutine(
                      context,
                      roleId: roleId,
                      title: title.text.trim(),
                      description: description.text.trim(),
                      timeOfDay:
                          time.text.trim().isEmpty ? null : time.text.trim(),
                      estimatedMinutes: parsedMinutes,
                    )
                  : await ctrl.updateRoutine(
                      context,
                      id: item.id,
                      title: title.text.trim(),
                      description: description.text.trim(),
                      timeOfDay: time.text.trim(),
                      estimatedMinutes: parsedMinutes,
                    );
              if (result && dialogContext.mounted) {
                Navigator.pop(dialogContext, true);
              }
            },
          ),
        ],
      ),
    );

    title.dispose();
    description.dispose();
    time.dispose();
    minutes.dispose();
    if (saved == true) ctrl.update();
  }

  Future<void> _confirmDelete(BuildContext context, DailyRoutineController ctrl,
      RoleDailyRoutineItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete routine item'),
        content: Text('Remove "${item.title}" from this role routine?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ctrl.deleteRoutine(context, item.id);
    }
  }
}

class _RoutineCard extends StatelessWidget {
  final RoleDailyRoutineItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoutineCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${item.sequence}',
                style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w600)),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(item.description,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textSecondary)),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (item.timeOfDay != null && item.timeOfDay!.isNotEmpty)
                      _MetaChip(Iconsax.clock, item.timeOfDay!),
                    if (item.estimatedMinutes != null)
                      _MetaChip(Iconsax.timer, '${item.estimatedMinutes} min'),
                    _MetaChip(
                        item.isActive
                            ? Iconsax.tick_circle
                            : Iconsax.close_circle,
                        item.isActive ? 'Active' : 'Inactive'),
                  ],
                ),
              ],
            ),
          ),
          PermissionGate(
            require: Perms.rolesUpdate,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
        ],
      );
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.clock, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text('No daily routine items for this role.',
                  style: AppTextStyles.bodyMd
                      .copyWith(color: AppColors.textMuted)),
              const SizedBox(height: 16),
              PermissionGate(
                require: Perms.rolesUpdate,
                child: MyElevatedButton(
                  height: 40,
                  child: 'Add routine item',
                  icon: const Icon(Iconsax.add,
                      size: 16, color: AppColors.textOnPrimary),
                  onTap: onAdd,
                ),
              ),
            ],
          ),
        ),
      );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.warning_2, size: 48, color: AppColors.danger),
              const SizedBox(height: 12),
              const Text('Error loading daily routine'),
              const SizedBox(height: 6),
              Text(message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              MyOutlinedButton(height: 40, child: 'Retry', onTap: onRetry),
            ],
          ),
        ),
      );
}
