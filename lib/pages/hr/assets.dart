import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/widget/add_asset_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_asset_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller/assets_controller.dart';
import 'models/assets_model.dart';

class AssetsPage extends StatelessWidget {
  const AssetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AssetController controller = Get.put(AssetController());
    final ScrollController scrollController = ScrollController();
    final storage = const FlutterSecureStorage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Header ---
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
                        'Company Assets',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(height: 8),
                      MyText(
                        'Manage company properties across all branches',
                        size: 14,
                        weight: 400,
                        color: Color(0xFF64748B),
                      ),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: AppColors.white,
                    ),
                    child: "New Asset",
                    onTap: () async {
                      String? token = await storage.read(key: 'access_token');
                      if (token != null && context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AddAssetDialog(token: token);
                          },
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
        kSizedBox,

        // --- Filters & Search ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Search Bar
                  Expanded(
                    flex: 2,
                    child: MyTextFormField(
                      hintText: 'Search by asset name...',
                      onChanged: controller.onSearchChanged,
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  if (MediaQuery.of(context).size.width > 800) ...[
                    const SizedBox(width: 16),
                    _buildFiltersRow(controller),
                  ]
                ],
              ),
              // Mobile/Tablet Layout for filters
              if (MediaQuery.of(context).size.width <= 800) ...[
                const SizedBox(height: 16),
                _buildFiltersRow(controller),
              ]
            ],
          ),
        ),

        kSizedBoxSM,

        // --- Table ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Scrollbar(
                controller: scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width -
                          100, // Ensure proper width
                    ),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(40),
                                child: CircularProgressIndicator()));
                      }
                      if (controller.assetList.isEmpty) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text(
                                    "No assets found matching your criteria.")));
                      }

                      return DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows:
                            _createRows(context, controller.assetList, storage),
                        showBottomBorder: true,
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- Pagination ---
              _buildPaginationControls(controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersRow(AssetController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SizedBox(
          height: 56,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final bool allEmpty = controller.branches.isEmpty &&
          controller.departments.isEmpty &&
          controller.statuses.isEmpty;
      if (allEmpty) return const SizedBox.shrink();

      return Row(
        children: [
          // Branch Filter
          _buildDropdown(
            label: "Branch",
            items: controller.branches,
            selectedValue: controller.selectedBranch,
            onChanged: (val) {
              controller.selectedBranch.value = val!;
              controller.onFilterChanged();
            },
          ),
          const SizedBox(width: 12),
          // Department Filter
          Obx(() => _buildDropdown(
                label: "Department",
                // Map department names for dropdown items
                items: controller.departments.map((d) => d['name']!).toList(),
                selectedValue: controller.departments.any(
                        (d) => d['id'] == controller.selectedDepartmentId.value)
                    ? controller.departments
                        .firstWhere((d) =>
                            d['id'] == controller.selectedDepartmentId.value)['name']!
                        .obs
                    : 'All Departments'.obs,
                onChanged: (val) {
                  // Find ID from Name
                  final selectedMap = controller.departments.firstWhere(
                      (d) => d['name'] == val,
                      orElse: () => {'id': 'All', 'name': 'All'});
                  controller.selectedDepartmentId.value = selectedMap['id']!;
                  controller.onFilterChanged();
                },
              )),
          const SizedBox(width: 12),
          // Status Filter
          _buildDropdown(
            label: "Status",
            items: controller.statuses,
            selectedValue: controller.selectedStatus,
            onChanged: (val) {
              controller.selectedStatus.value = val!;
              controller.onFilterChanged();
            },
          ),
        ],
      );
    });
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required RxString selectedValue,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(label, size: 12, color: const Color(0xFF64748B), weight: 500),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: Obx(() => DropdownButton<String>(
                  value: items.contains(selectedValue.value)
                      ? selectedValue.value
                      : items.first,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      size: 18, color: Color(0xFF64748B)),
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                  items: items
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: onChanged,
                )),
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls(AssetController controller) {
    return Obx(() {
      // If list is short and we are on page 1, we might hide pagination,
      // but showing it provides context (Page 1) even if disabled.
      if (controller.assetList.isEmpty) return const SizedBox.shrink();

      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed:
                controller.currentPage.value > 1 ? controller.prevPage : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: "Previous Page",
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: MyText(
              "Page ${controller.currentPage.value}",
              color: AppColors.blue,
              weight: 600,
            ),
          ),
          IconButton(
            onPressed: controller.hasMore.value ? controller.nextPage : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: "Next Page",
          ),
        ],
      );
    });
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(label: MyText("Asset Name")),
      DataColumn(label: MyText("Type")),
      DataColumn(label: MyText("Branch")),
      DataColumn(label: MyText("Department")), // New Column
      DataColumn(label: MyText("Purchase Date")),
      DataColumn(label: MyText("Value")),
      DataColumn(label: MyText("Status")),
      DataColumn(label: MyText("Action")),
    ];
  }

  List<DataRow> _createRows(
      BuildContext context, List<Asset> assets, FlutterSecureStorage storage) {
    return assets.map((asset) {
      return DataRow(cells: <DataCell>[
        DataCell(
          GestureDetector(
            onTap: () async {
              String? token = await storage.read(key: 'access_token');
              if (token != null && context.mounted) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ViewAssetDialog(asset: asset, token: token);
                  },
                );
              }
            },
            child: MyText(
              asset.name,
              size: 14,
              weight: 500,
              color: AppColors.blue,
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getTypeColor(asset.assetType).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                width: 0.6,
                color: _getTypeColor(asset.assetType),
              ),
            ),
            child: MyText(
              asset.assetType,
              size: 12,
              weight: 500,
              color: _getTypeColor(asset.assetType),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.blue),
              const SizedBox(width: 6),
              MyText(asset.branch, size: 14, weight: 400),
            ],
          ),
        ),
        DataCell(
          MyText(
            asset.departmentId ??
                '-', // Showing ID or Name if available in model
            size: 14,
            weight: 400,
          ),
        ),
        DataCell(
          MyText(
            asset.purchaseDate != null
                ? DateFormat('yyyy-MM-dd').format(asset.purchaseDate!)
                : '-',
            size: 14,
            weight: 400,
          ),
        ),
        DataCell(
          MyText(
            asset.value.toStringAsFixed(2),
            size: 14,
            weight: 600,
            color: Colors.green,
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border:
                  Border.all(width: 0.6, color: _getStatusColor(asset.status)),
              color: _getStatusColor(asset.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: MyText(
              asset.status.toUpperCase(),
              size: 12,
              weight: 500,
            ),
          ),
        ),
        const DataCell(ThreeDotPop()),
      ]);
    }).toList();
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'laptop':
        return Colors.blue;
      case 'vehicle':
        return Colors.purple;
      case 'furniture':
        return Colors.orange;
      case 'equipment':
        return Colors.green;
      case 'printer':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'in-use':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
