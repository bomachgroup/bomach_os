import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:flutter/material.dart';

/// A wrapper that renders a [DataTable] on large screens and a list of cards
/// on mobile/tablet to avoid horizontal scrolling.
class ResponsiveTable<T> extends StatelessWidget {
  const ResponsiveTable({
    super.key,
    required this.items,
    required this.columns,
    required this.rowBuilder,
    required this.mobileCardBuilder,
    this.onRowTap,
    this.onDetailsTap,
  });

  final List<T> items;
  final List<DataColumn> columns;
  final DataRow Function(T item, int index) rowBuilder;
  final Widget Function(T item, int index) mobileCardBuilder;
  final void Function(T item)? onRowTap;
  final void Function(T item)? onDetailsTap;

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: onRowTap != null ? () => onRowTap!(item) : null,
              child: mobileCardBuilder(item, index),
            ),
          );
        }),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.sm,
      child: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.sizeOf(context).width - 64,
            ),
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
              showBottomBorder: true,
              dividerThickness: 1,
              columns: columns,
              rows: List.generate(
                items.length,
                (index) => rowBuilder(items[index], index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
