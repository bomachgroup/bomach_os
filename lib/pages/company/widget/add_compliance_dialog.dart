import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/company_controller.dart';
import '../../../src/model/company_model.dart';

class AddComplianceDialog extends StatefulWidget {
  const AddComplianceDialog({super.key});

  @override
  State<AddComplianceDialog> createState() => _AddComplianceDialogState();
}

class _AddComplianceDialogState extends State<AddComplianceDialog> {
  final CompanyController controller = Get.find<CompanyController>();
  
  final typeCtrl = TextEditingController();
  final itemCtrl = TextEditingController();
  final numberCtrl = TextEditingController();
  final regDateCtrl = TextEditingController();
  final expDateCtrl = TextEditingController();
  
  String selectedStatus = "active";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("New Compliance Record", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            MyDropdown(
              title: "Type",
              hintText: "Select Type",
              items: const ["CAC", "Tax", "License", "Other"],
              onChanged: (val) => typeCtrl.text = val ?? "",
            ),
            const SizedBox(height: 16),
            MyTextFormField(controller: itemCtrl, title: "Registration Item", hintText: "e.g. ISO Certification"),
            const SizedBox(height: 16),
            MyTextFormField(controller: numberCtrl, title: "Number", hintText: "e.g. RC 123456"),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildDatePicker(regDateCtrl, "Date Registered")),
              const SizedBox(width: 16),
              Expanded(child: _buildDatePicker(expDateCtrl, "Expiration Date")),
            ]),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyOutlinedButton(child: "Cancel", onTap: () => Navigator.pop(context), textColor: Colors.grey),
                const SizedBox(width: 12),
                Obx(() => MyElevatedButton(
                  child: controller.isSaving.value ? "Saving..." : "Save",
                  onTap: controller.isSaving.value ? (){} : () {
                    final newItem = Compliance(
                      id: '', // Backend handles ID
                      type: typeCtrl.text,
                      registrationItem: itemCtrl.text,
                      number: numberCtrl.text,
                      dateRegistered: regDateCtrl.text,
                      expirationDate: expDateCtrl.text,
                      status: "active",
                    );
                    controller.createCompliance(context, newItem);
                  },
                )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(TextEditingController ctrl, String label) {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          ctrl.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      },
      child: IgnorePointer(
        child: MyTextFormField(controller: ctrl, title: label, hintText: "Select Date"),
      ),
    );
  }
}