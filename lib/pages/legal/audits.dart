import 'package:bms_front_end/pages/legal/detailed_view.dart'
    show DetailsViewPage;
import 'package:flutter/material.dart';

import '../../components/button/my_elevated_button.dart';
import '../../components/input/my_textformfield.dart';
import '../../components/text/my_text.dart';
import '../../src/constants/colors.dart';
import 'dialogs/new_audit.dart';

class AuditsPageView extends StatelessWidget {
  const AuditsPageView({super.key});

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
                        const Text('Compliance Audits',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        const MyText(
                            'Monitor and manage compliance audits and assessments',
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: MyTextFormField(
                                hintText: 'Search audits...',
                                leading: Icon(
                                  Icons.search,
                                  color: AppColors.grey1.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            MyElevatedButton(
                              child: 'Shedule Audit',
                              onTap: () {
                                CreateNewAuditDialog.show(context);
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
                            Text('Compliance Audits',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                            SizedBox(height: 2),
                            MyText(
                                'Monitor and manage compliance audits and assessments',
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
                                  hintText: 'Search audits...',
                                  leading: Icon(
                                    Icons.search,
                                    color:
                                        AppColors.grey1.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              MyElevatedButton(
                                child: 'Shedule Audit',
                                onTap: () {
                                  CreateNewAuditDialog.show(context);
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
              const SizedBox(height: 20),
              AuditsTable(isMobile: isMobile),
            ],
          ),
        );
      },
    );
  }
}

class AuditsTable extends StatelessWidget {
  final bool isMobile;
  const AuditsTable({super.key, this.isMobile = false});

  DataRow _buildDataRow(Map<String, String> data, BuildContext context) {
    Color statusColor;
    switch (data['status']) {
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.orange;
        break;
      case 'Scheduled':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    Color scoreColor = Colors.green;
    if (data['score'] != 'N/A') {
      int scoreValue = int.tryParse(data['score']!.replaceAll('%', '')) ?? 0;
      if (scoreValue < 80) scoreColor = Colors.orange;
      if (scoreValue < 60) scoreColor = Colors.red;
    }

    return DataRow(
      cells: [
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 120 : 260),
            child: Text(
              data['audit']!,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: isMobile ? 11 : 14),
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 60 : 100),
            child: Text(
              data['type']!,
              style: TextStyle(fontSize: isMobile ? 10 : 13),
            ),
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 70 : 120),
            child: Text(
              data['auditor']!,
              style: TextStyle(fontSize: isMobile ? 10 : 13),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              data['status']!,
              style: TextStyle(
                color: statusColor,
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              if (data['score'] != 'N/A')
                SizedBox(
                  width: isMobile ? 36 : 50,
                  child: LinearProgressIndicator(
                    value: (int.tryParse(
                              data['score']!.replaceAll('%', ''),
                            ) ??
                            0) /
                        100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
              const SizedBox(width: 5),
              Text(
                data['score']!,
                style: TextStyle(fontSize: isMobile ? 10 : 13),
              ),
            ],
          ),
        ),
        DataCell(
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? 60 : 100),
            child: Text(
              data['date']!,
              style: TextStyle(fontSize: isMobile ? 10 : 13),
            ),
          ),
        ),
        DataCell(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  const Map<String, String> auditDetails = {
                    'Audit Name':
                        'Annual ISO 9001:2015 Quality Management System Audit',
                    'Audit Type': 'Internal Quality Audit',
                    'Audit Number': 'QMS-AUD-2024-001',
                    'Status': 'Completed',
                    'Risk Level': 'Medium',
                    'Description':
                        'Comprehensive internal audit of quality management systems across all departments to ensure continued ISO 9001:2015 compliance',
                    'Assigned Manager': 'QMS Manager',
                    'Created By': 'QMS Manager',
                  };

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DetailsViewPage(
                          title:
                              'Annual ISO 9001:2015 Quality Management System Audit',
                          details: auditDetails),
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
    final ScrollController scrollController = ScrollController();

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
          Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scrollController,
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
                    DataColumn(label: Text('Audit')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Auditor')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Score')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _audits.map((e) => _buildDataRow(e, context)).toList(),
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

final List<Map<String, String>> _audits = [
  {
    'audit': 'ISO 9001-2015 Quality Management System Surveillance Audit',
    'type': 'External',
    'auditor': 'Mrs. Funmi Adebayo',
    'status': 'Completed',
    'score': '87%',
    'date': '15 Mar 2024'
  },
  {
    'audit': 'COREN Professional Standards Compliance Audit',
    'type': 'Regulatory',
    'auditor': 'Engr. Dr. Bola Adeyemi',
    'status': 'Completed',
    'score': '95%',
    'date': '22 Jan 2024'
  },
  {
    'audit': 'Data Protection and Privacy Compliance Review',
    'type': 'Internal',
    'auditor': 'Mrs. Kemi Ogundimu',
    'status': 'In Progress',
    'score': '72%',
    'date': '12 Feb 2024'
  },
  {
    'audit': 'Environmental Management System Audit',
    'type': 'Customer',
    'auditor': 'Dr. Emeka Nwosu',
    'status': 'Scheduled',
    'score': 'N/A',
    'date': '5 Apr 2024'
  },
];
