import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_resource_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/role_resource_controller.dart';
import '../resource_dialog.dart';

class ResourcesTab extends StatelessWidget {
  final int roleId;

  const ResourcesTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleResourceController>(
      tag: 'role_detail_$roleId',
      init: RoleResourceController()
        ..scopedRoleId = roleId
        ..fetchAll(roleId: roleId),
      builder: (ctrl) {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _section('Physical Resources', Iconsax.box, AppColors.primary, ctrl.physicalResources.length,
                ctrl.physicalResources.map((r) => _physicalTile(r)).toList(), () => _add(ctrl, context)),
            const SizedBox(height: 24),
            _section('Software Tools', Iconsax.monitor, AppColors.info, ctrl.softwareTools.length,
                ctrl.softwareTools.map((r) => _softwareTile(r)).toList(), () => _add(ctrl, context)),
            const SizedBox(height: 24),
            _section('Reference Documents', Iconsax.document, AppColors.warning, ctrl.referenceDocuments.length,
                ctrl.referenceDocuments.map((r) => _docTile(r)).toList(), () => _add(ctrl, context)),
            const SizedBox(height: 24),
            _section('Technical Skills', Iconsax.code, AppColors.success, ctrl.technicalSkills.length,
                ctrl.technicalSkills.map((r) => _techSkillTile(r)).toList(), () => _add(ctrl, context)),
            const SizedBox(height: 24),
            _section('Soft Skills', Iconsax.people, AppColors.danger, ctrl.softSkills.length,
                ctrl.softSkills.map((r) => _softSkillTile(r)).toList(), () => _add(ctrl, context)),
            const SizedBox(height: 24),
            _section('Experience Requirements', Iconsax.briefcase, AppColors.textSecondary, ctrl.experienceRequirements.length,
                ctrl.experienceRequirements.map((r) => _expTile(r)).toList(), () => _add(ctrl, context)),
            const SizedBox(height: 24),
            _section('Certifications', Iconsax.tick_circle, AppColors.primary, ctrl.certifications.length,
                ctrl.certifications.map((r) => _certTile(r)).toList(), () => _add(ctrl, context)),
          ],
        );
      },
    );
  }

  void _add(RoleResourceController ctrl, BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CreateResourceDialog(ctrl: ctrl, presetRoleId: roleId),
    );
  }

  Widget _section(String title, IconData icon, Color color, int count, List<Widget> items, VoidCallback onAdd) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(title,
                style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$count',
                  style: AppTextStyles.bodySm.copyWith(color: color, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text('No items.',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textMuted)),
                ),
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
              ],
            ),
          )
        else
          ...items,
      ],
    );
  }

  Widget _itemTile(Widget leading, Widget title, Widget? trailing, List<Widget>? chips) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [leading, const SizedBox(width: 12), Expanded(child: title),       trailing ?? const SizedBox.shrink()]),
          if (chips != null && chips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 4, children: chips),
          ],
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: AppTextStyles.bodySm.copyWith(color: color, fontSize: 11)),
    );
  }

  Widget _physicalTile(PhysicalResource r) {
    return _itemTile(
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Iconsax.box, color: AppColors.primary, size: 18),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.name, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
          if (r.description != null && r.description!.isNotEmpty)
            Text(r.description!, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
        ],
      ),
      Text('x${r.quantity}', style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
      r.isAssigned ? [_chip('Assigned', AppColors.success)] : null,
    );
  }

  Widget _softwareTile(SoftwareTool r) {
    return _itemTile(
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Iconsax.monitor, color: AppColors.info, size: 18),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.name, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
      null,
      [
        if (r.vendor != null && r.vendor!.isNotEmpty) _chip(r.vendor!, AppColors.info),
        if (r.licenseType != null && r.licenseType!.isNotEmpty) _chip(r.licenseType!, AppColors.textSecondary),
      ],
    );
  }

  Widget _docTile(ReferenceDocument r) {
    return _itemTile(
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Iconsax.document, color: AppColors.warning, size: 18),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.title, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
      null,
      [
        if (r.documentType != null && r.documentType!.isNotEmpty) _chip(r.documentType!, AppColors.warning),
        if (r.filePath != null && r.filePath!.isNotEmpty) _chip(r.filePath!, AppColors.textSecondary),
      ],
    );
  }

  Widget _techSkillTile(TechnicalSkill r) {
    return _itemTile(
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Iconsax.code, color: AppColors.success, size: 18),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.name, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
      null,
      [
        if (r.category != null && r.category!.isNotEmpty) _chip(r.category!, AppColors.success),
        if (r.proficiencyLevel != null && r.proficiencyLevel!.isNotEmpty) _chip(r.proficiencyLevel!, AppColors.info),
      ],
    );
  }

  Widget _softSkillTile(SoftSkill r) {
    return _itemTile(
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Iconsax.people, color: AppColors.danger, size: 18),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.name, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
          if (r.description != null && r.description!.isNotEmpty)
            Text(r.description!, style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
        ],
      ),
      null,
      null,
    );
  }

  Widget _expTile(ExperienceRequirement r) {
    return _itemTile(
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Iconsax.briefcase, color: AppColors.textSecondary, size: 18),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.description, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
      Text('${r.minYears}+ yrs', style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary)),
      [
        if (r.experienceType != null && r.experienceType!.isNotEmpty) _chip(r.experienceType!, AppColors.textSecondary),
      ],
    );
  }

  Widget _certTile(Certification r) {
    return _itemTile(
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Iconsax.tick_circle, color: AppColors.primary, size: 18),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.name, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
      null,
      [
        if (r.issuingBody != null && r.issuingBody!.isNotEmpty) _chip(r.issuingBody!, AppColors.primary),
        if (r.isMandatory) _chip('Mandatory', AppColors.danger),
      ],
    );
  }
}
