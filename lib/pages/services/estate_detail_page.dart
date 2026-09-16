import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/services/models/estate_models.dart';
import 'package:bomach_os/pages/services/widget/add_plot_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/screen_size.dart';
import 'package:bomach_os/src/utils/number_formatting.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Estate Details',
        subtitle: widget.estate.estateName,
        leading: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: AppRadii.brMd,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.brMd,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: const Icon(Iconsax.arrow_left_2,
                  size: 18, color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
      children: [
        _buildEstateInfoCard(),
        _buildPlotsHeader(),
        _buildPlotStats(),
        _buildFilterRow(),
        _buildPlotsGrid(),
      ],
    );
  }

  Widget _buildEstateInfoCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: AppRadii.brMd,
                ),
                child: const Icon(Iconsax.building_4,
                    size: 32, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.estate.name,
                      style: AppTextStyles.h1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Iconsax.location,
                            size: 16, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.estate.location,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              StatusChip(
                label: widget.estate.status.isNotEmpty
                    ? widget.estate.status
                    : widget.estate.estateStatus,
                tone: _statusTone(widget.estate.estateStatus),
              ),
            ],
          ),
          if (widget.estate.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              widget.estate.description,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 20),
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
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: AppRadii.brSm,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.bodyMd.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlotsHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              const Text('Estate Plots', style: AppTextStyles.h2),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 240,
                    child: MyTextFormField(
                      hintText: 'Search plots...',
                      height: 44,
                      leading: const Icon(Iconsax.search_normal,
                          size: 18, color: AppColors.textMuted),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                  MyElevatedButton(
                    height: 44,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    icon: const Icon(Iconsax.add_circle,
                        color: AppColors.white, size: 18),
                    child: 'Add Plot',
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
                    height: 44,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    bgColor: AppColors.surface,
                    textColor: AppColors.primary,
                    borderColor: AppColors.primary,
                    icon: const Icon(Iconsax.receipt_2,
                        color: AppColors.primary, size: 18),
                    child: 'Generate Invoice',
                    onTap: () {},
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlotStats() {
    final availablePlots = _plots.where((p) => p.status == 'Available').length;
    final reservedPlots = _plots.where((p) => p.status == 'Reserved').length;
    final soldPlots = _plots.where((p) => p.status == 'Sold').length;

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 760;
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
            child: _statCard(
                'Total Plots', '${_plots.length}', Iconsax.element_4,
                StatusTone.primary),
          ),
          SizedBox(
            width: cardWidth,
            child: _statCard('Available', '$availablePlots',
                Iconsax.tick_circle, StatusTone.success),
          ),
          SizedBox(
            width: cardWidth,
            child: _statCard(
                'Reserved', '$reservedPlots', Iconsax.clock, StatusTone.warning),
          ),
          SizedBox(
            width: cardWidth,
            child: _statCard(
                'Sold', '$soldPlots', Iconsax.verify, StatusTone.info),
          ),
        ],
      );
    });
  }

  Widget _statCard(
      String label, String value, IconData icon, StatusTone tone) {
    final palette = _tonePalette(tone);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: palette.$1,
              borderRadius: AppRadii.brMd,
            ),
            child: Icon(icon, color: palette.$2, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value,
                    style: AppTextStyles.h2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _tonePalette(StatusTone tone) {
    switch (tone) {
      case StatusTone.success:
        return (AppColors.successSubtle, AppColors.success);
      case StatusTone.warning:
        return (AppColors.warningSubtle, AppColors.warning);
      case StatusTone.danger:
        return (AppColors.dangerSubtle, AppColors.danger);
      case StatusTone.info:
        return (AppColors.infoSubtle, AppColors.info);
      case StatusTone.primary:
        return (AppColors.primarySubtle, AppColors.primary);
      case StatusTone.neutral:
        return (AppColors.surfaceMuted, AppColors.textSecondary);
    }
  }

  Widget _buildFilterRow() {
    final filters = ['All', 'Available', 'Reserved', 'Sold', 'Under Offer'];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: filters.map(_buildFilterChip).toList(),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        borderRadius: AppRadii.brPill,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: AppRadii.brPill,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderSubtle,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
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

  Widget _buildPlotsGrid() {
    if (_filteredPlots.isEmpty) {
      return const AppCard(
        padding: EdgeInsets.all(12),
        child: EmptyState(
          icon: Iconsax.element_4,
          title: 'No plots found',
          subtitle: 'Adjust your filters or add a plot to get started.',
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
    final tone = _plotStatusTone(plot.status);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  plot.plotNumber,
                  style: AppTextStyles.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusChip(
                label: plot.status,
                tone: tone,
                dense: true,
              ),
            ],
          ),
          if (plot.blockNumber != null) ...[
            const SizedBox(height: 4),
            Text(
              plot.blockNumber!,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Iconsax.ruler,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '${plot.size.toStringAsFixed(0)} sqm',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            plot.price.toNaira(decimals: 0),
            style: AppTextStyles.h4.copyWith(color: AppColors.primary),
          ),
          if (plot.buyerName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Iconsax.profile_circle,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    plot.buyerName!,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  StatusTone _statusTone(String status) {
    switch (status) {
      case 'active':
        return StatusTone.success;
      case 'development':
      case 'under_development':
        return StatusTone.warning;
      case 'sold_out':
        return StatusTone.primary;
      case 'completed':
        return StatusTone.info;
      case 'suspended':
        return StatusTone.danger;
      case 'inactive':
      default:
        return StatusTone.neutral;
    }
  }

  StatusTone _plotStatusTone(String status) {
    switch (status) {
      case 'Available':
        return StatusTone.success;
      case 'Reserved':
        return StatusTone.warning;
      case 'Sold':
        return StatusTone.primary;
      case 'Under Offer':
        return StatusTone.info;
      default:
        return StatusTone.neutral;
    }
  }
}

