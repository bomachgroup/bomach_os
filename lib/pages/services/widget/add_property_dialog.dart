import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/input/upload_file.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AddPropertyDialog extends StatefulWidget {
  const AddPropertyDialog({super.key});

  @override
  State<AddPropertyDialog> createState() => _AddPropertyDialogState();
}

class _AddPropertyDialogState extends State<AddPropertyDialog> {
  bool _showOptionalFields = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText(
                    'Add New Property',
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
                          // Property Name
                          const Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyTextFormField(
                                      hintText: 'Enter property name',
                                      spaceBetweenText: 10,
                                      title: 'Property Name*',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Property Type and Category
                          const Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyDropdown(
                                      items: [
                                        'Residential',
                                        'Commercial',
                                        'Industrial',
                                        'Land',
                                        'Mixed-Use'
                                      ],
                                      hintText: 'Select type',
                                      spaceBetweenText: 10,
                                      title: 'Property Type*',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyDropdown(
                                      items: [
                                        'For Sale',
                                        'For Rent',
                                        'For Lease',
                                        'Sold',
                                        'Rented'
                                      ],
                                      hintText: 'Select category',
                                      spaceBetweenText: 10,
                                      title: 'Category*',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Location
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyTextFormField(
                                hintText: 'Enter full address',
                                spaceBetweenText: 10,
                                title: 'Location/Address*',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Price and Size
                          const Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyTextFormField(
                                      hintText: 'Enter price',
                                      spaceBetweenText: 10,
                                      title: 'Price (₦)*',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyTextFormField(
                                      spaceBetweenText: 10,
                                      hintText: 'Enter size',
                                      title: 'Size (sqm)*',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Bedrooms, Bathrooms, Parking
                          const Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyTextFormField(
                                      hintText: '0',
                                      spaceBetweenText: 10,
                                      title: 'Bedrooms',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyTextFormField(
                                      spaceBetweenText: 10,
                                      hintText: '0',
                                      title: 'Bathrooms',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyTextFormField(
                                      spaceBetweenText: 10,
                                      hintText: '0',
                                      title: 'Parking Spaces',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Description
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyTextFormField(
                                maxLines: 4,
                                hintText: 'Enter property description',
                                spaceBetweenText: 10,
                                title: 'Description',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Status and Owner
                          const Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyDropdown(
                                      spaceBetweenText: 10,
                                      hintText: "Select status",
                                      items: [
                                        "Available",
                                        "Reserved",
                                        "Sold",
                                        "Under Construction",
                                        "Pending"
                                      ],
                                      title: 'Status*',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyTextFormField(
                                      spaceBetweenText: 10,
                                      hintText: 'Enter owner name',
                                      title: 'Owner/Developer',
                                    ),
                                  ],
                                ),
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
                                    'Additional Details (Optional)',
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
                            const Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyTextFormField(
                                        hintText: 'Year built',
                                        spaceBetweenText: 10,
                                        title: 'Year Built',
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyTextFormField(
                                        spaceBetweenText: 10,
                                        hintText: 'Enter features',
                                        title: 'Features/Amenities',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            kSizedBox,
                            const MyText(
                              'Upload Property Images',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const UploadFile(),
                            kSizedBox,
                            const MyText(
                              'Upload Documents (Title, Survey Plan, etc.)',
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                    child: 'Save Property',
                    onTap: () {
                      // TODO: Implement save property logic
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
