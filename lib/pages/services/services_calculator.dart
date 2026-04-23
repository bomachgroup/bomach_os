import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/app_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const AppText.displayLg('Services Cost Calculator'),
          kSizedBox,
          const AppText.bodyLg(
            'Get instant estimates for various professional services',
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 30),

          // Form
          Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                bool isWideScreen = constraints.maxWidth > 900;

                return Column(
                  children: [
                    // Service Selection Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutral300),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText.h3('Service Details'),
                          const SizedBox(height: 20),
                          if (isWideScreen)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildServiceCategoryDropdown(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildServiceTypeDropdown(),
                                ),
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
                                Expanded(
                                  child: _buildProjectScaleDropdown(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildUrgencyDropdown(),
                                ),
                              ],
                            )
                          else ...[
                            _buildProjectScaleDropdown(),
                            const SizedBox(height: 16),
                            _buildUrgencyDropdown(),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Project Information Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutral300),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText.h3('Project Information'),
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
                    ),

                    const SizedBox(height: 24),

                    // Additional Services Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutral300),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText.h3('Additional Services'),
                          const SizedBox(height: 20),
                          CheckboxListTile(
                            title: const Text('Site Visit (+₦80,000)'),
                            subtitle:
                                const Text('Professional site inspection'),
                            value: _includeSiteVisit,
                            onChanged: (value) {
                              setState(() {
                                _includeSiteVisit = value ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            title: const Text('Detailed Report (+₦60,000)'),
                            subtitle: const Text(
                                'Comprehensive analysis and recommendations'),
                            value: _includeDetailedReport,
                            onChanged: (value) {
                              setState(() {
                                _includeDetailedReport = value ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            title: const Text('Technical Drawings (+₦100,000)'),
                            subtitle: const Text(
                                'CAD drawings and technical illustrations'),
                            value: _includeTechnicalDrawings,
                            onChanged: (value) {
                              setState(() {
                                _includeTechnicalDrawings = value ?? false;
                              });
                            },
                            activeColor: AppColors.primary,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Client Information Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutral300),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppText.h3('Contact Information (Optional)'),
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
                    ),

                    const SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyElevatedButton(
                          child: 'Reset',
                          onTap: _resetForm,
                          bgColor: AppColors.neutral400,
                          textColor: AppColors.black,
                        ),
                        const SizedBox(width: 16),
                        MyElevatedButton(
                          child: 'Calculate Estimate',
                          onTap: _calculateEstimate,
                        ),
                      ],
                    ),

                    // Estimate Result
                    if (_showEstimate) ...[
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryPressed],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 16,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Iconsax.money_tick,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const AppText.bodyLg(
                              'Estimated Cost',
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            const SizedBox(height: 8),
                            AppText.displayMd(
                              '₦${_calculatedCost.toStringAsFixed(2)}',
                              color: AppColors.white,
                            ),
                            const SizedBox(height: 8),
                            AppText.bodyMd(
                              _selectedServiceType,
                              color: AppColors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'This is an estimated cost. Final price will be determined after consultation.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            MyElevatedButton(
                              child: 'Request Detailed Quote',
                              onTap: () {
                                AppToast.success(context, 'Quote request sent successfully!');
                              },
                              bgColor: Colors.white,
                              textColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText.label('Service Category'),
        const SizedBox(height: 10),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedServiceCategory,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              borderRadius: BorderRadius.circular(15),
              items: _servicesByCategory.keys.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedServiceCategory = value!;
                  // Reset service type to first item in new category
                  _selectedServiceType = _currentServiceTypes.first;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText.label('Service Type'),
        const SizedBox(height: 10),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedServiceType,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              borderRadius: BorderRadius.circular(15),
              items: _currentServiceTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedServiceType = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectScaleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText.label('Project Scale'),
        const SizedBox(height: 10),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedProjectScale,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              borderRadius: BorderRadius.circular(15),
              items: _projectScales.map((String scale) {
                return DropdownMenuItem<String>(
                  value: scale,
                  child: Text(scale),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedProjectScale = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgencyDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText.label('Project Urgency'),
        const SizedBox(height: 10),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUrgency,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              borderRadius: BorderRadius.circular(15),
              items: _urgencyLevels.map((String level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedUrgency = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
