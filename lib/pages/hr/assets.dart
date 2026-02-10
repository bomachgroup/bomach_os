import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
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

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  final ScrollController _scrollController = ScrollController();
  final AssetController controller = Get.put(AssetController());
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await _getToken(context);
    if (token != null) {
      controller.fetchAssets(token);
    }
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

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
                      final token = await _getToken(context);
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
                      hintText: 'Search by asset name...',
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
                      SortBar(
                        text: "Refresh",
                        //  onTap: _loadData
                      ),
                      SortBar(text: "Asset Type"),
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
                      minWidth: bodySpace(context),
                    ),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator()));
                      }
                      if (controller.assetList.isEmpty) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text("No assets found.")));
                      }

                      return DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows: _createRows(context, controller.assetList),
                        showBottomBorder: true,
                      );
                    }),
                  ),
                ),
              ),
              const MyPaginator(),
            ],
          ),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(label: MyText("Asset ID")),
      DataColumn(label: MyText("Asset Name")),
      DataColumn(label: MyText("Type")),
      DataColumn(label: MyText("Branch")),
      DataColumn(label: MyText("Assigned ID")), // Model only has ID
      DataColumn(label: MyText("Purchase Date")),
      DataColumn(label: MyText("Value")),
      DataColumn(label: MyText("Status")),
      DataColumn(label: MyText("Action")),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Asset> assets) {
    return assets.map((asset) {
      return DataRow(cells: <DataCell>[
        DataCell(
          MyText(
            asset.id,
            size: 14,
            weight: 500,
            isSelectable: false,
          ),
        ),
        DataCell(
          onTap: () async {
            final token = await _getToken(context);
            if (token != null && context.mounted) {
              showDialog(
                context: context,
                builder: (context) {
                  return ViewAssetDialog(asset: asset, token: token);
                },
              );
            }
          },
          MyText(
            asset.name,
            size: 14,
            weight: 500,
            color: AppColors.blue,
            isSelectable: false,
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
            asset.assignedToId ?? 'Unassigned',
            size: 14,
            weight: 400,
            color: asset.assignedToId == null ? Colors.grey : Colors.black,
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
