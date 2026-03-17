import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../../src/model/employees_model.dart';
import 'controller/associate_controller.dart';
import 'widget/add_associate_dialog.dart';
import 'widget/view_associate_dialog.dart';

class AssociatesPage extends StatefulWidget {
  const AssociatesPage({super.key});

  @override
  State<AssociatesPage> createState() => _AssociatesPageState();
}

class _AssociatesPageState extends State<AssociatesPage> {
  final AssociatesController controller = Get.put(AssociatesController());
  final _storage = const FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await _getToken(context);
    if (token != null) {
      controller.fetchAssociates(token);
    }
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
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
                        'Associates',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(height: 8),
                      MyText(
                        'Manage external partners and associates',
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
                    child: "New Associate",
                    onTap: () async {
                      final token = await _getToken(context);
                      if (token != null && context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AddAssociateDialog(token: token);
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
                      hintText: 'Search associates...',
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
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
                      minWidth: MediaQuery.of(context).size.width - 100,
                    ),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator()));
                      }

                      if (controller.associateList.isEmpty) {
                        return const Center(
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text("No associates found.")));
                      }

                      return DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows: _createRows(context, controller.associateList),
                        showBottomBorder: true,
                      );
                    }),
                  ),
                ),
              ),
              // const PaginatorFooter(),
            ],
          ),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return [
      const DataColumn(label: MyText('Name')),
      const DataColumn(label: MyText('Email')),
      const DataColumn(label: MyText('Role/Type')),
      const DataColumn(label: MyText('Phone')),
      const DataColumn(label: MyText('Status')),
      const DataColumn(label: MyText('Action')),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Employee> associates) {
    return associates.map((associate) {
      return DataRow(cells: <DataCell>[
        DataCell(
          Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greyBg,
                ),
                width: 36,
                height: 36,
                child: associate.profilePicture != null
                    ? CircleAvatar(
                        backgroundImage:
                            NetworkImage(associate.profilePicture!))
                    : Center(
                        child: Text(associate.firstName.isNotEmpty
                            ? associate.firstName[0]
                            : 'A')),
              ),
              const SizedBox(width: 8),
              MyText(
                "${associate.firstName} ${associate.lastName}",
                size: 14,
                weight: 500,
              ),
            ],
          ),
        ),
        DataCell(MyText(associate.email)),
        DataCell(MyText(associate.employmentType ?? '-')),
        DataCell(MyText(associate.phoneNumber ?? '-')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                width: 0.6,
                color: associate.isActive ? AppColors.green : AppColors.red,
              ),
              color: (associate.isActive ? AppColors.green : AppColors.red)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: MyText(
              associate.isActive ? 'Active' : 'Inactive',
              size: 12,
              weight: 500,
              color: associate.isActive ? AppColors.green : AppColors.red,
            ),
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.visibility, color: AppColors.blue),
            onPressed: () {
              showDialog(
                context: context,
                builder: (c) => ViewAssociateDialog(associate: associate),
              );
            },
          ),
        ),
      ]);
    }).toList();
  }
}
