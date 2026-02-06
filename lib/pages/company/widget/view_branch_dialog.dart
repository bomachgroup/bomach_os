import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/model/branch_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/branch_controller.dart';
import 'add_branch_dialog.dart';

class ViewBranchDialog extends StatefulWidget {
  const ViewBranchDialog({super.key});

  @override
  State<ViewBranchDialog> createState() => _ViewBranchDialogState();
}

class _ViewBranchDialogState extends State<ViewBranchDialog> {
  final BranchController controller = Get.find<BranchController>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Obx(() {
          if (controller.isLoadingDetail.value) {
            return const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final branch = controller.currentBranch.value;

          if (branch == null) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: const Center(child: Text("Branch details not found")),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: MyText(
                        branch.branchName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        child: Column(
                          children: [
                            _buildDetailRow("Branch Name", branch.branchName),
                            kSizedBox,
                            _buildDetailRow("Country", branch.countryName),
                            kSizedBox,
                            _buildDetailRow("State", branch.stateName),
                            kSizedBox,
                            _buildDetailRow("L.G.A", branch.lga),
                            kSizedBox,
                            _buildDetailRow(
                                "Office Address", branch.officeAddress),
                            kSizedBox,
                            _buildDetailRow("Branch ID", branch.branchId),
                            kSizedBox,
                            _buildStatusRow(branch),
                            kSizedBox,
                            _buildManagerRow(branch),
                            kSizedBox,
                            _buildDetailRow(
                                "Contact Email", branch.contactEmail),
                            kSizedBox,
                            _buildDetailRow(
                                "Contact Phone", branch.contactPhone),
                            kSizedBox,
                            _buildDetailRow("Uploaded Branch File",
                                branch.branchFile ?? "No file uploaded"),
                            kSizedBox,
                            _buildDetailRow("Date Created", branch.createdAt),
                            kSizedBox,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        alignment: WrapAlignment.end,
                        children: [
                          // MyElevatedButton(
                          //   bgColor: AppColors.red,
                          //   child: 'Delete',
                          //   onTap: () {
                          //     // Implement delete logic here
                          //     Navigator.pop(context);
                          //   },
                          // ),
                          MyElevatedButton(
                            child: 'Edit',
                            onTap: () {
                              Navigator.pop(context);
                              controller.loadFormResources();

                              showDialog(
                                context: context,
                                builder: (context) => AddBranchDialog(
                                  branchToEdit: controller.currentBranch.value,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: MyText(
            label,
            weight: 300,
            size: 16,
          ),
        ),
        Expanded(
          flex: 5,
          child: MyText(
            value.isNotEmpty ? value : "N/A",
            weight: 400,
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(Branch branch) {
    bool isActive = branch.operationalStatus.toLowerCase() == 'active';
    return Row(
      children: [
        const Expanded(
          flex: 3,
          child: MyText(
            "Operational Status",
            weight: 300,
            size: 16,
          ),
        ),
        Expanded(
          flex: 5,
          child: Row(
            children: [
              Container(
                height: 10,
                width: 10,
                decoration: ShapeDecoration(
                  color: isActive ? AppColors.green : AppColors.red,
                  shape: const OvalBorder(),
                ),
              ),
              kSizedBoxWidthTiny,
              MyText(branch.operationalStatusDisplay),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildManagerRow(Branch branch) {
    return Row(
      children: [
        const Expanded(
          flex: 3,
          child: MyText(
            "Manager",
            weight: 300,
            size: 16,
          ),
        ),
        Expanded(
          flex: 5,
          child: Row(
            children: [
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                width: 36,
                height: 36,
                child: Image.asset('assets/icons/profile-icon.png'),
              ),
              kSizedBoxWidth,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    branch.managerName.isNotEmpty
                        ? branch.managerName
                        : "Unassigned",
                    weight: 400,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
