import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/image/my_network_image.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/services/controller/property_controller.dart';
import 'package:bomach_os/pages/services/widget/add_property_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
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
        return const PageScaffold(
          children: [
            SizedBox(height: 80),
            Center(
              child: Text('No property selected'),
            ),
          ],
        );
      }

      return PageScaffold(
        maxContentWidth: 1440,
        header: PageHeader(
          title: property.name,
          subtitle: property.formattedType.isNotEmpty
              ? '${property.formattedType} • ${property.formattedCategory}'
              : property.formattedCategory,
          leading: _backButton(context),
          trailing: MyOutlinedButton(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
            icon: const Icon(Iconsax.edit,
                size: 16, color: AppColors.primary),
            child: 'Edit Property',
            onTap: () {
              showDialog(
                context: context,
                builder: (context) =>
                    AddPropertyDialog(property: property),
              );
            },
          ),
        ),
        children: [
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
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: _buildRightSection(property),
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLeftSection(property),
                    const SizedBox(height: 20),
                    _buildRightSection(property),
                  ],
                );
              }
            },
          ),
        ],
      );
    });
  }

  Widget _backButton(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.brMd,
      child: InkWell(
        borderRadius: AppRadii.brMd,
        onTap: () => context.pop(),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderStrong),
            borderRadius: AppRadii.brMd,
          ),
          child: const Icon(Iconsax.arrow_left_2,
              size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildLeftSection(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          elevation: AppCardElevation.sm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageGallery(property),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusChip(
                    label: property.formattedStatus,
                    tone: _statusTone(property.status),
                  ),
                  if (property.propertyType.isNotEmpty)
                    StatusChip(
                      label: property.formattedType,
                      tone: _typeTone(property.propertyType),
                    ),
                  StatusChip(
                    label: property.formattedCategory,
                    tone: StatusTone.primary,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Iconsax.location,
                      size: 18, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      property.location,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                property.formattedPrice,
                style: AppTextStyles.displayMd.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildPropertyFeatures(property),
        const SizedBox(height: 20),
        _buildTabSection(property),
      ],
    );
  }

  Widget _buildRightSection(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildQuickInfoCard(property),
      ],
    );
  }

  Widget _buildImageGallery(Property property) {
    final images = property.images;

    if (images.isEmpty) {
      return ClipRRect(
        borderRadius: AppRadii.brLg,
        child: Container(
          width: double.infinity,
          height: 380,
          color: AppColors.primarySubtle,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.home, size: 72, color: AppColors.primary),
              const SizedBox(height: 14),
              Text(
                'No images available',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: AppRadii.brLg,
          child: Stack(
            children: [
              MyNetworkImage(
                images[_currentImageIndex],
                width: double.infinity,
                height: 380,
                fit: BoxFit.cover,
                errorPlaceholder: Container(
                  width: double.infinity,
                  height: 380,
                  color: AppColors.primarySubtle,
                  child: const Icon(Iconsax.gallery_slash,
                      size: 72, color: AppColors.textMuted),
                ),
              ),
              if (images.length > 1) ...[
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _galleryNavButton(
                      icon: Iconsax.arrow_left_2,
                      onTap: () => setState(() {
                        _currentImageIndex =
                            (_currentImageIndex - 1 + images.length) %
                                images.length;
                      }),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _galleryNavButton(
                      icon: Iconsax.arrow_right_3,
                      onTap: () => setState(() {
                        _currentImageIndex =
                            (_currentImageIndex + 1) % images.length;
                      }),
                    ),
                  ),
                ),
              ],
              Positioned(
                bottom: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.neutral900.withValues(alpha: 0.65),
                    borderRadius: AppRadii.brPill,
                  ),
                  child: Text(
                    '${_currentImageIndex + 1} / ${images.length}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _currentImageIndex;
                return GestureDetector(
                  onTap: () => setState(() => _currentImageIndex = index),
                  child: Container(
                    width: 96,
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.brMd,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderSubtle,
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadii.brMd,
                      child: MyNetworkImage(
                        images[index],
                        fit: BoxFit.cover,
                        errorPlaceholder: const Icon(Iconsax.gallery_slash,
                            size: 24, color: AppColors.textMuted),
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

  Widget _galleryNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.neutral900.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: AppColors.textOnPrimary),
        ),
      ),
    );
  }

  Widget _buildPropertyFeatures(Property property) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Property Features', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              if (property.bedrooms > 0)
                _buildFeatureItem(
                    Icons.bed_outlined, '${property.bedrooms} Bedrooms'),
              if (property.bathrooms > 0)
                _buildFeatureItem(Icons.bathtub_outlined,
                    '${property.bathrooms} Bathrooms'),
              _buildFeatureItem(Iconsax.ruler, '${property.size} sqm'),
              if (property.parkingSpaces > 0)
                _buildFeatureItem(
                    Iconsax.car, '${property.parkingSpaces} Parking'),
              _buildFeatureItem(Iconsax.home, property.formattedType),
              _buildFeatureItem(
                  Iconsax.category_2, property.formattedCategory),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: AppRadii.brMd,
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTabSection(Property property) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            labelStyle:
                AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
            unselectedLabelStyle: AppTextStyles.bodyMd,
            tabs: const [
              Tab(text: 'Description'),
              Tab(text: 'Location'),
            ],
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          SizedBox(
            height: 280,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDescriptionTab(property),
                _buildLocationTab(property),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionTab(Property property) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('About This Property', style: AppTextStyles.h4),
            const SizedBox(height: 14),
            Text(
              property.description.isNotEmpty
                  ? property.description
                  : 'No description available.',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationTab(Property property) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Location', style: AppTextStyles.h4),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Iconsax.location, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  property.location,
                  style: AppTextStyles.bodyMd,
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

    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Info', style: AppTextStyles.h4),
          const SizedBox(height: 16),
          _buildInfoRow('Property ID', 'PROP-${property.id}'),
          _buildInfoRow('Type', property.formattedType),
          _buildInfoRow('Category', property.formattedCategory),
          _buildInfoRow('Size', '${property.size} sqm'),
          _buildInfoRow(
              'Client ID', property.clientId.isEmpty ? '—' : property.clientId),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'vacant':
        return StatusTone.success;
      case 'occupied':
      case 'sold':
      case 'rented':
        return StatusTone.primary;
      case 'reserved':
      case 'pending':
        return StatusTone.warning;
      case 'off_market':
        return StatusTone.neutral;
      case 'inactive':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }

  StatusTone _typeTone(String type) {
    switch (type.toLowerCase()) {
      case 'residential':
        return StatusTone.primary;
      case 'commercial':
        return StatusTone.info;
      case 'industrial':
        return StatusTone.warning;
      case 'land':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }
}
