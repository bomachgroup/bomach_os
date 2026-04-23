import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/image/my_network_image.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/app_text.dart';
import 'package:bms_front_end/pages/services/controller/property_controller.dart';
import 'package:bms_front_end/pages/services/widget/add_property_dialog.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText.displayLg(
                        'Properties',
                      ),
                      const SizedBox(height: 8),
                      AppText.bodyMd(
                        'Manage your property inventory and listings',
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      SizedBox(
                        width: 200,
                        child: MyTextFormField(
                          controller: _searchController,
                          hintText: 'Search properties...',
                          leading: Icon(
                            Iconsax.search_normal,
                            color: AppColors.neutral500.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      MyElevatedButton(
                        child: 'Search',
                        onTap: _applyFilters,
                      ),
                      MyElevatedButton(
                        icon: const Icon(
                          Iconsax.add_circle,
                          color: AppColors.white,
                        ),
                        child: "Add Property",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const AddPropertyDialog();
                            },
                          );
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,

        // Stats Cards
        _buildStatsCards(),

        kSizedBox,

        // Category Filter Chips
        const MyText(
          'Category',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categoryFilters.keys
                    .map((label) => _buildFilterChip(
                          label,
                          isSelected: _selectedCategory == label,
                          onTap: () {
                            setState(() => _selectedCategory = label);
                            _applyFilters();
                          },
                        ))
                    .toList(),
              ),
            ),
          ],
        ),

        kSizedBoxSM,

        // Status & Property Type Filters
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Status Dropdown
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
                  // Property Type Dropdown
                  _buildDropdownFilter(
                    label: 'Property Type',
                    value: _selectedType,
                    items: _typeFilters.keys.toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedType = value);
                        _applyFilters();
                      }
                    },
                  ),
                  // Clear Filters
                  if (_hasActiveFilters)
                    GestureDetector(
                      onTap: _clearAllFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.close_circle, size: 16, color: Colors.red),
                            SizedBox(width: 4),
                            Text(
                              'Clear Filters',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),

        kSizedBox,

        // Property List
        _buildPropertyList(),
      ],
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.neutral500,
            ),
          ),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            isDense: true,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
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

      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _buildStatCard('Total Properties', '${props.length}', Iconsax.home,
              AppColors.primary),
          _buildStatCard(
              'Available', '$available', Iconsax.tick_circle, Colors.green),
          _buildStatCard(
              'Reserved', '$reserved', Iconsax.clock, Colors.orange),
          _buildStatCard(
              'Sold/Rented', '$soldOrRented', Iconsax.tick_circle, Colors.purple),
        ],
      );
    });
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
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
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            radius: 20,
            child: Icon(icon, color: color, size: 20),
          ),
          kSizedBoxSM,
          MyText(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          MyText(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label,
      {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral300,
          ),
        ),
        child: AppText.bodyMd(
          label,
          isSelectable: false,
          color: isSelected ? AppColors.white : AppColors.neutral500,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPropertyList() {
    return Obx(() {
      if (_controller.errorMessage.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _controller.errorMessage.value,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.fetchProperties(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (_controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (_controller.properties.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(40.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'No properties found',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                if (_hasActiveFilters) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _clearAllFilters,
                    child: const Text('Clear Filters'),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      return Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controller.properties.length,
            separatorBuilder: (context, index) => kSizedBoxSM,
            itemBuilder: (context, index) {
              final property = _controller.properties[index];
              return _buildPropertyListItem(property);
            },
          ),
          const SizedBox(height: 24),
          // Pagination Controls
          Obx(() {
            final currentPage = _controller.currentPage.value;
            final hasNextPage =
                _controller.properties.length >= _controller.limit;

            final totalPages = hasNextPage ? currentPage + 1 : currentPage;
            int endPage = totalPages.clamp(1, totalPages);
            int startPage = (endPage - 4).clamp(1, endPage);

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed:
                      currentPage > 1 ? () => _controller.previousPage() : null,
                  icon: const Icon(Iconsax.arrow_left_2),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        currentPage > 1 ? AppColors.primary : Colors.grey[300],
                    foregroundColor:
                        currentPage > 1 ? Colors.white : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                ...List.generate(
                  endPage - startPage + 1,
                  (index) {
                    final pageNumber = startPage + index;
                    final isCurrentPage = pageNumber == currentPage;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => _controller.goToPage(pageNumber),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                isCurrentPage ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isCurrentPage
                                  ? AppColors.primary
                                  : Colors.grey[300]!,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$pageNumber',
                            style: TextStyle(
                              color:
                                  isCurrentPage ? Colors.white : Colors.black87,
                              fontWeight: isCurrentPage
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: hasNextPage ? () => _controller.nextPage() : null,
                  icon: const Icon(Iconsax.arrow_right_3),
                  style: IconButton.styleFrom(
                    backgroundColor:
                        hasNextPage ? AppColors.primary : Colors.grey[300],
                    foregroundColor:
                        hasNextPage ? Colors.white : Colors.grey[600],
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 40),
        ],
      );
    });
  }

  Widget _buildPropertyListItem(Property property) {
    final statusColor = _getStatusColor(property.status);
    final hasImage = property.images.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: InkWell(
        onTap: () {
          _controller.selectedProperty.value = property;
          context.go(RouteConstants.propertyDetail);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: hasImage
                  ? MyNetworkImage(
                      property.images.first,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorPlaceholder: _buildPlaceholderImage(),
                    )
                  : _buildPlaceholderImage(),
            ),
            kSizedBoxWidthSM,
            // Property Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: MyText(
                          property.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: MyText(
                          property.formattedStatus,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Iconsax.location,
                          size: 16, color: AppColors.neutral500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: MyText(
                          property.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPropertyInfo(
                          Icons.bed, '${property.bedrooms} beds'),
                      kSizedBoxWidthSM,
                      _buildPropertyInfo(
                          Icons.bathtub, '${property.bathrooms} baths'),
                      kSizedBoxWidthSM,
                      _buildPropertyInfo(
                          Iconsax.ruler, '${property.size} sqm'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(
                        property.formattedPrice,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: MyText(
                              property.formattedCategory,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (property.propertyType.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.purple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: MyText(
                                property.formattedType,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.purple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
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
      children: [
        Icon(icon, size: 16, color: AppColors.neutral500),
        const SizedBox(width: 4),
        MyText(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.neutral500,
          ),
        ),
      ],
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
      case 'off_market':
        return Colors.grey;
      default:
        return AppColors.neutral500;
    }
  }
}
