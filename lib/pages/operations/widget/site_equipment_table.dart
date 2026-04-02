import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/controllers/site_equipment_controller.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SiteEquipmentTable extends StatefulWidget {
  final int worksiteId;
  const SiteEquipmentTable({super.key, required this.worksiteId});

  @override
  State<SiteEquipmentTable> createState() => _SiteEquipmentTableState();
}

class _SiteEquipmentTableState extends State<SiteEquipmentTable> {
  final ScrollController _scrollController = ScrollController();
  late final SiteEquipmentController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(SiteEquipmentController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchEquipment(context, worksiteId: widget.worksiteId);
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

        if (controller.equipment.isEmpty) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text("No equipment found.")));
        }

        return Column(
          children: [
            Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: bodySpace(context)),
                  child: DataTable(
                    dataRowMinHeight: 68,
                    dataRowMaxHeight: 68,
                    columnSpacing: 24,
                    horizontalMargin: 12,
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
      DataColumn(
          headingRowAlignment: MainAxisAlignment.start, label: MyText("S/N")),
      DataColumn(label: MyText("Equipment Name")),
      DataColumn(label: MyText("Unit Value")),
      DataColumn(label: MyText("Action")),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    final items = controller.equipment;
    return List.generate(items.length, (index) {
      final eq = items[index];
      return DataRow(cells: <DataCell>[
        DataCell(MyText("${index + 1}")),
        DataCell(
          Row(
            children: [
              SvgPicture.asset(
                "assets/svg/note2.svg",
                colorFilter:
                    const ColorFilter.mode(AppColors.black, BlendMode.srcIn),
              ),
              kSizedBoxWidth,
              MyText(eq.name, size: 16, weight: 400, isSelectable: false),
            ],
          ),
        ),
        DataCell(MyText(eq.unitValue)),
        DataCell(
          PopupMenuButton(
            itemBuilder: (ctx) => [
              PopupMenuItem(
                child: const Text("Delete"),
                onTap: () => controller.deleteEquipment(
                    context, eq.id, widget.worksiteId),
              ),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ),
      ]);
    });
  }
}

class AddEquipmentDialog extends StatefulWidget {
  final int worksiteId;
  const AddEquipmentDialog({super.key, required this.worksiteId});

  @override
  State<AddEquipmentDialog> createState() => _AddEquipmentDialogState();
}

class _AddEquipmentDialogState extends State<AddEquipmentDialog> {
  final SiteEquipmentController controller =
      Get.find<SiteEquipmentController>();

  final nameCtrl = TextEditingController();
  final unitValueCtrl = TextEditingController();

  @override
  void dispose() {
    nameCtrl.dispose();
    unitValueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText('Add Equipment',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                    title: 'Equipment Name*',
                    hintText: 'e.g. Excavator',
                  ),
                  const SizedBox(height: 24),
                  MyTextFormField(
                    controller: unitValueCtrl,
                    title: 'Unit Value*',
                    hintText: 'e.g. 2',
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
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
                          child: 'Save',
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
    if (nameCtrl.text.isEmpty || unitValueCtrl.text.isEmpty) return;

    final eq = SiteEquipment(
      id: 0,
      worksiteId: widget.worksiteId,
      name: nameCtrl.text,
      unitValue: unitValueCtrl.text,
      createdAt: '',
      updatedAt: '',
    );

    controller.createEquipment(context, eq);
  }
}
