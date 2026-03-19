import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../controller/leave_request_controller.dart';
import '../models/leave_request_model.dart';

class AddLeaveRequestDialog extends StatefulWidget {
  final LeaveRequest? request;
  const AddLeaveRequestDialog({super.key, this.request});

  @override
  State<AddLeaveRequestDialog> createState() => _AddLeaveRequestDialogState();
}

class _AddLeaveRequestDialogState extends State<AddLeaveRequestDialog> {
  final LeaveRequestController _ctrl = Get.find<LeaveRequestController>();

  @override
  void initState() {
    super.initState();
    if (widget.request != null) {
      _ctrl.populateForm(widget.request!);
    } else {
      _ctrl.clearForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    widget.request == null
                        ? 'New Leave Request'
                        : 'Edit Leave Request',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Obx(() => MyDropdown(
                                          items: _ctrl.leaveTypes,
                                          hintText:
                                              _ctrl.selectedLeaveType.value,
                                          spaceBetweenText: 10,
                                          title: 'Leave Type',
                                        )),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: MyTextFormField(
                                  controller: _ctrl.startDateController,
                                  hintText: 'Select Date',
                                  spaceBetweenText: 10,
                                  title: 'Start Date',
                                  readOnly: true,
                                  onTap: () => _ctrl.pickDate(context, true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          MyTextFormField(
                            controller: _ctrl.endDateController,
                            hintText: 'Select Date',
                            spaceBetweenText: 10,
                            title: 'End Date',
                            readOnly: true,
                            onTap: () => _ctrl.pickDate(context, false),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: MyTextFormField(
                                  controller: _ctrl.reasonController,
                                  hintText: "Enter reason",
                                  spaceBetweenText: 10,
                                  maxLines: 5,
                                  title: 'Reason',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    borderColor: null,
                    child: 'Cancel',
                    onTap: _ctrl.isSaving.value
                        ? null
                        : () {
                            _ctrl.clearForm();
                            Navigator.pop(context);
                          },
                  ),
                  const SizedBox(width: 16),
                  Obx(() => MyElevatedButton(
                        icon: _ctrl.isSaving.value
                            ? null
                            : SvgPicture.asset(
                                "assets/svg/check.svg",
                                colorFilter: const ColorFilter.mode(
                                    AppColors.white, BlendMode.srcIn),
                              ),
                        child: _ctrl.isSaving.value ? 'Saving...' : 'Save',
                        onTap: _ctrl.isSaving.value
                            ? null
                            : () => _ctrl.saveLeaveRequest(context,
                                id: widget.request?.id),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
