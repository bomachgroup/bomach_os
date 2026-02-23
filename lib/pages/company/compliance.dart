import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/company_controller.dart';
import 'widget/add_compliance_dialog.dart';

class CompliancePage extends StatefulWidget {
  const CompliancePage({super.key});

  @override
  State<CompliancePage> createState() => _CompliancePageState();
}

class _CompliancePageState extends State<CompliancePage> {
  final CompanyController controller = Get.find<CompanyController>();

  @override
  void initState() {
    super.initState();
    controller.fetchComplianceRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText('Compliance & Registration', style: AppText.black_600_16),
                SizedBox(height: 4),
                MyText('Manage regulatory compliance documents', size: 12, color: Colors.grey),
              ],
            ),
            MyElevatedButton(
              height: 40,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              child: "New Compliance",
              onTap: () => showDialog(
                context: context,
                builder: (c) => const AddComplianceDialog(),
              ),
            )
          ],
        ),
        kSizedBox,

        // Search Bar
        const SizedBox(
          width: 300,
          child: MyTextFormField(
            hintText: 'Search compliance...',
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
            if (controller.isComplianceLoading.value) {
              return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
            }
            if (controller.complianceList.isEmpty) {
              return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No records found")));
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
                columns: const [
                  DataColumn(label: Text("Type")),
                  DataColumn(label: Text("Registration Item")),
                  DataColumn(label: Text("Number")),
                  DataColumn(label: Text("Date Registered")),
                  DataColumn(label: Text("Expiry Date")),
                  DataColumn(label: Text("Status")),
                  DataColumn(label: Text("Action")),
                ],
                rows: controller.complianceList.map((item) {
                  return DataRow(cells: [
                    DataCell(Text(item.type, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(item.registrationItem)),
                    DataCell(Text(item.number)),
                    DataCell(Text(item.dateRegistered)),
                    DataCell(Text(item.expirationDate)),
                    DataCell(_buildStatusBadge(item.status)),
                    const DataCell(ThreeDotPop()),
                  ]);
                }).toList(),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status.toLowerCase() == 'active' ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}