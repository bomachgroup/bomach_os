import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/cards/real_estate_card.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/widget/add_property_dialog.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PropertyListPage extends StatefulWidget {
  const PropertyListPage({super.key});

  @override
  State<PropertyListPage> createState() => _PropertyListPageState();
}

class _PropertyListPageState extends State<PropertyListPage> {
  bool _isGridView = true;
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _properties = [
    {
      'name': 'Aso Villa Estate',
      'type': 'Residential',
      'category': 'For Sale',
      'location': 'Asokoro, Abuja',
      'price': '₦45,000,000',
      'size': '500 sqm',
      'bedrooms': 5,
      'bathrooms': 4,
      'parking': 3,
      'status': 'Available',
      'description':
          'Luxury 5-bedroom duplex in prestigious Aso Villa Estate with modern amenities and 24/7 security.',
      'image': 'assets/image/man-demo.png',
    },
    {
      'name': 'Fortress City Estate',
      'type': 'Residential',
      'category': 'For Sale',
      'location': 'Centenary City, Enugu',
      'price': '₦28,500,000',
      'size': '400 sqm',
      'bedrooms': 4,
      'bathrooms': 3,
      'parking': 2,
      'status': 'Available',
      'description':
          'Beautiful 4-bedroom detached house in serene environment with excellent infrastructure.',
      'image': 'assets/image/man-demo.png',
    },
    {
      'name': 'Bethel City Estate',
      'type': 'Residential',
      'category': 'For Rent',
      'location': 'Independence Layout, Enugu',
      'price': '₦2,500,000/year',
      'size': '350 sqm',
      'bedrooms': 4,
      'bathrooms': 3,
      'parking': 2,
      'status': 'Reserved',
      'description':
          'Spacious 4-bedroom duplex available for rent in prime location with modern facilities.',
      'image': 'assets/image/man-demo.png',
    },
    {
      'name': 'Diamond Heights',
      'type': 'Commercial',
      'category': 'For Lease',
      'location': 'Ogui Road, Enugu',
      'price': '₦5,000,000/year',
      'size': '800 sqm',
      'bedrooms': 0,
      'bathrooms': 6,
      'parking': 10,
      'status': 'Available',
      'description':
          'Prime commercial property suitable for office space, shops, or mixed-use development.',
      'image': 'assets/image/man-demo.png',
    },
    {
      'name': 'Victoria Gardens',
      'type': 'Land',
      'category': 'For Sale',
      'location': 'Trans-Ekulu, Enugu',
      'price': '₦12,000,000',
      'size': '600 sqm',
      'bedrooms': 0,
      'bathrooms': 0,
      'parking': 0,
      'status': 'Available',
      'description':
          'Fenced plot of land with C of O in rapidly developing area, perfect for development.',
      'image': 'assets/image/man-demo.png',
    },
    {
      'name': 'Royal Palm Apartments',
      'type': 'Residential',
      'category': 'For Sale',
      'location': 'GRA, Enugu',
      'price': '₦65,000,000',
      'size': '750 sqm',
      'bedrooms': 6,
      'bathrooms': 5,
      'parking': 4,
      'status': 'Under Construction',
      'description':
          'Luxury 6-bedroom mansion with swimming pool, gym, and smart home features.',
      'image': 'assets/image/man-demo.png',
    },
  ];

  List<Map<String, dynamic>> get _filteredProperties {
    if (_selectedFilter == 'All') return _properties;
    return _properties
        .where((prop) =>
            prop['category'] == _selectedFilter ||
            prop['type'] == _selectedFilter ||
            prop['status'] == _selectedFilter)
        .toList();
  }

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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'Properties',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(height: 8),
                      MyText(
                        'Manage your property inventory and listings',
                        style: AppText.black_400_14,
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
                          hintText: 'Search properties...',
                          leading: Icon(
                            Icons.search,
                            color: AppColors.grey1.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      const SortBar(text: "Sort"),
                      MyElevatedButton(
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
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

        // Filter and View Toggle
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('For Sale'),
                  _buildFilterChip('For Rent'),
                  _buildFilterChip('For Lease'),
                  _buildFilterChip('Available'),
                  _buildFilterChip('Reserved'),
                ],
              ),
            ),
            kSizedBoxWidthSM,
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.grid_view,
                    color: _isGridView ? AppColors.blue : AppColors.grey1,
                  ),
                  onPressed: () {
                    setState(() {
                      _isGridView = true;
                    });
                  },
                  tooltip: 'Grid View',
                ),
                IconButton(
                  icon: Icon(
                    Icons.view_list,
                    color: !_isGridView ? AppColors.blue : AppColors.grey1,
                  ),
                  onPressed: () {
                    setState(() {
                      _isGridView = false;
                    });
                  },
                  tooltip: 'List View',
                ),
              ],
            ),
          ],
        ),

        kSizedBox,

        // Property List/Grid
        _isGridView ? _buildGridView() : _buildListView(),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard('Total Properties', '${_properties.length}',
            Icons.home_work, AppColors.blue),
        _buildStatCard(
            'Available',
            '${_properties.where((p) => p['status'] == 'Available').length}',
            Icons.check_circle,
            Colors.green),
        _buildStatCard(
            'Reserved',
            '${_properties.where((p) => p['status'] == 'Reserved').length}',
            Icons.schedule,
            Colors.orange),
        _buildStatCard(
            'Sold/Rented',
            '${_properties.where((p) => p['status'] == 'Sold').length}',
            Icons.done_all,
            Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey4),
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
              color: AppColors.grey1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blue : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.blue : AppColors.grey4,
          ),
        ),
        child: MyText(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.grey1,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      childAspectRatio: isLargeScreen(context)
          ? 0.86
          : isMediumScreen(context)
              ? 0.86
              : 0.75,
      shrinkWrap: true,
      crossAxisCount: isLargeScreen(context)
          ? 3
          : isMediumScreen(context)
              ? 2
              : 1,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: _filteredProperties.map((property) {
        return RealEstateCard(
          image: property['image'],
          title: property['name'],
          details: property['description'],
          buttonText: "View Details",
          onTap: () {
            context.go(RouteConstants.propertyDetail);
          },
        );
      }).toList(),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredProperties.length,
      separatorBuilder: (context, index) => kSizedBoxSM,
      itemBuilder: (context, index) {
        final property = _filteredProperties[index];
        return _buildPropertyListItem(property);
      },
    );
  }

  Widget _buildPropertyListItem(Map<String, dynamic> property) {
    final statusColor = _getStatusColor(property['status']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey4),
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
          context.go(RouteConstants.propertyDetail);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                property['image'],
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
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
                          property['name'],
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
                          property['status'],
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
                      const Icon(Icons.location_on,
                          size: 16, color: AppColors.grey1),
                      const SizedBox(width: 4),
                      MyText(
                        property['location'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.grey1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPropertyInfo(
                          Icons.bed, '${property['bedrooms']} beds'),
                      kSizedBoxWidthSM,
                      _buildPropertyInfo(
                          Icons.bathtub, '${property['bathrooms']} baths'),
                      kSizedBoxWidthSM,
                      _buildPropertyInfo(
                          Icons.square_foot, '${property['size']}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText(
                        property['price'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.blue,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: MyText(
                          property['category'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

  Widget _buildPropertyInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey1),
        const SizedBox(width: 4),
        MyText(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.grey1,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Reserved':
        return Colors.orange;
      case 'Sold':
      case 'Rented':
        return Colors.purple;
      case 'Under Construction':
        return Colors.blue;
      case 'Pending':
        return Colors.amber;
      default:
        return AppColors.grey1;
    }
  }
}
