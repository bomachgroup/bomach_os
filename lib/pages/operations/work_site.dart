import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return PageScaffold(
      header: PageHeader(
        title: 'Worksites',
        subtitle: 'Management of field worksites and locations',
        trailing: OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AddWorksiteDialog(),
            );
          },
          icon: const Icon(Iconsax.add_circle, size: 18),
          label: const Text('Add Worksite'),
        ),
      ),
      children: [
        AppCard(
          padding: const EdgeInsets.all(0),
          child: Obx(() {
            if (controller.isLoading.value) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: LoadingSkeleton.listRows(count: 8),
              );
            }

            if (controller.worksites.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(48),
                child: EmptyState.empty(
                  title: 'No worksites found',
                  subtitle: 'Add a new worksite to start tracking field operations.',
                ),
              );
            }

            return Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith(
                        (states) => AppColors.surfaceMuted.withValues(alpha: 0.5)),
                    headingTextStyle: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    dataTextStyle: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    dataRowMinHeight: 64,
                    dataRowMaxHeight: 64,
                    columnSpacing: 24,
                    horizontalMargin: 20,
                    dividerThickness: 1.0,
                    columns: _createColumns(),
                    rows: _createRows(context, controller.worksites),
                    showBottomBorder: false,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(label: Text("Site Name")),
      DataColumn(label: Text("Location")),
      DataColumn(label: Text("Status")),
      DataColumn(label: Text("Description")),
      DataColumn(label: Text("Action")),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Worksite> worksites) {
    return worksites.map((site) {
      return DataRow(cells: [
        DataCell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => WorksiteDetailPage(worksite: site)));
          },
          Text(site.name, style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
        DataCell(Text(site.location)),
        DataCell(StatusChip(
          label: site.status,
          tone: site.status.toLowerCase() == 'active'
              ? StatusTone.success
              : StatusTone.warning,
        )),
        DataCell(
            SizedBox(width: 250, child: Text(site.description, maxLines: 1, overflow: TextOverflow.ellipsis))),
        DataCell(
          PopupMenuButton(
            icon: const Icon(Iconsax.more, size: 18),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text("Delete"),
                onTap: () =>
                    controller.deleteWorksite(context, site.id, site.id),
              )
            ],
          ),
        ),
      ]);
    }).toList();
  }
}
