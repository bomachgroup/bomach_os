import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/controller/property_controller.dart';
import 'package:bms_front_end/pages/services/models/property_model.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddPropertyDialog extends StatefulWidget {
  final Property? property;

  const AddPropertyDialog({super.key, this.property});

  @override
  State<AddPropertyDialog> createState() => _AddPropertyDialogState();
}

class _AddPropertyDialogState extends State<AddPropertyDialog> {
  final _formKey = GlobalKey<FormState>();
  final PropertyController _controller = Get.find<PropertyController>();
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();
  final ImagePicker _imagePicker = ImagePicker();

  bool get isEditing => widget.property != null;

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _propertyTypeController;
  late final TextEditingController _categoryController;
  late final TextEditingController _locationController;
  late final TextEditingController _priceController;
  late final TextEditingController _sizeController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;
  late final TextEditingController _parkingController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _statusController;

  // Image URLs list
  final List<String> _imageUrls = [];

  bool _isSaving = false;
  bool _isUploading = false;

  // Maps for display text <-> API value
  static const Map<String, String> _propertyTypeMap = {
    'Residential': 'residential',
    'Commercial': 'commercial',
    'Industrial': 'industrial',
    'Land': 'land',
  };

  static const Map<String, String> _categoryMap = {
    'For Sale': 'sale',
    'For Rent': 'rent',
    'For Lease': 'lease',
  };

  static const Map<String, String> _statusMap = {
    'Available': 'available',
    'Sold': 'sold',
    'Rented': 'rented',
    'Reserved': 'reserved',
    'Pending': 'pending',
    'Off Market': 'off_market',
  };

  // Reverse maps
  static final Map<String, String> _propertyTypeReverse =
      _propertyTypeMap.map((k, v) => MapEntry(v, k));
  static final Map<String, String> _categoryReverse =
      _categoryMap.map((k, v) => MapEntry(v, k));
  static final Map<String, String> _statusReverse =
      _statusMap.map((k, v) => MapEntry(v, k));

  @override
  void initState() {
    super.initState();
    final p = widget.property;

    _nameController = TextEditingController(text: p?.name ?? '');
    _propertyTypeController = TextEditingController(
        text: _propertyTypeReverse[p?.propertyType] ?? '');
    _categoryController =
        TextEditingController(text: _categoryReverse[p?.category] ?? '');
    _locationController = TextEditingController(text: p?.location ?? '');
    _priceController = TextEditingController(
        text: p != null && p.price != '0' ? p.price : '');
    _sizeController = TextEditingController(
        text: p != null && p.size != '0' ? p.size : '');
    _bedroomsController = TextEditingController(
        text: p != null && p.bedrooms > 0 ? '${p.bedrooms}' : '');
    _bathroomsController = TextEditingController(
        text: p != null && p.bathrooms > 0 ? '${p.bathrooms}' : '');
    _parkingController = TextEditingController(
        text: p != null && p.parkingSpaces > 0 ? '${p.parkingSpaces}' : '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _statusController =
        TextEditingController(text: _statusReverse[p?.status] ?? '');

    if (p != null && p.images.isNotEmpty) {
      _imageUrls.addAll(p.images);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _propertyTypeController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _sizeController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _parkingController.dispose();
    _descriptionController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        Get.snackbar('Error', 'Authentication token not found',
            backgroundColor: Colors.red, colorText: Colors.white);
        setState(() => _isUploading = false);
        return;
      }

      final bytes = await pickedFile.readAsBytes();
      final url = await _authService.uploadFile(
        token,
        bytes,
        pickedFile.name,
      );

      setState(() {
        _imageUrls.add(url);
        _isUploading = false;
      });
    } catch (e) {
      setState(() => _isUploading = false);
      Get.snackbar('Error', 'Failed to upload image: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final propertyType =
        _propertyTypeMap[_propertyTypeController.text.trim()] ?? '';
    final category = _categoryMap[_categoryController.text.trim()] ?? '';
    final location = _locationController.text.trim();
    final status = _statusMap[_statusController.text.trim()] ?? 'available';

    if (name.isEmpty ||
        propertyType.isEmpty ||
        category.isEmpty ||
        location.isEmpty) {
      Get.snackbar('Error', 'Please fill in all required fields',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    setState(() => _isSaving = true);

    final data = {
      'name': name,
      'property_type': propertyType,
      'category': category,
      'location': location,
      'price': double.tryParse(_priceController.text.trim()) ?? 0,
      'size': double.tryParse(_sizeController.text.trim()) ?? 0,
      'bedrooms': int.tryParse(_bedroomsController.text.trim()) ?? 0,
      'bathrooms': int.tryParse(_bathroomsController.text.trim()) ?? 0,
      'parking_spaces': int.tryParse(_parkingController.text.trim()) ?? 0,
      'description': _descriptionController.text.trim(),
      'images': _imageUrls,
      'status': status,
    };

    bool success;
    if (isEditing) {
      success = await _controller.updateProperty(widget.property!.id, data);
    } else {
      success = await _controller.createProperty(data);
    }

    setState(() => _isSaving = false);

    if (success && mounted) {
      Navigator.pop(context);
      Get.snackbar(
        'Success',
        isEditing
            ? 'Property updated successfully'
            : 'Property created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
          'Error',
          _controller.errorMessage.value.isNotEmpty
              ? _controller.errorMessage.value
              : 'Failed to save property',
          backgroundColor: Colors.red,
          colorText: Colors.white);
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
                    isEditing ? 'Edit Property' : 'Add New Property',
                    style: const TextStyle(
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
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Property Name
                        MyTextFormField(
                          controller: _nameController,
                          hintText: 'Enter property name',
                          spaceBetweenText: 10,
                          title: 'Property Name*',
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Property name is required'
                              : null,
                        ),
                        const SizedBox(height: 24),

                        // Property Type and Category
                        Row(
                          children: [
                            Expanded(
                              child: MyDropdown(
                                controller: _propertyTypeController,
                                items: _propertyTypeMap.keys.toList(),
                                hintText: 'Select type',
                                spaceBetweenText: 10,
                                title: 'Property Type*',
                                validator: (val) =>
                                    val == null || val.trim().isEmpty
                                        ? 'Property type is required'
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: MyDropdown(
                                controller: _categoryController,
                                items: _categoryMap.keys.toList(),
                                hintText: 'Select category',
                                spaceBetweenText: 10,
                                title: 'Category*',
                                validator: (val) =>
                                    val == null || val.trim().isEmpty
                                        ? 'Category is required'
                                        : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Location
                        MyTextFormField(
                          controller: _locationController,
                          hintText: 'Enter full address',
                          spaceBetweenText: 10,
                          title: 'Location/Address*',
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Location is required'
                              : null,
                        ),
                        const SizedBox(height: 24),

                        // Price and Size
                        Row(
                          children: [
                            Expanded(
                              child: MyTextFormField(
                                controller: _priceController,
                                hintText: 'Enter price',
                                spaceBetweenText: 10,
                                title: 'Price (₦)*',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[\d.]')),
                                ],
                                validator: (val) =>
                                    val == null || val.trim().isEmpty
                                        ? 'Price is required'
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: MyTextFormField(
                                controller: _sizeController,
                                hintText: 'Enter size',
                                spaceBetweenText: 10,
                                title: 'Size (sqm)',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[\d.]')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Bedrooms, Bathrooms, Parking
                        Row(
                          children: [
                            Expanded(
                              child: MyTextFormField(
                                controller: _bedroomsController,
                                hintText: '0',
                                spaceBetweenText: 10,
                                title: 'Bedrooms',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: MyTextFormField(
                                controller: _bathroomsController,
                                hintText: '0',
                                spaceBetweenText: 10,
                                title: 'Bathrooms',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: MyTextFormField(
                                controller: _parkingController,
                                hintText: '0',
                                spaceBetweenText: 10,
                                title: 'Parking Spaces',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Description
                        MyTextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          hintText: 'Enter property description',
                          spaceBetweenText: 10,
                          title: 'Description',
                        ),
                        const SizedBox(height: 24),

                        // Status
                        MyDropdown(
                          controller: _statusController,
                          hintText: 'Select status',
                          items: _statusMap.keys.toList(),
                          spaceBetweenText: 10,
                          title: 'Status*',
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Status is required'
                              : null,
                        ),
                        const SizedBox(height: 24),

                        // Property Images
                        const MyText(
                          'Property Images',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Upload button
                        GestureDetector(
                          onTap: _isUploading ? null : _pickAndUploadImage,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              color: AppColors.blue.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.blue.withValues(alpha: 0.3),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: _isUploading
                                ? const Column(
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Uploading image...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.grey1,
                                        ),
                                      ),
                                    ],
                                  )
                                : const Column(
                                    children: [
                                      Icon(
                                        Icons.cloud_upload_outlined,
                                        size: 32,
                                        color: AppColors.blue,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Click to upload images',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Supported: PNG, JPG, JPEG',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.grey1,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        // Uploaded images list
                        if (_imageUrls.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          ..._imageUrls.asMap().entries.map((entry) {
                            final index = entry.key;
                            final url = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        Colors.grey.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        url,
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          width: 56,
                                          height: 56,
                                          color: AppColors.blue
                                              .withValues(alpha: 0.1),
                                          child: const Icon(
                                              Icons.broken_image,
                                              size: 24),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Image ${index + 1}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            url,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.grey1,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close,
                                          size: 18, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _imageUrls.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
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
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 16),
                  _isSaving
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(),
                        )
                      : MyElevatedButton(
                          icon: SvgPicture.asset(
                            "assets/svg/check.svg",
                            colorFilter: const ColorFilter.mode(
                                AppColors.white, BlendMode.srcIn),
                          ),
                          child:
                              isEditing ? 'Update Property' : 'Save Property',
                          onTap: _saveProperty,
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
