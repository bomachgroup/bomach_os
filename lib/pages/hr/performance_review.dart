import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/chart/star_5.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/widget/add_performance_review_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_performance_review_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controller/performance_review_controller.dart';
import 'models/performance_review.dart';

class PerformanceReviewPage extends StatefulWidget {
  const PerformanceReviewPage({super.key});

  @override
  State<PerformanceReviewPage> createState() => PerformanceReviewPageState();
}

class PerformanceReviewPageState extends State<PerformanceReviewPage> {
  final ScrollController _scrollController = ScrollController();
  final PerformanceReviewController controller =
      Get.put(PerformanceReviewController());

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'Performance Review',
                        style: AppText.black_500_32,
                      ),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.white,
                    ),
                    child: "New Performance Review",
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AddPerformanceReviewDialog();
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 250,
                    child: MyTextFormField(
                      hintText: 'Search by name...',
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const Row(
                    spacing: 15,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SortBar(text: "Today"),
                      SortBar(text: "Status"),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        kSizedBoxSM,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ));
                      }

                      if (controller.performanceReviews.isEmpty) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("No reviews found."),
                        ));
                      }

                      return DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows:
                            _createRows(context, controller.performanceReviews),
                        showBottomBorder: true,
                      );
                    }),
                  ),
                ),
              ),
              // const MyPaginator(),
            ],
          ),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(label: MyText("Employee ID")),
      const DataColumn(label: MyText("Name & Email")),
      const DataColumn(label: MyText("Review Period")),
      const DataColumn(label: MyText("Date")),
      const DataColumn(label: MyText("Overall Rating")),
      const DataColumn(label: MyText("Action")),
    ];
  }

  List<DataRow> _createRows(
      BuildContext context, List<PerformanceReview> reviews) {
    return reviews.map((review) {
      return DataRow(cells: <DataCell>[
        DataCell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ViewPerformanceReviewDialog(review: review),
            );
          },
          MyText(
            review.employeeId,
            size: 16,
            weight: 400,
            isSelectable: false,
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                review.employeeId,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        DataCell(MyText(review.reviewPeriod, isSelectable: false)),
        DataCell(MyText(review.reviewDate?.toIso8601String() ?? '',
            size: 14, weight: 300)),
        const DataCell(Star5()),
        const DataCell(ThreeDotPop()),
      ]);
    }).toList();
  }
}
