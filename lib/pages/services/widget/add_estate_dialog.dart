import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/country_state_city_picker.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/pages/services/controller/estate_controller.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
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

  String? _requiredValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Add New Estate',
      subtitle: 'Register a new real estate development.',
      size: DialogSize.lg,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: 'Basic Information',
              child: Column(
                children: [
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
                  const SizedBox(height: 16),
                  Obx(() => Row(
                        children: [
                          Expanded(
                            child: _buildChoiceDropdown(
                              'Estate Type *',
                              _selectedEstateType,
                              _ctrl.estateTypes,
                              (v) => setState(() => _selectedEstateType = v),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildChoiceDropdown(
                              'Estate Status *',
                              _selectedEstateStatus,
                              _ctrl.estateStatuses,
                              (v) => setState(() => _selectedEstateStatus = v),
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 16),
                  MyTextFormField(
                    controller: _developerCtrl,
                    title: 'Developer / Company *',
                    hintText: 'e.g. Bomach Properties Ltd',
                    validator: _requiredValidator,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Location',
              child: Column(
                children: [
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
                  const SizedBox(height: 16),
                  MyTextFormField(
                    controller: _addressCtrl,
                    title: 'Precise Address *',
                    hintText: 'Full address',
                    validator: _requiredValidator,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Pricing & Area',
              child: Row(
                children: [
                  Expanded(
                    child: MyTextFormField(
                      controller: _pricePerSqmCtrl,
                      title: 'Price per sqm *',
                      hintText: '0.00',
                      keyboardType: TextInputType.number,
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
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Description',
              child: MyTextFormField(
                controller: _descriptionCtrl,
                title: 'Description *',
                hintText: 'Describe the estate...',
                maxLines: 3,
                validator: _requiredValidator,
              ),
            ),
          ],
        ),
      ),
      actions: [
        MyOutlinedButton(
          height: 44,
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),
        Obx(() => MyElevatedButton(
              height: 44,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              isLoading: _ctrl.isSaving.value,
              child: 'Save Estate',
              onTap: _ctrl.isSaving.value ? null : _save,
            )),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildChoiceDropdown(
    String label,
    String? value,
    List<Map<String, dynamic>> choices,
    ValueChanged<String?> onChanged,
  ) {
    final items = choices
        .map((c) => c['display_name']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    // Map display name back to raw value on selection.
    String? displayFromValue;
    if (value != null) {
      final match = choices.firstWhere(
        (c) => (c['value']?.toString() ?? '') == value,
        orElse: () => <String, dynamic>{},
      );
      displayFromValue = match['display_name']?.toString();
    }

    return MyDropdown(
      title: label,
      hintText: 'Select ${label.replaceAll(' *', '')}',
      items: items,
      initialSelection: displayFromValue,
      onChanged: (selected) {
        if (selected == null) {
          onChanged(null);
          return;
        }
        final match = choices.firstWhere(
          (c) => (c['display_name']?.toString() ?? '') == selected,
          orElse: () => <String, dynamic>{},
        );
        onChanged(match['value']?.toString());
      },
    );
  }
}
