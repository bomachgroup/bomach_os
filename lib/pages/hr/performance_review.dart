import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chart/star_5.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/nav/three_dot_pop.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/hr/widget/add_performance_review_dialog.dart';
import 'package:bomach_os/pages/hr/widget/view_performance_review_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'controller/performance_review_controller.dart';
import 'models/performance_review.dart';

class PerformanceReviewPage extends StatelessWidget {
  const PerformanceReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PerformanceReviewController controller =
        Get.put(PerformanceReviewController());

    return PageScaffold(
      header: PageHeader(
        title: 'Performance Review',
        subtitle: 'Track and manage employee performance evaluations.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle, color: AppColors.white, size: 18),
          child: "New Review",
          onTap: () => showDialog(
            context: context,
            builder: (context) => const AddPerformanceReviewDialog(),
          ),
        ),
      ),
      children: [
        // Search & Filter Bar
        const AppCard(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: AppCardElevation.sm,
          child: Row(
            children: [
              Expanded(
                child: MyTextFormField(
                  hintText: 'Search by name or ID...',
                  height: 44,
                  leading: Icon(Iconsax.search_normal,
                      size: 18, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),

        // Table Card
        AppCard(
          padding: EdgeInsets.zero,
          elevation: AppCardElevation.sm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reviews Registry', style: AppTextStyles.h3),
                    SizedBox(height: 4),
                    Text(
                      'Historical performance data for all staff',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.performanceReviews.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text("No reviews found."),
                    ),
                  );
                }

                if (context.isMobile) {
                  return Column(
                    children: controller.performanceReviews.map((review) => _buildMobileCard(context, review)).toList(),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: DataTable(
                      dataRowMinHeight: 68,
                      dataRowMaxHeight: 68,
                      columnSpacing: 24,
                      horizontalMargin: 24,
                      headingRowColor:
                          WidgetStateProperty.all(AppColors.surfaceMuted),
                      headingTextStyle: AppTextStyles.bodySm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                      columns: _createColumns(),
                      rows: _createRows(context, controller.performanceReviews),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCard(BuildContext context, PerformanceReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.employeeId,
                style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
              const Star5(),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'ID: ${review.employeeId}',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Period',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    review.reviewPeriod,
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Review Date',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    review.reviewDate?.toIso8601String().split('T').first ?? '',
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Iconsax.eye, size: 18, color: AppColors.primary),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ViewPerformanceReviewDialog(review: review),
                ),
              ),
              const ThreeDotPop(),
            ],
          ),
        ],
      ),
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(label: Text("Employee")),
      const DataColumn(label: Text("Review Period")),
      const DataColumn(label: Text("Date")),
      const DataColumn(label: Text("Overall Rating")),
      const DataColumn(label: Text("Action")),
    ];
  }

  List<DataRow> _createRows(
      BuildContext context, List<PerformanceReview> reviews) {
    return reviews.map((review) {
      return DataRow(cells: <DataCell>[
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                review.employeeId,
                style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'ID: ${review.employeeId}',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        DataCell(Text(review.reviewPeriod, style: AppTextStyles.bodyMd)),
        DataCell(Text(
          review.reviewDate?.toIso8601String().split('T').first ?? '',
          style: AppTextStyles.bodyMd,
        )),
        const DataCell(Star5()),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon:
                    const Icon(Iconsax.eye, size: 18, color: AppColors.primary),
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) =>
                      ViewPerformanceReviewDialog(review: review),
                ),
              ),
              const ThreeDotPop(),
            ],
          ),
        ),
      ]);
    }).toList();
  }
}

