import 'package:flutter/material.dart';

import '../../components/button/my_elevated_button.dart';
import '../../components/input/my_textformfield.dart';
import '../../components/text/my_text.dart';
import '../../src/constants/colors.dart';
import 'detailed_view.dart';
import 'dialogs/legal_dialog.dart';

class CasesPageView extends StatelessWidget {
  const CasesPageView({super.key});

  @override
  Widget build(BuildContext context) {
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
              CasesTable(isMobile: isMobile),
            ],
          ),
        );
      },
    );
  }
}

class CasesTable extends StatelessWidget {
  final bool isMobile;
  CasesTable({super.key, this.isMobile = false});

  final ScrollController _scrollController = ScrollController();

  DataRow _buildDataRow(CaseData data, BuildContext context) {
    Color statusColor;
    switch (data.status) {
      case 'In Progress':
        statusColor = Colors.orange;
        break;
      case 'Settled':
        statusColor = Colors.green;
        break;
      case 'Open':
        statusColor = Colors.blue;
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
                data.type,
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
                data.status,
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
              data.exposure,
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
              data.nextHearing,
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
                  const Map<String, String> legalCaseDetails = {
                    'Case Number': 'CASE-2024-001',
                    'Case Title':
                        'Bomach Engineering vs. Delta Construction Ltd – Professional Negligence Claim',
                    'Case Type': 'Contract Dispute',
                    'Status': 'In Progress',
                    'Priority': 'High',
                    'Description':
                        'Complex boundary dispute arising from alleged survey inaccuracies in the Lekki Phase 2 development project. Client claims survey errors led to construction delays and significant financial losses.',
                    'Assigned Manager': 'Legal Manager',
                    'Created By': 'Legal Manager',
                  };

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DetailsViewPage(
                          title:
                              'Bomach Engineering vs. Delta Construction Ltd – Professional Negligence Claim',
                          details: legalCaseDetails),
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
                onPressed: () {},
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
                  rows: _cases.map((e) => _buildDataRow(e, context)).toList(),
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

class CaseData {
  final String caseName;
  final String type;
  final String status;
  final String exposure;
  final String nextHearing;

  CaseData(
      this.caseName, this.type, this.status, this.exposure, this.nextHearing);
}

final List<CaseData> _cases = [
  CaseData(
      'Bomach Engineering vs. Delta Construction Ltd - Boundary Dispute CASE-2024-001',
      'Contract Dispute',
      'In Progress',
      '₦8,500,000.00',
      '10 Apr 2024'),
  CaseData(
      'Employment Dispute - James Okafor vs. Bomach Engineering Services CASE-2024-002',
      'Employment',
      'Settled',
      '₦1,200,000.00',
      'N/A'),
  CaseData(
      'Regulatory Investigation - NESREA Environmental Compliance CASE-2024-003',
      'Regulatory',
      'Open',
      '₦15,000,000.00',
      '28 Feb 2024'),
];
