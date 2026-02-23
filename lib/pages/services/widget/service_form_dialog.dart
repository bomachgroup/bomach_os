import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../controller/service_controller.dart';
import '../models/service_model.dart';

class ServiceFormDialog extends StatefulWidget {
  final Service? service; // If provided, dialog is in edit mode

  const ServiceFormDialog({
    super.key,
    this.service,
  });

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _deliveryTimeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _statusController = TextEditingController();

  // Selected values
  int? _selectedCategoryId;
  String _selectedStatus = 'active';

  bool _isSubmitting = false;
  bool get _isEditMode => widget.service != null;

  @override
  void initState() {
    super.initState();
    // Prefill form if editing
    if (_isEditMode) {
      _prefillForm();
    } else {
      _statusController.text = 'Active';
    }
  }

  void _prefillForm() {
    final service = widget.service!;

    _nameController.text = service.name;
    _descriptionController.text = service.description;
    _basePriceController.text = service.basePrice;
    _deliveryTimeController.text = service.deliveryTime;
    _selectedCategoryId = service.category.id;
    _selectedStatus = service.status;

    // Format category and status for display
    _categoryController.text = _formatCategoryName(service.category.name);
    _statusController.text = _formatStatusName(service.status);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _deliveryTimeController.dispose();
    _categoryController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      _showErrorSnackbar('Please select a category');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get user ID from secure storage
      final userId = await _storage.read(key: 'user_id');
      if (userId == null) {
        _showErrorSnackbar('User ID not found. Please login again.');
        return;
      }

      final controller = Get.find<ServiceController>();

      // Create service object
      final service = Service(
        id: _isEditMode ? widget.service!.id : 0,
        name: _nameController.text.trim(),
        category: ServiceCategory(
          id: _selectedCategoryId!,
          name: '', // Will be populated by backend
          description: '',
        ),
        description: _descriptionController.text.trim(),
        basePrice: _basePriceController.text.trim(),
        deliveryTime: _deliveryTimeController.text.trim(),
        status: _selectedStatus,
        createdBy: userId,
      );

      final bool success;
      if (_isEditMode) {
        success = await controller.updateService(widget.service!.id, service);
      } else {
        success = await controller.createService(service);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackbar(
          _isEditMode
            ? 'Service updated successfully'
            : 'Service created successfully'
        );
      } else if (mounted) {
        _showErrorSnackbar(
          _isEditMode
            ? 'Failed to update service. Please try again.'
            : 'Failed to create service. Please try again.'
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Format category name for display
  /// Replaces underscores with spaces and capitalizes first letter
  String _formatCategoryName(String name) {
    if (name.isEmpty) return name;
    final withSpaces = name.replaceAll('_', ' ');
    return withSpaces[0].toUpperCase() + withSpaces.substring(1);
  }

  /// Format status name for display
  /// Capitalizes first letter
  String _formatStatusName(String status) {
    if (status.isEmpty) return status;
    return status[0].toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceController>();

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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                      _isEditMode ? 'Edit Service' : 'Create New Service',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Form fields
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Name
                        MyTextFormField(
                          controller: _nameController,
                          hintText: 'Enter service name',
                          spaceBetweenText: 10,
                          title: 'Service Name*',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Service name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Category
                        Obx(() {
                          if (controller.isLoadingCategories.value) {
                            return const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  'Category*',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ],
                            );
                          }

                          // Format category names for display
                          final categoryItems = controller.categories
                              .map((cat) => _formatCategoryName(cat.name))
                              .toList();

                          return MyDropdown(
                            controller: _categoryController,
                            items: categoryItems,
                            hintText: 'Select category',
                            spaceBetweenText: 10,
                            title: 'Category*',
                            onChanged: (value) {
                              if (value != null) {
                                // Find the category by matching formatted name
                                final selectedCategory = controller.categories
                                    .firstWhere((cat) => _formatCategoryName(cat.name) == value);
                                setState(() {
                                  _selectedCategoryId = selectedCategory.id;
                                });
                              }
                            },
                          );
                        }),
                        const SizedBox(height: 24),

                        // Description
                        MyTextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          hintText: 'Enter service description',
                          spaceBetweenText: 10,
                          title: 'Description*',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Description is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Base Price and Delivery Time
                        Row(
                          children: [
                            Expanded(
                              child: MyTextFormField(
                                controller: _basePriceController,
                                hintText: 'e.g., 10000',
                                spaceBetweenText: 10,
                                title: 'Base Price (₦)*',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Base price is required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: MyTextFormField(
                                controller: _deliveryTimeController,
                                spaceBetweenText: 10,
                                hintText: 'e.g., 7 days',
                                title: 'Delivery Time*',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Delivery time is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Status
                        MyDropdown(
                          controller: _statusController,
                          spaceBetweenText: 10,
                          hintText: "Select status",
                          items: const ["Active", "Inactive", "Draft"],
                          title: 'Status*',
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value?.toLowerCase() ?? 'active';
                            });
                          },
                        ),
                      ],
                    ),
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
                      onTap: _isSubmitting
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                    ),
                    const SizedBox(width: 16),
                    _isSubmitting
                        ? const SizedBox(
                            width: 120,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : MyElevatedButton(
                            icon: SvgPicture.asset(
                              "assets/svg/check.svg",
                              colorFilter: const ColorFilter.mode(
                                  AppColors.white, BlendMode.srcIn),
                            ),
                            child: _isEditMode ? 'Update' : 'Save',
                            onTap: _handleSubmit,
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
