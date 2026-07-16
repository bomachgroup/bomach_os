import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/role_kpi_model.dart';
import 'package:bomach_os/src/model/kpi_metric_model.dart';
import 'package:bomach_os/src/services/kpi_metric_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../controllers/role_kpi_controller.dart';
import '../controllers/roles_controller.dart';

class CreateEditKpiDialog extends StatefulWidget {
  final RoleKpiController ctrl;
  final RoleKpi? kpi;
  final int? presetRoleId;

  const CreateEditKpiDialog({
    super.key,
    required this.ctrl,
    this.kpi,
    this.presetRoleId,
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
  var _loadingMetrics = true;

  @override
  void initState() {
    super.initState();
    final kpi = widget.kpi;
    _selectedMetricId = kpi?.metricId;
    _selectedMetricUnit = kpi?.metric?.unit ?? '';
    _trackingMode = kpi?.trackingMode ?? 'manual';
    _period = kpi?.period ?? 'monthly';
    _isActive = kpi?.isActive ?? true;
    _selectedRoleId = widget.presetRoleId ?? kpi?.roleId;
    final targetVal = widget.kpi?.targetValue;
    final weightVal = widget.kpi?.weight;
    _targetCtrl = TextEditingController(
        text: targetVal != null
            ? targetVal.toStringAsFixed(targetVal % 1 == 0 ? 0 : 2)
            : '');
    _weightCtrl = TextEditingController(
        text: weightVal != null
            ? weightVal.toStringAsFixed(weightVal % 1 == 0 ? 0 : 2)
            : '');
    _sequenceCtrl = TextEditingController(
        text: kpi?.sequence?.toString() ?? '');
    _fetchMetrics();
  }

  Future<void> _fetchMetrics() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (token == null) return;
      final cleanToken = token.replaceAll('"', '').trim();
      final result = await _metricService.listMetrics(cleanToken);
      if (mounted) {
        setState(() {
          _metrics = result.list;
          _loadingMetrics = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingMetrics = false);
        Get.snackbar('Error', 'Could not load metrics: $e',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade50,
            colorText: Colors.red.shade800);
      }
    }
  }

  @override
  void dispose() {
    _targetCtrl.dispose();
    _weightCtrl.dispose();
    _sequenceCtrl.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_selectedMetricId == null) {
      Get.snackbar('Validation', 'Please select a metric',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_selectedRoleId == null && widget.kpi == null) {
      Get.snackbar('Validation', 'Please select a role',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final targetValue = double.tryParse(_targetCtrl.text.trim());
    final weight = double.tryParse(_weightCtrl.text.trim());
    final sequence = int.tryParse(_sequenceCtrl.text.trim());

    final isEdit = widget.kpi != null;
    final roleId = _selectedRoleId ?? widget.kpi!.roleId;

    bool success;
    if (isEdit) {
      success = await widget.ctrl.updateKpi(
        context,
        id: widget.kpi!.id!,
        trackingMode: _trackingMode,
        period: _period,
        targetValue: targetValue,
        weight: weight,
        sequence: sequence,
        isActive: _isActive,
      );
    } else {
      success = await widget.ctrl.createKpi(
        context,
        roleId: roleId,
        metricId: _selectedMetricId!,
        trackingMode: _trackingMode,
        period: _period,
        targetValue: targetValue,
        weight: weight,
        sequence: sequence,
        isActive: _isActive,
      );
    }

    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.kpi != null;

    return DialogScaffold(
      title: isEdit ? 'Edit KPI' : 'Add KPI',
      subtitle: isEdit
          ? 'Update the KPI definition for this role.'
          : 'Define a new Key Performance Indicator for a role template.',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Metric Selector ──────────────────────────────────────────
          const Text('Metric', style: AppTextStyles.label),
          const SizedBox(height: 8),
          _loadingMetrics
              ? const SizedBox(
                  height: 48,
                  child: Center(child: SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )),
                )
              : DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: AppRadii.brMd),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  initialValue: _selectedMetricId,
                  hint: const Text('Select a metric'),
                  items: _metrics.map((m) => DropdownMenuItem(
                    value: m.id,
                    child: Text('${m.name} (${m.unit})'),
                  )).toList(),
                  onChanged: (v) => setState(() {
                    _selectedMetricId = v;
                    final m = _metrics.firstWhereOrNull((x) => x.id == v);
                    _selectedMetricUnit = m?.unit ?? '';
                  }),
                ),
          const SizedBox(height: 16),

          // ── Role Selector (when no preset role) ─────────────────────
          if (widget.presetRoleId == null && !isEdit && Get.isRegistered<RolesController>()) ...[
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
                items: rc.roles.map((r) => DropdownMenuItem(
                  value: r.id,
                  child: Text(r.name),
                )).toList(),
                onChanged: (v) => setState(() => _selectedRoleId = v),
              ),
            ),
            const SizedBox(height: 16),
          ],

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
                      onChanged: (v) =>
                          setState(() => _trackingMode = v!),
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

          // ── Target + Weight row ─────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target Value ${_selectedMetricUnit.isNotEmpty ? "($_selectedMetricUnit)" : ""}',
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
              Text(
                '(inactive KPIs are hidden from dashboards)',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
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
