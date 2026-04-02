import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bms_front_end/components/text/my_text.dart';

class PaginatorFooter extends StatelessWidget {
  final int totalItems;
  final int limit;
  final int currentPage;

  // Made nullable. If null, the widget shrinks.
  final Function(int newPage)? onPageChanged;

  // Made nullable. If null, the dropdown is disabled.
  final Function(int newLimit)? onLimitChanged;

  final bool isMobile;
  final List<int> limitOptions;

  const PaginatorFooter({
    super.key,
    required this.totalItems,
    required this.limit,
    required this.currentPage,
    this.onPageChanged,
    this.onLimitChanged,
    this.isMobile = false,
    this.limitOptions = const [10, 20, 50, 100],
  });

  @override
  Widget build(BuildContext context) {
    // Guard Clause
    if (onPageChanged == null) {
      return const SizedBox.shrink();
    }

    // 1. Calculate Total Pages
    final int totalPages = (totalItems / limit).ceil();

    // 2. Calculate Display Range (e.g., "1 to 10")
    final int startItem = totalItems == 0 ? 0 : ((currentPage - 1) * limit) + 1;
    final int endItem = min(currentPage * limit, totalItems);

    // 3. Explicit Navigation Logic
    // If list items (totalItems) don't exceed limit, totalPages will be 1.
    // Therefore (1 < 1) is false, disabling the next button.
    final bool canGoNext = currentPage < totalPages;
    final bool canGoPrev = currentPage > 1;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // --- Limit Dropdown ---
        IgnorePointer(
          ignoring: onLimitChanged == null,
          child: PopupMenuButton<int>(
            enabled: onLimitChanged != null,
            onSelected: onLimitChanged,
            itemBuilder: (context) => limitOptions
                .map((val) => PopupMenuItem(
                      value: val,
                      child: Text("$val rows"),
                    ))
                .toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: onLimitChanged == null
                    ? Colors.grey.shade100
                    : Colors.white,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MyText('Showing', color: Colors.grey),
                  const SizedBox(width: 8),
                  MyText('$limit', weight: 600),
                  const SizedBox(width: 8),
                  Icon(Icons.keyboard_arrow_down,
                      size: 18,
                      color: onLimitChanged == null
                          ? Colors.grey.shade300
                          : Colors.grey.shade600)
                ],
              ),
            ),
          ),
        ),

        // --- Text Summary ---
        if (!isMobile)
          MyText(
            'Showing $startItem to $endItem out of $totalItems records',
            color: Colors.grey,
            size: 13,
          ),

        // --- Pagination Controls ---
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Previous Button
            IconButton(
              onPressed:
                  canGoPrev ? () => onPageChanged!(currentPage - 1) : null,
              icon: Icon(
                Icons.chevron_left,
                size: 20,
                color: canGoPrev ? Colors.black : Colors.grey.shade300,
              ),
            ),

            // Page Numbers
            ..._generatePageNumbers(totalPages).map((page) {
              return _buildPageNumber(
                page.toString(),
                isActive: page == currentPage,
                onTap: () => onPageChanged!(page),
              );
            }),

            // Next Button
            IconButton(
              onPressed:
                  canGoNext ? () => onPageChanged!(currentPage + 1) : null,
              icon: Icon(
                Icons.chevron_right,
                size: 20,
                color: canGoNext ? Colors.black : Colors.grey.shade300,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildPageNumber(String num,
      {bool isActive = false, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0055FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            num,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  List<int> _generatePageNumbers(int totalPages) {
    if (totalPages <= 5) {
      return List.generate(totalPages, (i) => i + 1);
    }

    Set<int> pages = {};
    pages.add(1);
    pages.add(totalPages);

    int start = max(2, currentPage - 1);
    int end = min(totalPages - 1, currentPage + 1);

    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    List<int> sortedPages = pages.toList()..sort();
    return sortedPages;
  }
}
