import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:collection/collection.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/services/auth_service.dart';
import 'package:bomach_os/src/services/biometric_api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:bomach_os/src/helper/date_picker_helper.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controller/work_report_controller.dart';
import '../models/work_report_model.dart';
import '../models/workspace_model.dart';
import 'dynamic_item_list_field.dart';

class DailyWorkReportDialog extends StatefulWidget {
  final WorkReport? existingReport;
  final String token;

  const DailyWorkReportDialog({
    super.key,
    this.existingReport,
    required this.token,
  });

  @override
  State<DailyWorkReportDialog> createState() => _DailyWorkReportDialogState();
}

class _DailyWorkReportDialogState extends State<DailyWorkReportDialog> {
  final WorkReportController controller = Get.find();

  late TextEditingController _hoursWorkedController;
  final List<TextEditingController> _achievedControllers = [];
  final List<TextEditingController> _problemsControllers = [];
  final List<TextEditingController> _plansControllers = [];
  final List<WorkReportAttachment> _attachments = [];
  bool _isUploading = false;

  DateTime _reportDate = DateTime.now();
  String? _selectedOperationalBase;
  List<WorkspaceConfig> _eligibleWorkspaces = [];
  bool _isLoadingWorkspaces = false;
  String? _workspaceError;

  @override
  void initState() {
    super.initState();
    final r = widget.existingReport;
    _hoursWorkedController =
        TextEditingController(text: r?.hoursWorked.toString() ?? '');
    _selectedOperationalBase = r?.operationalBase;

    final achievedItems = WorkReportFormatUtils.parseItems(r?.workActivities);
    if (achievedItems.isNotEmpty) {
      _achievedControllers.addAll(
          achievedItems.map((item) => TextEditingController(text: item)));
    } else {
      _achievedControllers.add(TextEditingController());
    }

    final problemsItems = WorkReportFormatUtils.parseItems(r?.taskDetails);
    if (problemsItems.isNotEmpty) {
      _problemsControllers.addAll(
          problemsItems.map((item) => TextEditingController(text: item)));
    } else {
      _problemsControllers.add(TextEditingController());
    }

    final plansItems = WorkReportFormatUtils.parseItems(r?.planNextDay);
    if (plansItems.isNotEmpty) {
      _plansControllers.addAll(
          plansItems.map((item) => TextEditingController(text: item)));
    } else {
      _plansControllers.add(TextEditingController());
    }

    _reportDate = r?.day ?? DateTime.now();
    if (r?.attachments != null) {
      _attachments.addAll(r!.attachments);
    }
    _loadWorkspaces();
  }

  @override
  void dispose() {
    _hoursWorkedController.dispose();
    for (final c in _achievedControllers) {
      c.dispose();
    }
    for (final c in _problemsControllers) {
      c.dispose();
    }
    for (final c in _plansControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadWorkspaces() async {
    setState(() {
      _isLoadingWorkspaces = true;
      _workspaceError = null;
    });
    try {
      final api = BiometricApiService();
      final raw = await api.getWorkspaces(widget.token);
      if (!mounted) return;
      setState(() {
        _eligibleWorkspaces = raw
            .map(WorkspaceConfig.fromJson)
            .where((workspace) => workspace.canClockIn)
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _workspaceError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoadingWorkspaces = false);
    }
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _isUploading = true);
    try {
      final authService = AuthService();
      final url = await authService.uploadFile(
          widget.token, file.bytes!.toList(), file.name);
      setState(() {
        _attachments.add(WorkReportAttachment(fileUrl: url));
      });
    } catch (e) {
      if (mounted) {
        AppToast.error(context, 'Failed to upload file: $e');

      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePopover(
      context,
      initialDate: _reportDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _reportDate) {
      setState(() => _reportDate = picked);
    }
  }

  void _handleSubmit() async {
    final navigatorContext = Navigator.of(context).context;
    if (_hoursWorkedController.text.isEmpty) {
      AppToast.error(context, 'Hours worked is required');
      return;
    }

    final activities =
        WorkReportFormatUtils.serializeItems(_achievedControllers);
    final problems = WorkReportFormatUtils.serializeItems(_problemsControllers);
    final plans = WorkReportFormatUtils.serializeItems(_plansControllers);

    final report = WorkReport(
      id: widget.existingReport?.id ?? '',
      employeeId: widget.existingReport?.employeeId ?? 0,
      day: _reportDate,
      hoursWorked: double.tryParse(_hoursWorkedController.text) ?? 0.0,
      operationalBase: _selectedOperationalBase?.isNotEmpty == true
          ? _selectedOperationalBase
          : null,
      workActivities: activities,
      taskDetails: problems,
      planNextDay: plans,
      status: 'draft',
      rating: widget.existingReport?.rating,
      feedback: widget.existingReport?.feedback,
      attachments: _attachments,
    );

    bool success;
    if (widget.existingReport != null) {
      success = await controller.updateReport(
          widget.token, widget.existingReport!.id, report);
    } else {
      success = await controller.createReport(widget.token, report);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      AppToast.success(navigatorContext, 'Report submitted');
    } else if (mounted) {
      AppToast.error(context, 'Failed to submit');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingReport != null;

    return DialogScaffold(
      title: isEdit ? 'Edit Work Report' : 'New Work Report',
      subtitle: isEdit
          ? 'Update your daily work activities, hours, and attachments.'
          : 'Log your daily work activities, hours, and any supporting files.',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSection(
            title: 'Report Summary',
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildDateField(
                        label: 'Report Date',
                        value: _reportDate,
                        onTap: _selectDate,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MyTextFormField(
                        title: 'Hours Worked',
                        controller: _hoursWorkedController,
                        keyboardType: TextInputType.number,
                        hintText: 'e.g. 8.0',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildOperationalBaseField(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Activities & Plans',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DynamicItemListField(
                  title: 'Things Achieved / Work Activities',
                  subtitle: 'Itemize the tasks and milestones completed today',
                  hintText: 'Describe an achievement or completed task...',
                  controllers: _achievedControllers,
                  onAdd: () {
                    setState(() {
                      _achievedControllers.add(TextEditingController());
                    });
                  },
                  onRemove: (index) {
                    setState(() {
                      _achievedControllers[index].dispose();
                      _achievedControllers.removeAt(index);
                    });
                  },
                ),
                const SizedBox(height: 20),
                DynamicItemListField(
                  title: 'Problems Faced / Challenges',
                  subtitle: 'List any blockers or difficulties encountered',
                  hintText: 'Describe a challenge, blocker, or issue faced...',
                  controllers: _problemsControllers,
                  onAdd: () {
                    setState(() {
                      _problemsControllers.add(TextEditingController());
                    });
                  },
                  onRemove: (index) {
                    setState(() {
                      _problemsControllers[index].dispose();
                      _problemsControllers.removeAt(index);
                    });
                  },
                ),
                const SizedBox(height: 20),
                DynamicItemListField(
                  title: 'Tasks & Plans for Next Week',
                  subtitle: 'What do you plan to work on next week / tomorrow',
                  hintText: 'Describe a planned task or goal...',
                  controllers: _plansControllers,
                  onAdd: () {
                    setState(() {
                      _plansControllers.add(TextEditingController());
                    });
                  },
                  onRemove: (index) {
                    setState(() {
                      _plansControllers[index].dispose();
                      _plansControllers.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSection(
            title: 'Attachments',
            subtitle: 'Upload supporting documents',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyElevatedButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  isLoading: _isUploading,
                  icon: const Icon(Iconsax.document_upload,
                      size: 18, color: AppColors.white),
                  child: _isUploading ? 'Uploading...' : 'Choose File',
                  onTap: _isUploading ? () {} : _pickAndUploadFile,
                ),
                if (_attachments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ..._attachments.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final url = entry.value.fileUrl;
                    final fileName =
                        Uri.tryParse(url)?.pathSegments.lastOrNull ?? url;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadii.brSm,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Iconsax.attach_circle,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fileName,
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: AppRadii.brSm,
                              onTap: () => setState(
                                  () => _attachments.removeAt(idx)),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Iconsax.close_circle,
                                    size: 16, color: AppColors.danger),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
          child: 'Cancel',
          onTap: () => Navigator.pop(context),
        ),
        Obx(() => MyElevatedButton(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              isLoading: controller.isSaving.value,
              child: 'Submit',
              onTap: controller.isSaving.value ? () {} : _handleSubmit,
            )),
      ],
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
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildOperationalBaseField() {
    if (_isLoadingWorkspaces) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Operational Base'),
          SizedBox(height: 8),
          LinearProgressIndicator(),
        ],
      );
    }
    if (_workspaceError != null) {
      return Row(
        children: [
          Expanded(child: Text('Unable to load workspaces: $_workspaceError')),
          TextButton(onPressed: _loadWorkspaces, child: const Text('Retry')),
        ],
      );
    }

    final labels = <String, String>{};
    final duplicateNames = <String>{};
    for (final workspace in _eligibleWorkspaces) {
      if (labels.containsValue(workspace.workspaceName)) {
        duplicateNames.add(workspace.workspaceName);
      }
      labels[_workspaceLabel(workspace, duplicateNames)] = workspace.workspaceName;
    }
    // Rebuild duplicate labels after the complete list is known.
    labels
      ..clear()
      ..addEntries(_eligibleWorkspaces.map((workspace) => MapEntry(
            _workspaceLabel(workspace, duplicateNames), workspace.workspaceName)));

    final options = labels.keys.toList();
    String? initialSelection;
    if (_selectedOperationalBase != null &&
        !labels.values.contains(_selectedOperationalBase)) {
      initialSelection = 'Previous: ${_selectedOperationalBase!}';
      options.insert(0, initialSelection);
    } else {
      initialSelection = labels.entries
          .firstWhereOrNull((entry) => entry.value == _selectedOperationalBase)
          ?.key;
    }

    if (options.isEmpty) {
      return const Text('No approved, active workspaces are available.');
    }
    return MyDropdown(
      title: 'Operational Base',
      hintText: 'Select an approved workspace',
      items: options,
      initialSelection: initialSelection,
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedOperationalBase =
            value.startsWith('Previous: ') ? value.substring(10) : labels[value]);
      },
    );
  }

  String _workspaceLabel(WorkspaceConfig workspace, Set<String> duplicates) {
    if (!duplicates.contains(workspace.workspaceName)) return workspace.workspaceName;
    return '${workspace.workspaceName} (${workspace.latitude.toStringAsFixed(4)}, ${workspace.longitude.toStringAsFixed(4)})';
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: AppRadii.brMd,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.brMd,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.calendar_1,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Text(
                  DateFormat('dd-MM-yyyy').format(value),
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
