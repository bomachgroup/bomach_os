import 'package:bms_front_end/src/constants/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/src/helper/responsive_breakpoints.dart';
import 'package:flutter/material.dart';

class DetailsViewPage extends StatelessWidget {
  final String title;
  final Map<String, String> details;

  const DetailsViewPage({
    super.key,
    required this.title,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = !context.breakpoint.isMobile;

    return SafeArea(
        child: Column(
      children: [
        _buildHeader(context),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            isLargeScreen
                ? _buildDetailsGrid(details, isLargeScreen)
                : _buildDetailsList(details),
          ],
        ),
      ],
    ));
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Flexible(child: _buildTitleBlock(title)),
        const Spacer(),
        _buildActionButton(
          label: 'Edit',
          color: AppColors.primary,
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          label: 'Delete',
          color: Colors.red,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildActionButton(
      {required String label,
      required Color color,
      required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTitleBlock(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Created 1/1/2024',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsList(Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        return _buildDetailItem(entry.key, entry.value, false);
      }).toList(),
    );
  }

  Widget _buildDetailsGrid(Map<String, String> data, bool isLargeScreen) {
    final items = data.entries.toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: List.generate((items.length / 2).ceil(), (index) {
          final index1 = index * 2;
          final index2 = index * 2 + 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDetailItem(
                    items[index1].key, items[index1].value, isLargeScreen),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: index2 < items.length
                    ? _buildDetailItem(
                        items[index2].key, items[index2].value, isLargeScreen)
                    : const SizedBox.shrink(),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, bool isLargeScreen) {
    final bool isDescription = label.toLowerCase().contains('description');

    return Padding(
      padding:
          isLargeScreen ? EdgeInsets.zero : const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: isLargeScreen ? FontWeight.normal : FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isDescription ? FontWeight.normal : FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (!isLargeScreen && !isDescription) const Divider(height: 16),
          if (isDescription) const SizedBox(height: 8),
        ],
      ),
    );
  }
}
