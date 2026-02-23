import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/model/branch_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/branch_controller.dart';

class AddBranchDialog extends StatefulWidget {
  final Branch? branchToEdit;
  const AddBranchDialog({super.key, this.branchToEdit});

  @override
  State<AddBranchDialog> createState() => _AddBranchDialogState();
}

class _AddBranchDialogState extends State<AddBranchDialog> {
  final BranchController controller = Get.find<BranchController>();

  // Controllers
  final nameCtrl = TextEditingController();
  final lgaCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  int? selectedCountryId;
  int? selectedStateId;
  String? selectedRole;
  String? selectedStatus;

  // Names for initial display
  String? displayCountry;
  String? displayState;

  @override
  void initState() {
    super.initState();
    if (widget.branchToEdit != null) {
      final b = widget.branchToEdit!;
      nameCtrl.text = b.branchName;
      lgaCtrl.text = b.lga;
      addressCtrl.text = b.officeAddress;
      emailCtrl.text = b.contactEmail;
      phoneCtrl.text = b.contactPhone;

      selectedCountryId = b.countryId;
      selectedStateId = b.stateId;
      selectedRole = b.branchRole;
      selectedStatus = b.operationalStatus;

      displayCountry = b.countryName;
      displayState = b.stateName;

      if (b.countryId != 0) controller.fetchStatesForCountry(b.countryId);
    } else {
      selectedStatus = "active";
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.branchToEdit != null;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(isEditing ? 'Edit Branch' : 'Create Branch',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: MyTextFormField(
                                controller: nameCtrl,
                                title: "Branch Name",
                                hintText: "Enter Name")),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Obx(() => MyDropdown(
                                  title: "Country",
                                  hintText: displayCountry ?? "Select Country",
                                  items: controller.countryList
                                      .map((e) => e.name)
                                      .toList(),
                                  onChanged: (val) {
                                    final country = controller.countryList
                                        .firstWhere((e) => e.name == val);
                                    setState(() {
                                      selectedCountryId = country.id;
                                      displayCountry = val;
                                      selectedStateId = null;
                                      displayState = null;
                                    });
                                    controller
                                        .fetchStatesForCountry(country.id);
                                  },
                                ))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Obx(() => MyDropdown(
                                  title: "State",
                                  hintText: displayState ?? "Select State",
                                  items: controller.stateList
                                      .map((e) => e.name)
                                      .toList(),
                                  onChanged: (val) {
                                    final state = controller.stateList
                                        .firstWhere((e) => e.name == val);
                                    setState(() => selectedStateId = state.id);
                                  },
                                ))),
                        const SizedBox(width: 16),
                        Expanded(
                            child: MyTextFormField(
                                controller: lgaCtrl,
                                title: "L.G.A",
                                hintText: "Enter LGA")),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: MyTextFormField(
                                controller: addressCtrl,
                                title: "Office Address",
                                hintText: "Enter address")),
                        const SizedBox(width: 16),
                        Expanded(
                            child: MyTextFormField(
                                title: "Branch ID",
                                hintText: isEditing
                                    ? "${widget.branchToEdit?.id}"
                                    : "Auto-generated",
                                readOnly: true,
                                fillColor: Colors.grey.shade100)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Obx(() => MyDropdown(
                                  title: "Branch Type",
                                  hintText: selectedRole ?? "Select Type",
                                  items: controller
                                          .fieldChoices.value?.branchRole
                                          .map((e) => e.label)
                                          .toList() ??
                                      [],
                                  onChanged: (val) {
                                    final choice = controller
                                        .fieldChoices.value?.branchRole
                                        .firstWhere((e) => e.label == val);
                                    if (choice != null)
                                      setState(
                                          () => selectedRole = choice.value);
                                  },
                                ))),
                        const SizedBox(width: 16),
                        Expanded(
                            child: Obx(() => MyDropdown(
                                  title: "Operational Status",
                                  hintText: selectedStatus ?? "Select Status",
                                  items: controller
                                          .fieldChoices.value?.operationalStatus
                                          .map((e) => e.label)
                                          .toList() ??
                                      [],
                                  onChanged: (val) {
                                    final choice = controller
                                        .fieldChoices.value?.operationalStatus
                                        .firstWhere((e) => e.label == val);
                                    if (choice != null)
                                      setState(
                                          () => selectedStatus = choice.value);
                                  },
                                ))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: MyTextFormField(
                                controller: emailCtrl,
                                title: "Contact Email",
                                hintText: "email@example.com")),
                        const SizedBox(width: 16),
                        Expanded(
                            child: MyTextFormField(
                                controller: phoneCtrl,
                                title: "Contact Phone",
                                hintText: "Enter phone")),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                      child: "Cancel",
                      onTap: () => Navigator.pop(context),
                      textColor: Colors.grey),
                  const SizedBox(width: 12),
                  Obx(() => MyElevatedButton(
                        width: 120,
                        child: controller.isSaving.value ? "Saving..." : "Save",
                        onTap: controller.isSaving.value
                            ? () {}
                            : () {
                                final data = {
                                  "branch_name": nameCtrl.text,
                                  "country_id": selectedCountryId,
                                  "state_id": selectedStateId,
                                  "lga": lgaCtrl.text,
                                  "office_address": addressCtrl.text,
                                  "operational_status": selectedStatus,
                                  "branch_role": selectedRole,
                                  "contact_email": emailCtrl.text,
                                  "contact_phone": phoneCtrl.text,
                                  "is_active": true,
                                };

                                if (isEditing) {
                                  controller.updateBranch(
                                      context, widget.branchToEdit!.id, data);
                                } else {
                                  controller.createBranch(context, data);
                                }
                              },
                      )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
