import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/widget/add_program_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_program_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../pages/hr/models/training_program_model.dart';
import 'controller/training_program_controller.dart'; 

class TrainingProgramPage extends StatefulWidget {
  const TrainingProgramPage({super.key});

  @override
  State<TrainingProgramPage> createState() => TrainingProgramPageState();
}

class TrainingProgramPageState extends State<TrainingProgramPage> {
  final ScrollController _scrollController = ScrollController();
  final TrainingProgramController controller = Get.put(TrainingProgramController());
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await _getToken(context);
    if (token != null) {
      controller.fetchPrograms(token);
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
                      MyText('Training Program', style: AppText.black_500_32),
                    ],
                  ),
                  MyElevatedButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.white),
                    child: "New Training Program",
                    onTap: () async {
                      final token = await _getToken(context);
                      if (token != null && context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) => AddProgramDialog(token: token),
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
                      hintText: 'Search by name',
                      leading: Icon(Icons.search, color: AppColors.grey1.withValues(alpha: 0.5)),
                    ),
                  ),
                  const Row(
                    spacing: 15,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SortBar(text: "Refresh",
                      // onTap: _loadData,
                      ), 
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
                    constraints: BoxConstraints(minWidth: bodySpace(context)),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
                      }
                      if (controller.programList.isEmpty) {
                        return const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No programs found.")));
                      }
                      return DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows: _createRows(context, controller.programList),
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
      DataColumn(label: MyText("Program Name")),
      DataColumn(label: MyText("Provider")),
      DataColumn(label: MyText("Start Date")),
      DataColumn(label: MyText("End Date")),
      DataColumn(label: MyText("Status")),
      DataColumn(label: MyText("Action")),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<TrainingProgram> items) {
    return items.map((program) {
      return DataRow(cells: <DataCell>[
        DataCell(
          MyText(program.programName, size: 16, weight: 400, isSelectable: false),
          onTap: () async {
            final token = await _getToken(context);
            if (token != null && context.mounted) {
              showDialog(
                context: context,
                builder: (context) => ViewProgramDialog(program: program, token: token),
              );
            }
          },
        ),
        DataCell(MyText(program.provider)),
        DataCell(MyText(program.startDate != null ? DateFormat('yyyy-MM-dd').format(program.startDate!) : '-')),
        DataCell(MyText(program.endDate != null ? DateFormat('yyyy-MM-dd').format(program.endDate!) : '-')),
        DataCell(
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
             decoration: BoxDecoration(
               color: Colors.blue.withOpacity(0.1), 
               borderRadius: BorderRadius.circular(4)
             ),
             child: MyText(program.status, color: Colors.blue),
           )
        ),
        const DataCell(ThreeDotPop()),
      ]);
    }).toList();
  }
}