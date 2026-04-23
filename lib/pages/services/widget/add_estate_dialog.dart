import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/country_state_city_picker.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/pages/services/controller/estate_controller.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEstateDialog extends StatefulWidget {
  const AddEstateDialog({super.key});

  @override
  State<AddEstateDialog> createState() => _AddEstateDialogState();
}

class _AddEstateDialogState extends State<AddEstateDialog> {
  final _formKey = GlobalKey<FormState>();
  final EstateController _ctrl = Get.find<EstateController>();

  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _developerCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _pricePerSqmCtrl = TextEditingController();
  final _totalAreaCtrl = TextEditingController();

  String? _selectedEstateType;
  String? _selectedEstateStatus;

  String? _countryName = 'Nigeria';
  String? _countryCode = 'NG';
  String _stateValue = '';
  String _cityValue = '';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _developerCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    _pricePerSqmCtrl.dispose();
    _totalAreaCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final payload = {
      'estate_name': _nameCtrl.text.trim(),
      'estate_code': _codeCtrl.text.trim(),
      'estate_type': _selectedEstateType,
      'developer_company_name': _developerCtrl.text.trim(),
      'estate_description': _descriptionCtrl.text.trim(),
      'country_id': 1, // Default Nigeria (backend-managed mapping)
      'country': _countryName ?? '',
      'country_code': _countryCode ?? '',
      'state': _stateValue.trim(),
      'city_town': _cityValue.trim(),
      'precise_address': _addressCtrl.text.trim(),
      'price_per_sqm': double.tryParse(_pricePerSqmCtrl.text) ?? 0,
      'estate_status': _selectedEstateStatus,
      if (_totalAreaCtrl.text.isNotEmpty)
        'total_area': double.tryParse(_totalAreaCtrl.text),
    };

    final success = await _ctrl.createEstate(context, payload);
    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppTextStyles.h3('Add New Estate'),
                    IconButton(
                      icon: const Icon(Iconsax.close_circle),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Form body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Name + Code
                      Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: _nameCtrl,
                              title: 'Estate Name *',
                              hintText: 'e.g. Aso Villa Estate',
                              validator: _requiredValidator,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              controller: _codeCtrl,
                              title: 'Estate Code *',
                              hintText: 'e.g. AVE-001',
                              validator: _requiredValidator,
                            ),
                          ),
                        ],
                      ),
                      kSizedBox,

                      // Row 2: Type + Status (from API choices)
                      Obx(() => Row(
                            children: [
                              Expanded(
                                child: _buildChoiceDropdown(
                                  'Estate Type *',
                                  _selectedEstateType,
                                  _ctrl.estateTypes,
                                  (v) =>
                                      setState(() => _selectedEstateType = v),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildChoiceDropdown(
                                  'Estate Status *',
                                  _selectedEstateStatus,
                                  _ctrl.estateStatuses,
                                  (v) =>
                                      setState(() => _selectedEstateStatus = v),
                                ),
                              ),
                            ],
                          )),
                      kSizedBox,

                      // Developer
                      MyTextFormField(
                        controller: _developerCtrl,
                        title: 'Developer / Company *',
                        hintText: 'e.g. Bomach Properties Ltd',
                        validator: _requiredValidator,
                      ),
                      kSizedBox,

                      // Row 3: Country + State + City
                      CountryStateCityPicker(
                        initialCountry: _countryName,
                        initialCountryCode: _countryCode,
                        cityLabel: 'City / Town',
                        onCountryChanged: (name, iso) {
                          setState(() {
                            _countryName = name;
                            _countryCode = iso;
                          });
                        },
                        onStateChanged: (v) => _stateValue = v,
                        onCityChanged: (v) => _cityValue = v,
                      ),
                      kSizedBox,

                      // Address
                      MyTextFormField(
                        controller: _addressCtrl,
                        title: 'Precise Address *',
                        hintText: 'Full address',
                        validator: _requiredValidator,
                      ),
                      kSizedBox,

                      // Row 4: Price per sqm + Total Area
                      Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              controller: _pricePerSqmCtrl,
                              title: 'Price per sqm *',
                              hintText: '0.00',
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(v) == null) {
                                  return 'Enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MyTextFormField(
                              controller: _totalAreaCtrl,
                              title: 'Total Area (sqm)',
                              hintText: 'Optional',
                            ),
                          ),
                        ],
                      ),
                      kSizedBox,

                      // Description
                      MyTextFormField(
                        controller: _descriptionCtrl,
                        title: 'Description *',
                        hintText: 'Describe the estate...',
                        maxLines: 3,
                        validator: _requiredValidator,
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(height: 1),

              // Footer
              Padding(
                padding: const EdgeInsets.all(16),
                child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyOutlinedButton(
                          textColor: AppColors.neutral500,
                          borderColor: null,
                          child: 'Cancel',
                          onTap: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 12),
                        MyElevatedButton(
                          height: 40,
                          child: _ctrl.isSaving.value
                              ? 'Saving...'
                              : 'Save Estate',
                          onTap: _ctrl.isSaving.value ? null : _save,
                        ),
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return null;
  }

  Widget _buildChoiceDropdown(
    String label,
    String? value,
    List<Map<String, dynamic>> choices,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: AppTextStyles.bodySm(
            label,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.neutral300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: AppTextStyles.bodySm(
                'Select ${label.replaceAll(' *', '')}',
                color: AppColors.neutral500,
              ),
              items: choices.map((c) {
                return DropdownMenuItem<String>(
                  value: c['value']?.toString() ?? '',
                  child: AppTextStyles.bodySm(c['display_name']?.toString() ?? ''),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
