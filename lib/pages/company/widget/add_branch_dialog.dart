import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/input/upload_file.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/model/branch_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController lgaCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController notesCtrl = TextEditingController();

  // IDs for logic
  int? selectedCountryId;
  int? selectedStateId;

  // Names for Display (Dropdown Hints)
  String? displayCountry;
  String? displayState;
  String? displayStatus;
  String? displayRole;

  // Values for API
  String? selectedStatusValue;
  String? selectedRoleValue;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final branch = widget.branchToEdit;

    if (branch != null) {
      nameCtrl.text = branch.branchName;
      lgaCtrl.text = branch.lga;
      addressCtrl.text = branch.officeAddress;
      emailCtrl.text = branch.contactEmail;
      phoneCtrl.text = branch.contactPhone;
      notesCtrl.text = branch.notes;

      selectedCountryId = branch.countryId;
      selectedStateId = branch.stateId;
      selectedStatusValue = branch.operationalStatus;
      selectedRoleValue = branch.branchRole;

      displayCountry = branch.countryName;
      displayState = branch.stateName;
      displayStatus = branch.operationalStatusDisplay;
      displayRole = branch.branchRoleDisplay.isNotEmpty
          ? branch.branchRoleDisplay
          : branch.branchRole;

      if (branch.countryId != 0) {
        controller.fetchStatesForCountry(branch.countryId);
      }
    } else {
      selectedStatusValue = "active";
      displayStatus = "Active";
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
    final isEditing = widget.branchToEdit != null;

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Obx(() {
          final isSaving = controller.isSaving.value;

          return IgnorePointer(
            ignoring: isSaving,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(
                        isEditing ? 'Edit Branch' : 'Create Branch',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyTextFormField(
                                          controller: nameCtrl,
                                          hintText: 'Enter branch name',
                                          spaceBetweenText: 10,
                                          title: 'Branch Name',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Obx(() => MyDropdown(
                                              spaceBetweenText: 10,
                                              hintText: displayCountry ??
                                                  "Select Country",
                                              items: controller.countryList
                                                  .map((e) => e.name)
                                                  .toList(),
                                              title: 'Country*',
                                              onChanged: (val) {
                                                final country = controller
                                                    .countryList
                                                    .firstWhere(
                                                        (e) => e.name == val);
                                                setState(() {
                                                  selectedCountryId =
                                                      country.id;
                                                  displayCountry = country.name;
                                                  selectedStateId = null;
                                                  displayState = null;
                                                });
                                                controller
                                                    .fetchStatesForCountry(
                                                        country.id);
                                              },
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Obx(() => MyDropdown(
                                              spaceBetweenText: 10,
                                              hintText: displayState ??
                                                  "Select State",
                                              items: controller.stateList
                                                  .map((e) => e.name)
                                                  .toList(),
                                              title: 'State*',
                                              onChanged: (val) {
                                                final state = controller
                                                    .stateList
                                                    .firstWhere(
                                                        (e) => e.name == val);
                                                setState(() {
                                                  selectedStateId = state.id;
                                                  displayState = state.name;
                                                });
                                              },
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyTextFormField(
                                          controller: lgaCtrl,
                                          hintText: 'Enter LGA',
                                          spaceBetweenText: 10,
                                          title: 'L.G.A*',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyTextFormField(
                                          controller: addressCtrl,
                                          hintText: "Enter office address",
                                          spaceBetweenText: 10,
                                          title: 'Office Address*',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyTextFormField(
                                          hintText: isEditing
                                              ? widget.branchToEdit!.branchId
                                              : "Auto-generated",
                                          readOnly: true,
                                          fillColor: Colors.grey.shade100,
                                          spaceBetweenText: 10,
                                          title: 'Branch ID',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Obx(() => MyDropdown(
                                              hintText: displayStatus ??
                                                  "Select Status",
                                              spaceBetweenText: 10,
                                              items: controller.fieldChoices
                                                      .value?.operationalStatus
                                                      .map((e) => e.label)
                                                      .toList() ??
                                                  [],
                                              title: 'Operational Status',
                                              onChanged: (val) {
                                                final choice = controller
                                                    .fieldChoices
                                                    .value
                                                    ?.operationalStatus
                                                    .firstWhere(
                                                        (e) => e.label == val);
                                                if (choice != null) {
                                                  setState(() {
                                                    selectedStatusValue =
                                                        choice.value;
                                                    displayStatus =
                                                        choice.label;
                                                  });
                                                }
                                              },
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyDropdown(
                                          hintText: isEditing
                                              ? widget.branchToEdit!.managerName
                                              : "Select Manager",
                                          spaceBetweenText: 10,
                                          items: const [],
                                          title: 'Manager',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyTextFormField(
                                          controller: emailCtrl,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          hintText: "example@email.com",
                                          spaceBetweenText: 10,
                                          title: 'Contact Email',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyTextFormField(
                                          controller: phoneCtrl,
                                          maxLength: 15,
                                          hintText: "Enter phone number",
                                          spaceBetweenText: 10,
                                          title: 'Contact Phone',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Obx(() => MyDropdown(
                                              hintText:
                                                  displayRole ?? "Select Role",
                                              spaceBetweenText: 10,
                                              items: controller.fieldChoices
                                                      .value?.branchRole
                                                      .map((e) => e.label)
                                                      .toList() ??
                                                  [],
                                              title: 'Branch Role',
                                              onChanged: (val) {
                                                final choice = controller
                                                    .fieldChoices
                                                    .value
                                                    ?.branchRole
                                                    .firstWhere(
                                                        (e) => e.label == val);
                                                if (choice != null) {
                                                  setState(() {
                                                    selectedRoleValue =
                                                        choice.value;
                                                    displayRole = choice.label;
                                                  });
                                                }
                                              },
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const MyText(
                                'Upload Branch File (optional)*',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const UploadFile(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyOutlinedButton(
                        textColor: AppColors.darkGrey1,
                        borderColor: null,
                        child: 'Cancel',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 16),
                      MyElevatedButton(
                        icon: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : SvgPicture.asset(
                                "assets/svg/check.svg",
                                colorFilter: const ColorFilter.mode(
                                    AppColors.white, BlendMode.srcIn),
                              ),
                        child: isSaving
                            ? 'Saving...'
                            : (isEditing ? 'Update' : 'Save'),
                        onTap: isSaving
                            ? () {}
                            : () {
                                if (!emailCtrl.text.contains('@') ||
                                    !emailCtrl.text.contains('.')) {
                                  // You can show a snackbar here
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Please enter a valid email address"),
                                        backgroundColor: Colors.red),
                                  );
                                  return;
                                }
                                // Collect Data
                                final data = {
                                  "branch_name": nameCtrl.text,
                                  "country_id": selectedCountryId,
                                  "state_id": selectedStateId,
                                  "lga": lgaCtrl.text,
                                  "office_address": addressCtrl.text,
                                  "operational_status": selectedStatusValue,
                                  "branch_role": selectedRoleValue,
                                  "contact_email": emailCtrl.text,
                                  "contact_phone": phoneCtrl.text,
                                  "manager_id": isEditing
                                      ? widget.branchToEdit!.managerId
                                      : 0,
                                  "is_active": true,
                                  "notes": notesCtrl.text
                                };

                                if (isEditing) {
                                  // UPDATE Logic
                                  controller.updateBranch(
                                      context, widget.branchToEdit!.id, data);
                                } else {
                                  // CREATE Logic
                                  controller.createBranch(context, data);
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
