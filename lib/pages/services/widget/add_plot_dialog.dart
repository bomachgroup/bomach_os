import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/input/upload_file.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/models/estate_models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AddPlotDialog extends StatefulWidget {
  final Estate estate;
  final Function(EstatePlot) onPlotAdded;

  const AddPlotDialog({
    super.key,
    required this.estate,
    required this.onPlotAdded,
  });

  @override
  State<AddPlotDialog> createState() => _AddPlotDialogState();
}

class _AddPlotDialogState extends State<AddPlotDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _showOptionalFields = false;

  // Form controllers
  final _plotNumberController = TextEditingController();
  final _blockNumberController = TextEditingController();
  final _sizeController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _buyerNameController = TextEditingController();
  final _buyerPhoneController = TextEditingController();
  final _buyerEmailController = TextEditingController();
  final _surveyPlanController = TextEditingController();

  String _selectedPlotType = 'Residential';
  String _selectedStatus = 'Available';

  @override
  void dispose() {
    _plotNumberController.dispose();
    _blockNumberController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _buyerNameController.dispose();
    _buyerPhoneController.dispose();
    _buyerEmailController.dispose();
    _surveyPlanController.dispose();
    super.dispose();
  }

  void _savePlot() {
    if (_formKey.currentState?.validate() ?? false) {
      final plot = EstatePlot(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        estateId: widget.estate.id.toString(),
        estateName: widget.estate.name,
        plotNumber: _plotNumberController.text,
        size: double.tryParse(_sizeController.text) ?? 0,
        plotType: _selectedPlotType,
        status: _selectedStatus,
        price: double.tryParse(_priceController.text) ?? 0,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        blockNumber: _blockNumberController.text.isEmpty
            ? null
            : _blockNumberController.text,
        buyerName: _buyerNameController.text.isEmpty
            ? null
            : _buyerNameController.text,
        buyerPhone: _buyerPhoneController.text.isEmpty
            ? null
            : _buyerPhoneController.text,
        buyerEmail: _buyerEmailController.text.isEmpty
            ? null
            : _buyerEmailController.text,
        surveyPlanNumber: _surveyPlanController.text.isEmpty
            ? null
            : _surveyPlanController.text,
        createdDate: DateTime.now(),
        reservationDate:
            _selectedStatus == 'Reserved' ? DateTime.now() : null,
        saleDate: _selectedStatus == 'Sold' ? DateTime.now() : null,
      );

      widget.onPlotAdded(plot);
      Navigator.of(context).pop();
    }
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
        child: Form(
          key: _formKey,
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const MyText(
                          'Add New Plot',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        MyText(
                          widget.estate.name,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.grey1,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
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
                            // Plot Number and Block Number
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyTextFormField(
                                        controller: _plotNumberController,
                                        hintText: 'e.g., Plot 001',
                                        spaceBetweenText: 10,
                                        title: 'Plot Number*',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter plot number';
                                          }
                                          return null;
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
                                      MyTextFormField(
                                        controller: _blockNumberController,
                                        spaceBetweenText: 10,
                                        hintText: 'e.g., Block A',
                                        title: 'Block Number (Optional)',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Plot Type and Status
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyDropdown(
                                        items: const [
                                          'Residential',
                                          'Commercial',
                                          'Mixed-Use',
                                          'Industrial'
                                        ],
                                        hintText: 'Select type',
                                        spaceBetweenText: 10,
                                        title: 'Plot Type*',
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedPlotType =
                                                value ?? 'Residential';
                                          });
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
                                        items: const [
                                          'Available',
                                          'Reserved',
                                          'Sold',
                                          'Under Offer'
                                        ],
                                        hintText: 'Select status',
                                        spaceBetweenText: 10,
                                        title: 'Status*',
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedStatus =
                                                value ?? 'Available';
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Size and Price
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyTextFormField(
                                        controller: _sizeController,
                                        hintText: 'Enter plot size',
                                        spaceBetweenText: 10,
                                        title: 'Size (sqm)*',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter plot size';
                                          }
                                          if (double.tryParse(value) == null) {
                                            return 'Enter a valid number';
                                          }
                                          return null;
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
                                      MyTextFormField(
                                        controller: _priceController,
                                        spaceBetweenText: 10,
                                        hintText: 'Enter price',
                                        title: 'Price (₦)*',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter price';
                                          }
                                          if (double.tryParse(value) == null) {
                                            return 'Enter a valid number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Description
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyTextFormField(
                                  controller: _descriptionController,
                                  maxLines: 3,
                                  hintText: 'Enter plot description',
                                  spaceBetweenText: 10,
                                  title: 'Description (Optional)',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Optional Section
                      const Divider(
                        color: AppColors.card,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showOptionalFields = !_showOptionalFields;
                                });
                              },
                              child: Row(
                                children: [
                                  const Flexible(
                                    child: MyText(
                                      'Buyer & Document Details (Optional)',
                                      size: 18,
                                      weight: 600,
                                    ),
                                  ),
                                  kSizedBoxWidthSM,
                                  Icon(
                                    _showOptionalFields
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 28,
                                  )
                                ],
                              ),
                            ),
                            if (_showOptionalFields) ...[
                              kSizedBox,
                              const MyText(
                                'Buyer Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey1,
                                ),
                              ),
                              kSizedBoxSM,
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyTextFormField(
                                          controller: _buyerNameController,
                                          hintText: 'Buyer name',
                                          spaceBetweenText: 10,
                                          title: 'Buyer Name',
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
                                          controller: _buyerPhoneController,
                                          spaceBetweenText: 10,
                                          hintText: 'Phone number',
                                          title: 'Phone',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              kSizedBox,
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyTextFormField(
                                          controller: _buyerEmailController,
                                          hintText: 'Email address',
                                          spaceBetweenText: 10,
                                          title: 'Email',
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
                                          controller: _surveyPlanController,
                                          spaceBetweenText: 10,
                                          hintText: 'Survey plan number',
                                          title: 'Survey Plan No.',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              kSizedBox,
                              const MyText(
                                'Upload Documents (Survey Plan, Title, etc.)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const UploadFile(),
                            ],
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
                      icon: SvgPicture.asset(
                        "assets/svg/check.svg",
                        colorFilter: const ColorFilter.mode(
                            AppColors.white, BlendMode.srcIn),
                      ),
                      child: 'Save Plot',
                      onTap: _savePlot,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
