import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/responsive_breakpoints.dart';
import 'package:bomach_os/src/model/role_target_template_model.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/targets_controller.dart';

const _periods = ['daily', 'weekly', 'monthly', 'quarterly', 'annual'];

class CreateEditTargetTemplateDialog extends StatefulWidget {
  final TargetsController ctrl;
  final int roleId;
  final RoleTargetTemplate? template;

  const CreateEditTargetTemplateDialog({
    super.key,
    required this.ctrl,
    required this.roleId,
    this.template,
  });

  @override
  State<CreateEditTargetTemplateDialog> createState() =>
      _CreateEditTargetTemplateDialogState();
}

class _CreateEditTargetTemplateDialogState
    extends State<CreateEditTargetTemplateDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _targetValueCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _sequenceCtrl;
  final _formKey = GlobalKey<FormState>();

  String _period = 'monthly';
  bool _isActive = true;
  bool _saving = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _titleCtrl = TextEditingController(text: t?.title ?? '');
    _descCtrl = TextEditingController(text: t?.description ?? '');
    _targetValueCtrl =
        TextEditingController(text: t?.targetValue?.toString() ?? '');
    _unitCtrl = TextEditingController(text: t?.unit ?? '');
    final sequence = t?.sequence;
    _sequenceCtrl = TextEditingController(
        text: (sequence != null && sequence > 0 ? sequence : 1).toString());
    _period = _periods.contains(t?.period) ? t!.period : 'monthly';
    _isActive = t?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _targetValueCtrl.dispose();
    _unitCtrl.dispose();
    _sequenceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.template != null;
    return PopScope(
      canPop: !_saving,
      child: DialogScaffold(
        title: isEdit ? 'Edit Target Template' : 'Add Target Template',
        subtitle: 'Define a measurable target for this role.',
        size: DialogSize.md,
        body: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_formError != null) ...[
                  _TargetTemplateError(message: _formError!),
                  const SizedBox(height: 14),
                ],
                const _TargetTemplateSection(
                  title: 'Target definition',
                  subtitle: 'Describe the result expected from this role.',
                ),
                TextFormField(
                  controller: _titleCtrl,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Target title',
                    hintText: 'e.g. Monthly revenue generated',
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a title for this target.'
                      : value.trim().length > 255
                          ? 'Target titles must be 255 characters or fewer.'
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the expected result',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 18),
                const _TargetTemplateSection(
                  title: 'Measurement',
                  subtitle: 'Set the expected value and review cadence.',
                ),
                ResponsiveRow(
                  spacing: 12,
                  children: [
                    TextFormField(
                      controller: _targetValueCtrl,
                      enabled: !_saving,
                      decoration: const InputDecoration(
                        labelText: 'Target value',
                        hintText: 'e.g. 100 or Bronze',
                        helperText:
                            'Use a number or a defined qualitative outcome.',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Enter a target value.'
                              : null,
                    ),
                    TextFormField(
                      controller: _unitCtrl,
                      enabled: !_saving,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        hintText: 'e.g. NGN, %, clients',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Review period'),
                  isExpanded: true,
                  initialValue: _period,
                  items: _periods
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(_periodLabel(p)),
                          ))
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (val) => setState(() => _period = val ?? _period),
                ),
                const SizedBox(height: 12),
                ExpansionTile(
                  maintainState: true,
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  title: const Text('Template settings'),
                  subtitle: const Text('Display order and active status'),
                  children: [
                    TextFormField(
                      controller: _sequenceCtrl,
                      enabled: !_saving,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Display order',
                        helperText: 'Lower numbers appear first.',
                      ),
                      validator: (value) {
                        final sequence = int.tryParse(value?.trim() ?? '');
                        if (sequence == null ||
                            sequence < 1 ||
                            sequence > 2147483647) {
                          return 'Enter a whole number from 1 to 2,147,483,647.';
                        }
                        return null;
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Active for this role'),
                      subtitle: const Text(
                          'Inactive templates are not assigned to new periods.'),
                      value: _isActive,
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _isActive = value),
                    ),
                  ],
                ),
              ],
            )),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: _saving ? null : _onSave,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Iconsax.save_2, size: 17),
            label: Text(
                _saving ? 'Saving…' : (isEdit ? 'Save changes' : 'Add target')),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false) || _saving) return;
    final title = _titleCtrl.text.trim();
    final rawValue = _targetValueCtrl.text.trim();
    // Try numeric, fall back to string
    final numericValue = double.tryParse(rawValue);
    if (numericValue != null && (!numericValue.isFinite || numericValue < 0)) {
      setState(() => _formError = 'A numeric target must be zero or greater.');
      return;
    }
    final dynamic targetValue = numericValue ?? rawValue;

    setState(() {
      _saving = true;
      _formError = null;
    });
    late final TargetActionResult result;
    if (widget.template != null) {
      result = await widget.ctrl.updateTarget(
        roleId: widget.roleId,
        templateId: widget.template!.id,
        title: title,
        targetValue: targetValue,
        period: _period,
        description: _descCtrl.text.trim(),
        unit: _unitCtrl.text.trim(),
        sequence: int.parse(_sequenceCtrl.text.trim()),
        isActive: _isActive,
      );
    } else {
      result = await widget.ctrl.createTarget(
        roleId: widget.roleId,
        title: title,
        targetValue: targetValue,
        period: _period,
        description: _descCtrl.text.trim(),
        unit: _unitCtrl.text.trim(),
        sequence: int.parse(_sequenceCtrl.text.trim()),
        isActive: _isActive,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);
    if (result.succeeded) {
      AppToast.success(context, result.message);
      Navigator.pop(context);
    } else {
      setState(() => _formError = result.message);
    }
  }

  static String _periodLabel(String value) {
    if (value == 'annual' || value == 'yearly') return 'Annual';
    return value
        .split('_')
        .map((part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class _TargetTemplateSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TargetTemplateSection({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(subtitle,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
}

class _TargetTemplateError extends StatelessWidget {
  final String message;

  const _TargetTemplateError({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.dangerSubtle,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Iconsax.warning_2, size: 17, color: AppColors.danger),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.danger)),
            ),
          ],
        ),
      );
}
