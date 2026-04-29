import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/image/my_network_image.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/services/controller/property_controller.dart';
import 'package:bomach_os/pages/services/widget/add_property_dialog.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import 'models/property_model.dart';

class PropertyListPage extends StatefulWidget {
  const PropertyListPage({super.key});

  @override
  State<PropertyListPage> createState() => _PropertyListPageState();
}

class _PropertyListPageState extends State<PropertyListPage> {
  final TextEditingController _searchController = TextEditingController();
  final PropertyController _controller = Get.put(PropertyController());

  // Filter selections
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  String _selectedType = 'All';

  static const Map<String, String?> _categoryFilters = {
    'All': null,
    'For Sale': 'sale',
    'For Rent': 'rent',
    'For Lease': 'lease',
  };

  static const Map<String, String?> _statusFilters = {
    'All': null,
    'Available': 'available',
    'Sold': 'sold',
    'Rented': 'rented',
    'Reserved': 'reserved',
    'Pending': 'pending',
    'Off Market': 'off_market',
  };

  static const Map<String, String?> _typeFilters = {
    'All': null,
    'Residential': 'residential',
    'Commercial': 'commercial',
    'Industrial': 'industrial',
    'Land': 'land',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    _controller.currentPage.value = 1;
    _controller.fetchProperties(
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      status: _statusFilters[_selectedStatus],
      category: _categoryFilters[_selectedCategory],
      propertyType: _typeFilters[_selectedType],
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCategory = 'All';
      _selectedStatus = 'All';
      _selectedType = 'All';
      _searchController.clear();
    });
    _controller.clearFilters();
  }

  bool get _hasActiveFilters =>
      _selectedCategory != 'All' ||
      _selectedStatus != 'All' ||
      _selectedType != 'All' ||
      _searchController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Properties',
        subtitle: 'Manage your property inventory and listings.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'Add Property',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const AddPropertyDialog(),
            );
          },
        ),
      ),
      children: [
        _buildStatsCards(),
        _buildToolbar(),
        _buildFilterChips(),
        _buildPropertyList(),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 320,
            child: MyTextFormField(
              controller: _searchController,
              hintText: 'Search properties by name or location',
              height: 48,
              leading: const Icon(Iconsax.search_normal,
                  size: 18, color: AppColors.textMuted),
              onChanged: (_) {},
            ),
          ),
          MyElevatedButton(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
            icon: const Icon(Iconsax.search_normal,
                color: AppColors.textOnPrimary, size: 18),
            child: 'Search',
            onTap: _applyFilters,
          ),
          _buildDropdownFilter(
            label: 'Status',
            value: _selectedStatus,
            items: _statusFilters.keys.toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedStatus = value);
                _applyFilters();
              }
            },
          ),
          _buildDropdownFilter(
            label: 'Type',
            value: _selectedType,
            items: _typeFilters.keys.toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedType = value);
                _applyFilters();
              }
            },
          ),
          if (_hasActiveFilters)
            Material(
              color: AppColors.dangerSubtle,
              borderRadius: AppRadii.brMd,
              child: InkWell(
                onTap: _clearAllFilters,
                borderRadius: AppRadii.brMd,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.close_circle,
                          size: 16, color: AppColors.danger),
                      const SizedBox(width: 6),
                      Text(
                        'Clear',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categoryFilters.keys
            .map((label) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildFilterChip(
                    label,
                    isSelected: _selectedCategory == label,
                    onTap: () {
                      setState(() => _selectedCategory = label);
                      _applyFilters();
                    },
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            isDense: true,
            icon: const Icon(Iconsax.arrow_down_1,
                size: 14, color: AppColors.textMuted),
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Obx(() {
      final props = _controller.properties;
      final available =
          props.where((p) => p.status.toLowerCase() == 'available').length;
      final reserved =
          props.where((p) => p.status.toLowerCase() == 'reserved').length;
      final soldOrRented = props
          .where((p) =>
              p.status.toLowerCase() == 'sold' ||
              p.status.toLowerCase() == 'rented')
          .length;

      return LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final perRow = isWide ? 4 : 2;
        const spacing = 16.0;
        final cardWidth =
            (constraints.maxWidth - ((perRow - 1) * spacing)) / perRow;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildStatCard('Total Properties', '${props.length}',
                  Iconsax.home, AppColors.primary),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard('Available', '$available',
                  Iconsax.tick_circle, AppColors.success),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard(
                  'Reserved', '$reserved', Iconsax.clock, AppColors.warning),
            ),
            SizedBox(
              width: cardWidth,
              child: _buildStatCard('Sold/Rented', '$soldOrRented',
                  Iconsax.tick_circle, AppColors.info),
            ),
          ],
        );
      });
    });
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadii.brMd,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(value, style: AppTextStyles.h1),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label,
      {required bool isSelected, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.brPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: AppRadii.brPill,
            border: Border.all(
              color:
                  isSelected ? AppColors.primary : AppColors.borderSubtle,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: isSelected
                  ? AppColors.textOnPrimary
                  : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyList() {
    return Obx(() {
      if (_controller.errorMessage.isNotEmpty) {
        return AppCard(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            icon: Iconsax.warning_2,
            title: 'Unable to load properties',
            subtitle: _controller.errorMessage.value,
            action: MyElevatedButton(
              height: 44,
              child: 'Retry',
              onTap: () => _controller.fetchProperties(),
            ),
          ),
        );
      }

      if (_controller.isLoading.value) {
        return AppCard(
          padding: const EdgeInsets.all(20),
          elevation: AppCardElevation.sm,
          child: LoadingSkeleton.listRows(count: 5, rowHeight: 120),
        );
      }

      if (_controller.properties.isEmpty) {
        return AppCard(
          padding: const EdgeInsets.all(24),
          child: EmptyState(
            icon: Iconsax.home,
            title: 'No properties found',
            subtitle: _hasActiveFilters
                ? 'Try adjusting your filters or search terms.'
                : 'Start by adding your first property to the inventory.',
            action: _hasActiveFilters
                ? MyElevatedButton(
                    height: 44,
                    child: 'Clear Filters',
                    onTap: _clearAllFilters,
                  )
                : MyElevatedButton(
                    height: 44,
                    icon: const Icon(Iconsax.add_circle,
                        color: AppColors.textOnPrimary, size: 18),
                    child: 'Add Property',
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => const AddPropertyDialog(),
                    ),
                  ),
          ),
        );
      }

      final currentPage = _controller.currentPage.value;
      final hasNextPage =
          _controller.properties.length >= _controller.limit;
      // Estimate total items so paginator can show correct navigation.
      final estimatedTotal = hasNextPage
          ? (currentPage * _controller.limit) + 1
          : ((currentPage - 1) * _controller.limit) +
              _controller.properties.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controller.properties.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final property = _controller.properties[index];
              return _buildPropertyListItem(property);
            },
          ),
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            elevation: AppCardElevation.sm,
            child: PaginatorFooter(
              totalItems: estimatedTotal,
              limit: _controller.limit,
              currentPage: currentPage,
              onPageChanged: (page) => _controller.goToPage(page),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    });
  }

  Widget _buildPropertyListItem(Property property) {
    final hasImage = property.images.isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      onTap: () {
        _controller.selectedProperty.value = property;
        context.go(RouteConstants.propertyDetail);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: AppRadii.brMd,
            child: hasImage
                ? MyNetworkImage(
                    property.images.first,
                    width: 140,
                    height: 120,
                    fit: BoxFit.cover,
                    errorPlaceholder: _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        property.name,
                        style: AppTextStyles.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    StatusChip(
                      label: property.formattedStatus,
                      tone: _statusTone(property.status),
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Iconsax.location,
                        size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        property.location,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    if (property.bedrooms > 0)
                      _buildPropertyInfo(
                          Icons.bed_outlined, '${property.bedrooms} beds'),
                    if (property.bathrooms > 0)
                      _buildPropertyInfo(Icons.bathtub_outlined,
                          '${property.bathrooms} baths'),
                    _buildPropertyInfo(
                        Iconsax.ruler, '${property.size} sqm'),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      property.formattedPrice,
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    StatusChip(
                      label: property.formattedCategory,
                      tone: StatusTone.primary,
                      dense: true,
                    ),
                    if (property.propertyType.isNotEmpty)
                      StatusChip(
                        label: property.formattedType,
                        tone: _typeTone(property.propertyType),
                        dense: true,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 140,
      height: 120,
      decoration: const BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: AppRadii.brMd,
      ),
      child: const Icon(
        Iconsax.home,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildPropertyInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 5),
        Text(
          text,
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
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
