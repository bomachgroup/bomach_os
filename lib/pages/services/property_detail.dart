import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/image/my_network_image.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/controller/property_controller.dart';
import 'package:bms_front_end/pages/services/widget/add_property_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'models/property_model.dart';

class PropertyDetailPage extends StatefulWidget {
  const PropertyDetailPage({super.key});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentImageIndex = 0;
  final PropertyController _controller = Get.find<PropertyController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final property = _controller.selectedProperty.value;

      if (property == null) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Text(
              'No property selected',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Row(
              children: [
                IconButton(
                  icon: const Icon(Iconsax.arrow_left_2),
                  onPressed: () => context.pop(),
                ),
                const Expanded(
                  child: MyText(
                    'Property Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                MyOutlinedButton(
                  borderColor: AppColors.neutral300,
                  textColor: AppColors.neutral500,
                  child: 'Edit',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AddPropertyDialog(property: property),
                    );
                  },
                ),
              ],
            ),

            kSizedBox,

            // Main content
            LayoutBuilder(
              builder: (context, constraints) {
                if (isLargeScreen(context)) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildLeftSection(property),
                      ),
                      kSizedBoxWidthSM,
                      Expanded(
                        flex: 2,
                        child: _buildRightSection(property),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildLeftSection(property),
                      kSizedBox,
                      _buildRightSection(property),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLeftSection(Property property) {
    final statusColor = _getStatusColor(property.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Gallery
        _buildImageGallery(property),

        kSizedBox,

        // Property Title and Status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: MyText(
                property.name,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: MyText(
                property.formattedStatus,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        kSizedBoxSM,

        // Location
        Row(
          children: [
            const Icon(Iconsax.location, size: 20, color: AppColors.neutral500),
            const SizedBox(width: 8),
            MyText(
              property.location,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),

        kSizedBox,

        // Price
        MyText(
          property.formattedPrice,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),

        kSizedBox,

        // Property Features
        _buildPropertyFeatures(property),

        kSizedBox,

        // Tabs Section
        _buildTabSection(property),
      ],
    );
  }

  Widget _buildRightSection(Property property) {
    return Column(
      children: [
        // Quick Info Card
        _buildQuickInfoCard(property),

        kSizedBox,

        // Contact Card
        // _buildContactCard(),

        // kSizedBox,

        // Documents Card
        // _buildDocumentsCard(),
      ],
    );
  }

  Widget _buildImageGallery(Property property) {
    final images = property.images;

    if (images.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 400,
          color: AppColors.primary.withValues(alpha: 0.1),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.home, size: 80, color: AppColors.primary),
              SizedBox(height: 16),
              MyText(
                'No images available',
                style: TextStyle(fontSize: 16, color: AppColors.neutral500),
              ),
            ],
          ),
        ),
      );
    }

    // Ensure index stays in bounds
    if (_currentImageIndex >= images.length) {
      _currentImageIndex = 0;
    }

    return Column(
      children: [
        // Main Image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              MyNetworkImage(
                images[_currentImageIndex],
                width: double.infinity,
                height: 400,
                fit: BoxFit.cover,
                errorPlaceholder: Container(
                  width: double.infinity,
                  height: 400,
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Iconsax.gallery_slash,
                      size: 80, color: AppColors.neutral500),
                ),
              ),
              if (images.length > 1) ...[
                // Navigation arrows
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Iconsax.arrow_left_2,
                          color: AppColors.white, size: 32),
                      onPressed: () {
                        setState(() {
                          _currentImageIndex =
                              (_currentImageIndex - 1) % images.length;
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Iconsax.arrow_right_3,
                          color: AppColors.white, size: 32),
                      onPressed: () {
                        setState(() {
                          _currentImageIndex =
                              (_currentImageIndex + 1) % images.length;
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ],
              // Image counter
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1} / ${images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (images.length > 1) ...[
          kSizedBoxSM,

          // Thumbnail Images
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _currentImageIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.neutral300,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: MyNetworkImage(
                        images[index],
                        fit: BoxFit.cover,
                        errorPlaceholder:
                            const Icon(Iconsax.gallery_slash, size: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPropertyFeatures(Property property) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Wrap(
        spacing: 40,
        runSpacing: 20,
        children: [
          if (property.bedrooms > 0)
            _buildFeatureItem(Icons.bed, '${property.bedrooms} Bedrooms'),
          if (property.bathrooms > 0)
            _buildFeatureItem(Icons.bathtub, '${property.bathrooms} Bathrooms'),
          _buildFeatureItem(Iconsax.ruler, '${property.size} sqm'),
          if (property.parkingSpaces > 0)
            _buildFeatureItem(
                Iconsax.car, '${property.parkingSpaces} Parking'),
          _buildFeatureItem(Iconsax.home, property.formattedType),
          _buildFeatureItem(Iconsax.category_2, property.formattedCategory),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          radius: 20,
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        MyText(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection(Property property) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral500,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Description'),
            Tab(text: 'Location'),
          ],
        ),
        kSizedBoxSM,
        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDescriptionTab(property),
              _buildLocationTab(property),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionTab(Property property) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyText(
              'About This Property',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            MyText(
              property.description.isNotEmpty
                  ? property.description
                  : 'No description available.',
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTab(Property property) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText(
            'Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Iconsax.location, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: MyText(
                  property.location,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard(Property property) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText(
            'Quick Info',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          kSizedBoxSM,
          _buildInfoRow('Property ID', 'PROP-${property.id}'),
          _buildInfoRow('Type', property.formattedType),
          _buildInfoRow('Category', property.formattedCategory),
          _buildInfoRow('Size', '${property.size} sqm'),
          _buildInfoRow('Client ID', property.clientId),
          if (property.createdAt != null)
            _buildInfoRow(
                'Listed Date', dateFormat.format(property.createdAt!)),
          if (property.updatedAt != null)
            _buildInfoRow(
                'Last Updated', dateFormat.format(property.updatedAt!)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyText(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.neutral500,
            ),
          ),
          Flexible(
            child: MyText(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'reserved':
        return Colors.orange;
      case 'sold':
      case 'rented':
        return Colors.purple;
      case 'under_construction':
        return Colors.blue;
      case 'pending':
        return Colors.amber;
      default:
        return AppColors.neutral500;
    }
  }
}
