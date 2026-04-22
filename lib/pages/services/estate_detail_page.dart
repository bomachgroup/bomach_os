import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/models/estate_models.dart';
import 'package:bms_front_end/pages/services/widget/add_plot_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';

class EstateDetailPage extends StatefulWidget {
  final Estate estate;

  const EstateDetailPage({
    super.key,
    required this.estate,
  });

  @override
  State<EstateDetailPage> createState() => _EstateDetailPageState();
}

class _EstateDetailPageState extends State<EstateDetailPage> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  // Sample plots data
  final List<EstatePlot> _plots = [];

  @override
  void initState() {
    super.initState();
    _initializeSamplePlots();
  }

  void _initializeSamplePlots() {
    // Generate sample plots for the estate
    for (int i = 1; i <= 12; i++) {
      final statuses = ['Available', 'Reserved', 'Sold', 'Under Offer'];
      final types = ['Residential', 'Commercial'];
      final status = statuses[i % statuses.length];

      _plots.add(
        EstatePlot(
          id: i.toString(),
          estateId: widget.estate.id.toString(),
          estateName: widget.estate.name,
          plotNumber: 'Plot ${i.toString().padLeft(3, '0')}',
          blockNumber: 'Block ${String.fromCharCode(65 + i ~/ 4)}',
          size: 500 + (i * 50),
          plotType: types[i % types.length],
          status: status,
          price: 5000000 + (i * 500000),
          description:
              'Prime ${types[i % types.length].toLowerCase()} plot in excellent location',
          buyerName:
              status == 'Sold' || status == 'Reserved' ? 'Client $i' : null,
          buyerPhone: status == 'Sold' || status == 'Reserved'
              ? '+234 80X XXX XX${i.toString().padLeft(2, '0')}'
              : null,
          createdDate: DateTime.now().subtract(Duration(days: i * 10)),
          reservationDate: status == 'Reserved'
              ? DateTime.now().subtract(const Duration(days: 5))
              : null,
          saleDate: status == 'Sold'
              ? DateTime.now().subtract(const Duration(days: 30))
              : null,
        ),
      );
    }
  }

  List<EstatePlot> get _filteredPlots {
    var filtered = _plots;

    // Apply status filter
    if (_selectedFilter != 'All') {
      filtered =
          filtered.where((plot) => plot.status == _selectedFilter).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((plot) =>
              plot.plotNumber
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              (plot.blockNumber
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false) ||
              (plot.buyerName
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }

    return filtered;
  }

  void _addPlot(EstatePlot plot) {
    setState(() {
      _plots.add(plot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Button and Header
        Row(
          children: [
            IconButton(
              icon: const Icon(Iconsax.arrow_left_2),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: MyText(
                'Estate Details',
                style: AppText.displayLg,
              ),
            ),
          ],
        ),
        kSizedBox,

        // Estate Info Card
        _buildEstateInfoCard(),
        kSizedBox,

        // Plots Section Header
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const MyText(
                    'Estate Plots',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      SizedBox(
                        width: 200,
                        child: MyTextFormField(
                          hintText: 'Search plots...',
                          leading: Icon(
                            Iconsax.search_normal,
                            color: AppColors.neutral500.withValues(alpha: 0.5),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                      ),
                      MyElevatedButton(
                        icon: const Icon(
                          Iconsax.add_circle,
                          color: AppColors.white,
                        ),
                        child: "Add Plot",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AddPlotDialog(
                                estate: widget.estate,
                                onPlotAdded: _addPlot,
                              );
                            },
                          );
                        },
                      ),
                      MyElevatedButton(
                        icon: const Icon(
                          Iconsax.add_circle,
                          color: AppColors.white,
                        ),
                        child: "Generate Invoice",
                        onTap: () {},
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,

        // Plot Stats
        _buildPlotStats(),
        kSizedBox,

        // Filter Chips
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildFilterChip('All'),
            _buildFilterChip('Available'),
            _buildFilterChip('Reserved'),
            _buildFilterChip('Sold'),
            _buildFilterChip('Under Offer'),
          ],
        ),
        kSizedBox,

        // Plots Grid
        _buildPlotsGrid(),
      ],
    );
  }

  Widget _buildEstateInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      widget.estate.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Iconsax.location,
                            size: 18, color: AppColors.neutral500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: MyText(
                            widget.estate.location,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.neutral500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.estate.status)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: MyText(
                  widget.estate.status,
                  style: TextStyle(
                    color: _getStatusColor(widget.estate.status),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          kSizedBox,
          MyText(
            widget.estate.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.neutral500,
              height: 1.5,
            ),
          ),
          kSizedBox,
          const Divider(),
          kSizedBoxSM,
          Wrap(
            spacing: 32,
            runSpacing: 16,
            children: [
              _buildInfoItem(
                  'Developer', widget.estate.developer, Iconsax.building_4),
              _buildInfoItem(
                  'Total Area',
                  '${widget.estate.totalArea?.toStringAsFixed(0) ?? '0'} sqm',
                  Iconsax.ruler),
              _buildInfoItem(
                  'Location', widget.estate.location, Iconsax.location),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutral500,
              ),
            ),
            MyText(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlotStats() {
    final availablePlots = _plots.where((p) => p.status == 'Available').length;
    final reservedPlots = _plots.where((p) => p.status == 'Reserved').length;
    final soldPlots = _plots.where((p) => p.status == 'Sold').length;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard(
            'Total Plots', '${_plots.length}', Iconsax.element_4, AppColors.primary),
        _buildStatCard(
            'Available', '$availablePlots', Iconsax.tick_circle, Colors.green),
        _buildStatCard(
            'Reserved', '$reservedPlots', Iconsax.clock, Colors.orange),
        _buildStatCard('Sold', '$soldPlots', Iconsax.tick_circle, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            radius: 18,
            child: Icon(icon, color: color, size: 18),
          ),
          kSizedBoxWidthSM,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              MyText(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.neutral500,
                ),
              ),
            ],
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
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral300,
          ),
        ),
        child: MyText(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.neutral500,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPlotsGrid() {
    if (_filteredPlots.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            children: [
              Icon(
                Iconsax.element_4,
                size: 64,
                color: AppColors.neutral500.withValues(alpha: 0.5),
              ),
              kSizedBox,
              const MyText(
                'No plots found',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isLargeScreen(context)
            ? 4
            : isMediumScreen(context)
                ? 3
                : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: _filteredPlots.length,
      itemBuilder: (context, index) {
        final plot = _filteredPlots[index];
        return _buildPlotCard(plot);
      },
    );
  }

  Widget _buildPlotCard(EstatePlot plot) {
    final statusColor = _getStatusColor(plot.status);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: MyText(
                  plot.plotNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: MyText(
                  plot.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (plot.blockNumber != null) ...[
            const SizedBox(height: 4),
            MyText(
              plot.blockNumber!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.neutral500,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Iconsax.ruler, size: 14, color: AppColors.neutral500),
              const SizedBox(width: 4),
              MyText(
                '${plot.size.toStringAsFixed(0)} sqm',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          MyText(
            '₦${plot.price.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (plot.buyerName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Iconsax.profile_circle, size: 14, color: AppColors.neutral500),
                const SizedBox(width: 4),
                Expanded(
                  child: MyText(
                    plot.buyerName!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.neutral500,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
      case 'Active':
        return Colors.green;
      case 'Reserved':
      case 'Under Development':
        return Colors.orange;
      case 'Sold':
        return Colors.purple;
      case 'Under Offer':
        return Colors.blue;
      case 'Planning':
        return Colors.cyan;
      case 'Completed':
        return Colors.teal;
      default:
        return AppColors.neutral500;
    }
  }
}
