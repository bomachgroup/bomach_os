import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/company_controller.dart';

class AuditLogPage extends StatefulWidget {
  const AuditLogPage({super.key});

  @override
  State<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage> {
  final CompanyController controller = Get.put(CompanyController());

  @override
  void initState() {
    super.initState();
    controller.fetchAuditLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText('Audit Log', style: AppText.black_600_32),
        const SizedBox(height: 8),
        const Text('Track all changes and activities in the system', style: TextStyle(color: Color(0xFF64748B))),
        kSizedBox,

        // Search Bar
        const SizedBox(
          width: 300,
          child: MyTextFormField(
            hintText: 'Search by event or user...',
            leading: Icon(Icons.search, color: Colors.grey),
          ),
        ),
        kSizedBox,

        // Table
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Obx(() {
            if (controller.isAuditLoading.value) {
              return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
            }
            if (controller.auditLogs.isEmpty) {
              return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No logs available")));
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                columns: const [
                  DataColumn(label: Text("Event Action")),
                  DataColumn(label: Text("Description")),
                  DataColumn(label: Text("User Email")),
                  DataColumn(label: Text("Date & Time")),
                  DataColumn(label: Text("IP Address")),
                ],
                rows: controller.auditLogs.map((log) {
                  return DataRow(cells: [
                    DataCell(Text(log.action, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(SizedBox(width: 250, child: Text(log.description, overflow: TextOverflow.ellipsis))),
                    DataCell(Text(log.userEmail)),
                    DataCell(Text(log.createdAt)),
                    DataCell(Text(log.ipAddress)),
                  ]);
                }).toList(),
              ),
            );
          }),
        ),
      ],
    );
  }
}