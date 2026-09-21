import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LandSurveyCalculatorPage extends StatefulWidget {
  const LandSurveyCalculatorPage({super.key});

  @override
  State<LandSurveyCalculatorPage> createState() =>
      _LandSurveyCalculatorPageState();
}

class _LandSurveyCalculatorPageState extends State<LandSurveyCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();
  final TextEditingController _clientPhoneController = TextEditingController();

  String _selectedSurveyType = 'Topographic Survey';
  String _selectedLandType = 'Urban';
  String _selectedUrgency = 'Standard (2-3 weeks)';
  bool _includeCADDrawing = false;
  bool _includeCoordinates = false;
  bool _includeReport = true;

  double _calculatedCost = 0.0;
  bool _showEstimate = false;

  final List<String> _surveyTypes = [
    'Topographic Survey',
    'Boundary Survey',
    'Construction Survey',
    'Subdivision Survey',
    'As-Built Survey',
    'ALTA/NSPS Survey',
    'Hydrographic Survey',
    'Cadastral Survey',
  ];

  final List<String> _landTypes = [
    'Urban',
    'Rural',
    'Industrial',
    'Agricultural',
    'Residential',
    'Commercial',
  ];

  final List<String> _urgencyLevels = [
    'Standard (2-3 weeks)',
    'Rush (1 week)',
    'Emergency (3-5 days)',
  ];

  @override
  void dispose() {
    _areaController.dispose();
    _locationController.dispose();
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    super.dispose();
  }

  void _calculateEstimate() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      double area = double.tryParse(_areaController.text) ?? 0;
      double baseCost = 0;

      // Base cost calculation based on survey type
      switch (_selectedSurveyType) {
        case 'Topographic Survey':
          baseCost = 150000;
          break;
        case 'Boundary Survey':
          baseCost = 120000;
          break;
        case 'Construction Survey':
          baseCost = 200000;
          break;
        case 'Subdivision Survey':
          baseCost = 180000;
          break;
        case 'As-Built Survey':
          baseCost = 160000;
          break;
        case 'ALTA/NSPS Survey':
          baseCost = 250000;
          break;
        case 'Hydrographic Survey':
          baseCost = 300000;
          break;
        case 'Cadastral Survey':
          baseCost = 140000;
          break;
      }

      // Area-based calculation (per square meter)
      double areaCost = area * 50;

      // Land type multiplier
      double landTypeMultiplier = 1.0;
      switch (_selectedLandType) {
        case 'Urban':
          landTypeMultiplier = 1.2;
          break;
        case 'Rural':
          landTypeMultiplier = 1.0;
          break;
        case 'Industrial':
          landTypeMultiplier = 1.3;
          break;
        case 'Agricultural':
          landTypeMultiplier = 0.9;
          break;
        case 'Residential':
          landTypeMultiplier = 1.1;
          break;
        case 'Commercial':
          landTypeMultiplier = 1.4;
          break;
      }

      // Urgency multiplier
      double urgencyMultiplier = 1.0;
      switch (_selectedUrgency) {
        case 'Standard (2-3 weeks)':
          urgencyMultiplier = 1.0;
          break;
        case 'Rush (1 week)':
          urgencyMultiplier = 1.5;
          break;
        case 'Emergency (3-5 days)':
          urgencyMultiplier = 2.0;
          break;
      }

      // Additional services
      double additionalCosts = 0;
      if (_includeCADDrawing) additionalCosts += 50000;
      if (_includeCoordinates) additionalCosts += 30000;
      if (_includeReport) additionalCosts += 40000;

      // Final calculation
      _calculatedCost =
          (baseCost + areaCost) * landTypeMultiplier * urgencyMultiplier +
              additionalCosts;

      setState(() {
        _showEstimate = true;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _areaController.clear();
    _locationController.clear();
    _clientNameController.clear();
    _clientEmailController.clear();
    _clientPhoneController.clear();
    setState(() {
      _selectedSurveyType = 'Topographic Survey';
      _selectedLandType = 'Urban';
      _selectedUrgency = 'Standard (2-3 weeks)';
      _includeCADDrawing = false;
      _includeCoordinates = false;
      _includeReport = true;
      _calculatedCost = 0.0;
      _showEstimate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1200,
      header: const PageHeader(
        title: 'Land Survey Cost Calculator',
        subtitle: 'Get an instant estimate for your land surveying project.',
      ),
      children: [
        Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWideScreen = constraints.maxWidth > 900;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSurveyDetailsCard(isWideScreen),
                  const SizedBox(height: 16),
                  _buildAdditionalServicesCard(),
                  const SizedBox(height: 16),
                  _buildClientInfoCard(isWideScreen),
                  const SizedBox(height: 20),
                  _buildActionRow(),
                  if (_showEstimate) ...[
                    const SizedBox(height: 20),
                    _buildEstimateResult(),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, {IconData? icon, String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTextStyles.h3),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyDetailsCard(bool isWideScreen) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Survey Details',
              icon: Iconsax.document_text,
              subtitle: 'Select the survey type, land category and area.'),
          const SizedBox(height: 20),
          if (isWideScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildSurveyTypeDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildLandTypeDropdown()),
              ],
            )
          else ...[
            _buildSurveyTypeDropdown(),
            const SizedBox(height: 16),
            _buildLandTypeDropdown(),
          ],
          const SizedBox(height: 16),
          if (isWideScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MyTextFormField(
                    controller: _areaController,
                    title: 'Land Area (sq. meters)',
                    hintText: 'Enter area in square meters',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter land area';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyTextFormField(
                    controller: _locationController,
                    title: 'Location',
                    hintText: 'Enter location/address',
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter location';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            )
          else ...[
            MyTextFormField(
              controller: _areaController,
              title: 'Land Area (sq. meters)',
              hintText: 'Enter area in square meters',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter land area';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            MyTextFormField(
              controller: _locationController,
              title: 'Location',
              hintText: 'Enter location/address',
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter location';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 16),
          _buildUrgencyDropdown(),
        ],
      ),
    );
  }

  Widget _buildAdditionalServicesCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Additional Services',
              icon: Iconsax.add_square,
              subtitle: 'Add optional deliverables to your estimate.'),
          const SizedBox(height: 12),
          _buildServiceOption(
            title: 'CAD Drawing',
            subtitle: 'Detailed AutoCAD drawings of the surveyed area',
            price: '+N50,000',
            value: _includeCADDrawing,
            onChanged: (value) {
              setState(() {
                _includeCADDrawing = value ?? false;
              });
            },
          ),
          const SizedBox(height: 10),
          _buildServiceOption(
            title: 'GPS Coordinates',
            subtitle: 'Precise GPS coordinates for all survey points',
            price: '+N30,000',
            value: _includeCoordinates,
            onChanged: (value) {
              setState(() {
                _includeCoordinates = value ?? false;
              });
            },
          ),
          const SizedBox(height: 10),
          _buildServiceOption(
            title: 'Detailed Report',
            subtitle: 'Comprehensive survey report with analysis',
            price: '+N40,000',
            value: _includeReport,
            onChanged: (value) {
              setState(() {
                _includeReport = value ?? false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOption({
    required String title,
    required String subtitle,
    required String price,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: AppRadii.brMd,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: value ? AppColors.primarySubtle : AppColors.surfaceMuted,
          borderRadius: AppRadii.brMd,
          border: Border.all(
            color: value ? AppColors.primarySoft : AppColors.borderSubtle,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTextStyles.label),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              price,
              style: AppTextStyles.label.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfoCard(bool isWideScreen) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Client Information (Optional)',
              icon: Iconsax.user,
              subtitle: 'We will use this to follow up on your quote.'),
          const SizedBox(height: 20),
          MyTextFormField(
            controller: _clientNameController,
            title: 'Full Name',
            hintText: 'Enter your full name',
          ),
          const SizedBox(height: 16),
          if (isWideScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MyTextFormField(
                    controller: _clientEmailController,
                    title: 'Email Address',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyTextFormField(
                    controller: _clientPhoneController,
                    title: 'Phone Number',
                    hintText: 'Enter your phone number',
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            )
          else ...[
            MyTextFormField(
              controller: _clientEmailController,
              title: 'Email Address',
              hintText: 'Enter your email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            MyTextFormField(
              controller: _clientPhoneController,
              title: 'Phone Number',
              hintText: 'Enter your phone number',
              keyboardType: TextInputType.phone,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MyOutlinedButton(
          child: 'Reset',
          onTap: _resetForm,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        const SizedBox(width: 12),
        MyElevatedButton(
          child: 'Calculate Estimate',
          onTap: _calculateEstimate,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: const Icon(Iconsax.calculator,
              color: AppColors.textOnPrimary, size: 16),
        ),
      ],
    );
  }

  Widget _buildEstimateResult() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      elevation: AppCardElevation.md,
      backgroundColor: AppColors.primarySubtle,
      borderColor: AppColors.primarySoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.calculator,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Estimated Cost',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'N${_calculatedCost.toStringAsFixed(2)}',
                      style: AppTextStyles.displayMd
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.primarySoft),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Iconsax.info_circle,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This is an estimated cost. Final price may vary based on site inspection.',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: MyElevatedButton(
              child: 'Request Quote',
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              onTap: () {
                AppToast.success(context, 'Quote request sent successfully!');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyTypeDropdown() {
    return MyDropdown(
      title: 'Survey Type',
      hintText: 'Select survey type',
      items: _surveyTypes,
      initialSelection: _selectedSurveyType,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedSurveyType = value;
          });
        }
      },
    );
  }

  Widget _buildLandTypeDropdown() {
    return MyDropdown(
      title: 'Land Type',
      hintText: 'Select land type',
      items: _landTypes,
      initialSelection: _selectedLandType,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedLandType = value;
          });
        }
      },
    );
  }

  Widget _buildUrgencyDropdown() {
    return MyDropdown(
      title: 'Project Urgency',
      hintText: 'Select urgency',
      items: _urgencyLevels,
      initialSelection: _selectedUrgency,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedUrgency = value;
          });
        }
      },
    );
  }
}
