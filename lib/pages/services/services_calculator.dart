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

class ServicesCalculatorPage extends StatefulWidget {
  const ServicesCalculatorPage({super.key});

  @override
  State<ServicesCalculatorPage> createState() => _ServicesCalculatorPageState();
}

class _ServicesCalculatorPageState extends State<ServicesCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _projectDescriptionController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _timelineController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();
  final TextEditingController _clientPhoneController = TextEditingController();

  String _selectedServiceCategory = 'Engineering Services';
  String _selectedServiceType = 'Geotechnical Investigation';
  String _selectedProjectScale = 'Small';
  String _selectedUrgency = 'Standard (3-4 weeks)';
  bool _includeSiteVisit = true;
  bool _includeDetailedReport = true;
  bool _includeTechnicalDrawings = false;

  double _calculatedCost = 0.0;
  bool _showEstimate = false;

  final Map<String, List<String>> _servicesByCategory = {
    'Engineering Services': [
      'Geotechnical Investigation',
      'Structural Engineering',
      'Environmental Impact Assessment',
      'Foundation Design',
      'Soil Testing',
      'Construction Supervision',
    ],
    'Real Estate Services': [
      'Property Valuation',
      'Market Analysis',
      'Property Management',
      'Investment Consultation',
      'Due Diligence',
    ],
    'Architectural Services': [
      'Architectural Design',
      'Building Plans',
      '3D Visualization',
      'Interior Design',
      'Renovation Planning',
    ],
    'Consulting Services': [
      'Project Management',
      'Feasibility Studies',
      'Risk Assessment',
      'Quality Control',
      'Technical Advisory',
    ],
    'Documentation Services': [
      'Title Documentation',
      'Permit Processing',
      'Compliance Documentation',
      'Technical Reports',
      'Certification Services',
    ],
  };

  final List<String> _projectScales = [
    'Small',
    'Medium',
    'Large',
    'Enterprise',
  ];

  final List<String> _urgencyLevels = [
    'Standard (3-4 weeks)',
    'Priority (2 weeks)',
    'Rush (1 week)',
    'Emergency (3-5 days)',
  ];

  @override
  void dispose() {
    _projectDescriptionController.dispose();
    _locationController.dispose();
    _timelineController.dispose();
    _clientNameController.dispose();
    _clientEmailController.dispose();
    _clientPhoneController.dispose();
    super.dispose();
  }

  List<String> get _currentServiceTypes {
    return _servicesByCategory[_selectedServiceCategory] ?? [];
  }

  void _calculateEstimate() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      double baseCost = 0;

      // Base cost based on service type
      switch (_selectedServiceType) {
        case 'Geotechnical Investigation':
          baseCost = 300000;
          break;
        case 'Structural Engineering':
          baseCost = 400000;
          break;
        case 'Environmental Impact Assessment':
          baseCost = 650000;
          break;
        case 'Foundation Design':
          baseCost = 250000;
          break;
        case 'Soil Testing':
          baseCost = 150000;
          break;
        case 'Construction Supervision':
          baseCost = 500000;
          break;
        case 'Property Valuation':
          baseCost = 180000;
          break;
        case 'Market Analysis':
          baseCost = 200000;
          break;
        case 'Property Management':
          baseCost = 350000;
          break;
        case 'Investment Consultation':
          baseCost = 280000;
          break;
        case 'Due Diligence':
          baseCost = 400000;
          break;
        case 'Architectural Design':
          baseCost = 600000;
          break;
        case 'Building Plans':
          baseCost = 350000;
          break;
        case '3D Visualization':
          baseCost = 200000;
          break;
        case 'Interior Design':
          baseCost = 450000;
          break;
        case 'Renovation Planning':
          baseCost = 300000;
          break;
        case 'Project Management':
          baseCost = 550000;
          break;
        case 'Feasibility Studies':
          baseCost = 400000;
          break;
        case 'Risk Assessment':
          baseCost = 320000;
          break;
        case 'Quality Control':
          baseCost = 280000;
          break;
        case 'Technical Advisory':
          baseCost = 350000;
          break;
        case 'Title Documentation':
          baseCost = 120000;
          break;
        case 'Permit Processing':
          baseCost = 100000;
          break;
        case 'Compliance Documentation':
          baseCost = 180000;
          break;
        case 'Technical Reports':
          baseCost = 200000;
          break;
        case 'Certification Services':
          baseCost = 150000;
          break;
        default:
          baseCost = 250000;
      }

      // Project scale multiplier
      double scaleMultiplier = 1.0;
      switch (_selectedProjectScale) {
        case 'Small':
          scaleMultiplier = 1.0;
          break;
        case 'Medium':
          scaleMultiplier = 1.5;
          break;
        case 'Large':
          scaleMultiplier = 2.5;
          break;
        case 'Enterprise':
          scaleMultiplier = 4.0;
          break;
      }

      // Urgency multiplier
      double urgencyMultiplier = 1.0;
      switch (_selectedUrgency) {
        case 'Standard (3-4 weeks)':
          urgencyMultiplier = 1.0;
          break;
        case 'Priority (2 weeks)':
          urgencyMultiplier = 1.3;
          break;
        case 'Rush (1 week)':
          urgencyMultiplier = 1.7;
          break;
        case 'Emergency (3-5 days)':
          urgencyMultiplier = 2.2;
          break;
      }

      // Additional services
      double additionalCosts = 0;
      if (_includeSiteVisit) additionalCosts += 80000;
      if (_includeDetailedReport) additionalCosts += 60000;
      if (_includeTechnicalDrawings) additionalCosts += 100000;

      // Final calculation
      _calculatedCost =
          (baseCost * scaleMultiplier * urgencyMultiplier) + additionalCosts;

      setState(() {
        _showEstimate = true;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _projectDescriptionController.clear();
    _locationController.clear();
    _timelineController.clear();
    _clientNameController.clear();
    _clientEmailController.clear();
    _clientPhoneController.clear();
    setState(() {
      _selectedServiceCategory = 'Engineering Services';
      _selectedServiceType = 'Geotechnical Investigation';
      _selectedProjectScale = 'Small';
      _selectedUrgency = 'Standard (3-4 weeks)';
      _includeSiteVisit = true;
      _includeDetailedReport = true;
      _includeTechnicalDrawings = false;
      _calculatedCost = 0.0;
      _showEstimate = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1200,
      header: const PageHeader(
        title: 'Services Cost Calculator',
        subtitle: 'Get instant estimates for various professional services.',
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
                  _buildServiceDetailsCard(isWideScreen),
                  const SizedBox(height: 16),
                  _buildProjectInfoCard(isWideScreen),
                  const SizedBox(height: 16),
                  _buildAdditionalServicesCard(),
                  const SizedBox(height: 16),
                  _buildContactInfoCard(isWideScreen),
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

  Widget _buildServiceDetailsCard(bool isWideScreen) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Service Details',
              icon: Iconsax.briefcase,
              subtitle: 'Pick the service, scale and desired turnaround.'),
          const SizedBox(height: 20),
          if (isWideScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildServiceCategoryDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildServiceTypeDropdown()),
              ],
            )
          else ...[
            _buildServiceCategoryDropdown(),
            const SizedBox(height: 16),
            _buildServiceTypeDropdown(),
          ],
          const SizedBox(height: 16),
          if (isWideScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildProjectScaleDropdown()),
                const SizedBox(width: 16),
                Expanded(child: _buildUrgencyDropdown()),
              ],
            )
          else ...[
            _buildProjectScaleDropdown(),
            const SizedBox(height: 16),
            _buildUrgencyDropdown(),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectInfoCard(bool isWideScreen) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Project Information',
              icon: Iconsax.document,
              subtitle: 'Tell us about the project scope and location.'),
          const SizedBox(height: 20),
          MyTextFormField(
            controller: _projectDescriptionController,
            title: 'Project Description',
            hintText: 'Briefly describe your project',
            maxLines: 4,
            height: 120,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter project description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          if (isWideScreen)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MyTextFormField(
                    controller: _locationController,
                    title: 'Location',
                    hintText: 'Enter project location',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter location';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MyTextFormField(
                    controller: _timelineController,
                    title: 'Desired Timeline',
                    hintText: 'e.g., 3 months',
                  ),
                ),
              ],
            )
          else ...[
            MyTextFormField(
              controller: _locationController,
              title: 'Location',
              hintText: 'Enter project location',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            MyTextFormField(
              controller: _timelineController,
              title: 'Desired Timeline',
              hintText: 'e.g., 3 months',
            ),
          ],
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
            title: 'Site Visit',
            subtitle: 'Professional site inspection',
            price: '+N80,000',
            value: _includeSiteVisit,
            onChanged: (value) {
              setState(() {
                _includeSiteVisit = value ?? false;
              });
            },
          ),
          const SizedBox(height: 10),
          _buildServiceOption(
            title: 'Detailed Report',
            subtitle: 'Comprehensive analysis and recommendations',
            price: '+N60,000',
            value: _includeDetailedReport,
            onChanged: (value) {
              setState(() {
                _includeDetailedReport = value ?? false;
              });
            },
          ),
          const SizedBox(height: 10),
          _buildServiceOption(
            title: 'Technical Drawings',
            subtitle: 'CAD drawings and technical illustrations',
            price: '+N100,000',
            value: _includeTechnicalDrawings,
            onChanged: (value) {
              setState(() {
                _includeTechnicalDrawings = value ?? false;
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

  Widget _buildContactInfoCard(bool isWideScreen) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Contact Information (Optional)',
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
                child: const Icon(Iconsax.money_tick,
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
                    const SizedBox(height: 4),
                    Text(
                      _selectedServiceType,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textSecondary),
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
                  'This is an estimated cost. Final price will be determined after consultation.',
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
              child: 'Request Detailed Quote',
              height: 42,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              onTap: () {
                AppToast.success(
                    context, 'Quote request sent successfully!');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategoryDropdown() {
    return MyDropdown(
      title: 'Service Category',
      hintText: 'Select service category',
      items: _servicesByCategory.keys.toList(),
      initialSelection: _selectedServiceCategory,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedServiceCategory = value;
            // Reset service type to first item in new category
            _selectedServiceType = _currentServiceTypes.first;
          });
        }
      },
    );
  }

  Widget _buildServiceTypeDropdown() {
    return MyDropdown(
      key: ValueKey('service-type-$_selectedServiceCategory'),
      title: 'Service Type',
      hintText: 'Select service type',
      items: _currentServiceTypes,
      initialSelection: _selectedServiceType,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedServiceType = value;
          });
        }
      },
    );
  }

  Widget _buildProjectScaleDropdown() {
    return MyDropdown(
      title: 'Project Scale',
      hintText: 'Select project scale',
      items: _projectScales,
      initialSelection: _selectedProjectScale,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedProjectScale = value;
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
