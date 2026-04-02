import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../src/model/departments_units_model.dart';
import '../controllers/department_units_controller.dart';

class BaseDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final double width;

  const BaseDialog({
    super.key,
    required this.title,
    required this.child,
    this.width = 700,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: width,
        constraints:
            BoxConstraints(maxWidth: width, maxHeight: screenHeight * 0.9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Body (Scrollable)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateDepartmentDialog extends StatefulWidget {
  final Department? department;
  const CreateDepartmentDialog({super.key, this.department});
  @override
  State<CreateDepartmentDialog> createState() => _CreateDepartmentDialogState();
}

class _CreateDepartmentDialogState extends State<CreateDepartmentDialog> {
  final controller = Get.find<DepartmentsUnitsController>();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.department != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      nameCtrl.text = widget.department!.name;
      descCtrl.text = widget.department!.description;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: isEditing ? "Edit Department" : "Create Department",
      width: 750,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyTextFormField(
              title: "Department Name",
              hintText: "Enter Name",
              controller: nameCtrl,
              validator: (val) =>
                  (val == null || val.isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 20),
            MyTextFormField(
              title: "Description",
              hintText: "Enter department description...",
              maxLines: 4,
              controller: descCtrl,
            ),
            const SizedBox(height: 32),

            // Footer Actions
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 16),
              Obx(() => MyElevatedButton(
                    width: 120,
                    child: controller.isSaving.value
                        ? "Saving..."
                        : (isEditing ? "Update" : "Save"),
                    onTap: controller.isSaving.value ? () {} : _onSave,
                  )),
            ]),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (isEditing) {
      controller.updateDepartment(
        context,
        departmentId: widget.department!.id,
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
      );
    } else {
      controller.createDepartment(
        context,
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
      );
    }
  }
}

class CreateUnitDialog extends StatefulWidget {
  final DepartmentUnit? unit;
  const CreateUnitDialog({super.key, this.unit});
  @override
  State<CreateUnitDialog> createState() => _CreateUnitDialogState();
}

class _CreateUnitDialogState extends State<CreateUnitDialog> {
  final controller = Get.find<DepartmentsUnitsController>();
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? selectedDeptId;

  bool get isEditing => widget.unit != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      nameCtrl.text = widget.unit!.name;
      descCtrl.text = widget.unit!.description;
      selectedDeptId = widget.unit!.departmentId;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: isEditing ? "Edit Unit" : "Create Unit",
      width: 750,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MyTextFormField(
                    title: "Unit Name",
                    hintText: "Enter Name",
                    controller: nameCtrl,
                    validator: (val) => (val == null || val.isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Obx(() => MyDropdown(
                        title: "Department",
                        hintText: isEditing
                            ? (widget.unit!.departmentName ?? "Select Dept")
                            : "Select Dept",
                        items: controller.departmentOptions
                            .map((e) => e['name'] ?? 'Unknown')
                            .toList(),
                        onChanged: (name) {
                          try {
                            final dept = controller.departmentOptions
                                .firstWhere((e) => e['name'] == name);
                            setState(() => selectedDeptId = dept['id']);
                          } catch (_) {}
                        },
                      )),
                ),
              ],
            ),
            const SizedBox(height: 20),
            MyTextFormField(
              title: "Description",
              hintText: "Enter unit description...",
              maxLines: 4,
              controller: descCtrl,
            ),
            const SizedBox(height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(width: 16),
              Obx(() => MyElevatedButton(
                    width: 120,
                    child: controller.isSaving.value
                        ? "Saving..."
                        : (isEditing ? "Update" : "Save"),
                    onTap: controller.isSaving.value ? () {} : _onSave,
                  )),
            ]),
          ],
        ),
      ),
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDeptId == null && !isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a department'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final deptId = selectedDeptId ?? widget.unit!.departmentId;

    if (isEditing) {
      controller.updateUnit(
        context,
        unitId: widget.unit!.id!,
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        departmentId: deptId,
      );
    } else {
      controller.createUnit(
        context,
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        departmentId: deptId,
      );
    }
  }
}

class ViewDepartmentDetailsDialog extends StatelessWidget {
  final Department department;
  const ViewDepartmentDetailsDialog({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      title: "Department Details",
      width: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Complete information for ${department.name}",
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _buildInfoColumn("Department Name", department.name)),
              Expanded(
                  child: _buildInfoColumn("Department Code",
                      "DEP-${department.id.length >= 3 ? department.id.substring(0, 3) : department.id}")),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoColumn("Description", department.description),
          const SizedBox(height: 32),

          // Performance & KPIs (mock data)
          const Text("Performance & KPIs",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Performance Score",
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Text("85%",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF005CE8))),
                          SizedBox(width: 4),
                          Icon(Icons.trending_up, color: Colors.green, size: 16)
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Staff",
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      SizedBox(height: 4),
                      Text("12",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildProgressBarRow("Revenue Achievement", 0.88),
          const SizedBox(height: 12),
          _buildProgressBarRow("Utilization Rate", 0.92),

          const SizedBox(height: 32),

          // Activity Summary
          const Text("Activity Summary",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          _buildSummaryRow("Tasks Completed:", "78", "Tasks Pending:", "12"),
          const SizedBox(height: 8),
          _buildSummaryRow("Active Members:", "10/12", "Active Projects:", "6"),

          const SizedBox(height: 32),

          // Budget Overview
          const Text("Budget Overview",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBudgetMetric("Allocated", "₦12,500,000", Colors.blue),
                    _buildBudgetMetric("Spent", "₦10,937,500", Colors.orange),
                    _buildBudgetMetric("Remaining", "₦1,562,500", Colors.green),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.875,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: const AlwaysStoppedAnimation(Colors.black87),
                  ),
                ),
                const SizedBox(height: 4),
                const Align(
                    alignment: Alignment.centerRight,
                    child: Text("87.5% utilized",
                        style: TextStyle(fontSize: 10, color: Colors.grey)))
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MyOutlinedButton(
                child: "Edit",
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) =>
                        CreateDepartmentDialog(department: department),
                  );
                },
              ),
              const SizedBox(width: 12),
              MyOutlinedButton(
                  child: "Close",
                  onTap: () => Navigator.pop(context),
                  textColor: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

class ViewUnitDetailsDialog extends StatelessWidget {
  final DepartmentUnit unit;
  const ViewUnitDetailsDialog({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    double productivity = 0.95;
    double quality = 0.99;
    double efficiency = 0.94;

    return BaseDialog(
      title: "Unit Details",
      width: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Complete information for ${unit.name}",
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildInfoColumn("Unit Name", unit.name)),
              Expanded(
                  child: _buildInfoColumn(
                      "Unit Code",
                      unit.id != null && unit.id!.length >= 3
                          ? "UNIT-${unit.id!.substring(0, 3)}"
                          : "UNIT-${unit.id ?? '?'}")),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _buildInfoColumn(
                      "Department", unit.departmentName ?? "-")),
              Expanded(
                  child: _buildInfoColumn(
                      "Head of Unit", unit.hod ?? "Not Assigned")),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoColumn("Description", unit.description),
          const SizedBox(height: 32),
          const Text("Performance Metrics",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          _buildMetricSlider("Productivity", productivity),
          _buildMetricSlider("Quality", quality),
          _buildMetricSlider("Efficiency Score", efficiency),
          const SizedBox(height: 32),
          const Text("Activity Summary",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          _buildSummaryRow("Tasks Completed:", "78", "Tasks Pending:", "12"),
          const SizedBox(height: 8),
          _buildSummaryRow("Active Members:", "6/6", "Team Size:", "6"),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              MyOutlinedButton(
                child: "Edit",
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => CreateUnitDialog(unit: unit),
                  );
                },
              ),
              const SizedBox(width: 12),
              MyOutlinedButton(
                  child: "Close",
                  onTap: () => Navigator.pop(context),
                  textColor: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}

// --- PRIVATE HELPERS ---

Widget _buildInfoColumn(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B))),
    ],
  );
}

Widget _buildProgressBarRow(String label, double value) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text("${(value * 100).toInt()}%",
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 6,
          backgroundColor: Colors.grey.shade100,
          valueColor: const AlwaysStoppedAnimation(Colors.black87),
        ),
      ),
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Target: 90%",
              style: TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      )
    ],
  );
}

Widget _buildSummaryRow(String l1, String v1, String l2, String v2) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Text(l1, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 8),
          Text(v1,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
      Row(
        children: [
          Text(l2, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 8),
          Text(v2,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    ],
  );
}

Widget _buildBudgetMetric(String label, String value, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      Container(
        margin: const EdgeInsets.only(top: 2),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2)),
        child: Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 11)),
      ),
    ],
  );
}

Widget _buildMetricSlider(String label, double value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            Text("${(value * 100).toInt()}%",
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 4,
            backgroundColor: Colors.grey.shade100,
            valueColor: const AlwaysStoppedAnimation(Colors.black87),
          ),
        ),
        const SizedBox(height: 2),
        const Text("Target: 90%",
            style: TextStyle(fontSize: 9, color: Colors.grey)),
      ],
    ),
  );
}
