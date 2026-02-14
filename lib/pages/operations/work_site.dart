import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../src/app_routes/app_route_constants.dart';
import 'controllers/work_site_controller.dart';
import 'models/models.dart';
import 'widget/add_worksite_dialog.dart';
import 'worksite_detail.dart';

class WorkSite extends StatefulWidget {
  const WorkSite({super.key});

  @override
  State<WorkSite> createState() => _WorkSiteState();
}

class _WorkSiteState extends State<WorkSite> {
  final ScrollController _scrollController = ScrollController();
  final WorksiteController controller = Get.put(WorksiteController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchWorksites(context);
    });
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
                spacing: 20,
                runSpacing: 20,
                children: [
                  const MyText("Worksites", size: 28, weight: 500),
                  MyElevatedButton(
                    child: "Add Worksite",
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        color: AppColors.white),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddWorksiteDialog(),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBoxBG,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.worksites.isEmpty) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("No worksites found."),
              ));
            }

            return Column(
              children: [
                Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width - 100),
                      child: DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows: _createRows(context, controller.worksites),
                        showBottomBorder: true,
                      ),
                    ),
                  ),
                ),
                const MyPaginator(),
              ],
            );
          }),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(label: MyText("Name")),
      DataColumn(label: MyText("Location")),
      DataColumn(label: MyText("Status")),
      DataColumn(label: MyText("Description")),
      DataColumn(label: MyText("Action")),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Worksite> worksites) {
    return worksites.map((site) {
      return DataRow(cells: [
        DataCell(
          onTap: () {
            context.push(RouteConstants.operationsWorksiteDetail, extra: site);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => WorksiteDetailPage(worksite: site)));
          },
          MyText(site.name, weight: 500),
        ),
        DataCell(MyText(site.location)),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4)),
          child: MyText(site.status, color: AppColors.blue),
        )),
        DataCell(
            SizedBox(width: 200, child: MyText(site.description, maxLines: 1))),
        DataCell(
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text("Delete"),
                onTap: () =>
                    controller.deleteWorksite(context, site.id, site.id),
              )
            ],
            child: const Icon(Icons.more_vert),
          ),
        ),
      ]);
    }).toList();
  }
}
