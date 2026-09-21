import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/components/input/avatar_picker.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/company_controller.dart';

class BaseEditDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isSaving;
  final DialogSize size;

  const BaseEditDialog({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    required this.onSave,
    required this.onCancel,
    required this.isSaving,
    this.size = DialogSize.lg,
  });

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: title,
      subtitle: subtitle,
      size: size,
      body: child,
      actions: [
        TextButton(
          onPressed: isSaving ? null : onCancel,
          child: const Text('Cancel'),
        ),
        MyElevatedButton(
          onTap: isSaving ? null : onSave,
          width: 120,
          child: isSaving ? 'Saving...' : 'Save',
          icon: isSaving
              ? null
              : const Icon(Iconsax.tick_circle, color: Colors.white, size: 18),
        ),
      ],
    );
  }
}

// ==============================================================================
// 1. EDIT PROFILE DIALOG
// ==============================================================================
class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({super.key});
  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final CompanyController controller = Get.find<CompanyController>();
  late TextEditingController nameCtrl,
      emailCtrl,
      phoneCtrl,
      addressCtrl,
      rcCtrl,
      sloganCtrl,
      industryCtrl;

  XFile? _pickedLogo;

  @override
  void initState() {
    super.initState();
    final data = controller.companySettings.value!;
    nameCtrl = TextEditingController(text: data.companyName);
    emailCtrl = TextEditingController(text: data.companyEmail);
    phoneCtrl = TextEditingController(text: data.companyPhone);
    addressCtrl = TextEditingController(text: data.companyAddresses);
    rcCtrl = TextEditingController(text: data.rcNumber);
    sloganCtrl = TextEditingController(text: data.companySlogan);
    industryCtrl = TextEditingController(text: controller.industry.value);
  }

  String _initials() {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return '';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1);
    return '${parts.first[0]}${parts.last[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => BaseEditDialog(
          title: "Edit Company Profile",
          subtitle:
              'Update company identity, registration details, and contact information.',
          isSaving: controller.isSaving.value,
          onCancel: () => Navigator.pop(context),
          onSave: () {
            controller.updateProfileInfo(
              context,
              name: nameCtrl.text,
              email: emailCtrl.text,
              phone: phoneCtrl.text,
              address: addressCtrl.text,
              slogan: sloganCtrl.text,
              industryVal: industryCtrl.text,
              rcNumber: rcCtrl.text.trim(),
              logoFile: _pickedLogo,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogSection(
                title: 'Brand',
                subtitle:
                    'Keep the company identity block consistent across the workspace.',
                child: Center(
                  child: AvatarPicker(
                    label: 'Company Logo',
                    currentImageUrl:
                        controller.companySettings.value?.companyLogo,
                    initials: _initials(),
                    pickedFile: _pickedLogo,
                    size: 112,
                    onPicked: (f) => setState(() => _pickedLogo = f),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildDialogSection(
                title: 'Identity',
                child: Column(
                  children: [
                    MyTextFormField(
                        controller: nameCtrl,
                        title: 'Company Name*',
                        hintText: ''),
                    const SizedBox(height: 20),
                    MyTextFormField(
                        controller: sloganCtrl,
                        title: 'Company Slogan',
                        hintText: '',
                        height: 72,
                        maxLines: 2),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              controller: industryCtrl,
                              title: 'Industry',
                              hintText: '')),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              controller: rcCtrl,
                              title: 'RC Number',
                              hintText: 'e.g. RC1234567')),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildDialogSection(
                title: 'Communications',
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(
                          child: MyTextFormField(
                              controller: emailCtrl,
                              title: 'Company Email',
                              hintText: '')),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyTextFormField(
                              controller: phoneCtrl,
                              title: 'Company Phone',
                              hintText: '')),
                    ]),
                    const SizedBox(height: 20),
                    MyTextFormField(
                        controller: addressCtrl,
                        title: 'Company Address',
                        hintText: 'Building, street, city, state, country',
                        maxLines: 3),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

// ==============================================================================
// 2. EDIT GLOBAL BUSINESS DIALOG
// ==============================================================================
class EditGlobalBusinessDialog extends StatefulWidget {
  const EditGlobalBusinessDialog({super.key});
  @override
  State<EditGlobalBusinessDialog> createState() =>
      _EditGlobalBusinessDialogState();
}

class _EditGlobalBusinessDialogState extends State<EditGlobalBusinessDialog> {
  final CompanyController controller = Get.find<CompanyController>();
  late TextEditingController primaryCtrl, secondaryCtrl, rulesCtrl;
  String selectedCurrency = "NGN";
  String selectedLanguage = "en-GB";
  String selectedTimezone = "WAT";

  String _getCurrencyLabel(String value) {
    final match = controller.fieldChoices.value?.currencies
        .firstWhereOrNull((e) => e.value == value);
    return match?.label ?? value;
  }

  String _getLanguageLabel(String value) {
    final match = controller.fieldChoices.value?.languages
        .firstWhereOrNull((e) => e.value == value);
    return match?.label ?? value;
  }

  @override
  void initState() {
    super.initState();
    final data = controller.companySettings.value!;
    primaryCtrl = TextEditingController(text: data.primaryColorCode);
    secondaryCtrl = TextEditingController(text: data.secondaryColorCode);
    rulesCtrl = TextEditingController(text: data.businessRules);
    if (data.defaultCurrency.isNotEmpty) {
      selectedCurrency = data.defaultCurrency;
    }
    if (data.languagePreference.isNotEmpty) {
      selectedLanguage = data.languagePreference;
    }
    selectedTimezone = controller.timeZone.value;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => BaseEditDialog(
          title: "Edit Global Business Settings",
          subtitle:
              'Control locale defaults, visual branding, approvals, and notifications.',
          isSaving: controller.isSaving.value,
          onCancel: () => Navigator.pop(context),
          onSave: () {
            controller.updateGlobalBusiness(context,
                primaryColor: primaryCtrl.text,
                secondaryColor: secondaryCtrl.text,
                currency: selectedCurrency,
                language: selectedLanguage,
                timeZoneVal: selectedTimezone,
                rules: rulesCtrl.text);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogSection(
                title: 'Brand palette',
                subtitle:
                    'Use restrained brand colors that align with the main product surfaces.',
                child: Row(children: [
                  Expanded(
                      child: MyTextFormField(
                          controller: primaryCtrl,
                          title: 'Primary Color Code',
                          hintText: '#000000')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: MyTextFormField(
                          controller: secondaryCtrl,
                          title: 'Secondary Color Code',
                          hintText: '#FFFFFF')),
                ]),
              ),
              const SizedBox(height: 20),
              _buildDialogSection(
                title: 'Regional defaults',
                child: Column(
                  children: [
                    Row(children: [
                      Expanded(
                          child: MyDropdown(
                              title: 'Default Currency',
                              hintText: _getCurrencyLabel(selectedCurrency),
                              items: controller.fieldChoices.value?.currencies
                                      .map((e) => e.label)
                                      .toList() ??
                                  const ["NGN", "USD", "EUR"],
                              onChanged: (v) {
                                final options =
                                    controller.fieldChoices.value?.currencies ??
                                        const [];
                                for (final option in options) {
                                  if (option.label == v) {
                                    setState(
                                        () => selectedCurrency = option.value);
                                    break;
                                  }
                                }
                              })),
                      const SizedBox(width: 16),
                      Expanded(
                          child: MyDropdown(
                              title: 'Language Preference',
                              hintText: _getLanguageLabel(selectedLanguage),
                              items: controller.fieldChoices.value?.languages
                                      .map((e) => e.label)
                                      .toList() ??
                                  const [
                                    "English UK",
                                    "English US",
                                    "French",
                                    "Spanish"
                                  ],
                              onChanged: (v) {
                                final options =
                                    controller.fieldChoices.value?.languages ??
                                        const [];
                                for (final option in options) {
                                  if (option.label == v) {
                                    setState(
                                        () => selectedLanguage = option.value);
                                    break;
                                  }
                                }
                              })),
                    ]),
                    const SizedBox(height: 20),
                    MyDropdown(
                        title: 'Time Zone',
                        hintText: selectedTimezone,
                        items: const ["WAT", "GMT", "EST"],
                        onChanged: (v) =>
                            setState(() => selectedTimezone = v!)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildDialogSection(
                title: 'Governance',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildToggleSection(
                      "Approvals",
                      ["Single-level", "Multi-level"],
                      controller.approvalType,
                    ),
                    const SizedBox(height: 20),
                    const Text("Notifications",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildCheckPill("Email", controller.notifyEmail),
                        _buildCheckPill("SMS", controller.notifySMS),
                        _buildCheckPill("Push", controller.notifyPush),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("Data Preferences",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildCheckPill("GDPR", controller.dataGdpr),
                        _buildCheckPill("CCPA", controller.dataCcpa),
                      ],
                    ),
                    const SizedBox(height: 20),
                    MyTextFormField(
                        controller: rulesCtrl,
                        title: 'Business Rules',
                        hintText: '',
                        maxLines: 4),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildToggleSection(
      String title, List<String> options, RxString currentVal) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Obx(() => Row(
            children: options.map((opt) {
              bool isSel = currentVal.value == opt;
              return GestureDetector(
                onTap: () => currentVal.value = opt,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primary : AppColors.surfaceMuted,
                    border: Border.all(
                        color:
                            isSel ? AppColors.primary : AppColors.borderSubtle),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(opt,
                      style: TextStyle(
                          color:
                              isSel ? Colors.white : AppColors.textSecondary)),
                ),
              );
            }).toList(),
          ))
    ]);
  }

  Widget _buildCheckPill(String label, RxBool val) {
    return Obx(() => GestureDetector(
          onTap: () => val.value = !val.value,
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: val.value ? AppColors.primary : AppColors.surfaceMuted,
              border: Border.all(
                  color:
                      val.value ? AppColors.primary : AppColors.borderSubtle),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(label,
                style: TextStyle(
                    color: val.value ? Colors.white : AppColors.textSecondary)),
          ),
        ));
  }
}

Widget _buildDialogSection({
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
