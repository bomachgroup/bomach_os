import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_date_field.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/controllers/milestone_controller.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ProjectMilestone extends StatefulWidget {
  final int projectId;
  const ProjectMilestone({super.key, required this.projectId});

  @override
  State<ProjectMilestone> createState() => _ProjectMilestoneState();
}

class _ProjectMilestoneState extends State<ProjectMilestone> {
  final ScrollController _scrollController = ScrollController();
  late final MilestoneController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MilestoneController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMilestones(context, projectId: widget.projectId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator()));
        }

        if (controller.milestones.isEmpty) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text("No milestones found.")));
        }

        return Column(
          children: [
            Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: bodySpace(context)),
                  child: DataTable(
                    columns: _createColumns(),
                    rows: _createRows(context),
                    showBottomBorder: true,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(label: MyText("S/N")),
      DataColumn(label: MyText("Milestone Title")),
      DataColumn(label: MyText("Budget")),
      DataColumn(label: MyText("Priority")),
      DataColumn(label: MyText("Status")),
      DataColumn(label: MyText("Action")),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    final milestones = controller.milestones;
    return List.generate(milestones.length, (index) {
      final m = milestones[index];
      return DataRow(cells: [
        DataCell(MyText("${index + 1}")),
        DataCell(MyText(m.name)),
        DataCell(MyText(m.budget.isEmpty ? '-' : m.budget)),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: getRandomColorFromList(m.priority).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6)),
          child: MyText(m.priority.isEmpty ? '-' : m.priority),
        )),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: getRandomColorFromList(m.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6)),
          child: MyText(m.status),
        )),
        DataCell(PopupMenuButton(
          itemBuilder: (ctx) => [
            PopupMenuItem(
              child: const Text("Edit"),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AddMileStoneDialog(
                    projectId: widget.projectId, milestone: m),
              ),
            ),
            PopupMenuItem(
              child: const Text("Delete"),
              onTap: () => controller.deleteMilestone(
                  context, m.id, widget.projectId),
            ),
          ],
          child: const Icon(Icons.more_vert),
        )),
      ]);
    });
  }
}

class AddMileStoneDialog extends StatefulWidget {
  final int projectId;
  final Milestone? milestone;
  const AddMileStoneDialog({super.key, required this.projectId, this.milestone});

  @override
  State<AddMileStoneDialog> createState() => _AddMileStoneDialogState();
}

class _AddMileStoneDialogState extends State<AddMileStoneDialog> {
  late final MilestoneController controller;

  late TextEditingController nameCtrl;
  late TextEditingController budgetCtrl;
  late TextEditingController startDateCtrl;
  late TextEditingController endDateCtrl;
  late TextEditingController descCtrl;

  String selectedStatus = 'Pending';
  String selectedPriority = 'Medium';

  @override
  void initState() {
    super.initState();
    controller = Get.find<MilestoneController>();
    final m = widget.milestone;
    nameCtrl = TextEditingController(text: m?.name ?? '');
    budgetCtrl = TextEditingController(text: m?.budget ?? '');
    startDateCtrl = TextEditingController(text: m?.startDate ?? '');
    endDateCtrl = TextEditingController(text: m?.endDate ?? '');
    descCtrl = TextEditingController(text: m?.description ?? '');
    if (m != null) {
      if (m.status.isNotEmpty) selectedStatus = m.status;
      if (m.priority.isNotEmpty) selectedPriority = m.priority;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    budgetCtrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.milestone != null;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    isEdit ? 'Edit Milestone' : 'Create Milestone',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              controller: nameCtrl,
                              title: 'Milestone Title*',
                              hintText: 'Enter title')),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              controller: budgetCtrl,
                              title: 'Budget',
                              hintText: '0.00')),
                    ]),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(
                        child: MyDropdown(
                            title: 'Priority',
                            items: const ['Low', 'Medium', 'High'],
                            hintText: 'Select',
                            controller:
                                TextEditingController(text: selectedPriority),
                            onChanged: (val) =>
                                setState(() => selectedPriority = val!)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyDropdown(
                            title: 'Status*',
                            items: const [
                              'Pending',
                              'In Progress',
                              'Completed'
                            ],
                            hintText: 'Select',
                            controller:
                                TextEditingController(text: selectedStatus),
                            onChanged: (val) =>
                                setState(() => selectedStatus = val!)),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    Row(children: [
                      Expanded(
                          child: MyDateField(
                              controller: startDateCtrl,
                              title: 'Start Date')),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyDateField(
                              controller: endDateCtrl,
                              title: 'End Date')),
                    ]),
                    const SizedBox(height: 24),
                    MyTextFormField(
                        controller: descCtrl,
                        title: 'Description',
                        maxLines: 3,
                        hintText: 'Milestone details...'),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                      child: 'Cancel', onTap: () => Navigator.pop(context)),
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

    final m = Milestone(
      id: widget.milestone?.id ?? 0,
      projectId: widget.projectId,
      name: nameCtrl.text,
      description: descCtrl.text,
      priority: selectedPriority,
      status: selectedStatus,
      budget: budgetCtrl.text,
      progress: widget.milestone?.progress ?? 0,
      startDate: startDateCtrl.text,
      endDate: endDateCtrl.text,
      createdAt: widget.milestone?.createdAt ?? '',
      updatedAt: '',
    );

    if (widget.milestone == null) {
      controller.createMilestone(context, m);
    } else {
      controller.updateMilestone(context, m.id, m);
    }
  }
}
