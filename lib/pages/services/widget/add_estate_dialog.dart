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

class AddEstateDialog extends StatefulWidget {
  final Function(Estate) onEstateAdded;

  const AddEstateDialog({
    super.key,
    required this.onEstateAdded,
  });

  @override
  State<AddEstateDialog> createState() => _AddEstateDialogState();
}

class _AddEstateDialogState extends State<AddEstateDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _showOptionalFields = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _developerController = TextEditingController();
  final _totalAreaController = TextEditingController();
  final _totalPlotsController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();

  String _selectedStatus = 'Active';

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _developerController.dispose();
    _totalAreaController.dispose();
    _totalPlotsController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  void _saveEstate() {
    if (_formKey.currentState?.validate() ?? false) {
      final totalPlots = int.tryParse(_totalPlotsController.text) ?? 0;
      final estate = Estate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        developer: _developerController.text,
        totalArea: double.tryParse(_totalAreaController.text) ?? 0,
        totalPlots: totalPlots,
        availablePlots: totalPlots,
        soldPlots: 0,
        reservedPlots: 0,
        status: _selectedStatus,
        createdDate: DateTime.now(),
        contactPerson: _contactPersonController.text.isEmpty
            ? null
            : _contactPersonController.text,
        contactPhone: _contactPhoneController.text.isEmpty
            ? null
            : _contactPhoneController.text,
        contactEmail: _contactEmailController.text.isEmpty
            ? null
            : _contactEmailController.text,
      );

      widget.onEstateAdded(estate);
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
                    const MyText(
                      'Add New Estate',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
                            // Estate Name
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyTextFormField(
                                        controller: _nameController,
                                        hintText: 'Enter estate name',
                                        spaceBetweenText: 10,
                                        title: 'Estate Name*',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter estate name';
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

                            // Location
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyTextFormField(
                                  controller: _locationController,
                                  hintText: 'Enter full location/address',
                                  spaceBetweenText: 10,
                                  title: 'Location*',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter location';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Developer and Status
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyTextFormField(
                                        controller: _developerController,
                                        hintText: 'Enter developer name',
                                        spaceBetweenText: 10,
                                        title: 'Developer/Company*',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter developer';
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
                                      MyDropdown(
                                        items: const [
                                          'Active',
                                          'Under Development',
                                          'Planning',
                                          'Completed'
                                        ],
                                        hintText: 'Select status',
                                        spaceBetweenText: 10,
                                        title: 'Status*',
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedStatus = value ?? 'Active';
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Total Area and Total Plots
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyTextFormField(
                                        controller: _totalAreaController,
                                        hintText: 'Enter total area',
                                        spaceBetweenText: 10,
                                        title: 'Total Area (sqm)*',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter total area';
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
                                        controller: _totalPlotsController,
                                        spaceBetweenText: 10,
                                        hintText: 'Enter number of plots',
                                        title: 'Total Plots*',
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter total plots';
                                          }
                                          if (int.tryParse(value) == null) {
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
                                  maxLines: 4,
                                  hintText: 'Enter estate description',
                                  spaceBetweenText: 10,
                                  title: 'Description*',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter description';
                                    }
                                    return null;
                                  },
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
                                      'Contact Information (Optional)',
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
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyTextFormField(
                                          controller: _contactPersonController,
                                          hintText: 'Contact person name',
                                          spaceBetweenText: 10,
                                          title: 'Contact Person',
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
                                          controller: _contactPhoneController,
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
                                          controller: _contactEmailController,
                                          hintText: 'Email address',
                                          spaceBetweenText: 10,
                                          title: 'Email',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              kSizedBox,
                              const MyText(
                                'Upload Estate Images',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const UploadFile(),
                              kSizedBox,
                              const MyText(
                                'Upload Documents (Layout Plan, Approval, etc.)',
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
                      child: 'Save Estate',
                      onTap: _saveEstate,
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
