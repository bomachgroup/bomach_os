import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/model/board_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/board_controller.dart';

// ─── CREATE / EDIT RESOLUTION DIALOG ─────────────────────────────

class NewResolutionDialog extends StatefulWidget {
  final BoardResolution? resolution; // null = create, non-null = edit
  const NewResolutionDialog({super.key, this.resolution});

  @override
  State<NewResolutionDialog> createState() => _NewResolutionDialogState();
}

class _NewResolutionDialogState extends State<NewResolutionDialog> {
  final _formKey = GlobalKey<FormState>();
  final BoardController controller = Get.find<BoardController>();

  late final TextEditingController titleCtrl;
  late final TextEditingController descriptionCtrl;
  late final TextEditingController dateCtrl;
  late final TextEditingController notesCtrl;

  String? selectedType;
  String? selectedStatus;
  bool get isEdit => widget.resolution != null;

  @override
  void initState() {
    super.initState();
    final r = widget.resolution;
    titleCtrl = TextEditingController(text: r?.title ?? '');
    descriptionCtrl = TextEditingController(text: r?.description ?? '');
    notesCtrl = TextEditingController(text: r?.notes ?? '');

    // Format date
    String dateText = '';
    if (r?.resolutionDate != null && r!.resolutionDate.isNotEmpty) {
      try {
        final parsed = DateTime.parse(r.resolutionDate);
        dateText = DateFormat('MMM d, yyyy').format(parsed);
      } catch (_) {
        dateText = r.resolutionDate;
      }
    }
    dateCtrl = TextEditingController(text: dateText);

    // Set type/status from existing resolution
    if (r != null) {
      selectedType =
          r.resolutionTypeDisplay.isNotEmpty ? r.resolutionTypeDisplay : null;
      selectedStatus = r.statusDisplay.isNotEmpty ? r.statusDisplay : null;
    } else {
      selectedStatus = 'Pending';
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    dateCtrl.dispose();
    notesCtrl.dispose();
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
                      isEdit ? 'Edit Resolution' : 'New Resolution',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.close_circle),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Resolution Title
                _fieldLabel('Resolution Title'),
                MyTextFormField(
                  controller: titleCtrl,
                  hintText: 'Type here',
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Resolution Type
                _fieldLabel('Resolution Type'),
                Obx(() {
                  // Reactive rebuild when choices load
                  final _ = controller.resolutionChoices.value;
                  return _buildTypeDropdown();
                }),
                const SizedBox(height: 16),

                // Date & Status Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Date'),
                          MyTextFormField(
                            controller: dateCtrl,
                            hintText: 'Select date',
                            readOnly: true,
                            trailing: const Icon(Iconsax.calendar_1,
                                size: 18, color: Colors.grey),
                            onTap: _pickDate,
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
                          _fieldLabel('Status'),
                          Obx(() {
                            final _ = controller.resolutionChoices.value;
                            return _buildStatusDropdown();
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                _fieldLabel('Description'),
                MyTextFormField(
                  controller: descriptionCtrl,
                  hintText: 'Type here',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Notes
                _fieldLabel('Notes'),
                MyTextFormField(
                  controller: notesCtrl,
                  hintText: 'Type here',
                  maxLines: 3,
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
                              ? 'Update Resolution'
                              : 'Submit for Approval',
                          isLoading: controller.isSavingResolution.value,
                          onTap: _onSave,
                          icon: const Icon(Iconsax.tick_circle,
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

  Widget _buildTypeDropdown() {
    final choices = controller.resolutionChoices.value?.resolutionTypes ?? [];
    final typeLabels = choices.map((e) => e.label).toList();

    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: typeLabels.contains(selectedType) ? selectedType : null,
          hint: const Text('Select',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Iconsax.arrow_down_1, color: Colors.grey),
          items: typeLabels
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: (val) => setState(() => selectedType = val),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    final choices = controller.resolutionChoices.value?.statuses ?? [];
    final statusLabels = choices.map((e) => e.label).toList();

    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: statusLabels.contains(selectedStatus) ? selectedStatus : null,
          hint: const Text('Pending',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Iconsax.arrow_down_1, color: Colors.grey),
          items: statusLabels
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (val) => setState(() => selectedStatus = val),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        dateCtrl.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    // Validate resolution type is selected
    if (selectedType == null) {
      AppToast.error(context, 'Please select a resolution type');
      return;
    }

    // Convert display date to API format
    String apiDate = '';
    try {
      final parsed = DateFormat('MMM d, yyyy').parse(dateCtrl.text);
      apiDate = DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      apiDate = dateCtrl.text;
    }

    // Map display labels to API values
    final typeOption = controller.resolutionChoices.value?.resolutionTypes
        .firstWhereOrNull((e) => e.label == selectedType);
    final statusOption = controller.resolutionChoices.value?.statuses
        .firstWhereOrNull((e) => e.label == selectedStatus);

    final data = <String, dynamic>{
      'title': titleCtrl.text.trim(),
      'resolution_type': typeOption?.value ?? selectedType ?? '',
      'resolution_date': apiDate,
      'status': statusOption?.value ?? selectedStatus ?? 'pending',
      'description': descriptionCtrl.text.trim(),
      if (notesCtrl.text.trim().isNotEmpty) 'notes': notesCtrl.text.trim(),
    };

    if (isEdit) {
      controller.updateResolution(context, widget.resolution!.id, data);
    } else {
      controller.createResolution(context, data);
    }
  }
}

// ─── VIEW RESOLUTION DIALOG ──────────────────────────────────────

class ViewResolutionDialog extends StatelessWidget {
  final BoardResolution resolution;
  const ViewResolutionDialog({super.key, required this.resolution});

  @override
  Widget build(BuildContext context) {
    final BoardController controller = Get.find<BoardController>();

    // Format date
    String displayDate = resolution.resolutionDate;
    try {
      final parsed = DateTime.parse(resolution.resolutionDate);
      displayDate = DateFormat('MMMM d, yyyy').format(parsed);
    } catch (_) {}

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
                  const Text('Resolution info',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildDetailRow('Title', resolution.title),
              _buildDetailRow('Type', resolution.resolutionTypeDisplay),
              _buildDetailRow('Date', displayDate),

              // Status
              _buildStatusRow(resolution.statusDisplay),

              if (resolution.description.isNotEmpty)
                _buildDetailRow('Description', resolution.description),

              if (resolution.createdByName.isNotEmpty)
                _buildDetailRow('Created By', resolution.createdByName),

              if (resolution.approvedByName != null &&
                  resolution.approvedByName!.isNotEmpty)
                _buildDetailRow('Approved By', resolution.approvedByName!),

              if (resolution.attachmentUrl != null &&
                  resolution.attachmentUrl!.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text('Attachment',
                      style: TextStyle(color: AppColors.neutral500, fontSize: 13)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.attach_circle, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text('View Attachment', style: TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Notes
              if (resolution.notes != null && resolution.notes!.isNotEmpty)
                _buildDetailRow('Notes', resolution.notes!),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildActionButton(
                    label: 'Archive',
                    color: Colors.red,
                    onTap: () async {
                      Navigator.pop(context);
                      final confirmed = await _showArchiveConfirmation(
                          context, resolution.title);
                      if (confirmed == true && context.mounted) {
                        controller.archiveResolution(context, resolution.id);
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    label: 'Edit',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (_) =>
                            NewResolutionDialog(resolution: resolution),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: const TextStyle(color: AppColors.neutral500, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'archived':
        color = Colors.grey;
        break;
      default:
        color = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          const SizedBox(
            width: 110,
            child: Text('Status',
                style: TextStyle(color: AppColors.neutral500, fontSize: 13)),
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
                Icon(Iconsax.record_circle, size: 8, color: color),
                const SizedBox(width: 6),
                Text(status,
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

  Future<bool?> _showArchiveConfirmation(
      BuildContext context, String name) async {
    return showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Archive Resolution'),
        content: Text('Are you sure you want to archive "$name"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child:
                  const Text('Archive', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
