import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/role_knowledge_base_controller.dart';
import '../knowledge_base_dialog.dart';

class KnowledgeBaseTab extends StatelessWidget {
  final int roleId;
  const KnowledgeBaseTab({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RoleKnowledgeBaseController>(
      tag: 'kb_$roleId',
      init: RoleKnowledgeBaseController()..fetchEntries(roleId: roleId),
      builder: (ctrl) {
        return Obx(() {
          if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator());
        final entries = ctrl.entries;

        return Column(children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
            child: MyTextFormField(
              hintText: 'Search knowledge base...',
              height: 44,
              leading: const Icon(Iconsax.search_normal, size: 18, color: AppColors.textMuted),
              onChanged: ctrl.onSearchChanged,
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(40), child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Iconsax.document, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 16),
                    Text('No knowledge entries.', style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: 16),
                    MyElevatedButton(height: 40, child: 'Add Entry',
                      icon: const Icon(Iconsax.add, size: 16, color: AppColors.textOnPrimary),
                      onTap: () => showDialog(context: context, builder: (_) => CreateEditKnowledgeEntryDialog(ctrl: ctrl, roleId: roleId))),
                  ])))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    itemCount: entries.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      if (index == entries.length) {
                        return Center(
                          child: TextButton.icon(onPressed: () => showDialog(context: context, builder: (_) => CreateEditKnowledgeEntryDialog(ctrl: ctrl, roleId: roleId)),
                            icon: const Icon(Icons.add, size: 16), label: const Text('Add Entry')),
                        );
                      }
                      final e = entries[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Iconsax.document_text, color: AppColors.primary, size: 20)),
                          const SizedBox(width: 16),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Expanded(child: Text(e.title, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600))),
                              PopupMenuButton<String>(
                                icon: const Icon(Iconsax.more, size: 18, color: AppColors.textSecondary),
                                onSelected: (v) {
                                  if (v == 'edit') showDialog(context: context, builder: (_) => CreateEditKnowledgeEntryDialog(ctrl: ctrl, roleId: roleId, entry: e));
                                  else if (v == 'delete') _confirmDelete(context, ctrl, e);
                                },
                                itemBuilder: (_) => [
                                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
                                ],
                              ),
                            ]),
                            const SizedBox(height: 6),
                            Wrap(spacing: 6, runSpacing: 4, children: [
                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text(e.category, style: const TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w600))),
                              if (e.tags != null && e.tags!.isNotEmpty)
                                Text(e.tags!, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                            ]),
                            if (e.description != null && e.description!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(e.description!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                            if (e.url != null && e.url!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Iconsax.link, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Flexible(child: Text(e.url!, style: AppTextStyles.caption.copyWith(color: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ]),
                            ],
                          ])),
                        ]),
                      );
                    },
                  ),
          ),
        ]);
      });
    },
  );
}

  void _confirmDelete(BuildContext context, RoleKnowledgeBaseController ctrl, dynamic e) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Entry'), content: Text('Remove "${e.title}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        TextButton(onPressed: () { Navigator.pop(ctx); ctrl.deleteEntry(e.id); }, child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
      ],
    ));
  }
}
