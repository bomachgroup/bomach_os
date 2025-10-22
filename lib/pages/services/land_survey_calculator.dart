import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

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
      _calculatedCost = (baseCost + areaCost) *
              landTypeMultiplier *
              urgencyMultiplier +
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const MyText(
            'Land Survey Cost Calculator',
            style: AppText.black_500_32,
          ),
          kSizedBox,
          const MyText(
            'Get an instant estimate for your land surveying project',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Colors.black54,
            ),
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
                    // Survey Details Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey4),
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
                          const Text(
                            'Survey Details',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (isWideScreen)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildSurveyTypeDropdown(),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildLandTypeDropdown(),
                                ),
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
                    ),

                    const SizedBox(height: 24),

                    // Additional Services Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey4),
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
                          const Text(
                            'Additional Services',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          CheckboxListTile(
                            title: const Text('CAD Drawing (+₦50,000)'),
                            subtitle: const Text(
                                'Detailed AutoCAD drawings of the surveyed area'),
                            value: _includeCADDrawing,
                            onChanged: (value) {
                              setState(() {
                                _includeCADDrawing = value ?? false;
                              });
                            },
                            activeColor: AppColors.blue,
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            title:
                                const Text('GPS Coordinates (+₦30,000)'),
                            subtitle: const Text(
                                'Precise GPS coordinates for all survey points'),
                            value: _includeCoordinates,
                            onChanged: (value) {
                              setState(() {
                                _includeCoordinates = value ?? false;
                              });
                            },
                            activeColor: AppColors.blue,
                            contentPadding: EdgeInsets.zero,
                          ),
                          CheckboxListTile(
                            title: const Text('Detailed Report (+₦40,000)'),
                            subtitle: const Text(
                                'Comprehensive survey report with analysis'),
                            value: _includeReport,
                            onChanged: (value) {
                              setState(() {
                                _includeReport = value ?? false;
                              });
                            },
                            activeColor: AppColors.blue,
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
                        border: Border.all(color: AppColors.grey4),
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
                          const Text(
                            'Client Information (Optional)',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                          bgColor: AppColors.grey2,
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
                            colors: [AppColors.blue, Color(0xFF0044CC)],
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
                              Icons.calculate_outlined,
                              color: Colors.white,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Estimated Cost',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₦${_calculatedCost.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                              ),
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
                                'This is an estimated cost. Final price may vary based on site inspection.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            MyElevatedButton(
                              child: 'Request Quote',
                              onTap: () {
                                // Navigate to quote request or show dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Quote request sent successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              bgColor: Colors.white,
                              textColor: AppColors.blue,
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

  Widget _buildSurveyTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Survey Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.card),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSurveyType,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              borderRadius: BorderRadius.circular(15),
              items: _surveyTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedSurveyType = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Land Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.card),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLandType,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              borderRadius: BorderRadius.circular(15),
              items: _landTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _selectedLandType = value!;
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
        const Text(
          'Project Urgency',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.card),
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
