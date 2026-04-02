import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controllers/work_site_controller.dart';
import '../models/models.dart';

class AddWorksiteDialog extends StatefulWidget {
  final Worksite? worksite;
  final int projectId;

  const AddWorksiteDialog({
    super.key,
    this.worksite,
    this.projectId = 0,
  });

  @override
  State<AddWorksiteDialog> createState() => AddWorksiteDialogState();
}

class AddWorksiteDialogState extends State<AddWorksiteDialog> {
  final WorksiteController controller = Get.find<WorksiteController>();

  late TextEditingController nameCtrl;
  late TextEditingController locationCtrl;
  late TextEditingController descCtrl;
  String selectedStatus = 'Active';

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.worksite?.name ?? '');
    locationCtrl = TextEditingController(text: widget.worksite?.location ?? '');
    descCtrl = TextEditingController(text: widget.worksite?.description ?? '');

    if (widget.worksite != null && widget.worksite!.status.isNotEmpty) {
      selectedStatus = widget.worksite!.status;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    locationCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.worksite != null;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(isEdit ? 'Edit Worksite' : 'Add Worksite',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  MyTextFormField(
                    controller: nameCtrl,
                    title: 'Worksite Name*',
                    hintText: "e.g. Site A",
                  ),
                  const SizedBox(height: 24),
                  MyTextFormField(
                    controller: locationCtrl,
                    title: 'Location*',
                    hintText: 'e.g. 123 Industrial Rd',
                  ),
                  const SizedBox(height: 24),
                  MyDropdown(
                    title: 'Status',
                    items: const ['Active', 'Inactive', 'Completed'],
                    hintText: 'Select Status',
                    controller: TextEditingController(text: selectedStatus),
                    onChanged: (val) => setState(() => selectedStatus = val!),
                  ),
                  const SizedBox(height: 24),
                  MyTextFormField(
                    controller: descCtrl,
                    title: 'Details/Notes',
                    maxLines: 4,
                    hintText: 'Additional details...',
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    child: 'Cancel',
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => controller.isActionLoading.value
                      ? const CircularProgressIndicator()
                      : MyElevatedButton(
                          icon: SvgPicture.asset("assets/svg/check.svg",
                              colorFilter: const ColorFilter.mode(
                                  AppColors.white, BlendMode.srcIn)),
                          child: isEdit ? 'Update' : 'Save',
                          onTap: _save,
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (nameCtrl.text.isEmpty || locationCtrl.text.isEmpty) return;

    final formWorksite = Worksite(
      id: widget.worksite?.id ?? 0,
      projectId: widget.worksite?.projectId ?? widget.projectId,
      name: nameCtrl.text,
      location: locationCtrl.text,
      status: selectedStatus,
      description: descCtrl.text,
      createdAt: widget.worksite?.createdAt ?? '',
      updatedAt: '',
    );

    if (widget.worksite == null) {
      controller.createWorksite(context, formWorksite);
    } else {
      controller.updateWorksite(context, formWorksite.id, formWorksite);
    }
  }
}
