import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_date_field.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/contract_controller.dart';
import '../models/models.dart';

import 'package:bomach_os/src/utils/app_date_format.dart';
class AddContractDialog extends StatefulWidget {
  final Contract? contract;

  const AddContractDialog({super.key, this.contract});

  @override
  State<AddContractDialog> createState() => _AddContractDialogState();
}

class _AddContractDialogState extends State<AddContractDialog> {
  final ContractController controller = Get.find<ContractController>();
  final _formKey = GlobalKey<FormState>();

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
    startCtrl = TextEditingController(
        text: formatAppDateValue(c?.startDate, fallback: c?.startDate ?? ''));
    endCtrl = TextEditingController(
        text: formatAppDateValue(c?.endDate, fallback: c?.endDate ?? ''));
    projectIdCtrl = TextEditingController(
        text: (c?.projectId ?? widget.contract?.projectId).toString());

    if (c != null) {
      if (c.contractType.isNotEmpty) selectedType = c.contractType;
      if (c.status.isNotEmpty) selectedStatus = c.status;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    numberCtrl.dispose();
    valueCtrl.dispose();
    startCtrl.dispose();
    endCtrl.dispose();
    projectIdCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (nameCtrl.text.isEmpty || numberCtrl.text.isEmpty) return;

    final contract = Contract(
      id: widget.contract?.id ?? 0,
      projectId: int.tryParse(projectIdCtrl.text) ?? 0,
      name: nameCtrl.text,
      contractNumber: numberCtrl.text,
      contractType: selectedType,
      status: selectedStatus,
      value: double.tryParse(valueCtrl.text) ?? 0.0,
      startDate: appDateToApiDate(startCtrl.text) ?? '',
      endDate: appDateToApiDate(endCtrl.text) ?? '',
      createdAt: widget.contract?.createdAt ?? '',
      updatedAt: '',
    );

    if (widget.contract == null) {
      controller.createContract(context, contract);
    } else {
      controller.updateContract(context, contract.id, contract);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.contract != null;

    return Obx(() => DialogScaffold(
          title: isEdit ? 'Edit Contract' : 'New Contract',
          subtitle: isEdit
              ? 'Update contract terms, value, and scheduling.'
              : 'Register a new contract with its type, value, and duration.',
          size: DialogSize.lg,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Contract information',
                  subtitle:
                      'Identify the contract and its reference number.',
                  child: Column(
                    children: [
                      MyTextFormField(
                        controller: nameCtrl,
                        title: 'Contract Name',
                        hintText: 'e.g. Site A Development Contract',
                        validator: (val) =>
                            (val == null || val.trim().isEmpty)
                                ? 'Required'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: numberCtrl,
                              title: 'Contract Number',
                              hintText: 'e.g. CON-2024-001',
                              validator: (val) =>
                                  (val == null || val.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyDropdown(
                              title: 'Contract Type',
                              hintText: 'Select type',
                              items: const [
                                'Fixed Price',
                                'Time & Material',
                                'Retainer',
                              ],
                              initialSelection: selectedType,
                              onChanged: (val) => setState(
                                  () => selectedType = val ?? selectedType),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Value & status',
                  subtitle:
                      'Set the contract value and its current lifecycle state.',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MyDropdown(
                          title: 'Status',
                          hintText: 'Select status',
                          items: const [
                            'Pending',
                            'Active',
                            'Completed',
                            'Terminated',
                          ],
                          initialSelection: selectedStatus,
                          onChanged: (val) => setState(
                              () => selectedStatus = val ?? selectedStatus),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MyTextFormField(
                          controller: valueCtrl,
                          title: 'Value (₦)',
                          hintText: '0.00',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Schedule',
                  subtitle: 'Define the contract duration.',
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                ),
              ],
            ),
          ),
          actions: [
            MyOutlinedButton(
              child: 'Cancel',
              height: 44,
              onTap: () => Navigator.pop(context),
              textColor: AppColors.textSecondary,
              borderColor: AppColors.borderStrong,
            ),
            MyElevatedButton(
              width: 140,
              height: 44,
              child: controller.isActionLoading.value
                  ? 'Saving...'
                  : (isEdit ? 'Update' : 'Save'),
              onTap: controller.isActionLoading.value ? null : _save,
              icon: controller.isActionLoading.value
                  ? null
                  : const Icon(
                      Iconsax.tick_circle,
                      size: 18,
                      color: AppColors.textOnPrimary,
                    ),
            ),
          ],
        ));
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
