import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/work_site_controller.dart';
import '../models/models.dart';

class AddWorksiteDialog extends StatefulWidget {
  final Worksite? worksite;
  final int projectId;

  const AddWorksiteDialog({super.key, this.worksite, this.projectId = 0});

  @override
  State<AddWorksiteDialog> createState() => AddWorksiteDialogState();
}

class AddWorksiteDialogState extends State<AddWorksiteDialog> {
  final WorksiteController controller = Get.find<WorksiteController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController locationCtrl;
  late TextEditingController descCtrl;
  String selectedStatus = 'Active';
  String? selectedClientId;
  String? selectedLeadId;
  final clientCtrl = TextEditingController();
  final leadCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.worksite?.name ?? '');
    locationCtrl = TextEditingController(text: widget.worksite?.location ?? '');
    descCtrl = TextEditingController(text: widget.worksite?.description ?? '');

    if (widget.worksite != null && widget.worksite!.status.isNotEmpty) {
      selectedStatus = widget.worksite!.status;
    }
    selectedClientId = widget.worksite?.clientId?.toString();
    selectedLeadId = widget.worksite?.leadId?.toString();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    locationCtrl.dispose();
    descCtrl.dispose();
    clientCtrl.dispose();
    leadCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (nameCtrl.text.isEmpty || locationCtrl.text.isEmpty) return;

    final formWorksite = Worksite(
      id: widget.worksite?.id ?? 0,
      projectId: widget.worksite?.projectId ?? widget.projectId,
      name: nameCtrl.text,
      location: locationCtrl.text,
      status: selectedStatus,
      description: descCtrl.text,
      clientId: selectedClientId == null
          ? null
          : int.tryParse(selectedClientId!),
      leadId: selectedLeadId == null ? null : int.tryParse(selectedLeadId!),
      createdAt: widget.worksite?.createdAt ?? '',
      updatedAt: '',
    );

    if (widget.worksite == null) {
      controller.createWorksite(context, formWorksite);
    } else {
      controller.updateWorksite(context, formWorksite.id, formWorksite);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.worksite != null;

    return Obx(
      () => DialogScaffold(
          title: isEdit ? 'Edit Worksite' : 'New Worksite',
          subtitle: isEdit
              ? 'Update worksite location and operational status.'
              : 'Register a new field worksite with location and status.',
          size: DialogSize.md,
          body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSection(
                  title: 'Site information',
                  subtitle: 'Identify the worksite and its location.',
                  child: Column(
                    children: [
                      MyTextFormField(
                        controller: nameCtrl,
                        title: 'Worksite Name',
                        hintText: 'e.g. Site A',
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      MyTextFormField(
                        controller: locationCtrl,
                        title: 'Location',
                        hintText: 'e.g. 123 Industrial Rd',
                        maxLines: 2,
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Required'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              _buildSection(
                title: 'Client or lead (optional)',
                subtitle: 'Choose one contact to associate with this worksite.',
                child: Column(
                  children: [
                    Obx(
                      () => MyDropdown(
                        controller: clientCtrl,
                        title: 'Client',
                        hintText: 'No client selected',
                        initialSelection: selectedClientId == null
                            ? null
                            : controller.clients
                                  .firstWhereOrNull(
                                    (client) =>
                                        client.id.toString() ==
                                        selectedClientId,
                                  )
                                  ?.fullName,
                        items: controller.clients
                            .map((client) => client.fullName)
                            .toList(),
                        onChanged: (name) {
                          final client = controller.clients.firstWhereOrNull(
                            (item) => item.fullName == name,
                          );
                          setState(() {
                            selectedClientId = client?.id.toString();
                            if (client != null) {
                              selectedLeadId = null;
                              leadCtrl.clear();
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => MyDropdown(
                        controller: leadCtrl,
                        title: 'Lead',
                        hintText: 'No lead selected',
                        initialSelection: selectedLeadId == null
                            ? null
                            : controller.leads
                                  .firstWhereOrNull(
                                    (lead) =>
                                        lead.id.toString() == selectedLeadId,
                                  )
                                  ?.fullName,
                        items: controller.leads
                            .map((lead) => lead.fullName)
                            .toList(),
                        onChanged: (name) {
                          final lead = controller.leads.firstWhereOrNull(
                            (item) => item.fullName == name,
                          );
                          setState(() {
                            selectedLeadId = lead?.id.toString();
                            if (lead != null) {
                              selectedClientId = null;
                              clientCtrl.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
                _buildSection(
                  title: 'Operational status',
                  subtitle: 'Track the current working state of this site.',
                  child: MyDropdown(
                    title: 'Status',
                    hintText: 'Select Status',
                    items: const ['Active', 'Paused', 'Closed', 'Hazard'],
                    initialSelection: selectedStatus,
                    onChanged: (val) =>
                        setState(() => selectedStatus = val ?? selectedStatus),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Notes',
                  child: MyTextFormField(
                    controller: descCtrl,
                    title: 'Details / Notes',
                    hintText: 'Additional details...',
                    maxLines: 4,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            MyOutlinedButton(
              child: 'Cancel',
              height: 44,
              onTap: () => Navigator.pop(context),
              textColor: AppColors.textSecondary,
              borderColor: AppColors.borderStrong,
            ),
            MyElevatedButton(
              width: 140,
              height: 44,
              child: controller.isActionLoading.value
                  ? 'Saving...'
                  : (isEdit ? 'Update' : 'Save'),
              onTap: controller.isActionLoading.value ? null : _save,
              icon: controller.isActionLoading.value
                  ? null
                  : const Icon(
                      Iconsax.tick_circle,
                      size: 18,
                      color: AppColors.textOnPrimary,
                    ),
            ),
          ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
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
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
