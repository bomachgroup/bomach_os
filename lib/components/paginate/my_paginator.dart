import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';

class MyPaginator extends StatefulWidget {
  final int totalRecords;
  final void Function(int page, int limit)? onPageChanged;

  const MyPaginator({
    super.key,
    this.totalRecords = 0,
    this.onPageChanged,
  });

  @override
  MyPaginatorState createState() => MyPaginatorState();
}

class MyPaginatorState extends State<MyPaginator> {
  int currentPage = 1;
  int rowsPerPage = 10;

  List<int> rowsOptions = [10, 20, 50];

  int get totalPages =>
      widget.totalRecords == 0 ? 1 : (widget.totalRecords / rowsPerPage).ceil();

  void _goToPage(int page) {
    if (page < 1 || page > totalPages) return;
    setState(() => currentPage = page);
    widget.onPageChanged?.call(page, rowsPerPage);
  }

  void _changeLimit(int limit) {
    setState(() {
      rowsPerPage = limit;
      currentPage = 1;
    });
    widget.onPageChanged?.call(1, limit);
  }

  /// Returns up to 5 page numbers centred around [currentPage].
  List<int> _visiblePages() {
    if (totalPages <= 5) return List.generate(totalPages, (i) => i + 1);
    int start = (currentPage - 2).clamp(1, totalPages - 4);
    return List.generate(5, (i) => start + i);
  }

  @override
  Widget build(BuildContext context) {
    final int start =
        widget.totalRecords == 0 ? 0 : ((currentPage - 1) * rowsPerPage) + 1;
    final int end = widget.totalRecords == 0
        ? 0
        : (start + rowsPerPage - 1).clamp(1, widget.totalRecords);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rows-per-page selector
          if (!isSmallScreen(context))
            Row(
              children: [
                const MyText("Showing",
                    style: TextStyle(color: AppColors.grey2)),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<int>(
                    focusColor: AppColors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    value: rowsPerPage,
                    underline: const SizedBox(),
                    items: rowsOptions.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: MyText("$value"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) _changeLimit(value);
                    },
                  ),
                ),
              ],
            )
          else
            const SizedBox(),

          // Record count label
          if (isLargeScreen(context))
            MyText(
              widget.totalRecords == 0
                  ? 'No records'
                  : "Showing $start to $end out of ${widget.totalRecords} records",
              style: TextStyle(color: Colors.grey[600]),
            ),

          // Page buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 1 ? () => _goToPage(currentPage - 1) : null,
              ),
              ..._visiblePages().map((i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => _goToPage(i),
                      child: Container(
                        alignment: Alignment.center,
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: currentPage == i
                                ? AppColors.blue
                                : AppColors.white,
                          ),
                          borderRadius: BorderRadius.circular(
                              currentPage == i ? 10 : 35),
                          color: currentPage == i ? null : AppColors.white,
                        ),
                        child: MyText('$i',
                            size: 14,
                            weight: currentPage == i ? 700 : 400),
                      ),
                    ),
                  )),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => _goToPage(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
