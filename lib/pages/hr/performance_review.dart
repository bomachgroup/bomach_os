import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chart/star_5.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/nav/three_dot_pop.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/hr/widget/add_performance_review_dialog.dart';
import 'package:bomach_os/pages/hr/widget/view_performance_review_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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
        trailing: PermissionGate(
          require: Perms.performanceReviewsCreate,
          child: MyElevatedButton(
            height: 48,
            icon: const Icon(Iconsax.add_circle,
                color: AppColors.white, size: 18),
            child: "New Review",
            onTap: () => showDialog(
              context: context,
              builder: (context) => const AddPerformanceReviewDialog(),
            ),
          ),
        ),
      ),
      children: [
        // Search & Filter Bar
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          elevation: AppCardElevation.sm,
          child: Row(
            children: [
              Expanded(
                child: MyTextFormField(
                  hintText: 'Search by name or ID...',
                  height: 44,
                  leading: const Icon(Iconsax.search_normal,
                      size: 18, color: AppColors.textMuted),
                  onChanged: controller.onSearchChanged,
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

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        'Error loading performance reviews: ${controller.errorMessage.value}',
                        style: const TextStyle(color: AppColors.danger),
                      ),
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

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: controller.performanceReviews
                        .map((review) => _buildMobileCard(context, review))
                        .toList(),
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
                style:
                    AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
              ),
              const Star5(),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'ID: ${review.employeeId}',
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
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
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
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
        ],
      ),
    );
  }
}
