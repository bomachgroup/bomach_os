import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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
        _showSuccessSnackbar(_isEditMode
            ? 'Service updated successfully'
            : 'Service created successfully');
      } else if (mounted) {
        _showErrorSnackbar(_isEditMode
            ? 'Failed to update service. Please try again.'
            : 'Failed to create service. Please try again.');
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
    AppToast.error(context, message);
  }

  void _showSuccessSnackbar(String message) {
    AppToast.success(context, message);
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

    return DialogScaffold(
      title: _isEditMode ? 'Edit Service' : 'Create New Service',
      subtitle: _isEditMode
          ? 'Update details for this service offering.'
          : 'Define a new service offering for your catalog.',
      size: DialogSize.md,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSection(
              title: 'Service details',
              children: [
                MyTextFormField(
                  controller: _nameController,
                  hintText: 'Enter service name',
                  title: 'Service Name*',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Service name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.isLoadingCategories.value) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Category*', style: AppTextStyles.label),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadii.brMd,
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Loading categories...',
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  final categoryItems = controller.categories
                      .map((cat) => _formatCategoryName(cat.name))
                      .toList();

                  return MyDropdown(
                    controller: _categoryController,
                    items: categoryItems,
                    hintText: 'Select category',
                    title: 'Category*',
                    onChanged: (value) {
                      if (value != null) {
                        final selectedCategory = controller.categories
                            .firstWhere(
                                (cat) => _formatCategoryName(cat.name) == value);
                        setState(() {
                          _selectedCategoryId = selectedCategory.id;
                        });
                      }
                    },
                  );
                }),
                const SizedBox(height: 16),
                MyDropdown(
                  controller: _statusController,
                  items: const ['Active', 'Inactive'],
                  hintText: 'Select status',
                  title: 'Status*',
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value?.toLowerCase() == 'active'
                          ? 'active'
                          : 'inactive';
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          onTap: _isSubmitting
              ? null
              : () {
                  Navigator.pop(context);
                },
        ),
        MyElevatedButton(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          isLoading: _isSubmitting,
          icon: const Icon(Iconsax.tick_circle,
              size: 18, color: AppColors.textOnPrimary),
          child: _isEditMode ? 'Update Service' : 'Add Service',
          onTap: _handleSubmit,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}
