import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controllers/contract_controller.dart';
import '../models/models.dart';

class AddContractDialog extends StatefulWidget {
  final Contract? contract;

  const AddContractDialog({super.key, this.contract});

  @override
  State<AddContractDialog> createState() => _AddContractDialogState();
}

class _AddContractDialogState extends State<AddContractDialog> {
  final ContractController controller = Get.find<ContractController>();

  late TextEditingController nameCtrl;
  late TextEditingController numberCtrl;
  late TextEditingController valueCtrl;
  late TextEditingController startCtrl;
  late TextEditingController endCtrl;

  late TextEditingController projectIdCtrl;

  String selectedType = 'Fixed Price';
  String selectedStatus = 'Pending';

  @override
  void initState() {
    super.initState();
    final c = widget.contract;
    nameCtrl = TextEditingController(text: c?.name ?? '');
    numberCtrl = TextEditingController(text: c?.contractNumber ?? '');
    valueCtrl = TextEditingController(text: c?.value.toString() ?? '0');
    startCtrl = TextEditingController(text: c?.startDate ?? '');
    endCtrl = TextEditingController(text: c?.endDate ?? '');
    projectIdCtrl = TextEditingController(
        text: (c?.projectId ?? widget.contract?.projectId).toString());

    if (c != null) {
      if (c.contractType.isNotEmpty) selectedType = c.contractType;
      if (c.status.isNotEmpty) selectedStatus = c.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.contract != null;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
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
                    isEdit ? 'Edit Contract' : 'Create Contract',
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
                      title: 'Contract Name*',
                      hintText: 'e.g. Site A Development Contract',
                    ),
                    const SizedBox(height: 24),

                    // Row 1: Number & Type
                    Row(
                      children: [
                        Expanded(
                          child: MyTextFormField(
                            controller: numberCtrl,
                            title: 'Contract Number*',
                            hintText: 'e.g. CON-2024-001',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyDropdown(
                            hintText: '',
                            title: 'Contract Type*',
                            items: const [
                              'Fixed Price',
                              'Time & Material',
                              'Retainer'
                            ],
                            controller:
                                TextEditingController(text: selectedType),
                            onChanged: (val) =>
                                setState(() => selectedType = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: MyDropdown(
                            hintText: '',
                            title: 'Status*',
                            items: const [
                              'Pending',
                              'Active',
                              'Completed',
                              'Terminated'
                            ],
                            controller:
                                TextEditingController(text: selectedStatus),
                            onChanged: (val) =>
                                setState(() => selectedStatus = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyTextFormField(
                            controller: valueCtrl,
                            title: 'Value (N)*',
                            hintText: '0.00',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Row 3: Dates
                    Row(
                      children: [
                        Expanded(
                          child: MyTextFormField(
                            controller: startCtrl,
                            title: 'Start Date*',
                            hintText: "YYYY-MM-DD",
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MyTextFormField(
                            controller: endCtrl,
                            title: 'End Date',
                            hintText: "YYYY-MM-DD",
                          ),
                        ),
                      ],
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
    if (nameCtrl.text.isEmpty || numberCtrl.text.isEmpty) return;

    final contract = Contract(
      id: widget.contract?.id ?? 0,
      projectId: int.tryParse(projectIdCtrl.text) ?? 0,
      name: nameCtrl.text,
      contractNumber: numberCtrl.text,
      contractType: selectedType,
      status: selectedStatus,
      value: double.tryParse(valueCtrl.text) ?? 0.0,
      startDate: startCtrl.text,
      endDate: endCtrl.text,
      createdAt: widget.contract?.createdAt ?? '',
      updatedAt: '',
    );

    if (widget.contract == null) {
      controller.createContract(context, contract);
    } else {
      controller.updateContract(context, contract.id, contract);
    }
  }
}
