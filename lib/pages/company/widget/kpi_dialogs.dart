import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_kpi_model.dart';
import 'package:bomach_os/src/model/kpi_metric_model.dart';
import 'package:bomach_os/src/services/kpi_metric_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../controllers/role_kpi_controller.dart';
import '../controllers/roles_controller.dart';

Future<KpiActionResult?> showKpiEditorDialog(
  BuildContext context, {
  required RoleKpiController ctrl,
  RoleKpi? kpi,
  int? presetRoleId,
  Future<List<KPIMetric>> Function()? loadMetrics,
}) async {
  final result = await showDialog<KpiActionResult>(
    context: context,
    builder: (_) => CreateEditKpiDialog(
      ctrl: ctrl,
      kpi: kpi,
      presetRoleId: presetRoleId,
      loadMetrics: loadMetrics,
    ),
  );
  if (result?.succeeded == true && context.mounted) {
    AppToast.success(context, result!.message,
        duration: const Duration(seconds: 2));
  }
  return result;
}

Future<bool> showRemoveKpiConfirmation(
  BuildContext context, {
  required RoleKpiController ctrl,
  required int roleId,
  required int id,
  required String metricName,
}) async {
  var saving = false;
  String? error;
  final removed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        title: const Text('Remove KPI from role?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Remove "$metricName" from this role?'),
            const SizedBox(height: 8),
            const Text(
              'This removes only the role assignment. The shared metric and historical employee KPI data will remain.',
            ),
            if (error != null) ...[
              const SizedBox(height: 12),
              _InlineKpiError(message: error!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed:
                saving ? null : () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: saving
                ? null
                : () async {
                    setDialogState(() {
                      saving = true;
                      error = null;
                    });
                    final result = await ctrl.deleteKpi(roleId: roleId, id: id);
                    if (!dialogContext.mounted) return;
                    if (result.succeeded) {
                      Navigator.pop(dialogContext, true);
                    } else {
                      setDialogState(() {
                        saving = false;
                        error = result.message;
                      });
                    }
                  },
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(saving ? 'Removing...' : 'Remove from role'),
          ),
        ],
      ),
    ),
  );
  if (removed == true && context.mounted) {
    AppToast.success(context, 'KPI removed from the role.',
        duration: const Duration(seconds: 2));
  }
  return removed == true;
}

class _MetricChoice {
  final KPIMetric? metric;
  final RoleKpi? assignment;

  const _MetricChoice.metric(this.metric) : assignment = null;
  const _MetricChoice.assignment(this.assignment) : metric = null;
}

class CreateEditKpiDialog extends StatefulWidget {
  final RoleKpiController ctrl;
  final RoleKpi? kpi;
  final int? presetRoleId;
  final Future<List<KPIMetric>> Function()? loadMetrics;

  const CreateEditKpiDialog({
    super.key,
    required this.ctrl,
    this.kpi,
    this.presetRoleId,
    this.loadMetrics,
  });

  @override
  State<CreateEditKpiDialog> createState() => _CreateEditKpiDialogState();
}

class _CreateEditKpiDialogState extends State<CreateEditKpiDialog> {
  final KpiMetricService _metricService = KpiMetricService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  late final TextEditingController _targetCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _sequenceCtrl;

  late int? _selectedMetricId;
  late String _selectedMetricUnit;
  late String _trackingMode;
  late String _period;
  late bool _isActive;
  late int? _selectedRoleId;

  var _metrics = <KPIMetric>[];
  var _assignments = <RoleKpi>[];
  var _loadingMetrics = true;
  String? _metricLoadError;
  var _loadingAssignments = false;
  String? _assignmentLoadError;
  String? _actionError;
  RoleKpi? _editingKpi;
  int _assignmentRequestId = 0;

  RoleKpi? get _activeKpi => _editingKpi ?? widget.kpi;
  bool get _isEdit => _activeKpi != null;

  @override
  void initState() {
    super.initState();
    final kpi = _activeKpi;
    _selectedMetricId = kpi?.metricId;
    _selectedMetricUnit = kpi?.metric?.unit ?? '';
    _trackingMode = kpi?.trackingMode ?? 'manual';
    _period = RoleKpi.editablePeriod(kpi?.period ?? 'monthly');
    _isActive = kpi?.isActive ?? true;
    _selectedRoleId = widget.presetRoleId ?? kpi?.roleId;
    final targetVal = kpi?.targetValue;
    final weightVal = kpi?.weight;
    _targetCtrl = TextEditingController(
        text: targetVal != null
            ? targetVal.toStringAsFixed(targetVal % 1 == 0 ? 0 : 2)
            : '');
    _weightCtrl = TextEditingController(
        text: weightVal != null
            ? weightVal.toStringAsFixed(weightVal % 1 == 0 ? 0 : 2)
            : '');
    _sequenceCtrl =
        TextEditingController(text: kpi?.sequence?.toString() ?? '');
    _fetchMetrics();
    if (_selectedRoleId != null) {
      _fetchAssignments(_selectedRoleId!);
    }
  }

  Future<void> _fetchMetrics() async {
    if (mounted) {
      setState(() {
        _loadingMetrics = true;
        _metricLoadError = null;
      });
    }
    try {
      final metrics = widget.loadMetrics != null
          ? await widget.loadMetrics!()
          : await _loadMetricsFromApi();
      if (mounted) {
        setState(() {
          final activeMetric = _activeKpi?.metric;
          if (activeMetric != null &&
              !metrics.any((metric) => metric.id == activeMetric.id)) {
            metrics.insert(
              0,
              KPIMetric(
                id: activeMetric.id,
                name: activeMetric.name,
                description: activeMetric.description,
                unit: activeMetric.unit,
              ),
            );
          }
          _metrics = metrics;
          _loadingMetrics = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingMetrics = false;
          _metricLoadError = 'Could not load KPI metrics. Please retry.';
        });
      }
    }
  }

  Future<List<KPIMetric>> _loadMetricsFromApi() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) {
      throw Exception('Authentication required. Sign in again.');
    }
    final cleanToken = token.replaceAll('"', '').trim();
    final metrics = <KPIMetric>[];
    var offset = 0;
    var count = 0;
    do {
      final result = await _metricService.listMetrics(
        cleanToken,
        limit: 100,
        offset: offset,
      );
      metrics.addAll(result.list);
      count = result.count;
      if (result.list.isEmpty) break;
      offset += result.list.length;
    } while (offset < count);
    return metrics;
  }

  Future<void> _fetchAssignments(int roleId) async {
    final requestId = ++_assignmentRequestId;
    setState(() {
      _loadingAssignments = true;
      _assignmentLoadError = null;
    });
    final result = await widget.ctrl.loadRoleAssignments(roleId);
    if (!mounted || requestId != _assignmentRequestId) return;
    setState(() {
      _assignments = result.list;
      _assignmentLoadError = result.error;
      _loadingAssignments = false;
    });
  }

  void _onRoleChanged(int? roleId) {
    setState(() {
      _selectedRoleId = roleId;
      _selectedMetricId = null;
      _selectedMetricUnit = '';
      _actionError = null;
      _assignments = [];
      _assignmentLoadError = null;
    });
    if (roleId != null) _fetchAssignments(roleId);
  }

  Future<void> _pickMetric() async {
    if (_selectedRoleId == null ||
        _loadingAssignments ||
        _assignmentLoadError != null) {
      return;
    }
    final choice = await showDialog<_MetricChoice>(
      context: context,
      builder: (context) => _MetricPickerDialog(
        metrics: _metrics,
        assignments: _assignments,
        selectedMetricId: _selectedMetricId,
        editableAssignmentId: _activeKpi?.id,
      ),
    );
    if (!mounted || choice == null) return;
    if (choice.assignment != null) {
      _switchToEdit(choice.assignment!);
    } else if (choice.metric != null) {
      setState(() {
        _selectedMetricId = choice.metric!.id;
        _selectedMetricUnit = choice.metric!.unit;
        _actionError = null;
      });
    }
  }

  void _switchToEdit(RoleKpi kpi) {
    setState(() {
      _editingKpi = kpi;
      _selectedRoleId = kpi.roleId;
      _selectedMetricId = kpi.metricId;
      _selectedMetricUnit = kpi.metric?.unit ?? '';
      _trackingMode = kpi.trackingMode;
      _period = RoleKpi.editablePeriod(kpi.period);
      _isActive = kpi.isActive;
      _targetCtrl.text = kpi.targetValue?.toString() ?? '';
      _weightCtrl.text = kpi.weight?.toString() ?? '';
      _sequenceCtrl.text = kpi.sequence?.toString() ?? '';
      _actionError = null;
    });
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _weightCtrl.dispose();
    _sequenceCtrl.dispose();
    super.dispose();
  }

  void _showCreateMetricDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: 'percentage');
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Metric'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyTextFormField(
                controller: nameCtrl,
                hintText: 'Metric name (required)',
                height: 44,
              ),
              const SizedBox(height: 12),
              MyTextFormField(
                controller: unitCtrl,
                hintText: 'Unit (e.g. %, count, hours)',
                height: 44,
              ),
              const SizedBox(height: 12),
              MyTextFormField(
                controller: descCtrl,
                hintText: 'Description (optional)',
                height: 88,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) {
                Get.snackbar('Validation', 'Name is required',
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }
              try {
                final token = await _storage.read(key: 'access_token');
                if (token == null) return;
                final cleanToken = token.replaceAll('"', '').trim();
                final created = await _metricService.createMetric(
                  cleanToken,
                  name: nameCtrl.text.trim(),
                  unit: unitCtrl.text.trim().isEmpty
                      ? 'percentage'
                      : unitCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                setState(() {
                  _metrics = [..._metrics, created];
                  _selectedMetricId = created.id;
                  _selectedMetricUnit = created.unit;
                });
                Get.snackbar('Success', 'Metric "${created.name}" created',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.shade50,
                    colorText: Colors.green.shade800);
              } catch (e) {
                Get.snackbar('Error', 'Failed to create metric: $e',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.shade50,
                    colorText: Colors.red.shade800);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _setActionError(String message) {
    if (mounted) setState(() => _actionError = message);
  }

  Future<void> _onSave() async {
    setState(() => _actionError = null);
    if (_selectedMetricId == null) {
      _setActionError('Select a metric to continue.');
      return;
    }
    if (_selectedRoleId == null) {
      _setActionError('Select a role to continue.');
      return;
    }
    if (_loadingMetrics || _metricLoadError != null) {
      _setActionError('Load the KPI metrics before saving.');
      return;
    }
    if (_loadingAssignments || _assignmentLoadError != null) {
      _setActionError('Confirm this role’s assigned metrics before saving.');
      return;
    }

    final targetText = _targetCtrl.text.trim();
    final targetValue = targetText.isEmpty ? null : double.tryParse(targetText);
    if (targetText.isNotEmpty && targetValue == null) {
      _setActionError('Target must be a number.');
      return;
    }
    if (targetValue != null && targetValue < 0) {
      _setActionError('Target cannot be negative.');
      return;
    }

    final weightText = _weightCtrl.text.trim();
    final weight = weightText.isEmpty ? null : double.tryParse(weightText);
    if (weightText.isNotEmpty && weight == null) {
      _setActionError('Weight must be a number.');
      return;
    }
    if (weight != null && (weight < 0 || weight > 100)) {
      _setActionError('Weight must be between 0 and 100.');
      return;
    }

    final sequenceText = _sequenceCtrl.text.trim();
    final sequence = sequenceText.isEmpty ? null : int.tryParse(sequenceText);
    if (sequenceText.isNotEmpty && (sequence == null || sequence < 1)) {
      _setActionError('Sequence must be a positive whole number.');
      return;
    }

    final activeKpi = _activeKpi;
    final roleId = _selectedRoleId!;

    final result = activeKpi != null
        ? await widget.ctrl.updateKpi(
            roleId: roleId,
            id: activeKpi.id!,
            metricId: _selectedMetricId!,
            trackingMode: _trackingMode,
            period: _period,
            targetValue: targetValue,
            weight: weight,
            sequence: sequence,
            isActive: _isActive,
          )
        : await widget.ctrl.createKpi(
            roleId: roleId,
            metricId: _selectedMetricId!,
            trackingMode: _trackingMode,
            period: _period,
            targetValue: targetValue,
            weight: weight,
            sequence: sequence,
            isActive: _isActive,
          );

    if (!mounted) return;
    if (result.succeeded) {
      Navigator.pop(context, result);
    } else {
      _setActionError(result.message);
      if (result.statusCode == 409) _fetchAssignments(roleId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _isEdit;

    return DialogScaffold(
      title: isEdit ? 'Edit KPI' : 'Add KPI',
      subtitle: isEdit
          ? 'Update the KPI definition for this role.'
          : 'Define a new Key Performance Indicator for a role template.',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_actionError != null) ...[
            _InlineKpiError(message: _actionError!),
            const SizedBox(height: 16),
          ],
          // The global form requires a role before it can determine which
          // metrics are already assigned and therefore unavailable.
          if (widget.presetRoleId == null &&
              widget.kpi == null &&
              _editingKpi == null &&
              Get.isRegistered<RolesController>()) ...[
            const Text('Role', style: AppTextStyles.label),
            const SizedBox(height: 8),
            GetBuilder<RolesController>(
              init: Get.find<RolesController>(),
              builder: (rc) => DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(borderRadius: AppRadii.brMd),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                initialValue: _selectedRoleId,
                hint: const Text('Select role'),
                items: rc.roles
                    .map((r) => DropdownMenuItem(
                          value: r.id,
                          child: Text(r.name),
                        ))
                    .toList(),
                onChanged: _onRoleChanged,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Metric Selector ──────────────────────────────────────────
          Row(
            children: [
              const Expanded(child: Text('Metric', style: AppTextStyles.label)),
              PermissionGate(
                require: Perms.kpisCreate,
                child: GestureDetector(
                  onTap: () => _showCreateMetricDialog(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_circle_outline,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text('New',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _loadingMetrics
              ? const SizedBox(
                  height: 48,
                  child: Center(
                      child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )),
                )
              : _metricLoadError != null
                  ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            _metricLoadError!,
                            style: const TextStyle(color: AppColors.danger),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Retry loading metrics',
                          onPressed: _fetchMetrics,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    )
                  : InkWell(
                      onTap: _selectedRoleId == null || _loadingAssignments
                          ? null
                          : _pickMetric,
                      borderRadius: AppRadii.brMd,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          enabled: _selectedRoleId != null &&
                              !_loadingAssignments &&
                              _assignmentLoadError == null,
                          border: const OutlineInputBorder(
                              borderRadius: AppRadii.brMd),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          suffixIcon: _loadingAssignments
                              ? const Padding(
                                  padding: EdgeInsets.all(13),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                )
                              : const Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          _selectedRoleId == null
                              ? 'Select a role first'
                              : _selectedMetricId == null
                                  ? (_metrics.isEmpty
                                      ? 'No metrics available — click “New”'
                                      : 'Select a metric')
                                  : _metrics
                                          .firstWhereOrNull((metric) =>
                                              metric.id == _selectedMetricId)
                                          ?.name ??
                                      _activeKpi?.metric?.name ??
                                      'Selected metric',
                          style: TextStyle(
                            color: _selectedRoleId == null
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
          if (_assignmentLoadError != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Could not check metrics assigned to this role: $_assignmentLoadError',
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
                IconButton(
                  tooltip: 'Retry role metrics',
                  onPressed: _selectedRoleId == null
                      ? null
                      : () => _fetchAssignments(_selectedRoleId!),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),

          // ── Tracking Mode + Period row ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tracking Mode', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(borderRadius: AppRadii.brMd),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      initialValue: _trackingMode,
                      items: RoleKpi.trackingModeOptions
                          .map((t) => DropdownMenuItem(
                              value: t, child: Text(_formatLabel(t))))
                          .toList(),
                      onChanged: (v) => setState(() => _trackingMode = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Period', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(borderRadius: AppRadii.brMd),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      initialValue: _period,
                      items: RoleKpi.periodOptions
                          .map((p) => DropdownMenuItem(
                              value: p, child: Text(_formatLabel(p))))
                          .toList(),
                      onChanged: (v) => setState(() => _period = v!),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_trackingMode == 'automatic' || _trackingMode == 'semi_automatic')
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'This mode is stored as configuration; automatic calculations are not configured.',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),

          // ── Target + Weight row ─────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Target Value ${_selectedMetricUnit.isNotEmpty ? "($_selectedMetricUnit)" : ""}',
                        style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    MyTextFormField(
                      controller: _targetCtrl,
                      hintText: 'e.g. 95',
                      height: 48,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weight', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    MyTextFormField(
                      controller: _weightCtrl,
                      hintText: 'e.g. 1.0',
                      height: 48,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Sequence ────────────────────────────────────────────────
          const Text('Sequence (optional)', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MyTextFormField(
            controller: _sequenceCtrl,
            hintText: 'Display order',
            height: 48,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // ── Active toggle ─────────────────────────────────────────────
          Row(
            children: [
              Switch(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                activeThumbColor: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text('Active', style: AppTextStyles.bodyMd),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '(inactive KPIs are hidden from dashboards)',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          onTap: () => Navigator.pop(context),
        ),
        Obx(() => MyElevatedButton(
              width: 140,
              height: 44,
              onTap: widget.ctrl.isSaving.value ? null : _onSave,
              child: widget.ctrl.isSaving.value
                  ? 'Saving...'
                  : (isEdit ? 'Save Changes' : 'Add KPI'),
            )),
      ],
    );
  }

  String _formatLabel(String s) =>
      s.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');
}

class _InlineKpiError extends StatelessWidget {
  final String message;

  const _InlineKpiError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerSubtle,
        borderRadius: AppRadii.brSm,
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.danger),
              semanticsLabel: message,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPickerDialog extends StatelessWidget {
  final List<KPIMetric> metrics;
  final List<RoleKpi> assignments;
  final int? selectedMetricId;
  final int? editableAssignmentId;

  const _MetricPickerDialog({
    required this.metrics,
    required this.assignments,
    required this.selectedMetricId,
    required this.editableAssignmentId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select a metric'),
      content: SizedBox(
        width: 480,
        height: 460,
        child: metrics.isEmpty
            ? const Center(child: Text('No KPI metrics are available.'))
            : ListView.separated(
                itemCount: metrics.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final metric = metrics[index];
                  final assigned = assignments.firstWhereOrNull(
                    (item) =>
                        item.metricId == metric.id &&
                        item.id != editableAssignmentId,
                  );
                  if (assigned != null) {
                    return ListTile(
                      enabled: false,
                      leading:
                          const Icon(Iconsax.chart, color: AppColors.textMuted),
                      title: Text(metric.name,
                          style: const TextStyle(color: AppColors.textMuted)),
                      subtitle: Text('${metric.unit} · Already assigned'),
                      trailing: PermissionGate(
                        allOf: const [
                          Perms.roleKpisUpdate,
                          Perms.kpisList,
                        ],
                        child: TextButton.icon(
                          onPressed: () => Navigator.pop(
                              context, _MetricChoice.assignment(assigned)),
                          icon: const Icon(Iconsax.edit_2, size: 16),
                          label: const Text('Edit'),
                        ),
                      ),
                    );
                  }
                  return ListTile(
                    selected: metric.id == selectedMetricId,
                    leading: Icon(
                      metric.id == selectedMetricId
                          ? Iconsax.tick_circle
                          : Iconsax.chart,
                      color: metric.id == selectedMetricId
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    title: Text(metric.name),
                    subtitle: Text(metric.unit),
                    onTap: () =>
                        Navigator.pop(context, _MetricChoice.metric(metric)),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
