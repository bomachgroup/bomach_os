import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_date_field.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controllers/timeline_controller.dart';
import '../models/models.dart';

class AddTimelineDialog extends StatefulWidget {
  final TimelineModel? timeline;

  const AddTimelineDialog({
    super.key,
    this.timeline,
  });

  @override
  State<AddTimelineDialog> createState() => _AddTimelineDialogState();
}

class _AddTimelineDialogState extends State<AddTimelineDialog> {
  final TimelineController controller = Get.find<TimelineController>();

  late TextEditingController nameCtrl;
  late TextEditingController descCtrl;
  late TextEditingController startCtrl;
  late TextEditingController endCtrl;

  String selectedStatus = 'Pending';

  @override
  void initState() {
    super.initState();
    final t = widget.timeline;
    nameCtrl = TextEditingController(text: t?.name ?? '');
    descCtrl = TextEditingController(text: t?.description ?? '');
    startCtrl = TextEditingController(text: t?.startDate ?? '');
    endCtrl = TextEditingController(text: t?.endDate ?? '');

    if (t != null && t.status.isNotEmpty) {
      selectedStatus = t.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.timeline != null;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    isEdit ? 'Edit Timeline Phase' : 'Create Timeline Phase',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form Fields
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyTextFormField(
                      controller: nameCtrl,
                      title: 'Phase Name*',
                      hintText: 'e.g. Planning',
                    ),
                    const SizedBox(height: 24),
                    MyDropdown(
                      hintText: '',
                      title: 'Status*',
                      items: const [
                        'Pending',
                        'In Progress',
                        'Completed',
                        'On Hold'
                      ],
                      controller: TextEditingController(text: selectedStatus),
                      onChanged: (val) => setState(() => selectedStatus = val!),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: MyDateField(
                            controller: startCtrl,
                            title: 'Start Date',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyDateField(
                            controller: endCtrl,
                            title: 'End Date',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    MyTextFormField(
                      controller: descCtrl,
                      title: 'Description',
                      maxLines: 4,
                      hintText: 'Phase details...',
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
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
    if (nameCtrl.text.isEmpty) return;

    final timeline = TimelineModel(
      id: widget.timeline?.id ?? 0,
      projectId: widget.timeline?.projectId ?? 0,
      name: nameCtrl.text,
      description: descCtrl.text,
      status: selectedStatus,
      startDate: startCtrl.text,
      endDate: endCtrl.text,
      createdAt: widget.timeline?.createdAt ?? '',
      updatedAt: '',
    );

    if (widget.timeline == null) {
      controller.createTimeline(context, timeline);
    } else {
      controller.updateTimeline(context, timeline.id, timeline);
    }
  }
}
