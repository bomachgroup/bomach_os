import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/button/my_elevated_button.dart';
import '../../components/input/my_textformfield.dart';
import '../../components/text/my_text.dart';
import '../../src/constants/colors.dart';
import 'controllers/legal_case_controller.dart';
import 'detailed_view.dart';
import 'dialogs/legal_dialog.dart';
import 'models/legal_case_model.dart';

class CasesPageView extends StatelessWidget {
  const CasesPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LegalCaseController());

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Legal Cases",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        const MyText(
                            "Manage litigation, disputes, and legal proceedings",
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: MyTextFormField(
                                hintText: 'Search for cases...',
                                leading: Icon(
                                  Icons.search,
                                  color: AppColors.grey1.withValues(alpha: 0.5),
                                ),
                                onChanged: controller.onSearchChanged,
                              ),
                            ),
                            const SizedBox(width: 8),
                            MyElevatedButton(
                              child: 'Create Cases',
                              onTap: () {
                                CreateNewLegalCaseDialog.show(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Legal Cases",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                            SizedBox(height: 2),
                            MyText(
                                "Manage litigation, disputes, and legal proceedings",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.black54)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 250,
                                child: MyTextFormField(
                                  hintText: 'Search for cases...',
                                  leading: Icon(
                                    Icons.search,
                                    color:
                                        AppColors.grey1.withValues(alpha: 0.5),
                                  ),
                                  onChanged: controller.onSearchChanged,
                                ),
                              ),
                              const SizedBox(width: 12),
                              MyElevatedButton(
                                child: 'Create Cases',
                                onTap: () {
                                  CreateNewLegalCaseDialog.show(context);
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (controller.caseList.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.gavel_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text("No legal cases found",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                          SizedBox(height: 4),
                          Text("Create a new case to get started",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }

                return CasesTable(
                  isMobile: isMobile,
                  cases: controller.caseList,
                  controller: controller,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class CasesTable extends StatelessWidget {
  final bool isMobile;
  final List<LegalCase> cases;
  final LegalCaseController controller;
  CasesTable({
    super.key,
    this.isMobile = false,
    required this.cases,
    required this.controller,
  });

  final ScrollController _scrollController = ScrollController();

  DataRow _buildDataRow(LegalCase data, BuildContext context) {
    Color statusColor;
    switch (data.statusDisplay.toLowerCase()) {
      case 'in progress':
        statusColor = Colors.orange;
        break;
      case 'settled':
        statusColor = Colors.green;
        break;
      case 'open':
        statusColor = Colors.blue;
        break;
      case 'won':
        statusColor = Colors.green;
        break;
      case 'lost':
        statusColor = Colors.red;
        break;
      case 'closed':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return DataRow(
      cells: [
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 180 : 300),
            child: Text(
              data.caseName,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 70 : 120),
            child: Chip(
              label: Text(
                data.caseTypeDisplay,
                style: TextStyle(
                    color: Colors.white, fontSize: isMobile ? 10 : 12),
              ),
              backgroundColor: Colors.grey[700],
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 70 : 120),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: statusColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                data.statusDisplay,
                style: TextStyle(
                  color: statusColor,
                  fontSize: isMobile ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 70 : 100),
            child: Text(
              data.exposure ?? 'N/A',
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: isMobile ? 11 : 13, color: Colors.red),
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 80 : 120),
            child: Text(
              data.nextHearing ?? 'N/A',
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: isMobile ? 11 : 13),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  final Map<String, String> legalCaseDetails = {
                    'Case Number': data.caseNumber ?? 'N/A',
                    'Case Title': data.caseName,
                    'Case Type': data.caseTypeDisplay,
                    'Status': data.statusDisplay,
                    'Exposure': data.exposure ?? 'N/A',
                    'Description': data.description,
                    'Next Hearing': data.nextHearing ?? 'N/A',
                    'Date Filed': data.dateFiled ?? 'N/A',
                    'Date Closed': data.dateClosed ?? 'N/A',
                  };

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DetailsViewPage(
                          title: data.caseName, details: legalCaseDetails),
                    ),
                  );
                },
                icon: Icon(Icons.remove_red_eye_outlined,
                    color: Colors.black, size: isMobile ? 16 : 20),
                label: Text("View",
                    style: TextStyle(
                        color: Colors.black, fontSize: isMobile ? 11 : 13)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  minimumSize: Size(isMobile ? 40 : 60, 32),
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              OutlinedButton.icon(
                onPressed: () {
                  CreateNewLegalCaseDialog.show(context);
                },
                icon: Icon(Icons.edit_outlined,
                    color: Colors.black, size: isMobile ? 16 : 20),
                label: Text("Edit",
                    style: TextStyle(
                        color: Colors.black, fontSize: isMobile ? 11 : 13)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  minimumSize: Size(isMobile ? 40 : 60, 32),
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text("Delete Case"),
                      content: Text(
                          "Are you sure you want to delete '${data.caseName}'?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(c);
                            controller.deleteCase(context, data.id);
                          },
                          child: const Text("Delete",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.delete_outline,
                    color: Colors.red, size: isMobile ? 16 : 20),
                label: Text("Delete",
                    style: TextStyle(
                        color: Colors.red, fontSize: isMobile ? 11 : 13)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  minimumSize: Size(isMobile ? 40 : 60, 32),
                  padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 12, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Legal Cases",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 16 : 20,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            "Track all legal proceedings and disputes",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontSize: isMobile ? 12 : 14,
                ),
          ),
          const SizedBox(height: 16),
          Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: isMobile ? 600 : 900,
                  maxWidth: isMobile ? 700 : double.infinity,
                ),
                child: DataTable(
                  columnSpacing: isMobile ? 12 : 24,
                  headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
                  columns: const [
                    DataColumn(label: Text('Case')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Exposure')),
                    DataColumn(label: Text('Next Hearing')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: cases.map((e) => _buildDataRow(e, context)).toList(),
                  dataRowMinHeight: isMobile ? 36 : 48,
                  dataRowMaxHeight: isMobile ? 56 : 72,
                  headingRowHeight: isMobile ? 32 : 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
