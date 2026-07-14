import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_knowledge_base_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/role_knowledge_base_controller.dart';

class CreateEditKnowledgeEntryDialog extends StatefulWidget {
  final RoleKnowledgeBaseController ctrl;
  final int? roleId;
  final RoleKnowledgeEntry? entry;

  const CreateEditKnowledgeEntryDialog({super.key, required this.ctrl, this.roleId, this.entry});

  @override
  State<CreateEditKnowledgeEntryDialog> createState() => _CreateEditKnowledgeEntryDialogState();
}

class _CreateEditKnowledgeEntryDialogState extends State<CreateEditKnowledgeEntryDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _urlCtrl;
  late final TextEditingController _fileCtrl;
  late final TextEditingController _tagsCtrl;

  String _category = 'Reference';

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _urlCtrl = TextEditingController(text: e?.url ?? '');
    _fileCtrl = TextEditingController(text: e?.filePath ?? '');
    _tagsCtrl = TextEditingController(text: e?.tags ?? '');
    _category = e?.category ?? 'Reference';
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose(); _urlCtrl.dispose(); _fileCtrl.dispose(); _tagsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.entry != null;
    return DialogScaffold(
      title: isEdit ? 'Edit Knowledge Entry' : 'Add Knowledge Entry',
      subtitle: 'Attach documents, links, or references to this role.',
      size: DialogSize.md,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Title', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _titleCtrl, hintText: 'e.g. Onboarding SOP', height: 48),
          const SizedBox(height: 20),
          const Text('Category', style: AppTextStyles.label), const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(hintText: 'Select category', border: OutlineInputBorder(borderRadius: AppRadii.brMd), contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
            initialValue: _category,
            items: RoleKnowledgeEntry.categoryOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _category = v ?? 'Reference'),
          ),
          const SizedBox(height: 20),
          const Text('Description', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _descCtrl, hintText: 'Brief description', height: 72, maxLines: 3),
          const SizedBox(height: 20),
          const Text('URL / Link', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _urlCtrl, hintText: 'e.g. https://docs.example.com/sop', height: 48),
          const SizedBox(height: 20),
          const Text('File Path', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _fileCtrl, hintText: 'e.g. /shared/docs/sop_v2.pdf', height: 48),
          const SizedBox(height: 20),
          const Text('Tags', style: AppTextStyles.label), const SizedBox(height: 8),
          MyTextFormField(controller: _tagsCtrl, hintText: 'Comma separated: onboarding, hr, policy', height: 48),
        ]),
      ),
      actions: [
        MyOutlinedButton(child: 'Cancel', height: 44, onTap: () => Navigator.pop(context)),
        Obx(() => MyElevatedButton(width: 140, height: 44, onTap: widget.ctrl.isSaving.value ? null : _onSave,
          child: widget.ctrl.isSaving.value ? 'Saving...' : (isEdit ? 'Save Changes' : 'Add Entry'))),
      ],
    );
  }

  void _onSave() async {
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation', 'Title is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final body = <String, dynamic>{'title': _titleCtrl.text.trim(), 'category': _category};
    if (widget.roleId != null) body['role_id'] = widget.roleId;
    if (_descCtrl.text.trim().isNotEmpty) body['description'] = _descCtrl.text.trim();
    if (_urlCtrl.text.trim().isNotEmpty) body['url'] = _urlCtrl.text.trim();
    if (_fileCtrl.text.trim().isNotEmpty) body['file_path'] = _fileCtrl.text.trim();
    if (_tagsCtrl.text.trim().isNotEmpty) body['tags'] = _tagsCtrl.text.trim();

    final success = widget.entry != null ? await widget.ctrl.updateEntry(widget.entry!.id, body) : await widget.ctrl.addEntry(body);
    if (success && mounted) Navigator.pop(context);
  }
}
