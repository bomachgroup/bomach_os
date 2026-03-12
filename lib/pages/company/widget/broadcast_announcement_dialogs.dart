import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/model/broadcast_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/broadcast_controller.dart';

// ─── CREATE / EDIT ANNOUNCEMENT DIALOG ──────────────────────────

class CreateEditAnnouncementDialog extends StatefulWidget {
  final Announcement? announcement; // null = create, non-null = edit
  const CreateEditAnnouncementDialog({super.key, this.announcement});

  @override
  State<CreateEditAnnouncementDialog> createState() =>
      _CreateEditAnnouncementDialogState();
}

class _CreateEditAnnouncementDialogState
    extends State<CreateEditAnnouncementDialog> {
  final _formKey = GlobalKey<FormState>();
  final BroadcastController controller = Get.find<BroadcastController>();

  late final TextEditingController titleCtrl;
  late final TextEditingController contentCtrl;
  late final TextEditingController publishAtCtrl;
  late final TextEditingController expiresAtCtrl;

  String? selectedAnnouncementType;
  String? selectedPriority;
  bool isActive = true;

  // Branch & department IDs — for now we use checkboxes with labels
  // TODO: Load actual branches/departments from API
  Set<int> selectedBranchIds = {};
  Set<int> selectedDepartmentIds = {};

  bool get isEdit => widget.announcement != null;

  @override
  void initState() {
    super.initState();
    final a = widget.announcement;
    titleCtrl = TextEditingController(text: a?.title ?? '');
    contentCtrl = TextEditingController(text: a?.content ?? '');

    // Format dates
    publishAtCtrl = TextEditingController(
        text: _formatDateForDisplay(a?.publishAt ?? ''));
    expiresAtCtrl = TextEditingController(
        text: _formatDateForDisplay(a?.expiresAt ?? ''));

    if (a != null) {
      selectedAnnouncementType = a.announcementType.isNotEmpty
          ? a.announcementType
          : null;
      selectedPriority = a.priority.isNotEmpty ? a.priority : null;
      isActive = a.isActive;
      selectedBranchIds = a.branchIds.toSet();
      selectedDepartmentIds = a.departmentIds.toSet();
    } else {
      selectedAnnouncementType = 'general';
      selectedPriority = 'normal';
      isActive = true;
    }
  }

  String _formatDateForDisplay(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    contentCtrl.dispose();
    publishAtCtrl.dispose();
    expiresAtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Announcement' : 'Create Announcement',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                _fieldLabel('Title'),
                MyTextFormField(
                  controller: titleCtrl,
                  hintText: 'Type here',
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Content
                _fieldLabel('Content'),
                MyTextFormField(
                  controller: contentCtrl,
                  hintText: 'Type here',
                  maxLines: 4,
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Announcement Type & Priority Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Announcement Type'),
                          _buildAnnouncementTypeDropdown(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Priority'),
                          _buildPriorityDropdown(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Is Active toggle
                Row(
                  children: [
                    _fieldLabel('Active'),
                    const SizedBox(width: 8),
                    Switch(
                      value: isActive,
                      activeColor: AppColors.blue,
                      onChanged: (val) => setState(() => isActive = val),
                    ),
                    Text(isActive ? 'Yes' : 'No',
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),

                // Publish At & Expires At Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Publish At'),
                          MyTextFormField(
                            controller: publishAtCtrl,
                            hintText: 'Select date',
                            readOnly: true,
                            trailing: const Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey),
                            onTap: () => _pickDate(publishAtCtrl),
                            validator: (val) => (val == null || val.isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Expires At'),
                          MyTextFormField(
                            controller: expiresAtCtrl,
                            hintText: 'Select date',
                            readOnly: true,
                            trailing: const Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey),
                            onTap: () => _pickDate(expiresAtCtrl),
                            validator: (val) => (val == null || val.isEmpty)
                                ? 'Required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyOutlinedButton(
                      child: 'Cancel',
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Obx(() => MyElevatedButton(
                          child: isEdit
                              ? 'Update Announcement'
                              : 'Create Announcement',
                          isLoading: controller.isSavingAnnouncement.value,
                          onTap: _onSave,
                          icon: const Icon(Icons.check,
                              color: Colors.white, size: 18),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildAnnouncementTypeDropdown() {
    final choices =
        controller.announcementChoices.value?.announcementTypes ?? [];
    final typeItems = choices.isNotEmpty
        ? choices.map((e) => e.value).toList()
        : ['general', 'urgent', 'policy', 'event'];

    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: typeItems.contains(selectedAnnouncementType)
              ? selectedAnnouncementType
              : null,
          hint: const Text('Select type',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: typeItems
              .map((t) => DropdownMenuItem(
                  value: t,
                  child: Text(_capitalize(t),
                      style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (val) =>
              setState(() => selectedAnnouncementType = val),
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    final choices = controller.announcementChoices.value?.priorities ?? [];
    final priorityItems = choices.isNotEmpty
        ? choices.map((e) => e.value).toList()
        : ['low', 'normal', 'high', 'urgent'];

    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: priorityItems.contains(selectedPriority)
              ? selectedPriority
              : null,
          hint: const Text('Select priority',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: priorityItems
              .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(_capitalize(p),
                      style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (val) => setState(() => selectedPriority = val),
        ),
      ),
    );
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        ctrl.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (selectedAnnouncementType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an announcement type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Convert dates to ISO 8601 format for the API
    String apiPublishAt = '';
    String apiExpiresAt = '';
    try {
      final parsedFrom =
          DateFormat('MMM d, yyyy').parse(publishAtCtrl.text);
      apiPublishAt = parsedFrom.toUtc().toIso8601String();
    } catch (_) {
      apiPublishAt = publishAtCtrl.text;
    }
    try {
      final parsedTo =
          DateFormat('MMM d, yyyy').parse(expiresAtCtrl.text);
      apiExpiresAt = parsedTo.toUtc().toIso8601String();
    } catch (_) {
      apiExpiresAt = expiresAtCtrl.text;
    }

    final data = <String, dynamic>{
      'title': titleCtrl.text.trim(),
      'content': contentCtrl.text.trim(),
      'announcement_type': selectedAnnouncementType ?? 'general',
      'priority': selectedPriority ?? 'normal',
      'branch_ids': selectedBranchIds.toList(),
      'department_ids': selectedDepartmentIds.toList(),
      'is_active': isActive,
      'publish_at': apiPublishAt,
      'expires_at': apiExpiresAt,
    };

    if (isEdit) {
      controller.updateAnnouncement(context, widget.announcement!.id, data);
    } else {
      controller.createAnnouncement(context, data);
    }
  }
}

// ─── VIEW ANNOUNCEMENT DIALOG ───────────────────────────────────

class ViewAnnouncementDialog extends StatelessWidget {
  final Announcement announcement;
  const ViewAnnouncementDialog({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    final BroadcastController controller = Get.find<BroadcastController>();

    // Format dates
    String displayPublishAt = _formatDate(announcement.publishAt);
    String displayExpiresAt = _formatDate(announcement.expiresAt);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Announcement info',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildDetailRow('Title', announcement.title),
              _buildDetailRow('Content', announcement.content),
              _buildDetailRow('Type', announcement.announcementTypeDisplay),
              _buildDetailRow('Priority', announcement.priorityDisplay),

              // Active Status
              _buildActiveRow(announcement.isActive),

              _buildDetailRow('Publish At', displayPublishAt),
              _buildDetailRow('Expires At', displayExpiresAt),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    label: 'Delete',
                    color: Colors.red,
                    onTap: () async {
                      Navigator.pop(context);
                      final confirmed = await _showDeleteConfirmation(
                          context, announcement.title);
                      if (confirmed == true && context.mounted) {
                        controller.deleteAnnouncement(
                            context, announcement.id);
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    label: 'Edit',
                    color: AppColors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) => CreateEditAnnouncementDialog(
                            announcement: announcement),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '–';
    try {
      final parsed = DateTime.parse(dateStr);
      return DateFormat('MMMM d, yyyy').format(parsed);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style:
                    const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRow(bool active) {
    final color = active ? Colors.green : Colors.grey;
    final label = active ? 'Active' : 'Inactive';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const SizedBox(
            width: 130,
            child: Text('Status',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8, color: color),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(
      BuildContext context, String name) async {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Announcement'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
