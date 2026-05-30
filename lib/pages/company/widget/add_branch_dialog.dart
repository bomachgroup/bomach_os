import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/country_state_city_picker.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/branch_model.dart';
import 'package:bomach_os/src/helper/language_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/branch_controller.dart';
import '../controllers/company_controller.dart';

class AddBranchDialog extends StatefulWidget {
  const AddBranchDialog({super.key, this.branchToEdit});

  final Branch? branchToEdit;

  @override
  State<AddBranchDialog> createState() => _AddBranchDialogState();
}

class _AddBranchDialogState extends State<AddBranchDialog> {
  final BranchController controller = Get.find<BranchController>();
  final CompanyController companyController = Get.find<CompanyController>();
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  String? countryName;
  String? countryCode;
  String _stateValue = '';
  String _cityValue = '';
  String? selectedRole;
  String? selectedStatus;
  int? selectedManagerId;
  String? selectedCurrency;
  String? selectedLanguage;
  bool isActive = true;
  String? displayManager;

  String? _getCurrencyLabel(String? value) {
    if (value == null) return null;
    final match = companyController.fieldChoices.value?.currencies
        .firstWhereOrNull((e) => e.value == value);
    return match?.label ?? value;
  }

  String? _getLanguageLabel(String? value) {
    if (value == null) return null;
    final match = companyController.fieldChoices.value?.languages
        .firstWhereOrNull((e) => e.value == value);
    return match?.label ?? value;
  }

  bool get isEditing => widget.branchToEdit != null;

  @override
  void initState() {
    super.initState();
    if (widget.branchToEdit != null) {
      final branch = widget.branchToEdit!;
      nameCtrl.text = branch.branchName;
      _stateValue = branch.state;
      _cityValue = branch.city;
      addressCtrl.text = branch.officeAddress;
      emailCtrl.text = branch.contactEmail;
      phoneCtrl.text = branch.contactPhone;
      notesCtrl.text = branch.notes;
      countryName = branch.country.isEmpty ? null : branch.country;
      countryCode = branch.countryCode.isEmpty ? null : branch.countryCode;
      selectedRole = branch.branchRole;
      selectedStatus = branch.operationalStatus;
      selectedManagerId = branch.managerId != 0 ? branch.managerId : null;
      selectedCurrency =
          branch.defaultCurrency.isEmpty ? null : branch.defaultCurrency;
      selectedLanguage =
          branch.languagePreference.isEmpty ? null : branch.languagePreference;
      isActive = branch.isActive;
      displayManager =
          branch.managerName.isNotEmpty ? branch.managerName : null;
    } else {
      selectedStatus = 'active';
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    addressCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => DialogScaffold(
          title: isEditing ? 'Edit Branch' : 'Create Branch',
          subtitle: isEditing
              ? 'Update branch operations, management, and location details.'
              : 'Set up a new branch with location, contact, and management details.',
          size: DialogSize.lg,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Basic information',
                  subtitle: 'Define the branch identity and operational role.',
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: nameCtrl,
                              title: 'Branch Name',
                              hintText: 'Enter branch name',
                              validator: (val) => (val == null || val.isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              title: 'Branch ID',
                              hintText: isEditing
                                  ? '${widget.branchToEdit?.id}'
                                  : 'Auto-generated',
                              readOnly: true,
                              fillColor: AppColors.surfaceMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Obx(
                              () => MyDropdown(
                                title: 'Branch Type',
                                hintText:
                                    _getRoleDisplayLabel() ?? 'Select type',
                                items: controller.fieldChoices.value?.branchRole
                                        .map((e) => e.label)
                                        .toList() ??
                                    [],
                                onChanged: (val) {
                                  final options = controller
                                          .fieldChoices.value?.branchRole ??
                                      const <FieldOption>[];
                                  for (final option in options) {
                                    if (option.label == val) {
                                      setState(
                                          () => selectedRole = option.value);
                                      break;
                                    }
                                  }
                                },
                                validator: (_) =>
                                    selectedRole == null ? 'Required' : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Obx(
                              () => MyDropdown(
                                title: 'Operational Status',
                                hintText:
                                    _getStatusDisplayLabel() ?? 'Select status',
                                items: controller
                                        .fieldChoices.value?.operationalStatus
                                        .map((e) => e.label)
                                        .toList() ??
                                    [],
                                onChanged: (val) {
                                  final options = controller.fieldChoices.value
                                          ?.operationalStatus ??
                                      const <FieldOption>[];
                                  for (final option in options) {
                                    if (option.label == val) {
                                      setState(
                                          () => selectedStatus = option.value);
                                      break;
                                    }
                                  }
                                },
                                validator: (_) =>
                                    selectedStatus == null ? 'Required' : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Location',
                  subtitle:
                      'Capture where the branch operates and what defaults it inherits.',
                  child: Column(
                    children: [
                      CountryStateCityPicker(
                        initialCountry: countryName,
                        initialCountryCode: countryCode,
                        initialState: _stateValue.isEmpty ? null : _stateValue,
                        initialCity: _cityValue.isEmpty ? null : _cityValue,
                        onCountryChanged: (name, iso) {
                          setState(() {
                            countryName = name;
                            countryCode = iso;
                          });
                        },
                        onStateChanged: (value) => _stateValue = value,
                        onCityChanged: (value) => _cityValue = value,
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: addressCtrl,
                        title: 'Office Address',
                        hintText: 'Enter full address',
                        validator: (val) =>
                            (val == null || val.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyDropdown(
                              title: 'Default Currency',
                              hintText: _getCurrencyLabel(selectedCurrency) ??
                                  'Inherit',
                              items: companyController
                                      .fieldChoices.value?.currencies
                                      .map((e) => e.label)
                                      .toList() ??
                                  const ['NGN', 'USD', 'EUR', 'GBP'],
                              onChanged: (val) {
                                final options = companyController
                                        .fieldChoices.value?.currencies ??
                                    const [];
                                for (final option in options) {
                                  if (option.label == val) {
                                    setState(
                                        () => selectedCurrency = option.value);
                                    break;
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyDropdown(
                              title: 'Language',
                              hintText: _getLanguageLabel(selectedLanguage) ??
                                  'Inherit',
                              items: companyController
                                      .fieldChoices.value?.languages
                                      .map((e) => e.label)
                                      .toList() ??
                                  const [
                                    'English UK',
                                    'English US',
                                    'French',
                                    'Spanish'
                                  ],
                              onChanged: (val) {
                                final options = companyController
                                        .fieldChoices.value?.languages ??
                                    const [];
                                for (final option in options) {
                                  if (option.label == val) {
                                    setState(
                                        () => selectedLanguage = option.value);
                                    break;
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Contact & management',
                  subtitle:
                      'Assign a manager and define how the branch can be reached.',
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: emailCtrl,
                              title: 'Contact Email',
                              hintText: 'email@example.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) => (val == null || val.isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              controller: phoneCtrl,
                              title: 'Contact Phone',
                              hintText: '+234...',
                              keyboardType: TextInputType.phone,
                              validator: (val) => (val == null || val.isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Obx(
                              () => MyDropdown(
                                title: 'Branch Manager',
                                hintText: displayManager ?? 'Select manager',
                                items: controller.allEmployees
                                    .map((e) => e.fullName)
                                    .toList(),
                                onChanged: (val) {
                                  for (final employee
                                      in controller.allEmployees) {
                                    if (employee.fullName == val) {
                                      setState(() {
                                        selectedManagerId =
                                            int.tryParse(employee.id) ?? 0;
                                        displayManager = val;
                                      });
                                      break;
                                    }
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: AppRadii.brMd,
                                border:
                                    Border.all(color: AppColors.borderSubtle),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Active Status',
                                      style: AppTextStyles.label),
                                  const SizedBox(height: 12),
                                  SwitchListTile(
                                    value: isActive,
                                    onChanged: (val) =>
                                        setState(() => isActive = val),
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    activeThumbColor: AppColors.success,
                                    title: Text(
                                      isActive ? 'Active' : 'Inactive',
                                      style: AppTextStyles.bodyMd.copyWith(
                                        color: isActive
                                            ? AppColors.success
                                            : AppColors.danger,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Notes',
                  child: MyTextFormField(
                    controller: notesCtrl,
                    title: 'Additional Information',
                    hintText: 'Enter any additional notes',
                    maxLines: 3,
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
              width: 120,
              height: 44,
              child: controller.isSaving.value ? 'Saving...' : 'Save',
              onTap: controller.isSaving.value ? null : _onSave,
              icon: controller.isSaving.value
                  ? null
                  : const Icon(Iconsax.tick_circle,
                      size: 18, color: AppColors.textOnPrimary),
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

  String? _getRoleDisplayLabel() {
    if (selectedRole == null) return null;
    final choices =
        controller.fieldChoices.value?.branchRole ?? const <FieldOption>[];
    for (final choice in choices) {
      if (choice.value == selectedRole) return choice.label;
    }
    return selectedRole;
  }

  String? _getStatusDisplayLabel() {
    if (selectedStatus == null) return null;
    final choices = controller.fieldChoices.value?.operationalStatus ??
        const <FieldOption>[];
    for (final choice in choices) {
      if (choice.value == selectedStatus) return choice.label;
    }
    return selectedStatus;
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'branch_name': nameCtrl.text.trim(),
      'country': countryName ?? '',
      'country_code': countryCode ?? '',
      'state': _stateValue.trim(),
      'state_code': '',
      'city': _cityValue.trim(),
      'office_address': addressCtrl.text.trim(),
      'operational_status': selectedStatus,
      'branch_role': selectedRole,
      'contact_email': emailCtrl.text.trim(),
      'contact_phone': phoneCtrl.text.trim(),
      'manager_id': selectedManagerId ?? 0,
      'notes': notesCtrl.text.trim(),
      'is_active': isActive,
      if (selectedCurrency != null) 'default_currency': selectedCurrency,
      if (selectedLanguage != null)
        'language_preference': LanguageHelper.toCode(selectedLanguage),
    };

    if (isEditing) {
      controller.updateBranch(context, widget.branchToEdit!.id, data);
    } else {
      controller.createBranch(context, data);
    }
  }
}
