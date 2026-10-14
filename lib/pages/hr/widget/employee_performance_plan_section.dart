import 'dart:convert';

import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/kpi_metric_model.dart';
import 'package:bomach_os/src/services/employee_performance_plan_service.dart';
import 'package:bomach_os/src/services/kpi_metric_service.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:bomach_os/src/utils/number_formatting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

const _maxPlanItemSequence = 2147483647;

enum _EmployeeKpiSource { employeeOnly, sharedMetric, createSharedMetric }

/// Shared presentation for manager editing and the staff read-only plan view.
class EmployeePerformancePlanSection extends StatefulWidget {
  final int? employeeUserId;
  final bool readOnly;
  final EmployeePerformancePlanService? service;
  final Future<String> Function()? tokenReader;

  const EmployeePerformancePlanSection({
    super.key,
    this.employeeUserId,
    this.readOnly = false,
    this.service,
    this.tokenReader,
  });

  @override
  State<EmployeePerformancePlanSection> createState() =>
      _EmployeePerformancePlanSectionState();
}

class _EmployeePerformancePlanSectionState
    extends State<EmployeePerformancePlanSection> {
  final _storage = const FlutterSecureStorage();
  late final EmployeePerformancePlanService _service;
  final _reason = TextEditingController();
  late DateTime _periodStart;
  late DateTime _periodEnd;
  Map<String, dynamic>? _plan;
  List<Map<String, dynamic>> _history = [];
  String _scope = 'period_only';
  String _error = '';
  String? _reasonError;
  String _historyError = '';
  bool _loading = true;
  bool _saving = false;
  bool _refreshing = false;
  bool _hasDraftChanges = false;
  bool _historyLoaded = false;
  bool _historyLoading = false;

  bool get _isCompletedPeriod {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _periodEnd.isBefore(today);
  }

  bool get _canEdit {
    if (widget.readOnly || !Get.isRegistered<PermissionService>()) return false;
    final permissions = Get.find<PermissionService>();
    return !_isCompletedPeriod &&
        permissions.hasAll(const [
          Perms.employeeKpisUpdate,
          Perms.employeeTargetsUpdate,
        ]);
  }

  bool get _canReadCatalog =>
      Get.isRegistered<PermissionService>() &&
      Get.find<PermissionService>().has(Perms.kpisList);

  bool get _canCreateCatalog =>
      Get.isRegistered<PermissionService>() &&
      Get.find<PermissionService>().has(Perms.kpisCreate);

  int? get _userId => widget.employeeUserId;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? EmployeePerformancePlanService();
    final now = DateTime.now();
    _periodStart = DateTime(now.year, now.month);
    _periodEnd = DateTime(now.year, now.month + 1, 0);
    _loadPlan();
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<String> _token() async {
    if (widget.tokenReader != null) return widget.tokenReader!();
    var token = (await _storage.read(key: 'access_token') ?? '').trim();
    if (token.startsWith('Bearer ')) token = token.substring(7);
    return token.replaceAll('"', '').trim();
  }

  Future<void> _loadPlan() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final token = await _token();
      if (token.isEmpty) throw Exception('Sign in again to view this plan.');
      final plan = _userId == null
          ? await _service.getMine(
              token,
              periodStart: _periodStart,
              periodEnd: _periodEnd,
            )
          : await _service.getEmployee(
              token,
              _userId!,
              periodStart: _periodStart,
              periodEnd: _periodEnd,
            );
      if (!mounted) return;
      setState(() {
        _plan = _copy(plan);
        _hasDraftChanges = false;
        _reasonError = null;
      });
    } catch (error) {
      if (mounted) setState(() => _error = _cleanError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshPlan() async {
    if (!await _confirmDiscardDraft(
      title: 'Discard unsaved plan changes?',
      message: 'Refreshing will replace this draft with the saved plan.',
    )) {
      return;
    }
    if (!mounted) return;
    await _loadPlan();
  }

  Map<String, dynamic> _copy(Map<String, dynamic> value) =>
      Map<String, dynamic>.from(jsonDecode(jsonEncode(value)) as Map);

  String _cleanError(Object error) =>
      error.toString().replaceFirst(RegExp(r'^Exception: '), '');

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${_month(date.month)} ${date.year}';

  String _month(int month) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][month - 1];

  List<Map<String, dynamic>> _items(String key) =>
      (_plan?[key] as List? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

  Map<String, dynamic> _config(Map<String, dynamic> item) =>
      Map<String, dynamic>.from(item['config'] as Map? ?? const {});

  int? _intValue(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');

  double? _number(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');

  Future<void> _choosePeriod() async {
    if (!await _confirmDiscardDraft(
      title: 'Discard unsaved plan changes?',
      message:
          'Changing the period will discard the edits currently in this draft.',
    )) {
      return;
    }
    if (!mounted) return;
    final date = await showDatePicker(
      context: context,
      initialDate: _periodStart,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Choose a month in the plan period',
    );
    if (date == null || !mounted) return;
    setState(() {
      _periodStart = DateTime(date.year, date.month);
      _periodEnd = DateTime(date.year, date.month + 1, 0);
      _plan = null;
      _historyLoaded = false;
    });
    await _loadPlan();
  }

  Future<void> _save() async {
    if (_userId == null || !_canEdit || _saving) return;
    if (_reason.text.trim().isEmpty) {
      setState(() => _reasonError = 'Enter a reason before saving this plan.');
      return;
    }
    setState(() {
      _saving = true;
      _error = '';
    });
    try {
      final token = await _token();
      final payload = {
        'period_start': _iso(_periodStart),
        'period_end': _iso(_periodEnd),
        'change_scope': _scope,
        'reason': _reason.text.trim(),
        'kpis': _items('kpis').map(_kpiPayload).toList(),
        'targets': _items('targets').map(_targetPayload).toList(),
      };
      await _service.updateEmployee(token, _userId!, payload);
      _reason.clear();
      if (mounted) {
        setState(() {
          _hasDraftChanges = false;
          _reasonError = null;
        });
      }
      await _loadPlan();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Performance plan saved.')),
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = _cleanError(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _confirmDiscardDraft({
    required String title,
    required String message,
  }) async {
    if (!_hasDraftChanges) return true;
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => DialogScaffold(
            title: title,
            size: DialogSize.sm,
            body: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Keep editing'),
              ),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Discard draft'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Map<String, dynamic> _kpiPayload(Map<String, dynamic> item) {
    final config = _config(item);
    return {
      'item_key': item['item_key'],
      'role_kpi_metric_id': config['role_kpi_metric_id'],
      'metric_id': config['metric_id'],
      'create_shared_metric': item['create_shared_metric'] == true,
      'name': config['name'] ?? '',
      'description': config['description'] ?? '',
      'unit': config['unit'] ?? '',
      'tracking_mode': config['tracking_mode'] ?? 'manual',
      'target_value': config['target_value'],
      'weight': config['weight'],
      'period': config['period'] ?? 'monthly',
      'sequence': config['sequence'] ?? 1,
      'is_active': config['is_active'] == true,
    };
  }

  Map<String, dynamic> _targetPayload(Map<String, dynamic> item) {
    final config = _config(item);
    return {
      'item_key': item['item_key'],
      'role_target_template_id': config['role_target_template_id'],
      'title': config['title'] ?? '',
      'description': config['description'] ?? '',
      'target_value': config['target_value'] ?? '0',
      'unit': config['unit'] ?? '',
      'period': config['period'] ?? 'monthly',
      'sequence': config['sequence'] ?? 1,
      'is_active': config['is_active'] == true,
    };
  }

  String _iso(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  Future<void> _editKpi({Map<String, dynamic>? item}) async {
    final config = item == null ? <String, dynamic>{} : _config(item);
    final name = TextEditingController(text: config['name']?.toString() ?? '');
    final description =
        TextEditingController(text: config['description']?.toString() ?? '');
    final unit = TextEditingController(text: config['unit']?.toString() ?? '');
    final target =
        TextEditingController(text: config['target_value']?.toString() ?? '');
    final weight =
        TextEditingController(text: config['weight']?.toString() ?? '');
    final sequence = TextEditingController(
        text: (config['sequence'] ?? (_items('kpis').length + 1)).toString());
    final token = await _token();
    var metrics = <KPIMetric>[];
    var metricError = '';
    if (_canReadCatalog && token.isNotEmpty && item == null) {
      try {
        metrics =
            (await KpiMetricService().listMetrics(token, limit: 200)).list;
      } catch (error) {
        metricError = _cleanError(error);
      }
    }
    int? selectedMetric = _intValue(config['metric_id']);
    final existingShared = item != null &&
        (selectedMetric != null ||
            _intValue(config['role_kpi_metric_id']) != null);
    var source = existingShared
        ? _EmployeeKpiSource.sharedMetric
        : _EmployeeKpiSource.employeeOnly;
    var trackingMode = config['tracking_mode']?.toString() ?? 'manual';
    var period = config['period']?.toString() ?? 'monthly';
    var active = config['is_active'] != false;
    var formError = '';
    var metricSelectionError = '';
    final formKey = GlobalKey<FormState>();
    const sharedMetricUnits = ['percentage', 'count', 'currency', 'rating'];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => _DialogControllerOwner(
        controllers: [name, description, unit, target, weight, sequence],
        child: StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final sourceOptions = <DropdownMenuItem<_EmployeeKpiSource>>[
              const DropdownMenuItem(
                value: _EmployeeKpiSource.employeeOnly,
                child: Text('Employee-only KPI'),
              ),
              if (_canReadCatalog)
                const DropdownMenuItem(
                  value: _EmployeeKpiSource.sharedMetric,
                  child: Text('Use a shared metric'),
                ),
              if (_canCreateCatalog)
                const DropdownMenuItem(
                  value: _EmployeeKpiSource.createSharedMetric,
                  child: Text('Create a shared metric'),
                ),
            ];

            return DialogScaffold(
              title: item == null ? 'Add KPI' : 'Edit KPI',
              subtitle: existingShared
                  ? 'The shared definition stays unchanged; update this employee’s plan values.'
                  : 'Define the measure and target. Save the plan to apply your draft changes.',
              size: DialogSize.lg,
              body: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (formError.isNotEmpty) ...[
                      _validationMessage(formError),
                      const SizedBox(height: 14),
                    ],
                    const _EmployeePlanFormSection(
                      title: 'Measure definition',
                      subtitle:
                          'Choose a source, then describe what is measured.',
                    ),
                    if (item == null && sourceOptions.length > 1) ...[
                      DropdownButtonFormField<_EmployeeKpiSource>(
                        initialValue: source,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(labelText: 'Metric source'),
                        items: sourceOptions,
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() {
                            source = value;
                            selectedMetric = null;
                            metricSelectionError = '';
                            if (value ==
                                    _EmployeeKpiSource.createSharedMetric &&
                                !sharedMetricUnits.contains(unit.text.trim())) {
                              unit.text = 'percentage';
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        switch (source) {
                          _EmployeeKpiSource.employeeOnly =>
                            'This KPI belongs only to this employee.',
                          _EmployeeKpiSource.sharedMetric =>
                            'Choose an existing catalog metric. Its definition is shared and cannot be edited here.',
                          _EmployeeKpiSource.createSharedMetric =>
                            'The metric definition will be added to the shared catalog when the plan is saved.',
                        },
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                    ],
                    if (source == _EmployeeKpiSource.sharedMetric &&
                        !existingShared) ...[
                      OutlinedButton.icon(
                        key: const Key('employee-plan-kpi-select-metric'),
                        onPressed: metrics.isEmpty
                            ? null
                            : () async {
                                final selected = await showDialog<KPIMetric>(
                                  context: dialogContext,
                                  builder: (_) => _EmployeeMetricPickerDialog(
                                    metrics: metrics,
                                    selectedId: selectedMetric,
                                  ),
                                );
                                if (selected == null) return;
                                setDialogState(() {
                                  selectedMetric = selected.id;
                                  name.text = selected.name;
                                  description.text = selected.description;
                                  unit.text = selected.unit;
                                  metricSelectionError = '';
                                });
                              },
                        icon: const Icon(Iconsax.search_normal, size: 17),
                        label: Text(selectedMetric == null
                            ? 'Choose shared metric'
                            : name.text),
                      ),
                      if (metricSelectionError.isNotEmpty)
                        _fieldError(metricSelectionError),
                      if (metricError.isNotEmpty)
                        _CatalogLoadMessage(
                          message: metricError,
                          onRetry: () async {
                            try {
                              final refreshed = (await KpiMetricService()
                                      .listMetrics(token, limit: 200))
                                  .list;
                              setDialogState(() {
                                metrics = refreshed;
                                metricError = '';
                              });
                            } catch (error) {
                              setDialogState(
                                  () => metricError = _cleanError(error));
                            }
                          },
                        ),
                      if (metrics.isEmpty && metricError.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('No shared metrics are available.'),
                        ),
                      const SizedBox(height: 14),
                    ],
                    if (existingShared)
                      _ReadOnlyMetricSummary(
                        name: name.text,
                        description: description.text,
                        unit: unit.text,
                      )
                    else if (source != _EmployeeKpiSource.sharedMetric) ...[
                      TextFormField(
                        controller: name,
                        key: const Key('employee-plan-kpi-name'),
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'KPI name',
                          hintText: 'e.g. Qualified leads generated',
                        ),
                        validator: (value) => value == null ||
                                value.trim().isEmpty
                            ? 'Enter a KPI name.'
                            : value.trim().length > 200
                                ? 'KPI names must be 200 characters or fewer.'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: description,
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'What should this KPI measure?',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      if (source == _EmployeeKpiSource.createSharedMetric)
                        DropdownButtonFormField<String>(
                          initialValue: sharedMetricUnits.contains(unit.text)
                              ? unit.text
                              : 'percentage',
                          decoration: const InputDecoration(labelText: 'Unit'),
                          items: const [
                            DropdownMenuItem(
                                value: 'percentage',
                                child: Text('Percentage (%)')),
                            DropdownMenuItem(
                                value: 'count', child: Text('Count')),
                            DropdownMenuItem(
                                value: 'currency', child: Text('Currency')),
                            DropdownMenuItem(
                                value: 'rating', child: Text('Rating')),
                          ],
                          onChanged: (value) => unit.text = value ?? unit.text,
                        )
                      else
                        TextFormField(
                          controller: unit,
                          enabled: !_saving,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            hintText: 'e.g. tasks, hours, or %',
                          ),
                          validator: (value) => (value?.trim().length ?? 0) > 20
                              ? 'KPI units must be 20 characters or fewer.'
                              : null,
                        ),
                    ],
                    if (existingShared) const SizedBox(height: 16),
                    const SizedBox(height: 6),
                    const _EmployeePlanFormSection(
                      title: 'Goal and review',
                      subtitle: 'Set the expected result and review cadence.',
                    ),
                    _ResponsiveFormPair(
                      first: TextFormField(
                        controller: target,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Target value',
                          hintText: 'e.g. 40',
                        ),
                        validator: (value) {
                          final raw = value?.trim() ?? '';
                          if (raw.isEmpty) return null;
                          final parsed = _number(raw);
                          return parsed == null ||
                                  !parsed.isFinite ||
                                  parsed < 0
                              ? 'Enter a valid non-negative target.'
                              : null;
                        },
                      ),
                      second: TextFormField(
                        controller: weight,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Weight (%)',
                          hintText: 'Optional',
                        ),
                        validator: (value) {
                          final raw = value?.trim() ?? '';
                          if (raw.isEmpty) return null;
                          final parsed = _number(raw);
                          return parsed == null ||
                                  !parsed.isFinite ||
                                  parsed < 0 ||
                                  parsed > 100
                              ? 'Enter a value from 0 to 100.'
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ResponsiveFormPair(
                      first: DropdownButtonFormField<String>(
                        initialValue: trackingMode,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(labelText: 'Tracking method'),
                        items: const [
                          DropdownMenuItem(
                              value: 'manual', child: Text('Manual')),
                          DropdownMenuItem(
                              value: 'system', child: Text('System')),
                          DropdownMenuItem(
                              value: 'automatic', child: Text('Automatic')),
                          DropdownMenuItem(
                              value: 'semi_automatic',
                              child: Text('Semi-automatic')),
                        ],
                        onChanged: (value) => setDialogState(
                            () => trackingMode = value ?? trackingMode),
                      ),
                      second: DropdownButtonFormField<String>(
                        initialValue: period,
                        isExpanded: true,
                        decoration: const InputDecoration(
                            labelText: 'Measurement period'),
                        items: const [
                          DropdownMenuItem(
                              value: 'daily', child: Text('Daily')),
                          DropdownMenuItem(
                              value: 'weekly', child: Text('Weekly')),
                          DropdownMenuItem(
                              value: 'monthly', child: Text('Monthly')),
                          DropdownMenuItem(
                              value: 'quarterly', child: Text('Quarterly')),
                          DropdownMenuItem(
                              value: 'semi_annual', child: Text('Semi-annual')),
                          DropdownMenuItem(
                              value: 'annual', child: Text('Annual')),
                          DropdownMenuItem(
                              value: 'yearly', child: Text('Yearly')),
                          DropdownMenuItem(
                              value: 'custom', child: Text('Custom')),
                        ],
                        onChanged: (value) =>
                            setDialogState(() => period = value ?? period),
                      ),
                    ),
                    if (trackingMode == 'automatic' ||
                        trackingMode == 'semi_automatic') ...[
                      const SizedBox(height: 10),
                      _inlineNotice(
                          'This records the intended tracking method; progress is not calculated automatically.'),
                    ],
                    const SizedBox(height: 8),
                    ExpansionTile(
                      maintainState: true,
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      title: const Text('Plan settings'),
                      subtitle: const Text('Display order and active status'),
                      children: [
                        TextFormField(
                          controller: sequence,
                          key: const Key('employee-plan-kpi-sequence'),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Display order',
                            helperText: 'Lower numbers appear first.',
                          ),
                          validator: (value) {
                            final order = int.tryParse(value?.trim() ?? '');
                            return order == null ||
                                    order < 1 ||
                                    order > _maxPlanItemSequence
                                ? 'Display order must be between 1 and 2,147,483,647.'
                                : null;
                          },
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Active for this plan'),
                          subtitle: const Text(
                              'Inactive items are excluded from this plan.'),
                          value: active,
                          onChanged: (value) =>
                              setDialogState(() => active = value),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    if (source == _EmployeeKpiSource.sharedMetric &&
                        !existingShared &&
                        selectedMetric == null) {
                      setDialogState(() => metricSelectionError =
                          'Choose a shared metric to continue.');
                      return;
                    }
                    if (source == _EmployeeKpiSource.createSharedMetric &&
                        !sharedMetricUnits.contains(unit.text.trim())) {
                      setDialogState(() => formError =
                          'Choose a valid unit for the shared metric.');
                      return;
                    }
                    final nextConfig = <String, dynamic>{
                      ...config,
                      'role_kpi_metric_id': config['role_kpi_metric_id'],
                      'metric_id': source == _EmployeeKpiSource.sharedMetric
                          ? (selectedMetric ?? config['metric_id'])
                          : null,
                      'name': name.text.trim(),
                      'description': description.text.trim(),
                      'unit': unit.text.trim(),
                      'tracking_mode': trackingMode,
                      'target_value': target.text.trim().isEmpty
                          ? null
                          : target.text.trim(),
                      'weight': weight.text.trim().isEmpty
                          ? null
                          : weight.text.trim(),
                      'period': period,
                      'sequence': int.parse(sequence.text.trim()),
                      'is_active': active,
                    };
                    Navigator.pop(dialogContext, {
                      'item_key': item?['item_key'] ??
                          'employee-kpi-${DateTime.now().microsecondsSinceEpoch}',
                      'kind': 'kpi',
                      'source': config['role_kpi_metric_id'] == null
                          ? 'employee'
                          : 'role',
                      'source_id': config['role_kpi_metric_id'],
                      'is_customized': true,
                      'role_defaults': item?['role_defaults'] ?? {},
                      'config': nextConfig,
                      'create_shared_metric':
                          source == _EmployeeKpiSource.createSharedMetric,
                    });
                  },
                  child: Text(
                      item == null ? 'Add to draft' : 'Save draft changes'),
                ),
              ],
            );
          },
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      final items = _items('kpis');
      final index =
          items.indexWhere((entry) => entry['item_key'] == item?['item_key']);
      if (index < 0) {
        items.add(result);
      } else {
        items[index] = result;
      }
      _plan!['kpis'] = items;
      _hasDraftChanges = true;
    });
  }

  Future<void> _editTarget({Map<String, dynamic>? item}) async {
    final config = item == null ? <String, dynamic>{} : _config(item);
    final title =
        TextEditingController(text: config['title']?.toString() ?? '');
    final description =
        TextEditingController(text: config['description']?.toString() ?? '');
    final value =
        TextEditingController(text: config['target_value']?.toString() ?? '');
    final unit = TextEditingController(text: config['unit']?.toString() ?? '');
    final sequence = TextEditingController(
        text:
            (config['sequence'] ?? (_items('targets').length + 1)).toString());
    var period = config['period']?.toString() ?? 'monthly';
    var active = config['is_active'] != false;
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => _DialogControllerOwner(
        controllers: [title, description, value, unit, sequence],
        child: StatefulBuilder(
          builder: (dialogContext, setDialogState) => DialogScaffold(
            title: item == null ? 'Add target' : 'Edit target',
            subtitle:
                'Set a measurable deliverable. Save the plan to apply your draft changes.',
            size: DialogSize.lg,
            body: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _EmployeePlanFormSection(
                    title: 'Deliverable',
                    subtitle:
                        'Describe the result expected from this employee.',
                  ),
                  TextFormField(
                    controller: title,
                    key: const Key('employee-plan-target-title'),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Target title',
                      hintText: 'e.g. Complete client onboarding',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a target title.'
                        : value.trim().length > 255
                            ? 'Target titles must be 255 characters or fewer.'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: description,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Add context or completion criteria',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 18),
                  const _EmployeePlanFormSection(
                    title: 'Measure and review',
                    subtitle:
                        'Set the expected value, unit, and review cadence.',
                  ),
                  _ResponsiveFormPair(
                    first: TextFormField(
                      controller: value,
                      key: const Key('employee-plan-target-value'),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Target value',
                        hintText: 'e.g. 12',
                      ),
                      validator: (raw) {
                        final parsed = _number(raw?.trim());
                        return parsed == null || !parsed.isFinite || parsed < 0
                            ? 'Enter a valid non-negative value.'
                            : null;
                      },
                    ),
                    second: TextFormField(
                      controller: unit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        hintText: 'e.g. clients, NGN, or %',
                      ),
                      validator: (raw) => (raw?.trim().length ?? 0) > 100
                          ? 'Target units must be 100 characters or fewer.'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: period,
                    isExpanded: true,
                    decoration:
                        const InputDecoration(labelText: 'Review cadence'),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Daily')),
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(
                          value: 'monthly', child: Text('Monthly')),
                      DropdownMenuItem(
                          value: 'quarterly', child: Text('Quarterly')),
                      DropdownMenuItem(
                          value: 'semi_annual', child: Text('Semi-annual')),
                      DropdownMenuItem(value: 'annual', child: Text('Annual')),
                      DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                      DropdownMenuItem(value: 'custom', child: Text('Custom')),
                    ],
                    onChanged: (value) =>
                        setDialogState(() => period = value ?? period),
                  ),
                  const SizedBox(height: 8),
                  ExpansionTile(
                    maintainState: true,
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    title: const Text('Plan settings'),
                    subtitle: const Text('Display order and active status'),
                    children: [
                      TextFormField(
                        controller: sequence,
                        key: const Key('employee-plan-target-sequence'),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Display order',
                          helperText: 'Lower numbers appear first.',
                        ),
                        validator: (raw) {
                          final order = int.tryParse(raw?.trim() ?? '');
                          return order == null ||
                                  order < 1 ||
                                  order > _maxPlanItemSequence
                              ? 'Display order must be between 1 and 2,147,483,647.'
                              : null;
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Active for this plan'),
                        subtitle: const Text(
                            'Inactive items are excluded from this plan.'),
                        value: active,
                        onChanged: (value) =>
                            setDialogState(() => active = value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (!(formKey.currentState?.validate() ?? false)) return;
                  Navigator.pop(dialogContext, {
                    'item_key': item?['item_key'] ??
                        'employee-target-${DateTime.now().microsecondsSinceEpoch}',
                    'kind': 'target',
                    'source': config['role_target_template_id'] == null
                        ? 'employee'
                        : 'role',
                    'source_id': config['role_target_template_id'],
                    'is_customized': true,
                    'role_defaults': item?['role_defaults'] ?? {},
                    'config': {
                      ...config,
                      'role_target_template_id':
                          config['role_target_template_id'],
                      'title': title.text.trim(),
                      'description': description.text.trim(),
                      'target_value': value.text.trim(),
                      'unit': unit.text.trim(),
                      'period': period,
                      'sequence': int.parse(sequence.text.trim()),
                      'is_active': active,
                    },
                  });
                },
                child:
                    Text(item == null ? 'Add to draft' : 'Save draft changes'),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      final items = _items('targets');
      final index =
          items.indexWhere((entry) => entry['item_key'] == item?['item_key']);
      if (index < 0) {
        items.add(result);
      } else {
        items[index] = result;
      }
      _plan!['targets'] = items;
      _hasDraftChanges = true;
    });
  }

  Future<void> _refreshRoleDefaults() async {
    if (_userId == null || !_canEdit || _saving || _refreshing) return;
    if (!await _confirmDiscardDraft(
      title: 'Discard unsaved plan changes?',
      message:
          'Previewing role defaults starts from the saved plan and will discard this draft.',
    )) {
      return;
    }
    setState(() {
      _refreshing = true;
      _error = '';
    });
    try {
      final token = await _token();
      final preview = await _service.previewRefresh(
        token,
        _userId!,
        periodStart: _periodStart,
        periodEnd: _periodEnd,
      );
      if (!mounted) return;
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (dialogContext) => _RoleRefreshConfirmationDialog(
          initialPreview: preview,
          previewAgain: () => _service.previewRefresh(
            token,
            _userId!,
            periodStart: _periodStart,
            periodEnd: _periodEnd,
          ),
          apply: (previewToken, refreshReason) => _service.applyRefresh(
            token,
            _userId!,
            periodStart: _periodStart,
            periodEnd: _periodEnd,
            reason: refreshReason,
            previewToken: previewToken,
          ),
          labelFor: _label,
          cleanError: _cleanError,
        ),
      );
      if (result == null) return;
      if (!mounted) return;
      await _loadPlan();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Role defaults applied as plan revision ${result['revision']}.')),
      );
    } catch (error) {
      if (mounted) setState(() => _error = _cleanError(error));
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  String _label(String action) => switch (action) {
        'period_edit' || 'period_only' => 'This period only',
        'carry_forward' => 'Carry-forward edit',
        'role_refresh' => 'Role defaults refresh',
        'added' => 'Added',
        'updated' => 'Updated',
        'retired' => 'Retired',
        'detached' => 'Retained as employee-only',
        'preserved' => 'Customized items kept',
        _ => action,
      };

  String _auditTimestamp(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return 'Time unavailable';
    final local = parsed.toLocal();
    final date =
        '${local.day.toString().padLeft(2, '0')} ${_month(local.month)} ${local.year}';
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    return '$date, $hour:$minute $period';
  }

  String _auditPeriod(dynamic start, dynamic end) {
    DateTime? parse(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '');
    final parsedStart = parse(start);
    final parsedEnd = parse(end);
    if (parsedStart == null || parsedEnd == null) return 'Period unavailable';
    return '${_date(parsedStart)} – ${_date(parsedEnd)}';
  }

  List<String> _auditChangeLines(Map<String, dynamic> entry) {
    final before =
        Map<String, dynamic>.from(entry['before_snapshot'] as Map? ?? const {});
    final after =
        Map<String, dynamic>.from(entry['after_snapshot'] as Map? ?? const {});
    final lines = <String>[];
    for (final kind in ['kpis', 'targets']) {
      final oldItems = (before[kind] as List? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      final newItems = (after[kind] as List? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      final oldByKey = {
        for (final item in oldItems) item['item_key']?.toString(): item,
      };
      final newByKey = {
        for (final item in newItems) item['item_key']?.toString(): item,
      };
      for (final key in {...oldByKey.keys, ...newByKey.keys}) {
        if (key == null) continue;
        final oldItem = oldByKey[key];
        final newItem = newByKey[key];
        final config = Map<String, dynamic>.from(
            (newItem ?? oldItem)?['config'] as Map? ?? const {});
        final name =
            (config['name'] ?? config['title'] ?? 'Plan item').toString();
        final type = kind == 'kpis' ? 'KPI' : 'Target';
        if (oldItem == null) {
          lines.add('Added $type: $name');
          continue;
        }
        if (newItem == null) {
          lines.add('Removed $type: $name');
          continue;
        }
        final oldConfig =
            Map<String, dynamic>.from(oldItem['config'] as Map? ?? const {});
        final newConfig =
            Map<String, dynamic>.from(newItem['config'] as Map? ?? const {});
        for (final field in {...oldConfig.keys, ...newConfig.keys}) {
          if (field == 'role_kpi_metric_id' ||
              field == 'role_target_template_id') continue;
          if (oldConfig[field] == newConfig[field]) continue;
          final label = field
              .split('_')
              .map((part) => part.isEmpty
                  ? part
                  : '${part[0].toUpperCase()}${part.substring(1)}')
              .join(' ');
          lines.add(
              '$name · $label: ${_auditValue(oldConfig[field])} → ${_auditValue(newConfig[field])}');
        }
      }
    }
    return lines;
  }

  String _auditValue(dynamic value) {
    if (value == null || value.toString().isEmpty) return '—';
    if (value is bool) return value ? 'Yes' : 'No';
    return value.toString();
  }

  Future<void> _loadHistory() async {
    if (_historyLoaded || _historyLoading || _userId == null) return;
    setState(() {
      _historyLoading = true;
      _historyError = '';
    });
    try {
      final items = await _service.history(await _token(), _userId!);
      if (!mounted) return;
      setState(() {
        _history = items;
        _historyLoaded = true;
      });
    } catch (error) {
      if (mounted) setState(() => _historyError = _cleanError(error));
    } finally {
      if (mounted) setState(() => _historyLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _plan == null) {
      return const Padding(
        padding: EdgeInsets.all(28),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error.isNotEmpty && _plan == null) {
      return _errorState();
    }
    if (_plan == null) return _errorState();

    final kpis = _items('kpis');
    final targets = _items('targets');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 10,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: AppColors.primarySubtle,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: const Icon(Iconsax.calendar_1,
                            size: 19, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_month(_periodStart.month)} ${_periodStart.year}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodyLg
                                  .copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_date(_periodStart)} – ${_date(_periodEnd)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 4,
                    children: [
                      TextButton.icon(
                        onPressed: _choosePeriod,
                        icon: const Icon(Iconsax.calendar_edit, size: 17),
                        label: const Text('Change period'),
                      ),
                      IconButton(
                        onPressed: _loading ? null : _refreshPlan,
                        tooltip: 'Refresh plan',
                        icon: const Icon(Iconsax.refresh),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Plan source', style: AppTextStyles.caption),
                  _PlanTag(
                    label: _planSourceLabel(_plan!),
                    color: _planSourceColor(_plan!),
                  ),
                  if (_plan!['revision'] != null)
                    Text('Revision ${_plan!['revision']}',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        if (_isCompletedPeriod)
          _inlineNotice('Completed periods are read-only.'),
        if (_error.isNotEmpty) _inlineError(_error),
        const SizedBox(height: 14),
        if (_canEdit && _hasDraftChanges)
          _inlineNotice(
              'Unsaved plan changes. Add a reason and save the plan to apply them.'),
        _sectionHeading('KPIs', Iconsax.chart_2,
            count: kpis.length, onAdd: _canEdit ? () => _editKpi() : null),
        if (kpis.isEmpty) _emptyItems('No KPIs are assigned for this period.'),
        ...kpis.map((item) => _itemCard(item, isKpi: true)),
        const SizedBox(height: 12),
        _sectionHeading('Targets', Iconsax.flag,
            count: targets.length,
            onAdd: _canEdit ? () => _editTarget() : null),
        if (targets.isEmpty)
          _emptyItems('No targets are assigned for this period.'),
        ...targets.map((item) => _itemCard(item, isKpi: false)),
        if (_canEdit) ...[
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Plan changes',
                      style: AppTextStyles.bodyMd
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                      _hasDraftChanges
                          ? 'Choose how these edits should take effect.'
                          : 'Add or edit a KPI or target to create a plan change.',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _scope,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Change applies to',
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'period_only',
                          child: Text('This period only',
                              maxLines: 1, overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(
                          value: 'carry_forward',
                          child: Text('This period and future periods',
                              maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (value) =>
                        setState(() => _scope = value ?? _scope),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _scope == 'period_only'
                        ? 'Only the selected period changes. Other saved periods stay as they are.'
                        : 'Apply this plan from the selected period to future periods when they are generated. Already-saved periods stay unchanged.',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _reason,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 2,
                    onChanged: (_) {
                      if (_reasonError != null) {
                        setState(() => _reasonError = null);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Reason for change',
                      hintText: 'Briefly explain the approved adjustment',
                      helperText: 'Required for the audit history.',
                      errorText: _reasonError,
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(spacing: 10, runSpacing: 8, children: [
                    FilledButton.icon(
                      onPressed: _saving || _refreshing || !_hasDraftChanges
                          ? null
                          : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Iconsax.save_2),
                      label: Text(_saving ? 'Saving' : 'Save plan'),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          _saving || _refreshing ? null : _refreshRoleDefaults,
                      icon: _refreshing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Iconsax.refresh),
                      label: Text(_refreshing
                          ? 'Checking role defaults'
                          : 'Preview role refresh'),
                    ),
                  ]),
                ]),
          ),
          const SizedBox(height: 10),
          AppCard(
            padding: EdgeInsets.zero,
            elevation: AppCardElevation.none,
            child: Material(
              color: AppColors.surface,
              child: ExpansionTile(
                leading: const Icon(Iconsax.clock,
                    size: 19, color: AppColors.textSecondary),
                title: const Text('Change history'),
                subtitle:
                    const Text('Review previous plan updates and reasons.'),
                onExpansionChanged: (expanded) {
                  if (expanded) _loadHistory();
                },
                children: [
                  if (_historyLoading)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  else if (_historyError.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(_historyError,
                              style: AppTextStyles.bodySm
                                  .copyWith(color: AppColors.danger)),
                          TextButton.icon(
                            onPressed: () {
                              _historyLoaded = false;
                              _loadHistory();
                            },
                            icon: const Icon(Iconsax.refresh, size: 16),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else if (_history.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No plan changes have been recorded.'),
                    )
                  else
                    ..._history.map((entry) {
                      final changes = _auditChangeLines(entry);
                      final actor =
                          entry['actor__email']?.toString() ?? 'Manager';
                      return ExpansionTile(
                        key: ValueKey('plan-history-${entry['id']}'),
                        title: Text(
                            '${_label(entry['action']?.toString() ?? '')} · $actor'),
                        subtitle: Text(
                          '${_auditTimestamp(entry['created_at'])} · ${_label(entry['change_scope']?.toString() ?? '')} · ${_auditPeriod(entry['period_start'], entry['period_end'])}',
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Reason',
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary)),
                                const SizedBox(height: 3),
                                Text(entry['reason']?.toString().isNotEmpty ==
                                        true
                                    ? entry['reason'].toString()
                                    : 'No reason provided'),
                                if (changes.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  for (final line in changes)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Text(line,
                                          style: AppTextStyles.bodySm),
                                    ),
                                ] else ...[
                                  const SizedBox(height: 8),
                                  Text('No item-level changes recorded.',
                                      style: AppTextStyles.bodySm.copyWith(
                                          color: AppColors.textSecondary)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionHeading(String title, IconData icon,
          {required int count, VoidCallback? onAdd}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 4,
          children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 19, color: AppColors.primary),
              const SizedBox(width: 9),
              Text(title, style: AppTextStyles.h3),
              const SizedBox(width: 9),
              Container(
                constraints: const BoxConstraints(minWidth: 24),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Text('$count',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary)),
              ),
            ]),
            if (onAdd != null)
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Iconsax.add, size: 17),
                label: Text(title == 'KPIs' ? 'Add KPI' : 'Add target'),
              ),
          ],
        ),
      );

  Widget _itemCard(Map<String, dynamic> item, {required bool isKpi}) {
    final config = _config(item);
    final title = (isKpi ? config['name'] : config['title'])?.toString() ?? '';
    final roleItemId = isKpi
        ? config['role_kpi_metric_id']
        : config['role_target_template_id'];
    final source = item['source'] == 'employee' && roleItemId == null
        ? 'Employee-only'
        : (item['is_customized'] == true ? 'Customized' : 'Inherited');
    final actual =
        isKpi ? item['actual_value'] : item['approved_progress_value'];
    final unit = config['unit']?.toString() ?? '';
    final formattedPeriod = _prettyLabel(config['period']?.toString() ?? '');
    final targetValue = _number(config['target_value']);
    final actualValue = _number(actual);
    final targetText = targetValue == null
        ? 'Not set'
        : formatValueWithUnit(_formatNumber(targetValue), unit);
    final actualText = actualValue == null
        ? 'No progress recorded'
        : formatValueWithUnit(_formatNumber(actualValue), unit);
    final description = config['description']?.toString().trim() ?? '';
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                ),
                child: Icon(isKpi ? Iconsax.chart_success : Iconsax.flag,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(title,
                      style: AppTextStyles.bodyMd
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
              if (_canEdit) ...[
                IconButton(
                    onPressed: () =>
                        isKpi ? _editKpi(item: item) : _editTarget(item: item),
                    tooltip: 'Edit item',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Iconsax.edit, size: 18)),
                IconButton(
                  onPressed: () => _toggleActive(item, isKpi),
                  tooltip: config['is_active'] == false
                      ? 'Reactivate item'
                      : 'Deactivate item',
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                      config['is_active'] == false
                          ? Iconsax.refresh
                          : Iconsax.pause,
                      size: 18),
                ),
              ],
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 28,
            runSpacing: 12,
            children: [
              _PlanMeasure(label: 'Target', value: targetText),
              _PlanMeasure(
                label: isKpi ? 'Actual' : 'Approved progress',
                value: actualText,
                subdued: actualValue == null,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              if (formattedPeriod.isNotEmpty)
                _PlanTag(label: formattedPeriod, color: AppColors.info),
              _PlanTag(
                label: source,
                color: source == 'Inherited'
                    ? AppColors.textSecondary
                    : AppColors.primary,
              ),
              _PlanTag(
                label: config['is_active'] == false ? 'Inactive' : 'Active',
                color: config['is_active'] == false
                    ? AppColors.textSecondary
                    : AppColors.success,
              ),
              if (isKpi && config['tracking_mode'] != null)
                _PlanTag(
                  label: _prettyLabel(config['tracking_mode'].toString()),
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) =>
      value.toStringAsFixed(value % 1 == 0 ? 0 : 2);

  String _prettyLabel(String value) {
    if (value.isEmpty) return '';
    if (value == 'yearly') return 'Annual';
    return value
        .split('_')
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _planSourceLabel(Map<String, dynamic> plan) =>
      switch (plan['source']) {
        'employee_plan' => 'Employee-specific plan',
        'period_snapshot' => 'Saved period snapshot',
        _ => 'Role defaults',
      };

  Color _planSourceColor(Map<String, dynamic> plan) =>
      plan['source'] == 'employee_plan'
          ? AppColors.primary
          : plan['source'] == 'period_snapshot'
              ? AppColors.info
              : AppColors.textSecondary;

  void _toggleActive(Map<String, dynamic> item, bool isKpi) {
    final copy = _copy(item);
    final config = Map<String, dynamic>.from(copy['config'] as Map);
    config['is_active'] = config['is_active'] != true;
    copy['config'] = config;
    copy['is_customized'] = true;
    setState(() {
      final key = isKpi ? 'kpis' : 'targets';
      final items = _items(key);
      final index =
          items.indexWhere((entry) => entry['item_key'] == item['item_key']);
      if (index >= 0) items[index] = copy;
      _plan![key] = items;
      _hasDraftChanges = true;
    });
  }

  Widget _emptyItems(String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: EmptyState(icon: Iconsax.chart, title: text, subtitle: ''),
      );

  Widget _inlineError(String message) => Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          const Icon(Iconsax.warning_2, size: 18, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
              child: Text(message,
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.danger))),
          IconButton(
              onPressed: () => setState(() => _error = ''),
              tooltip: 'Dismiss',
              icon: const Icon(Icons.close, size: 17)),
        ]),
      );

  Widget _validationMessage(String message) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          message,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.danger),
        ),
      );

  Widget _inlineNotice(String message) => Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
        ),
        child: Text(
          message,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.warning),
        ),
      );

  Widget _errorState() => Column(children: [
        EmptyState(
            icon: Iconsax.warning_2,
            title: 'Performance plan unavailable',
            subtitle: _error.isEmpty
                ? 'The selected employee has no current role.'
                : _error),
        TextButton.icon(
            onPressed: _refreshPlan,
            icon: const Icon(Iconsax.refresh),
            label: const Text('Retry')),
      ]);
}

class _EmployeePlanFormSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmployeePlanFormSection({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h4),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ResponsiveFormPair extends StatelessWidget {
  final Widget first;
  final Widget second;

  const _ResponsiveFormPair({required this.first, required this.second});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 680) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [first, const SizedBox(height: 12), second],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 12),
              Expanded(child: second),
            ],
          );
        },
      );
}

Widget _fieldError(String message) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        message,
        style: AppTextStyles.caption.copyWith(color: AppColors.danger),
      ),
    );

class _ReadOnlyMetricSummary extends StatelessWidget {
  final String name;
  final String description;
  final String unit;

  const _ReadOnlyMetricSummary({
    required this.name,
    required this.description,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style:
                    AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w700)),
            if (description.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(description,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary)),
            ],
            if (unit.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Unit · $unit',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ],
        ),
      );
}

class _CatalogLoadMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CatalogLoadMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Expanded(
                child: Text(message,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary))),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
}

class _EmployeeMetricPickerDialog extends StatefulWidget {
  final List<KPIMetric> metrics;
  final int? selectedId;

  const _EmployeeMetricPickerDialog({
    required this.metrics,
    required this.selectedId,
  });

  @override
  State<_EmployeeMetricPickerDialog> createState() =>
      _EmployeeMetricPickerDialogState();
}

class _EmployeeMetricPickerDialogState
    extends State<_EmployeeMetricPickerDialog> {
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
      title: 'Choose a shared metric',
      subtitle: 'The metric definition is shared across the organization.',
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
                        ? 'No shared metrics are available.'
                        : 'No metrics match “$_query”.'))
                : ListView.separated(
                    itemCount: metrics.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final metric = metrics[index];
                      final selected = metric.id == widget.selectedId;
                      return ListTile(
                        key: ValueKey('employee-metric-${metric.id}'),
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
                        trailing: selected
                            ? const Icon(Iconsax.tick_circle,
                                color: AppColors.primary, size: 18)
                            : null,
                        onTap: () => Navigator.pop(context, metric),
                      );
                    },
                  ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'))
      ],
    );
  }
}

class _PlanTag extends StatelessWidget {
  final String label;
  final Color color;

  const _PlanTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _PlanMeasure extends StatelessWidget {
  final String label;
  final String value;
  final bool subdued;

  const _PlanMeasure({
    required this.label,
    required this.value,
    this.subdued = false,
  });

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 130, maxWidth: 240),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySm.copyWith(
                color: subdued ? AppColors.textMuted : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}

class _RoleRefreshConfirmationDialog extends StatefulWidget {
  final Map<String, dynamic> initialPreview;
  final Future<Map<String, dynamic>> Function() previewAgain;
  final Future<Map<String, dynamic>> Function(String token, String reason)
      apply;
  final String Function(String) labelFor;
  final String Function(Object) cleanError;

  const _RoleRefreshConfirmationDialog({
    required this.initialPreview,
    required this.previewAgain,
    required this.apply,
    required this.labelFor,
    required this.cleanError,
  });

  @override
  State<_RoleRefreshConfirmationDialog> createState() =>
      _RoleRefreshConfirmationDialogState();
}

class _RoleRefreshConfirmationDialogState
    extends State<_RoleRefreshConfirmationDialog> {
  final _reasonController = TextEditingController();
  late Map<String, dynamic> _preview;
  String _error = '';
  String _reasonError = '';
  bool _applying = false;

  @override
  void initState() {
    super.initState();
    _preview = Map<String, dynamic>.from(widget.initialPreview);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _diff =>
      Map<String, dynamic>.from(_preview['diff'] as Map? ?? const {});

  bool get _hasChanges =>
      ['added', 'updated', 'retired', 'detached'].any((key) {
        final value = _diff[key];
        return value is List && value.isNotEmpty;
      });

  List<String> get _summaryLines => _diff.entries
          .where((entry) =>
              entry.value is List && (entry.value as List).isNotEmpty)
          .map((entry) {
        final names = (entry.value as List)
            .whereType<Map>()
            .map((item) => item['name']?.toString())
            .whereType<String>()
            .join(', ');
        return '${widget.labelFor(entry.key)}: $names';
      }).toList();

  Future<void> _apply() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() {
        _reasonError = 'Enter a reason before applying this refresh.';
        _error = '';
      });
      return;
    }
    if (!_hasChanges) return;

    setState(() {
      _applying = true;
      _error = '';
      _reasonError = '';
    });
    try {
      final result = await widget.apply(
        _preview['preview_token']?.toString() ?? '',
        reason,
      );
      if (mounted) Navigator.of(context).pop(result);
    } catch (error) {
      if (error is EmployeePerformancePlanApiException &&
          error.statusCode == 409) {
        try {
          final latest = await widget.previewAgain();
          if (!mounted) return;
          setState(() {
            _preview = Map<String, dynamic>.from(latest);
            _error =
                'The plan or role defaults changed. Review the updated changes, then apply again.';
          });
        } catch (previewError) {
          if (mounted) {
            setState(() => _error = widget.cleanError(previewError));
          }
        }
      } else if (mounted) {
        setState(() => _error = widget.cleanError(error));
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) => DialogScaffold(
        title: 'Refresh from role defaults',
        subtitle:
            'Review the proposed changes before applying them to this employee.',
        size: DialogSize.md,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_summaryLines.isEmpty)
              const Text('This plan already matches the role defaults.')
            else
              for (final line in _summaryLines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Iconsax.tick_circle,
                          size: 17, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(line)),
                    ],
                  ),
                ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                key: const Key('refresh-dialog-error'),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningSubtle,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _error,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              key: const Key('refresh-dialog-reason'),
              controller: _reasonController,
              enabled: !_applying,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Reason for refresh',
                hintText: 'Explain why these defaults are being applied',
                helperText: 'Required for the audit history.',
                errorText: _reasonError.isEmpty ? null : _reasonError,
                alignLabelWithHint: true,
              ),
              maxLines: 2,
              onChanged: (_) {
                if (_reasonError.isNotEmpty) {
                  setState(() => _reasonError = '');
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _applying ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _applying || !_hasChanges ? null : _apply,
            child: _applying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Apply refresh'),
          ),
        ],
      );
}

class _DialogControllerOwner extends StatefulWidget {
  final List<TextEditingController> controllers;
  final Widget child;

  const _DialogControllerOwner({
    required this.controllers,
    required this.child,
  });

  @override
  State<_DialogControllerOwner> createState() => _DialogControllerOwnerState();
}

class _DialogControllerOwnerState extends State<_DialogControllerOwner> {
  @override
  void dispose() {
    for (final controller in widget.controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
