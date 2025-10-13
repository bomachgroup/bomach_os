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
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  final ScrollController _scrollController = ScrollController();
  String selectedBranch = 'All Branches';

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
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AddAssetDialog();
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
                      hintText: 'Search by asset name, ID, type...',
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
                      SortBar(text: "All Branches"),
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
                    child: DataTable(
                      dataRowMinHeight: 68,
                      dataRowMaxHeight: 68,
                      columnSpacing: 24,
                      horizontalMargin: 12,
                      columns: _createColumns(),
                      rows: _createRows(context),
                      showBottomBorder: true,
                    ),
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
      DataColumn(
        headingRowAlignment: MainAxisAlignment.start,
        label: MyText(
          "Asset ID",
        ),
      ),
      DataColumn(
        label: MyText(
          "Asset Name",
        ),
      ),
      DataColumn(
        label: MyText(
          "Type",
        ),
      ),
      DataColumn(
        label: MyText(
          "Branch",
        ),
      ),
      DataColumn(
        label: MyText(
          "Assigned To",
        ),
      ),
      DataColumn(
        label: MyText(
          "Purchase Date",
        ),
      ),
      DataColumn(
        label: MyText(
          "Value",
        ),
      ),
      DataColumn(
        label: MyText(
          "Status",
        ),
      ),
      DataColumn(
        label: MyText(
          "Action",
        ),
      ),
    ];
  }

  List<DataRow> _createRows(BuildContext context) {
    // Mock assets data organized by branch
    final List<Map<String, dynamic>> assets = [
      {
        'id': 'AST-001',
        'name': 'Dell Latitude 5520',
        'type': 'Laptop',
        'branch': 'Enugu Branch',
        'assignedTo': 'John Doe',
        'assignedEmail': 'john.doe@bomach.com',
        'purchaseDate': 'Jan 15, 2024',
        'value': '₦850,000',
        'status': 'in-use',
      },
      {
        'id': 'AST-002',
        'name': 'HP LaserJet Pro',
        'type': 'Printer',
        'branch': 'Enugu Branch',
        'assignedTo': 'IT Department',
        'assignedEmail': 'it@bomach.com',
        'purchaseDate': 'Feb 20, 2024',
        'value': '₦450,000',
        'status': 'in-use',
      },
      {
        'id': 'AST-003',
        'name': 'Toyota Hilux',
        'type': 'Vehicle',
        'branch': 'Lagos Branch',
        'assignedTo': 'Operations Team',
        'assignedEmail': 'operations@bomach.com',
        'purchaseDate': 'Mar 10, 2023',
        'value': '₦18,500,000',
        'status': 'in-use',
      },
      {
        'id': 'AST-004',
        'name': 'Conference Table',
        'type': 'Furniture',
        'branch': 'Lagos Branch',
        'assignedTo': 'Meeting Room A',
        'assignedEmail': 'facilities@bomach.com',
        'purchaseDate': 'May 05, 2023',
        'value': '₦320,000',
        'status': 'in-use',
      },
      {
        'id': 'AST-005',
        'name': 'MacBook Pro 16"',
        'type': 'Laptop',
        'branch': 'Abuja Branch',
        'assignedTo': 'Sarah Johnson',
        'assignedEmail': 'sarah.j@bomach.com',
        'purchaseDate': 'Jun 12, 2024',
        'value': '₦1,450,000',
        'status': 'in-use',
      },
      {
        'id': 'AST-006',
        'name': 'Air Conditioner',
        'type': 'Equipment',
        'branch': 'Enugu Branch',
        'assignedTo': 'Main Office',
        'assignedEmail': 'facilities@bomach.com',
        'purchaseDate': 'Jul 08, 2023',
        'value': '₦550,000',
        'status': 'maintenance',
      },
      {
        'id': 'AST-007',
        'name': 'Office Desk',
        'type': 'Furniture',
        'branch': 'Abuja Branch',
        'assignedTo': 'Michael Brown',
        'assignedEmail': 'michael.b@bomach.com',
        'purchaseDate': 'Aug 22, 2023',
        'value': '₦95,000',
        'status': 'in-use',
      },
      {
        'id': 'AST-008',
        'name': 'Canon EOS Camera',
        'type': 'Equipment',
        'branch': 'Lagos Branch',
        'assignedTo': 'Marketing Team',
        'assignedEmail': 'marketing@bomach.com',
        'purchaseDate': 'Sep 15, 2024',
        'value': '₦680,000',
        'status': 'in-use',
      },
      {
        'id': 'AST-009',
        'name': 'Generator 10KVA',
        'type': 'Equipment',
        'branch': 'Enugu Branch',
        'assignedTo': 'Building Maintenance',
        'assignedEmail': 'maintenance@bomach.com',
        'purchaseDate': 'Oct 03, 2022',
        'value': '₦1,200,000',
        'status': 'in-use',
      },
      {
        'id': 'AST-010',
        'name': 'Server Rack',
        'type': 'IT Equipment',
        'branch': 'Lagos Branch',
        'assignedTo': 'Data Center',
        'assignedEmail': 'it@bomach.com',
        'purchaseDate': 'Nov 18, 2023',
        'value': '₦2,850,000',
        'status': 'in-use',
      },
    ];

    return assets.map((asset) {
      return DataRow(cells: <DataCell>[
        DataCell(
          MyText(
            asset['id'],
            size: 14,
            weight: 500,
            isSelectable: false,
          ),
        ),
        DataCell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return ViewAssetDialog(asset: asset);
              },
            );
          },
          MyText(
            asset['name'],
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
              color: _getTypeColor(asset['type']).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                width: 0.6,
                color: _getTypeColor(asset['type']),
              ),
            ),
            child: MyText(
              asset['type'],
              size: 12,
              weight: 500,
              color: _getTypeColor(asset['type']),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.blue,
              ),
              const SizedBox(width: 6),
              MyText(
                asset['branch'],
                size: 14,
                weight: 400,
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                width: 36,
                height: 36,
                child: Center(
                  child: MyText(
                    asset['assignedTo'][0],
                    size: 16,
                    weight: 600,
                    color: AppColors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyText(
                    asset['assignedTo'],
                    size: 14,
                    weight: 400,
                    isSelectable: false,
                  ),
                  MyText(
                    asset['assignedEmail'],
                    size: 12,
                    weight: 300,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          MyText(
            asset['purchaseDate'],
            size: 14,
            weight: 400,
          ),
        ),
        DataCell(
          MyText(
            asset['value'],
            size: 14,
            weight: 600,
            color: Colors.green,
          ),
        ),
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 0.6,
                        color: getRandomColorFromList(asset['status']),
                      ),
                      color: getRandomColorFromList(asset['status'])
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: MyText(
                      asset['status'] == 'in-use'
                          ? 'In Use'
                          : asset['status'] == 'maintenance'
                              ? 'Maintenance'
                              : 'Available',
                      size: 12,
                      weight: 500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const DataCell(
          ThreeDotPop(),
        ),
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
      case 'it equipment':
        return Colors.indigo;
      case 'printer':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
