import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/nav/three_dot_pop.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controller/benefits_controller.dart';
import 'models/benefits_model.dart';

class BenefitsPage extends StatefulWidget {
  const BenefitsPage({super.key});

  @override
  State<BenefitsPage> createState() => _BenefitsPageState();
}

class _BenefitsPageState extends State<BenefitsPage> {
  final BenefitsController _ctrl = Get.put(BenefitsController());
  final ScrollController _scrollController = ScrollController();

  // Colors
  final Color _blueColor = AppColors.primary;
  final Color _greenBg = AppColors.successSubtle;
  final Color _greenTxt = AppColors.success;
  final Color _redBg = AppColors.dangerSubtle;
  final Color _redTxt = AppColors.danger;
  final Color _yellowBg = AppColors.warningSubtle;
  final Color _yellowTxt = AppColors.warning;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. Header ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const MyText(
              'Benefits & Welfare',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => _showAllBenefitsDialog(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.neutral200),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                  ),
                  child: const Text("Benefits & Welfare",
                      style: TextStyle(color: Colors.black87)),
                ),
                const SizedBox(width: 12),
                MyElevatedButton(
                  icon: const Icon(Iconsax.add_circle,
                      color: Colors.white, size: 20),
                  child: "Add Staff to Benefits",
                  onTap: () {
                    // For demo, opening edit for first user
                    if (_ctrl.employeeList.isNotEmpty) {
                      _showEditStaffBenefitsDialog(
                          context, _ctrl.employeeList.first);
                    }
                  },
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 24),

        // --- 2. Filters & Table ---
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
          ),
          child: Column(
            children: [
              // Filters
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 300,
                    child: MyTextFormField(
                      controller: _ctrl.searchController,
                      hintText: 'Search...',
                      leading: Icon(Iconsax.search_normal,
                          color: Colors.grey.withValues(alpha: 0.5)),
                    ),
                  ),
                  Row(
                    children: [
                      _buildDropdownFilter("All Departments"),
                      const SizedBox(width: 12),
                      _buildDropdownFilter("All Benefits"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Table
              Obx(() => Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width - 300),
                        child: DataTable(
                          headingRowColor:
                              WidgetStateProperty.all(Colors.transparent),
                          dataRowColor:
                              WidgetStateProperty.all(Colors.transparent),
                          columnSpacing: 24,
                          horizontalMargin: 0,
                          columns: const [
                            DataColumn(label: Text("Employee")),
                            DataColumn(label: Text("Benefits")),
                            DataColumn(label: Text("Start Date")),
                            DataColumn(label: Text("Status")),
                            DataColumn(label: Text("Action")),
                          ],
                          rows: _ctrl.employeeList.map((record) {
                            return DataRow(cells: [
                              DataCell(Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.infoSubtle,
                                    child: Icon(Iconsax.profile_circle,
                                        size: 16, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(record.employeeName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                      Text(record.employeeRole,
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11)),
                                    ],
                                  ),
                                ],
                              )),
                              DataCell(SizedBox(
                                width: 200,
                                child: Text(
                                  record.activeBenefits.join(", "),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              )),
                              DataCell(Text(DateFormat('yyyy-MM-dd')
                                  .format(record.startDate))),
                              DataCell(_buildStatusBadge(record.status)),
                              DataCell(ThreeDotPop(
                                onTapView: () =>
                                    _showViewStaffDialog(context, record),
                                onTapEdit: () => _showEditStaffBenefitsDialog(
                                    context, record),
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  )),

              const SizedBox(height: 16),
              const Divider(color: AppColors.neutral100),
              const SizedBox(height: 16),

              // Pagination
              Obx(() => PaginatorFooter(
                    totalItems: _ctrl.employeeList.length,
                    limit: _ctrl.itemsPerPage.value,
                    currentPage: _ctrl.currentPage.value,
                    onPageChanged: (p) {},
                    onLimitChanged: (l) {},
                  )),
            ],
          ),
        ),
      ],
    );
  }

  // --- Dialogs ---

  // 1. All Benefits Management
  void _showAllBenefitsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("All Benefits",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Iconsax.close_circle))
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => Wrap(
                    runSpacing: 12,
                    children: _ctrl.availableBenefits
                        .map((b) => Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Iconsax.tick_square,
                                      color: AppColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                      child: Text(b,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500))),
                                  InkWell(
                                    onTap: () => _ctrl.removeBenefitType(b),
                                    child: const Icon(Iconsax.close_circle,
                                        color: Colors.red, size: 16),
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  )),
              const SizedBox(height: 24),
              MyElevatedButton(
                width: double.infinity,
                child: "Add Benefit",
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddBenefitDialog(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  // 2. Add New Benefit Type
  void _showAddBenefitDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Add Benefit",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Iconsax.close_circle))
                ],
              ),
              const SizedBox(height: 16),
              MyTextFormField(
                title: "Benefit Name",
                controller: nameCtrl,
                hintText: "Data Allowance",
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyElevatedButton(
                    child: "Save",
                    onTap: () {
                      bool success = _ctrl.addBenefitType(nameCtrl.text.trim());
                      if (success) {
                        Navigator.pop(ctx); // Use dialog context 'ctx' to pop
                        AppToast.success(context, 'Benefit added successfully');
                      }
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // 3. View Staff Benefits
  void _showViewStaffDialog(BuildContext context, BenefitRecord record) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Benefits Checklist for staff",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Iconsax.close_circle))
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.infoSubtle,
                      child: Icon(Iconsax.profile_circle, color: AppColors.primary)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.employeeName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("${record.employeeId} • ${record.employeeRole}",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 24),
              ...record.activeBenefits.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(b,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  )),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyElevatedButton(
                    child: "Edit",
                    onTap: () {
                      Navigator.pop(ctx);
                      _showEditStaffBenefitsDialog(context, record);
                    },
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // 4. Edit Staff Benefits
  void _showEditStaffBenefitsDialog(
      BuildContext context, BenefitRecord record) {
    final selected = Set<String>.from(record.activeBenefits);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (context, setState) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Edit Staff Benefits",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Iconsax.close_circle))
                  ],
                ),
                const SizedBox(height: 16),
                // User Info Header
                Row(
                  children: [
                    const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.infoSubtle,
                        child: Icon(Iconsax.profile_circle, color: AppColors.primary)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.employeeName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        Text(record.employeeRole,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Checklist
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: SingleChildScrollView(
                    child: Column(
                      children: _ctrl.availableBenefits.map((b) {
                        final isSelected = selected.contains(b);
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(b,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                          value: isSelected,
                          activeColor: _blueColor,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selected.add(b);
                              } else {
                                selected.remove(b);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyElevatedButton(
                      child: "Save",
                      onTap: () {
                        _ctrl.updateEmployeeBenefits(
                            record.id, selected.toList());
                        Navigator.pop(ctx);
                        AppToast.success(context, 'Updated successfully');
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- Helper Components ---

  Widget _buildDropdownFilter(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(text,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(width: 8),
          const Icon(Iconsax.arrow_down_1, size: 18, color: Colors.black54)
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color dot;

    if (status == 'Approved') {
      bg = _greenBg;
      dot = _greenTxt;
    } else if (status == 'Rejected') {
      bg = _redBg;
      dot = _redTxt;
    } else {
      bg = _yellowBg;
      dot = _yellowTxt;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(status,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          const Icon(Iconsax.arrow_down_1, size: 14, color: Colors.black54)
        ],
      ),
    );
  }
}
