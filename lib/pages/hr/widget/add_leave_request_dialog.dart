import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

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
    final isEdit = widget.request != null;

    return DialogScaffold(
      title: isEdit ? 'Edit Leave Request' : 'New Request',
      subtitle: isEdit
          ? 'Update the details of this leave request.'
          : 'Submit leave, absence, or late-arrival information for review.',
      size: DialogSize.lg,
      body: _buildBody(),
      actions: [
        Obx(() => MyOutlinedButton(
              child: 'Cancel',
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              textColor: AppColors.textSecondary,
              borderColor: AppColors.borderStrong,
              onTap: _ctrl.isSaving.value
                  ? null
                  : () {
                      _ctrl.clearForm();
                      Navigator.pop(context);
                    },
            )),
        PermissionGate(
          require:
              isEdit ? Perms.leaveRequestsUpdate : Perms.leaveRequestsCreate,
          child: Obx(() => MyElevatedButton(
                height: 44,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                icon: _ctrl.isSaving.value
                    ? null
                    : const Icon(Iconsax.tick_circle,
                        color: AppColors.textOnPrimary, size: 18),
                child: _ctrl.isSaving.value ? 'Saving...' : 'Save',
                onTap: _ctrl.isSaving.value
                    ? null
                    : () =>
                        _ctrl.saveLeaveRequest(context, id: widget.request?.id),
              )),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Obx(() {
      final kind = _ctrl.selectedCreateRequestKind.value;
      final isLate = kind == 'running_late';
      final isLeave = kind == 'leave';
      final kindLabel = switch (kind) {
        'absence' => 'Absence report',
        'running_late' => 'Running-late report',
        _ => 'Leave request',
      };

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            title: 'Request details',
            children: [
              if (widget.request == null) ...[
                MyDropdown(
                  items: const [
                    'Leave request',
                    'Absence report',
                    'Running-late report',
                  ],
                  hintText: kindLabel,
                  initialSelection: kindLabel,
                  title: 'Request type',
                  spaceBetweenText: 8,
                  onChanged: (label) {
                    final requestKind = switch (label) {
                      'Absence report' => 'absence',
                      'Running-late report' => 'running_late',
                      _ => 'leave',
                    };
                    _ctrl.updateCreateRequestKind(requestKind);
                  },
                ),
                const SizedBox(height: 16),
              ] else
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('Request type: $kindLabel',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              if (isLate)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: AppRadii.brMd,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Iconsax.info_circle,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'This report is recorded for today. Submit it before you clock in.',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                if (isLeave) ...[
                  MyDropdown(
                    items: _ctrl.leaveTypes,
                    hintText: _ctrl.selectedLeaveType.value.isEmpty
                        ? 'Select leave type'
                        : _ctrl.selectedLeaveType.value,
                    initialSelection: _ctrl.selectedLeaveType.value.isEmpty
                        ? null
                        : _ctrl.selectedLeaveType.value,
                    title: 'Leave type',
                    spaceBetweenText: 8,
                    onChanged: (value) {
                      if (value != null) _ctrl.selectedLeaveType.value = value;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                LayoutBuilder(builder: (context, constraints) {
                  final startField = MyTextFormField(
                    controller: _ctrl.startDateController,
                    hintText: 'Select date',
                    spaceBetweenText: 8,
                    title: 'Start date',
                    readOnly: true,
                    trailing: const Icon(
                      Iconsax.calendar_1,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => _ctrl.pickDate(context, true),
                  );
                  final endField = MyTextFormField(
                    controller: _ctrl.endDateController,
                    hintText: 'Select date',
                    spaceBetweenText: 8,
                    title: 'End date',
                    readOnly: true,
                    trailing: const Icon(
                      Iconsax.calendar_1,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    onTap: () => _ctrl.pickDate(context, false),
                  );
                  if (constraints.maxWidth < 560) {
                    return Column(children: [
                      startField,
                      const SizedBox(height: 14),
                      endField,
                    ]);
                  }
                  return Row(children: [
                    Expanded(child: startField),
                    const SizedBox(width: 16),
                    Expanded(child: endField),
                  ]);
                }),
              ],
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: isLate
                ? 'Reason for delay'
                : isLeave
                    ? 'Reason for leave'
                    : 'Reason for absence',
            children: [
              MyTextFormField(
                controller: _ctrl.reasonController,
                hintText: isLate
                    ? 'Briefly explain why you expect to arrive late'
                    : isLeave
                        ? 'Briefly describe the reason for this leave'
                        : 'Briefly describe the absence',
                spaceBetweenText: 8,
                maxLines: 5,
                title: 'Reason',
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
