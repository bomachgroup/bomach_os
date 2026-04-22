import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/input/avatar_picker.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/company_controller.dart';

// Wrapper to standardise the Dialog look
class BaseEditDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isSaving;

  const BaseEditDialog({
    super.key,
    required this.title,
    required this.child,
    required this.onSave,
    required this.onCancel,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 900),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle, color: Colors.red),
                    onPressed: isSaving ? null : onCancel,
                    style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEEEE)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body
            Expanded(
                child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24), child: child)),

            // Footer
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: onCancel,
                      child: const Text("Cancel",
                          style: TextStyle(color: Colors.grey))),
                  const SizedBox(width: 16),
                  MyElevatedButton(
                    onTap: isSaving ? () {} : onSave,
                    width: 120,
                    child: isSaving ? 'Saving...' : 'Save',
                    icon: isSaving
                        ? null
                        : const Icon(Iconsax.tick_circle,
                            color: Colors.white, size: 18),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
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
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
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
              const SizedBox(height: 24),
              MyTextFormField(
                  controller: nameCtrl, title: 'Company Name*', hintText: ''),
              const SizedBox(height: 20),
              MyTextFormField(
                  controller: sloganCtrl,
                  title: 'Company Slogan',
                  hintText: ''),
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
                        controller: emailCtrl,
                        title: 'Company Email',
                        hintText: '')),
              ]),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                    child: MyTextFormField(
                        controller: phoneCtrl,
                        title: 'Company Phone',
                        hintText: '')),
                const SizedBox(width: 16),
                Expanded(
                    child: MyTextFormField(
                        controller: rcCtrl,
                        title: 'RC Number',
                        hintText: 'e.g. RC1234567')),
              ]),
              const SizedBox(height: 20),
              MyTextFormField(
                  controller: addressCtrl,
                  title: 'Company Address',
                  hintText: 'Building, street, city, state, country',
                  maxLines: 3),
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
  String selectedLanguage = "English (Nigeria)";
  String selectedTimezone = "WAT";

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
              Row(children: [
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
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                    child: MyDropdown(
                        title: 'Default Currency',
                        hintText: selectedCurrency,
                        items: const ["NGN", "USD", "EUR"],
                        onChanged: (v) =>
                            setState(() => selectedCurrency = v!))),
                const SizedBox(width: 16),
                Expanded(
                    child: MyDropdown(
                        title: 'Language Preference',
                        hintText: selectedLanguage,
                        items: const [
                          "English (Nigeria)",
                          "English (UK)",
                          "French"
                        ],
                        onChanged: (v) =>
                            setState(() => selectedLanguage = v!))),
              ]),
              const SizedBox(height: 20),
              MyDropdown(
                  title: 'Time Zone',
                  hintText: selectedTimezone,
                  items: const ["WAT", "GMT", "EST"],
                  onChanged: (v) => setState(() => selectedTimezone = v!)),
              const SizedBox(height: 20),

              // Toggles
              _buildToggleSection("Approvals", ["Single-level", "Multi-level"],
                  controller.approvalType),
              const SizedBox(height: 20),

              const Text("Notifications",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(children: [
                _buildCheckPill("Email", controller.notifyEmail),
                _buildCheckPill("SMS", controller.notifySMS),
                _buildCheckPill("Push", controller.notifyPush),
              ]),
              const SizedBox(height: 20),

              const Text("Data Preferences",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(children: [
                _buildCheckPill("GDPR", controller.dataGdpr),
                _buildCheckPill("CCPA", controller.dataCcpa),
              ]),

              const SizedBox(height: 20),
              MyTextFormField(
                  controller: rulesCtrl,
                  title: 'Business Rules',
                  hintText: '',
                  maxLines: 4),
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
                    color: isSel ? AppColors.primary : Colors.white,
                    border: Border.all(
                        color: isSel
                            ? AppColors.primary
                            : AppColors.neutral200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(opt,
                      style:
                          TextStyle(color: isSel ? Colors.white : Colors.grey)),
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
              color: val.value ? AppColors.primary : Colors.white,
              border: Border.all(
                  color: val.value
                      ? AppColors.primary
                      : AppColors.neutral200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(label,
                style:
                    TextStyle(color: val.value ? Colors.white : Colors.grey)),
          ),
        ));
  }
}
