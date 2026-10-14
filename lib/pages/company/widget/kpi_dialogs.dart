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
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:bomach_os/src/model/role_kpi_model.dart';
import 'package:bomach_os/src/model/kpi_metric_model.dart';
import 'package:bomach_os/src/services/kpi_metric_service.dart';
import 'package:bomach_os/src/services/permission_service.dart';
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
      builder: (dialogContext, setDialogState) => DialogScaffold(
        title: 'Remove KPI from role?',
        subtitle: 'This only changes the selected role assignment.',
        size: DialogSize.sm,
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Remove “$metricName” from this role?'),
            const SizedBox(height: 8),
            const Text(
              'The shared metric and historical employee KPI data will remain.',
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
          FilledButton(
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
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text(saving ? 'Removing…' : 'Remove from role'),
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
  bool get _canSave =>
      _selectedRoleId != null &&
      _selectedMetricId != null &&
      !_loadingMetrics &&
      !_loadingAssignments &&
      _metricLoadError == null &&
      _assignmentLoadError == null;

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

  Future<void> _showCreateMetricDialog(BuildContext context) async {
    final created = await showDialog<KPIMetric>(
      context: context,
      builder: (_) => _CreateMetricDialog(
        service: _metricService,
        storage: _storage,
      ),
    );
    if (!mounted || created == null) return;
    setState(() {
      _metrics = [..._metrics, created];
      _selectedMetricId = created.id;
      _selectedMetricUnit = created.unit;
      _actionError = null;
    });
    AppToast.success(context, 'Shared metric created.',
        duration: const Duration(seconds: 2));
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
    if (sequenceText.isNotEmpty &&
        (sequence == null || sequence < 1 || sequence > 2147483647)) {
      _setActionError('Display order must be between 1 and 2,147,483,647.');
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
                child: TextButton.icon(
                  onPressed: () => _showCreateMetricDialog(context),
                  icon: const Icon(Iconsax.add, size: 17),
                  label: const Text('Create metric'),
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
                                      ? 'No shared metrics available'
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
          if (!_isEdit &&
              _metrics.isEmpty &&
              !_loadingMetrics &&
              _metricLoadError == null) ...[
            const SizedBox(height: 8),
            _MetricEmptyNotice(
              canCreate: Get.isRegistered<PermissionService>() &&
                  Get.find<PermissionService>().has(Perms.kpisCreate),
            ),
          ],
          if (!_isEdit && _selectedMetricId == null && _metrics.isNotEmpty) ...[
            const SizedBox(height: 10),
            const _MetricSelectionHint(),
          ],
          const SizedBox(height: 16),

          if (_activeKpi != null || _selectedMetricId != null) ...[
            // ── Tracking Mode + Period row ──────────────────────────────
            ResponsiveRow(
              spacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tracking Mode', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Period', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
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
              ],
            ),
            const SizedBox(height: 16),

            if (_trackingMode == 'automatic' ||
                _trackingMode == 'semi_automatic')
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'This mode is stored as configuration; automatic calculations are not configured.',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),

            // ── Target + Weight row ─────────────────────────────────────
            ResponsiveRow(
              spacing: 12,
              children: [
                Column(
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
                Column(
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
              ],
            ),
            const SizedBox(height: 16),

            ExpansionTile(
              maintainState: true,
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: const Text('Assignment settings'),
              subtitle: const Text('Display order and active status'),
              children: [
                MyTextFormField(
                  controller: _sequenceCtrl,
                  hintText: 'Display order',
                  height: 48,
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  title: const Text('Active for this role'),
                  subtitle:
                      const Text('Inactive KPIs are hidden from dashboards.'),
                ),
              ],
            ),
          ],
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
              onTap: widget.ctrl.isSaving.value || !_canSave ? null : _onSave,
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

class _MetricEmptyNotice extends StatelessWidget {
  final bool canCreate;

  const _MetricEmptyNotice({required this.canCreate});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadii.brSm,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Iconsax.info_circle,
                size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                canCreate
                    ? 'There are no shared metrics yet. Create one to use it in role KPI assignments.'
                    : 'There are no shared metrics available. Ask an administrator to add a KPI metric.',
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
}

class _MetricSelectionHint extends StatelessWidget {
  const _MetricSelectionHint();

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Iconsax.info_circle,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Choose a metric to configure its target, tracking method, and review period.',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      );
}

class _CreateMetricDialog extends StatefulWidget {
  final KpiMetricService service;
  final FlutterSecureStorage storage;

  const _CreateMetricDialog({required this.service, required this.storage});

  @override
  State<_CreateMetricDialog> createState() => _CreateMetricDialogState();
}

class _CreateMetricDialogState extends State<_CreateMetricDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _unit = TextEditingController(text: 'percentage');
  final _description = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _unit.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!(_formKey.currentState?.validate() ?? false) || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final token = await widget.storage.read(key: 'access_token');
      if (token == null || token.trim().isEmpty) {
        throw Exception('Sign in again before creating a shared metric.');
      }
      final metric = await widget.service.createMetric(
        token.replaceAll('"', '').trim(),
        name: _name.text.trim(),
        unit: _unit.text.trim().isEmpty ? 'percentage' : _unit.text.trim(),
        description: _description.text.trim(),
      );
      if (mounted) Navigator.pop(context, metric);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = error
            .toString()
            .replaceFirst(RegExp(r'^Exception: (Unexpected error: )?'), '');
      });
    }
  }

  @override
  Widget build(BuildContext context) => DialogScaffold(
        title: 'Create shared metric',
        subtitle:
            'Add a reusable measure to the KPI catalog. You can assign it to roles after creation.',
        size: DialogSize.sm,
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null) ...[
                _InlineKpiError(message: _error!),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: _name,
                enabled: !_saving,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Metric name',
                  hintText: 'e.g. Client follow-ups completed',
                  helperText:
                      'Use a clear name that can be reused across roles.',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a metric name.'
                    : value.trim().length > 200
                        ? 'Metric names must be 200 characters or fewer.'
                        : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _unit,
                enabled: !_saving,
                decoration: const InputDecoration(
                  labelText: 'Unit',
                  hintText: 'percentage, count, hours',
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a unit.'
                    : value.trim().length > 20
                        ? 'Units must be 20 characters or fewer.'
                        : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _description,
                enabled: !_saving,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What does this metric measure?',
                  alignLabelWithHint: true,
                ),
                validator: (value) => value != null && value.trim().length > 500
                    ? 'Descriptions must be 500 characters or fewer.'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: _saving ? null : _create,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Iconsax.add, size: 17),
            label: Text(_saving ? 'Creating…' : 'Create metric'),
          ),
        ],
      );
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

class _MetricPickerDialog extends StatefulWidget {
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
  State<_MetricPickerDialog> createState() => _MetricPickerDialogState();
}

class _MetricPickerDialogState extends State<_MetricPickerDialog> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metrics = widget.metrics.where((metric) {
      final query = _query.trim().toLowerCase();
      return query.isEmpty ||
          metric.name.toLowerCase().contains(query) ||
          metric.description.toLowerCase().contains(query) ||
          metric.unit.toLowerCase().contains(query);
    }).toList();
    return DialogScaffold(
      title: 'Select a metric',
      subtitle: 'Choose the shared measure to assign to this role.',
      size: DialogSize.md,
      scrollable: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _search,
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              labelText: 'Search metrics',
              prefixIcon: Icon(Iconsax.search_normal),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: metrics.isEmpty
                ? Center(
                    child: Text(_query.isEmpty
                        ? 'No KPI metrics are available.'
                        : 'No metrics match “$_query”.'))
                : ListView.separated(
                    itemCount: metrics.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final metric = metrics[index];
                      final assigned = widget.assignments.firstWhereOrNull(
                        (item) =>
                            item.metricId == metric.id &&
                            item.id != widget.editableAssignmentId,
                      );
                      if (assigned != null) {
                        return ListTile(
                          key: ValueKey('assigned-metric-${metric.id}'),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          leading: const Icon(Iconsax.chart_2,
                              color: AppColors.textMuted),
                          title: Text(metric.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(color: AppColors.textMuted)),
                          subtitle: Text(
                            [metric.unit, 'Already assigned']
                                .where((value) => value.trim().isNotEmpty)
                                .join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                      final selected = metric.id == widget.selectedMetricId;
                      return ListTile(
                        key: ValueKey('metric-${metric.id}'),
                        selected: selected,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        leading: Icon(
                          selected ? Iconsax.tick_circle : Iconsax.chart_2,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        title: Text(metric.name,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                          [metric.description, metric.unit]
                              .where((value) => value.trim().isNotEmpty)
                              .join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Navigator.pop(
                            context, _MetricChoice.metric(metric)),
                      );
                    },
                  ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
