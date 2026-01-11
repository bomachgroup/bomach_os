import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/input/upload_file.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../controller.dart';

class EditCompanyDialog extends StatefulWidget {
  const EditCompanyDialog({super.key});

  @override
  State<EditCompanyDialog> createState() => _EditCompanyDialogState();
}

class _EditCompanyDialogState extends State<EditCompanyDialog> {
  final CompanyController controller = Get.find<CompanyController>();

  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController addressCtrl;
  late TextEditingController rcCtrl;
  late TextEditingController primaryColorCtrl;
  late TextEditingController secondaryColorCtrl;
  late TextEditingController sloganCtrl;
  late TextEditingController rulesCtrl;

  String selectedCurrency = "NGN Naira";
  String selectedLanguage = "English UK";

  @override
  void initState() {
    super.initState();
    final data = controller.companySettings.value!;

    nameCtrl = TextEditingController(text: data.companyName);
    emailCtrl = TextEditingController(text: data.companyEmail);
    phoneCtrl = TextEditingController(text: data.companyPhone);
    addressCtrl = TextEditingController(text: data.companyAddresses);
    rcCtrl = TextEditingController(text: data.rcNumber);
    primaryColorCtrl = TextEditingController(text: data.primaryColorCode);
    secondaryColorCtrl = TextEditingController(text: data.secondaryColorCode);
    sloganCtrl = TextEditingController(text: data.companySlogan);
    rulesCtrl = TextEditingController(text: data.businessRules);

    if (data.defaultCurrency.isNotEmpty)
      selectedCurrency = data.defaultCurrency;
    if (data.languagePreference.isNotEmpty)
      selectedLanguage = data.languagePreference;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    rcCtrl.dispose();
    primaryColorCtrl.dispose();
    secondaryColorCtrl.dispose();
    sloganCtrl.dispose();
    rulesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Obx(() {
          final bool isSaving = controller.isSaving.value;

          return IgnorePointer(
            ignoring: isSaving,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const MyText(
                        'Edit Company Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed:
                            isSaving ? null : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Form fields
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
                              MyTextFormField(
                                controller: nameCtrl,
                                hintText: 'Bomach Group of Companies',
                                spaceBetweenText: 10,
                                title: 'Company Name*',
                              ),
                              const SizedBox(height: 24),
                              MyTextFormField(
                                controller: emailCtrl,
                                hintText: 'bomachgroups@gmail.com',
                                spaceBetweenText: 10,
                                title: 'Company Email',
                              ),
                              const SizedBox(height: 24),
                              MyTextFormField(
                                controller: phoneCtrl,
                                hintText: '+2341234567890',
                                spaceBetweenText: 10,
                                title: 'Company Phone',
                              ),
                              const SizedBox(height: 24),
                              MyTextFormField(
                                controller: addressCtrl,
                                hintText: 'Enter addresses...',
                                spaceBetweenText: 10,
                                maxLines: 4,
                                title: 'Company Addresses',
                              ),
                              const SizedBox(height: 24),
                              const MyText(
                                'Company Logo',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              const UploadFile(),
                              const SizedBox(height: 24),
                              MyTextFormField(
                                controller: rcCtrl,
                                hintText: 'JFL488L03LHFR',
                                spaceBetweenText: 10,
                                title: 'RC Number',
                                readOnly: true, // User cannot edit this
                                fillColor: Colors.grey.shade100,
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
                                          controller: primaryColorCtrl,
                                          hintText: '#FE0000',
                                          spaceBetweenText: 10,
                                          title: 'Primary Color Code',
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
                                          controller: secondaryColorCtrl,
                                          spaceBetweenText: 10,
                                          hintText: "#3E4094",
                                          title: 'Secondary Color Code',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              MyTextFormField(
                                controller: sloganCtrl,
                                hintText: 'Company Slogan',
                                spaceBetweenText: 10,
                                title: 'Company Slogan',
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyDropdown(
                                          hintText: selectedCurrency,
                                          items: const [
                                            "NGN Naira",
                                            "USD Dollar",
                                            "EUR Euro"
                                          ],
                                          spaceBetweenText: 10,
                                          title: 'Default Currency',
                                          onChanged: (val) {
                                            if (val != null)
                                              setState(
                                                  () => selectedCurrency = val);
                                          },
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
                                        MyDropdown(
                                          hintText: selectedLanguage,
                                          items: const [
                                            "English UK",
                                            "English US",
                                            "French"
                                          ],
                                          spaceBetweenText: 10,
                                          title: 'Language Preference',
                                          onChanged: (val) {
                                            if (val != null)
                                              setState(
                                                  () => selectedLanguage = val);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyTextFormField(
                                    controller: rulesCtrl,
                                    maxLines: 4,
                                    hintText: 'Enter business rules...',
                                    spaceBetweenText: 10,
                                    title: 'Business Rules',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
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
                        onTap: isSaving
                            ? () {}
                            : () {
                                controller.updateCompanyProfile(
                                  context,
                                  name: nameCtrl.text,
                                  email: emailCtrl.text,
                                  phone: phoneCtrl.text,
                                  address: addressCtrl.text,
                                  rcNumber: rcCtrl.text,
                                  primaryColor: primaryColorCtrl.text,
                                  secondaryColor: secondaryColorCtrl.text,
                                  slogan: sloganCtrl.text,
                                  currency: selectedCurrency,
                                  language: selectedLanguage,
                                  rules: rulesCtrl.text,
                                );
                              },
                        icon: isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2))
                            : SvgPicture.asset(
                                "assets/svg/check.svg",
                                colorFilter: const ColorFilter.mode(
                                    AppColors.white, BlendMode.srcIn),
                              ),
                        child: isSaving ? 'Saving...' : 'Save',
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
