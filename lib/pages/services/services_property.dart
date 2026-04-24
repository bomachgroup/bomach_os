import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/pages/services/widget/service_form_dialog.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class ServicesPropertyPage extends StatefulWidget {
  const ServicesPropertyPage({super.key});

  @override
  State<ServicesPropertyPage> createState() => ServicesPropertyPageState();
}

class ServicesPropertyPageState extends State<ServicesPropertyPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Services',
        subtitle: 'Manage property service offerings and sub-services',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(
            Iconsax.add_circle,
            color: AppColors.textOnPrimary,
            size: 18,
          ),
          child: 'Add Service',
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const ServiceFormDialog(),
            );
          },
        ),
      ),
      children: [
        _buildToolbar(),
        _buildTableCard(context),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 720;
          final search = MyTextFormField(
            controller: _searchController,
            hintText: 'Search services...',
            height: 48,
            leading: const Icon(
              Iconsax.search_normal,
              size: 18,
              color: AppColors.textMuted,
            ),
          );

          final sortBtn = MyOutlinedButton(
            height: 48,
            icon: const Icon(
              Iconsax.sort,
              size: 16,
              color: AppColors.primary,
            ),
            child: 'Sort',
            onTap: () {},
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: sortBtn),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: search),
              const SizedBox(width: 16),
              sortBtn,
            ],
          );
        },
      ),
    );
  }

  Widget _buildTableCard(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Service catalog', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        'Showing 10 services with inventory and orders',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Property services',
                  tone: StatusTone.primary,
                  icon: Iconsax.home_2,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 1080),
                child: DataTable(
                  dataRowMinHeight: 68,
                  dataRowMaxHeight: 84,
                  columnSpacing: 28,
                  horizontalMargin: 20,
                  headingRowColor: WidgetStateProperty.all(
                    AppColors.surfaceMuted,
                  ),
                  columns: _createColumns(),
                  rows: _createRows(context),
                  showBottomBorder: true,
                  dividerThickness: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: _headerText('Service name'),
      ),
      DataColumn(label: _headerText('Sub service')),
      DataColumn(label: _headerText('Added inventory')),
      DataColumn(label: _headerText('Order sales count')),
      DataColumn(label: _headerText('Author date')),
      DataColumn(label: _headerText('Notes/Comments')),
    ];
  }

  Widget _headerText(String label) {
    return Text(
      label,
      style: AppTextStyles.bodySm.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  List<DataRow> _createRows(BuildContext context) {
    return List.generate(10, (index) {
      return DataRow(cells: <DataCell>[
        DataCell(
          onTap: () {
            context.go(RouteConstants.serviceDetail);
          },
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: AppRadii.brSm,
                ),
                child: const Icon(
                  Iconsax.home_2,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Real Estate',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '- Development and sales',
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                '- Buy/Sales of property',
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '- Fortress city Estate',
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                '- Bethel city Estate',
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        DataCell(
          Text(
            '10 Orders / sales - 35,00',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
          ),
        ),
        DataCell(
          Text(
            '11/02/2024',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
          ),
        ),
        DataCell(
          Text(
            '—',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textMuted),
          ),
        ),
      ]);
    });
  }
}
