import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_target_template_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/targets_controller.dart';
import '../target_template_dialog.dart';

class TargetsTab extends StatelessWidget {
  final int roleId;

  const TargetsTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    final tag = 'role_detail_$roleId';
    if (!Get.isRegistered<TargetsController>(tag: tag)) {
      Get.put(TargetsController(), tag: tag)
        ..scopedRoleId = roleId
        ..fetchTargets(roleId: roleId);
    }

    return GetBuilder<TargetsController>(
      tag: tag,
      builder: (ctrl) => Obx(() {
        if (ctrl.isLoading.value && ctrl.targets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.errorMessage.value.isNotEmpty && ctrl.targets.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                EmptyState(
                  icon: Iconsax.warning_2,
                  title: 'Targets could not be loaded',
                  subtitle: ctrl.errorMessage.value,
                  compact: true,
                ),
                TextButton.icon(
                  onPressed: () => ctrl.fetchTargets(roleId: roleId),
                  icon: const Icon(Iconsax.refresh, size: 16),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (ctrl.targets.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: AppCard(
              padding: const EdgeInsets.all(20),
              child: EmptyState(
                icon: Iconsax.flag,
                title: 'No target templates for this role',
                subtitle:
                    'Role targets are shared defaults. Employee-specific plans can be adjusted separately.',
                compact: true,
                action: MyElevatedButton(
                  height: 40,
                  child: 'Add target',
                  icon: const Icon(Iconsax.add,
                      size: 16, color: AppColors.textOnPrimary),
                  onTap: () => _showDialog(context, ctrl),
                ),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Shared role targets',
                            style: AppTextStyles.bodyMd
                                .copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text(
                          'Defaults for employees in this role',
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (ctrl.isLoading.value)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showDialog(context, ctrl),
                    icon: const Icon(Iconsax.add, size: 16),
                    label: const Text('Add target'),
                  ),
                ],
              ),
            ),
            if (ctrl.errorMessage.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: _InlineLoadError(
                  message: ctrl.errorMessage.value,
                  onRetry: () => ctrl.fetchTargets(roleId: roleId),
                ),
              ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              itemCount: ctrl.targets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final target = ctrl.targets[index];
                return _TargetTemplateCard(
                  target: target,
                  onEdit: () => _showDialog(context, ctrl, template: target),
                  onRemove: () => _confirmDelete(context, ctrl, target.id),
                );
              },
            ),
          ],
        );
      }),
    );
  }

  void _showDialog(BuildContext context, TargetsController ctrl,
      {dynamic template}) {
    showDialog(
      context: context,
      builder: (_) => CreateEditTargetTemplateDialog(
        ctrl: ctrl,
        roleId: roleId,
        template: template,
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, TargetsController ctrl, int templateId) async {
    final result = await showDialog<TargetActionResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RemoveTargetDialog(
        controller: ctrl,
        roleId: roleId,
        templateId: templateId,
      ),
    );
    if (result?.succeeded == true && context.mounted) {
      AppToast.success(context, result!.message);
    }
  }
}

class _TargetTemplateCard extends StatelessWidget {
  final RoleTargetTemplate target;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _TargetTemplateCard({
    required this.target,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.all(16),
        elevation: AppCardElevation.none,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: AppRadii.brSm,
              ),
              child:
                  const Icon(Iconsax.flag, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(target.title,
                          style: AppTextStyles.bodyMd
                              .copyWith(fontWeight: FontWeight.w600)),
                      _TemplateStatus(isActive: target.isActive),
                    ],
                  ),
                  if (target.description.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      target.description,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 24,
                    runSpacing: 12,
                    children: [
                      _TemplateMeta(
                          label: 'Target', value: target.targetDisplay),
                      _TemplateMeta(
                          label: 'Review period',
                          value: _periodLabel(target.period)),
                      _TemplateMeta(
                          label: 'Display order', value: '${target.sequence}'),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Target actions',
              icon: const Icon(Iconsax.more,
                  size: 18, color: AppColors.textSecondary),
              onSelected: (value) => value == 'edit' ? onEdit() : onRemove(),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit target')),
                PopupMenuItem(
                  value: 'remove',
                  child: Text('Remove template'),
                ),
              ],
            ),
          ],
        ),
      );
}

class _RemoveTargetDialog extends StatefulWidget {
  final TargetsController controller;
  final int roleId;
  final int templateId;

  const _RemoveTargetDialog({
    required this.controller,
    required this.roleId,
    required this.templateId,
  });

  @override
  State<_RemoveTargetDialog> createState() => _RemoveTargetDialogState();
}

class _RemoveTargetDialogState extends State<_RemoveTargetDialog> {
  bool _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: !_saving,
        child: DialogScaffold(
          title: 'Remove target template?',
          subtitle: 'This changes shared defaults for this role.',
          size: DialogSize.sm,
          showCloseButton: false,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Existing employee plans and submitted progress are not deleted.',
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                _InlineLoadError(message: _error!),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: _saving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _saving ? null : _remove,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Remove template'),
            ),
          ],
        ),
      );

  Future<void> _remove() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final result =
        await widget.controller.deleteTarget(widget.roleId, widget.templateId);
    if (!mounted) return;
    if (result.succeeded) {
      Navigator.pop(context, result);
    } else {
      setState(() {
        _saving = false;
        _error = result.message;
      });
    }
  }
}

class _TemplateMeta extends StatelessWidget {
  final String label;
  final String value;

  const _TemplateMeta({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 3),
          Text(value, style: AppTextStyles.bodySm),
        ],
      );
}

class _TemplateStatus extends StatelessWidget {
  final bool isActive;

  const _TemplateStatus({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successSubtle : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(isActive ? 'Active' : 'Inactive',
          style: AppTextStyles.caption.copyWith(color: color)),
    );
  }
}

class _InlineLoadError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _InlineLoadError({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.dangerSubtle,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Iconsax.warning_2, size: 17, color: AppColors.danger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.danger)),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      );
}

String _periodLabel(String value) {
  if (value == 'annual' || value == 'yearly') return 'Annual';
  return value
      .split('_')
      .map((part) =>
          part.isEmpty ? part : '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
