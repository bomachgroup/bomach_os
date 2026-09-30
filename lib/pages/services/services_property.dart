import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/responsive_table.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/services/widget/service_form_dialog.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
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
          ResponsiveTable<int>(
            items: List.generate(10, (i) => i),
            columns: _createColumns(),
            rowBuilder: (index, _) => _createDataRow(context, index),
            mobileCardBuilder: (index, _) => _buildMobileCard(context, index),
            onRowTap: (index) => context.go(RouteConstants.serviceDetail),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context, int index) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.borderSubtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              Expanded(
                child: Text(
                  'Real Estate',
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Iconsax.arrow_right_3,
                  size: 16, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 16),
          _buildMobileInfoItem(
              'Sub service', 'Development and sales, Buy/Sales'),
          _buildMobileInfoItem('Inventory', 'Fortress city, Bethel city'),
          _buildMobileInfoItem('Sales', '10 Orders / sales - 35,00'),
          _buildMobileInfoItem('Date', '02-11-2024'),
        ],
      ),
    );
  }

  Widget _buildMobileInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
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

  DataRow _createDataRow(BuildContext context, int index) {
    return DataRow(cells: <DataCell>[
      DataCell(
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
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              '- Buy/Sales of property',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
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
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            Text(
              '- Bethel city Estate',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
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
          '02-11-2024',
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
  }
}
