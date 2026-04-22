import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/data/country_state_city.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Cascading Country → State → City picker.
///
/// Country is always a searchable modal (via the `country_picker` package).
/// State and city populate from [CountryStateCity.data]. When the selected
/// country has no curated state list, state/city gracefully fall back to a
/// free-text [MyTextFormField] so nothing is blocked for less-common
/// countries.
///
/// All three values are optional inputs — pass what you have (e.g. when
/// editing an existing record) and the widget will restore the cascade.
class CountryStateCityPicker extends StatefulWidget {
  const CountryStateCityPicker({
    super.key,
    this.initialCountry,
    this.initialCountryCode,
    this.initialState,
    this.initialCity,
    this.onCountryChanged,
    this.onStateChanged,
    this.onCityChanged,
    this.cityRequired = true,
    this.countryLabel = 'Country',
    this.stateLabel = 'State / Province',
    this.cityLabel = 'City',
  });

  final String? initialCountry;
  final String? initialCountryCode;
  final String? initialState;
  final String? initialCity;

  /// Called with (name, isoCode). `isoCode` is the 2-letter country code from
  /// `country_picker` (e.g. `NG`, `US`) — useful when the backend stores it.
  final void Function(String name, String isoCode)? onCountryChanged;
  final void Function(String state)? onStateChanged;
  final void Function(String city)? onCityChanged;

  /// When false, the city field's validator will accept an empty value.
  final bool cityRequired;

  final String countryLabel;
  final String stateLabel;
  final String cityLabel;

  @override
  State<CountryStateCityPicker> createState() => _CountryStateCityPickerState();
}

class _CountryStateCityPickerState extends State<CountryStateCityPicker> {
  String? _country;
  String? _countryCode;
  String? _state;
  String? _city;

  // Controllers for fallback text fields (used when the selected country has
  // no curated state/city list).
  late final TextEditingController _stateFallbackCtrl;
  late final TextEditingController _cityFallbackCtrl;

  @override
  void initState() {
    super.initState();
    _country = widget.initialCountry;
    _countryCode = widget.initialCountryCode;
    _state = widget.initialState;
    _city = widget.initialCity;
    _stateFallbackCtrl = TextEditingController(text: _state ?? '');
    _cityFallbackCtrl = TextEditingController(text: _city ?? '');
  }

  @override
  void dispose() {
    _stateFallbackCtrl.dispose();
    _cityFallbackCtrl.dispose();
    super.dispose();
  }

  void _openCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      favorite: const ['NG', 'US', 'GB', 'GH', 'ZA'],
      countryListTheme: CountryListThemeData(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        backgroundColor: AppColors.surface,
        textStyle: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
        searchTextStyle: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
        inputDecoration: InputDecoration(
          hintText: 'Search country',
          hintStyle: AppText.bodyMd.copyWith(color: AppColors.textMuted),
          prefixIcon: const Icon(Iconsax.search_normal_1,
              size: 18, color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.surfaceMuted,
          border: const OutlineInputBorder(
            borderRadius: AppRadii.brMd,
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppRadii.brMd,
            borderSide: BorderSide(color: AppColors.borderSubtle),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: AppRadii.brMd,
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
      onSelect: (c) {
        setState(() {
          _country = c.name;
          _countryCode = c.countryCode;
          // Reset cascade.
          _state = null;
          _city = null;
          _stateFallbackCtrl.clear();
          _cityFallbackCtrl.clear();
        });
        widget.onCountryChanged?.call(c.name, c.countryCode);
        widget.onStateChanged?.call('');
        widget.onCityChanged?.call('');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final states = CountryStateCity.statesFor(_country);
    final cities = CountryStateCity.citiesFor(_country, _state);

    // If the current state isn't in the new country's list, drop it.
    if (states != null && _state != null && !states.contains(_state)) {
      _state = null;
    }
    if (cities != null && _city != null && !cities.contains(_city)) {
      _city = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CountryField(
          label: widget.countryLabel,
          country: _country,
          countryCode: _countryCode,
          onTap: _openCountryPicker,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildStateField(states)),
            const SizedBox(width: 16),
            Expanded(child: _buildCityField(cities)),
          ],
        ),
      ],
    );
  }

  Widget _buildStateField(List<String>? states) {
    if (states == null) {
      // Country either unselected or outside the curated dataset — fall back
      // to free-text so the user isn't blocked.
      return MyTextFormField(
        controller: _stateFallbackCtrl,
        title: widget.stateLabel,
        hintText: _country == null
            ? 'Select a country first'
            : 'Enter state / province',
        readOnly: _country == null,
        onChanged: (v) {
          setState(() => _state = v);
          widget.onStateChanged?.call(v);
        },
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Required' : null,
      );
    }

    return MyDropdown(
      title: widget.stateLabel,
      hintText: 'Select state',
      items: states,
      initialSelection: _state,
      onChanged: (v) {
        setState(() {
          _state = v;
          _city = null;
          _cityFallbackCtrl.clear();
        });
        widget.onStateChanged?.call(v ?? '');
        widget.onCityChanged?.call('');
      },
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _buildCityField(List<String>? cities) {
    if (cities == null) {
      return MyTextFormField(
        controller: _cityFallbackCtrl,
        title: widget.cityLabel,
        hintText: _state == null ? 'Select a state first' : 'Enter city',
        readOnly: _state == null,
        onChanged: (v) {
          setState(() => _city = v);
          widget.onCityChanged?.call(v);
        },
        validator: widget.cityRequired
            ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
            : null,
      );
    }

    return MyDropdown(
      title: widget.cityLabel,
      hintText: 'Select city',
      items: cities,
      initialSelection: _city,
      onChanged: (v) {
        setState(() => _city = v);
        widget.onCityChanged?.call(v ?? '');
      },
      validator: widget.cityRequired
          ? (v) => (v == null || v.isEmpty) ? 'Required' : null
          : null,
    );
  }
}

/// Country selection field — opens the searchable modal from `country_picker`
/// and renders the selected country inline with a subtle flag emoji badge.
class _CountryField extends StatelessWidget {
  const _CountryField({
    required this.label,
    required this.country,
    required this.countryCode,
    required this.onTap,
  });

  final String label;
  final String? country;
  final String? countryCode;
  final VoidCallback onTap;

  String _flag(String code) {
    // Map ISO 3166-1 alpha-2 → regional indicator emoji pair.
    if (code.length != 2) return '🌐';
    return code
        .toUpperCase()
        .split('')
        .map((c) => String.fromCharCode(c.codeUnitAt(0) + 127397))
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: country,
      validator: (_) =>
          (country == null || country!.isEmpty) ? 'Required' : null,
      builder: (state) {
        final hasError = state.hasError;
        final isEmpty = country == null || country!.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppText.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: AppRadii.brMd,
                onTap: () {
                  onTap();
                  // Mark the field touched on tap so required errors clear
                  // the moment the user picks something.
                  state.didChange(country);
                },
                child: Container(
                  height: 50,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadii.brMd,
                    border: Border.all(
                      color:
                          hasError ? AppColors.danger : AppColors.borderSubtle,
                      width: hasError ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (!isEmpty && countryCode != null) ...[
                        Text(_flag(countryCode!),
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 10),
                      ] else ...[
                        const Icon(Iconsax.global,
                            size: 18, color: AppColors.textMuted),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: Text(
                          isEmpty ? 'Select country' : country!,
                          style: AppText.bodyMd.copyWith(
                            color: isEmpty
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Iconsax.arrow_down_1,
                          size: 16, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                child: Text(
                  state.errorText ?? '',
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
