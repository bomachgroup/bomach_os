import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/cards/real_estate_card.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/models/estate_models.dart';
import 'package:bms_front_end/pages/services/widget/add_estate_dialog.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EstateManagementPage extends StatefulWidget {
  const EstateManagementPage({super.key});

  @override
  State<EstateManagementPage> createState() => _EstateManagementPageState();
}

class _EstateManagementPageState extends State<EstateManagementPage> {
  bool _isGridView = true;
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // Sample estates data
  final List<Estate> _estates = [
    Estate(
      id: '1',
      name: 'Aso Villa Estate',
      location: 'Asokoro, Abuja',
      description:
          'Premium residential estate with modern infrastructure and 24/7 security. Features include paved roads, street lights, water supply, and landscaped gardens.',
      developer: 'Bomach Properties Ltd',
      totalArea: 50000,
      totalPlots: 100,
      availablePlots: 45,
      soldPlots: 40,
      reservedPlots: 15,
      status: 'Active',
      createdDate: DateTime(2023, 1, 15),
      images: ['assets/image/man-demo.png'],
      contactPerson: 'John Doe',
      contactPhone: '+234 803 123 4567',
      contactEmail: 'john.doe@bomach.com',
    ),
    Estate(
      id: '2',
      name: 'Fortress City Estate',
      location: 'Centenary City, Enugu',
      description:
          'Luxury estate development with exceptional amenities including swimming pool, gym, and recreational centers.',
      developer: 'Fortress Homes',
      totalArea: 75000,
      totalPlots: 150,
      availablePlots: 80,
      soldPlots: 55,
      reservedPlots: 15,
      status: 'Active',
      createdDate: DateTime(2023, 3, 20),
      images: ['assets/image/man-demo.png'],
      contactPerson: 'Jane Smith',
      contactPhone: '+234 805 987 6543',
      contactEmail: 'jane.smith@fortress.com',
    ),
    Estate(
      id: '3',
      name: 'Victoria Gardens',
      location: 'Trans-Ekulu, Enugu',
      description:
          'Affordable housing estate with excellent road network and proximity to major facilities.',
      developer: 'Victoria Developers',
      totalArea: 35000,
      totalPlots: 80,
      availablePlots: 20,
      soldPlots: 50,
      reservedPlots: 10,
      status: 'Active',
      createdDate: DateTime(2022, 11, 10),
      images: ['assets/image/man-demo.png'],
      contactPerson: 'David Brown',
      contactPhone: '+234 806 111 2222',
      contactEmail: 'david@victoria.com',
    ),
    Estate(
      id: '4',
      name: 'Diamond Heights',
      location: 'Independence Layout, Enugu',
      description:
          'Under development estate with planned commercial and residential sections.',
      developer: 'Diamond Estates',
      totalArea: 100000,
      totalPlots: 200,
      availablePlots: 180,
      soldPlots: 10,
      reservedPlots: 10,
      status: 'Under Development',
      createdDate: DateTime(2024, 1, 5),
      images: ['assets/image/man-demo.png'],
      contactPerson: 'Sarah Johnson',
      contactPhone: '+234 807 333 4444',
      contactEmail: 'sarah@diamond.com',
    ),
  ];

  List<Estate> get _filteredEstates {
    var filtered = _estates;

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered =
          filtered.where((estate) => estate.status == _selectedFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((estate) =>
              estate.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              estate.location
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              estate.developer
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  void _addEstate(Estate estate) {
    setState(() {
      _estates.add(estate);
    });
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
                        'Estate Management',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(height: 8),
                      MyText(
                        'Manage your real estate developments and plots',
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
                          hintText: 'Search estates...',
                          leading: Icon(
                            Icons.search,
                            color: AppColors.grey1.withValues(alpha: 0.5),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value ?? '';
                            });
                          },
                        ),
                      ),
                      const SortBar(text: "Sort"),
                      MyElevatedButton(
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.white,
                        ),
                        child: "Add Estate",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AddEstateDialog(
                                onEstateAdded: _addEstate,
                              );
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
                  _buildFilterChip('Active'),
                  _buildFilterChip('Under Development'),
                  _buildFilterChip('Planning'),
                  _buildFilterChip('Completed'),
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

        // Estate List/Grid
        _isGridView ? _buildGridView() : _buildListView(),
      ],
    );
  }

  Widget _buildStatsCards() {
    final totalEstates = _estates.length;
    final totalPlots = _estates.fold<int>(0, (sum, e) => sum + e.totalPlots);
    final availablePlots =
        _estates.fold<int>(0, (sum, e) => sum + e.availablePlots);
    final soldPlots = _estates.fold<int>(0, (sum, e) => sum + e.soldPlots);

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard('Total Estates', '$totalEstates', Icons.domain,
            AppColors.blue),
        _buildStatCard(
            'Total Plots', '$totalPlots', Icons.grid_on, Colors.purple),
        _buildStatCard('Available Plots', '$availablePlots',
            Icons.check_circle, Colors.green),
        _buildStatCard('Sold Plots', '$soldPlots', Icons.done_all, Colors.orange),
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
    if (_filteredEstates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(
                Icons.domain_disabled,
                size: 64,
                color: AppColors.grey1.withValues(alpha: 0.5),
              ),
              kSizedBox,
              const MyText(
                'No estates found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.grey1,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
      children: _filteredEstates.map((estate) {
        return RealEstateCard(
          image: estate.images.isNotEmpty
              ? estate.images.first
              : 'assets/image/man-demo.png',
          title: estate.name,
          details:
              '${estate.location}\n${estate.totalPlots} plots | ${estate.availablePlots} available',
          buttonText: "Manage Estate",
          onTap: () {
            context.go(RouteConstants.estateDetail, extra: estate);
          },
        );
      }).toList(),
    );
  }

  Widget _buildListView() {
    if (_filteredEstates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(
                Icons.domain_disabled,
                size: 64,
                color: AppColors.grey1.withValues(alpha: 0.5),
              ),
              kSizedBox,
              const MyText(
                'No estates found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.grey1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredEstates.length,
      separatorBuilder: (context, index) => kSizedBoxSM,
      itemBuilder: (context, index) {
        final estate = _filteredEstates[index];
        return _buildEstateListItem(estate);
      },
    );
  }

  Widget _buildEstateListItem(Estate estate) {
    final statusColor = _getStatusColor(estate.status);

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
          context.go(RouteConstants.estateDetail, extra: estate);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estate Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                estate.images.isNotEmpty
                    ? estate.images.first
                    : 'assets/image/man-demo.png',
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            kSizedBoxWidthSM,
            // Estate Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: MyText(
                          estate.name,
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
                          estate.status,
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
                      Expanded(
                        child: MyText(
                          estate.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.grey1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.business,
                          size: 16, color: AppColors.grey1),
                      const SizedBox(width: 4),
                      MyText(
                        estate.developer,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.grey1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildEstateInfo(
                          Icons.grid_on, '${estate.totalPlots} plots'),
                      kSizedBoxWidthSM,
                      _buildEstateInfo(Icons.check_circle,
                          '${estate.availablePlots} available'),
                      kSizedBoxWidthSM,
                      _buildEstateInfo(
                          Icons.done_all, '${estate.soldPlots} sold'),
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

  Widget _buildEstateInfo(IconData icon, String text) {
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
      case 'Active':
        return Colors.green;
      case 'Under Development':
        return Colors.orange;
      case 'Planning':
        return Colors.blue;
      case 'Completed':
        return Colors.purple;
      default:
        return AppColors.grey1;
    }
  }
}
