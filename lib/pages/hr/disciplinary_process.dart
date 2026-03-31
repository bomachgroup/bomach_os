import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller/disciplinary_controller.dart';
import 'models/disciplinary_cases_model.dart';
import 'widget/add_disciplinary_case_dialog.dart';
import 'widget/appeal_disciplinary_case_dialog.dart';

class DisciplinaryProcessPage extends StatefulWidget {
  const DisciplinaryProcessPage({super.key});

  @override
  State<DisciplinaryProcessPage> createState() =>
      _DisciplinaryProcessPageState();
}

class _DisciplinaryProcessPageState extends State<DisciplinaryProcessPage> {
  final ScrollController _scrollController = ScrollController();
  final DisciplinaryController controller = Get.put(DisciplinaryController());
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await _getToken(context);
    if (token != null) {
      controller.fetchCases(token);
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
                        'Disciplinary Process',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(height: 8),
                      MyText(
                        'Track and manage disciplinary cases',
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
                    child: "New Case",
                    onTap: () async {
                      final token = await _getToken(context);
                      if (token != null && context.mounted) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AddDisciplinaryCaseDialog(token: token);
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
                      hintText: 'Search cases...',
                      leading: Icon(
                        Icons.search,
                        color: AppColors.grey1.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    tooltip: "Refresh",
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
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ));
                      }

                      if (controller.caseList.isEmpty) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("No disciplinary cases found."),
                        ));
                      }

                      return DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        columns: _createColumns(),
                        rows: _createRows(context, controller.caseList),
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
      const DataColumn(label: MyText('Employee ID')),
      const DataColumn(label: MyText('Action Type')),
      const DataColumn(label: MyText('Category')),
      const DataColumn(label: MyText('Violation Title')),
      const DataColumn(label: MyText('Date')),
      const DataColumn(label: MyText('Actions')),
    ];
  }

  List<DataRow> _createRows(
      BuildContext context, List<DisciplinaryCase> cases) {
    return cases.map((kase) {
      return DataRow(
        cells: <DataCell>[
          DataCell(
            MyText(
              kase.employeeId,
              style: AppText.black_500_16,
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getActionColor(kase.actionType).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: MyText(
                kase.actionType,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getActionColor(kase.actionType),
                ),
              ),
            ),
          ),
          DataCell(
            MyText(kase.violationCategory),
          ),
          DataCell(
            MyText(
              kase.violationTitle,
              style: AppText.sideMText_300_14,
            ),
          ),
          DataCell(
            MyText(
              kase.actionDate != null
                  ? DateFormat('dd MMM yyyy').format(kase.actionDate!)
                  : '-',
              style: AppText.sideMText_300_14,
            ),
          ),
          DataCell(
            GestureDetector(
              onTap: () async {
                final token = await _getToken(context);
                if (token != null && context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ViewDisciplinaryCaseDialog(
                        kase: kase,
                        token: token,
                      );
                    },
                  );
                }
              },
              child:
                  const Icon(Icons.visibility, size: 20, color: AppColors.blue),
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getActionColor(String actionType) {
    final type = actionType.toLowerCase();
    if (type.contains('termination') || type.contains('dismissal')) {
      return AppColors.red;
    }
    if (type.contains('suspension')) return Colors.orange;
    if (type.contains('warning')) return Colors.blue;
    return AppColors.grey1;
  }
}
