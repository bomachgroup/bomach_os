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
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final lgaCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  int? selectedCountryId;
  int? selectedStateId;
  String? selectedRole;
  String? selectedStatus;
  int? selectedManagerId;
  bool isActive = true;

  String? displayCountry;
  String? displayState;
  String? displayManager;

  bool get isEditing => widget.branchToEdit != null;

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
      notesCtrl.text = b.notes;

      selectedCountryId = b.countryId;
      selectedStateId = b.stateId;
      selectedRole = b.branchRole;
      selectedStatus = b.operationalStatus;
      selectedManagerId = b.managerId != 0 ? b.managerId : null;
      isActive = b.isActive;

      displayCountry = b.countryName;
      displayState = b.stateName;
      displayManager = b.managerName.isNotEmpty ? b.managerName : null;

      if (b.countryId != 0) controller.fetchStatesForCountry(b.countryId);
    } else {
      selectedStatus = "active";
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    lgaCtrl.dispose();
    addressCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(isEditing ? 'Edit Branch' : 'Create New Branch',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      MyText(
                        isEditing
                            ? 'Update branch information'
                            : 'Fill in the details to create a new branch',
                        size: 13,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: AppColors.red),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Basic Info
                      _buildSectionLabel('Basic Information'),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: nameCtrl,
                              title: "Branch Name",
                              hintText: "Enter branch name",
                              validator: (val) =>
                                  (val == null || val.isEmpty)
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              title: "Branch ID",
                              hintText: isEditing
                                  ? "${widget.branchToEdit?.id}"
                                  : "Auto-generated",
                              readOnly: true,
                              fillColor: Colors.grey.shade100,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Obx(() => MyDropdown(
                                  title: "Branch Type",
                                  hintText: _getRoleDisplayLabel() ??
                                      "Select type",
                                  items: controller
                                          .fieldChoices.value?.branchRole
                                          .map((e) => e.label)
                                          .toList() ??
                                      [],
                                  onChanged: (val) {
                                    final choice = controller
                                        .fieldChoices.value?.branchRole
                                        .firstWhere((e) => e.label == val);
                                    if (choice != null) {
                                      setState(
                                          () => selectedRole = choice.value);
                                    }
                                  },
                                  validator: (val) =>
                                      selectedRole == null ? 'Required' : null,
                                )),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() => MyDropdown(
                                  title: "Operational Status",
                                  hintText: _getStatusDisplayLabel() ??
                                      "Select status",
                                  items: controller
                                          .fieldChoices.value?.operationalStatus
                                          .map((e) => e.label)
                                          .toList() ??
                                      [],
                                  onChanged: (val) {
                                    final choice = controller.fieldChoices
                                        .value?.operationalStatus
                                        .firstWhere((e) => e.label == val);
                                    if (choice != null) {
                                      setState(
                                          () => selectedStatus = choice.value);
                                    }
                                  },
                                  validator: (val) =>
                                      selectedStatus == null
                                          ? 'Required'
                                          : null,
                                )),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section: Location
                      _buildSectionLabel('Location'),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Obx(() => MyDropdown(
                                  title: "Country",
                                  hintText:
                                      displayCountry ?? "Select country",
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
                                  validator: (val) => selectedCountryId == null
                                      ? 'Required'
                                      : null,
                                )),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(() => MyDropdown(
                                  title: "State",
                                  hintText:
                                      displayState ?? "Select state",
                                  items: controller.stateList
                                      .map((e) => e.name)
                                      .toList(),
                                  onChanged: (val) {
                                    final state = controller.stateList
                                        .firstWhere((e) => e.name == val);
                                    setState(() {
                                      selectedStateId = state.id;
                                      displayState = val;
                                    });
                                  },
                                  validator: (val) => selectedStateId == null
                                      ? 'Required'
                                      : null,
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: lgaCtrl,
                              title: "L.G.A",
                              hintText: "Enter LGA",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              controller: addressCtrl,
                              title: "Office Address",
                              hintText: "Enter full address",
                              validator: (val) =>
                                  (val == null || val.isEmpty)
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section: Contact
                      _buildSectionLabel('Contact Information'),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: emailCtrl,
                              title: "Contact Email",
                              hintText: "email@example.com",
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) =>
                                  (val == null || val.isEmpty)
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              controller: phoneCtrl,
                              title: "Contact Phone",
                              hintText: "+234...",
                              keyboardType: TextInputType.phone,
                              validator: (val) =>
                                  (val == null || val.isEmpty)
                                      ? 'Required'
                                      : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section: Management
                      _buildSectionLabel('Management'),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Obx(() => MyDropdown(
                                  title: "Branch Manager",
                                  hintText:
                                      displayManager ?? "Select manager",
                                  items: controller.allEmployees
                                      .map((e) => e.fullName)
                                      .toList(),
                                  onChanged: (val) {
                                    final emp = controller.allEmployees
                                        .firstWhere((e) => e.fullName == val);
                                    setState(() {
                                      selectedManagerId =
                                          int.tryParse(emp.id) ?? 0;
                                      displayManager = val;
                                    });
                                  },
                                )),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Active Status",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF334155))),
                                const SizedBox(height: 8),
                                SwitchListTile(
                                  value: isActive,
                                  onChanged: (val) =>
                                      setState(() => isActive = val),
                                  title: Text(
                                    isActive ? "Active" : "Inactive",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: isActive
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  activeThumbColor: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Section: Notes
                      _buildSectionLabel('Additional Information'),
                      const SizedBox(height: 12),
                      MyTextFormField(
                        controller: notesCtrl,
                        title: "Notes",
                        hintText: "Enter any additional notes",
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            const Divider(height: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    child: "Cancel",
                    onTap: () => Navigator.pop(context),
                    textColor: Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Obx(() => MyElevatedButton(
                        width: 120,
                        child: controller.isSaving.value
                            ? "Saving..."
                            : "Save",
                        onTap:
                            controller.isSaving.value ? () {} : _onSave,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getRoleDisplayLabel() {
    if (selectedRole == null) return null;
    final choices = controller.fieldChoices.value?.branchRole;
    if (choices == null) return selectedRole;
    final match = choices.where((e) => e.value == selectedRole);
    return match.isNotEmpty ? match.first.label : selectedRole;
  }

  String? _getStatusDisplayLabel() {
    if (selectedStatus == null) return null;
    final choices = controller.fieldChoices.value?.operationalStatus;
    if (choices == null) return selectedStatus;
    final match = choices.where((e) => e.value == selectedStatus);
    return match.isNotEmpty ? match.first.label : selectedStatus;
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF334155),
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "branch_name": nameCtrl.text.trim(),
      "country_id": selectedCountryId,
      "state_id": selectedStateId,
      "lga": lgaCtrl.text.trim(),
      "office_address": addressCtrl.text.trim(),
      "operational_status": selectedStatus,
      "branch_role": selectedRole,
      "contact_email": emailCtrl.text.trim(),
      "contact_phone": phoneCtrl.text.trim(),
      "manager_id": selectedManagerId ?? 0,
      "notes": notesCtrl.text.trim(),
      "is_active": isActive,
    };

    if (isEditing) {
      controller.updateBranch(context, widget.branchToEdit!.id, data);
    } else {
      controller.createBranch(context, data);
    }
  }
}
