import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/role_knowledge_base_controller.dart';
import 'widget/knowledge_base_dialog.dart';

class CompanyKnowledgeBasePage extends StatelessWidget {
  const CompanyKnowledgeBasePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(RoleKnowledgeBaseController());
    ctrl.fetchEntries();

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Knowledge Base',
        subtitle: 'Cross-role documents, templates, and references',
        trailing: MyElevatedButton(
          height: 44, child: 'Add Entry',
          icon: const Icon(Iconsax.add, size: 16, color: AppColors.textOnPrimary),
          onTap: () => showDialog(context: context, builder: (_) => CreateEditKnowledgeEntryDialog(ctrl: ctrl)),
        ),
      ),
      children: [
        Obx(() {
          if (ctrl.isLoading.value) {
            return LoadingSkeleton.listRows(count: 5);
          }

          return Column(children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MyTextFormField(
                hintText: 'Search knowledge base...',
                height: 48,
                leading: const Icon(Iconsax.search_normal, size: 18, color: AppColors.textMuted),
                onChanged: ctrl.onSearchChanged,
              ),
            ),
            if (ctrl.entries.isEmpty)
              const EmptyState(icon: Iconsax.document, title: 'No entries found',
                subtitle: 'Add documents, links, and references to the knowledge base.')
            else
              ...ctrl.entries.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Iconsax.document_text, color: AppColors.primary, size: 20)),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.title, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Wrap(spacing: 6, runSpacing: 4, children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                        child: Text(e.category, style: const TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w600))),
                      if (e.tags != null && e.tags!.isNotEmpty)
                        Text(e.tags!, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                    ]),
                    if (e.description != null && e.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(e.description!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ])),
                  if (e.url != null && e.url!.isNotEmpty)
                    IconButton(icon: const Icon(Iconsax.link, size: 18, color: AppColors.primary), tooltip: 'Open link',
                      onPressed: () {/* Open URL */}),
                  PopupMenuButton<String>(
                    icon: const Icon(Iconsax.more, size: 18, color: AppColors.textSecondary),
                    onSelected: (v) {
                      if (v == 'edit') showDialog(context: context, builder: (_) => CreateEditKnowledgeEntryDialog(ctrl: ctrl, entry: e));
                      else if (v == 'delete') _confirmDelete(context, ctrl, e);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
                    ],
                  ),
                ]),
              )),
          ]);
        }),
      ],
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
