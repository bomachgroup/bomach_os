import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/services/hr/attendance_calendar_service.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

class AttendanceCalendarPage extends StatefulWidget {
  const AttendanceCalendarPage({super.key});

  @override
  State<AttendanceCalendarPage> createState() => _AttendanceCalendarPageState();
}

class _AttendanceCalendarPageState extends State<AttendanceCalendarPage> {
  final _storage = const FlutterSecureStorage();
  final _service = AttendanceCalendarService();
  List<AttendanceCalendarEntry> _entries = [];
  bool _loading = true;
  String? _loadError;
  String _filter = 'upcoming';

  bool get _canCreate => Get.find<PermissionService>()
      .hasPermission('attendance_calendar', 'create');
  bool get _canUpdate => Get.find<PermissionService>()
      .hasPermission('attendance_calendar', 'update');
  bool get _canDeactivate => Get.find<PermissionService>()
      .hasPermission('attendance_calendar', 'deactivate');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<String?> _token() async {
    final value = await _storage.read(key: 'access_token');
    if (value == null) return null;
    return value.replaceFirst('Bearer ', '').replaceAll('"', '').trim();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final token = await _token();
      if (token == null || token.isEmpty) {
        throw Exception('Your session has expired. Sign in again to continue.');
      }
      final entries = await _service.list(token);
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'The work calendar could not be loaded.';
      });
    }
  }

  List<AttendanceCalendarEntry> get _visibleEntries {
    final today = _dateOnly(DateTime.now());
    final visible = _entries.where((entry) {
      if (_filter == 'inactive') return !entry.isActive;
      if (!entry.isActive) return false;
      return _filter == 'past'
          ? _dateOnly(entry.endDate).isBefore(today)
          : !_dateOnly(entry.endDate).isBefore(today);
    }).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    if (_filter == 'past') return visible.reversed.toList();
    return visible;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  Future<void> _openForm({AttendanceCalendarEntry? entry}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _CalendarEntryDialog(
        entry: entry,
        service: _service,
        tokenProvider: _token,
      ),
    );
    if (saved == true) {
      await _load();
      if (mounted) {
        AppToast.success(
            context,
            entry == null
                ? 'Calendar dates added.'
                : 'Calendar entry updated.');
      }
    }
  }

  Future<void> _deactivate(AttendanceCalendarEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove this calendar entry?'),
        content: Text(
          '${entry.name} will no longer affect attendance requirements. Its audit history will be kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep entry'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final token = await _token();
      if (token == null || token.isEmpty) throw Exception('Session expired');
      await _service.deactivate(token, entry.id);
      await _load();
      if (mounted) AppToast.success(context, 'Calendar entry deactivated.');
    } catch (_) {
      if (mounted)
        AppToast.error(context, 'The calendar entry could not be updated.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleEntries;
    return PageScaffold(
      header: PageHeader(
        title: 'Work Calendar',
        subtitle: 'Manage public holidays and approved company closures.',
        trailing: _canCreate
            ? FilledButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Iconsax.add, size: 18),
                label: const Text('Add dates'),
              )
            : null,
      ),
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Calendar entries', style: AppTextStyles.h3),
              const SizedBox(height: 4),
              Text(
                'Clock-ins remain available on optional days. Past changes update attendance summaries without changing recorded clock times.',
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  _FilterChip(
                      label: 'Upcoming',
                      value: 'upcoming',
                      current: _filter,
                      onSelect: _setFilter),
                  _FilterChip(
                      label: 'Past',
                      value: 'past',
                      current: _filter,
                      onSelect: _setFilter),
                  _FilterChip(
                      label: 'Inactive',
                      value: 'inactive',
                      current: _filter,
                      onSelect: _setFilter),
                ],
              ),
            ],
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_loadError != null)
          AppCard(
            child: Row(
              children: [
                const Icon(Iconsax.wifi, color: AppColors.textSecondary),
                const SizedBox(width: 12),
                Expanded(child: Text(_loadError!)),
                TextButton.icon(
                  onPressed: _load,
                  icon: const Icon(Iconsax.refresh, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ),
          )
        else if (visible.isEmpty)
          AppCard(
            child: Column(
              children: [
                const Icon(Iconsax.calendar_1,
                    size: 28, color: AppColors.textSecondary),
                const SizedBox(height: 10),
                Text(
                  _filter == 'inactive'
                      ? 'No inactive entries'
                      : 'No calendar dates here',
                  style: AppTextStyles.bodyMd
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                if (_filter == 'upcoming' && _canCreate) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _openForm(),
                    icon: const Icon(Iconsax.add, size: 18),
                    label: const Text('Add a calendar date'),
                  ),
                ],
              ],
            ),
          )
        else
          Column(
            children: [
              for (final entry in visible) ...[
                _CalendarEntryCard(
                  entry: entry,
                  canEdit: entry.isActive && _canUpdate,
                  canDeactivate: entry.isActive && _canDeactivate,
                  onEdit: () => _openForm(entry: entry),
                  onDeactivate: () => _deactivate(entry),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }

  void _setFilter(String value) => setState(() => _filter = value);
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    required this.current,
    required this.onSelect,
  });

  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) => ChoiceChip(
        label: Text(label),
        selected: current == value,
        onSelected: (_) => onSelect(value),
      );
}

class _CalendarEntryCard extends StatelessWidget {
  const _CalendarEntryCard({
    required this.entry,
    required this.canEdit,
    required this.canDeactivate,
    required this.onEdit,
    required this.onDeactivate,
  });

  final AttendanceCalendarEntry entry;
  final bool canEdit;
  final bool canDeactivate;
  final VoidCallback onEdit;
  final VoidCallback onDeactivate;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yyyy');
    final dates = entry.startDate == entry.endDate
        ? dateFormat.format(entry.startDate)
        : '${dateFormat.format(entry.startDate)} - ${dateFormat.format(entry.endDate)}';
    final kindLabel =
        entry.kind == 'public_holiday' ? 'Public holiday' : 'Company closure';
    final color = entry.isActive ? AppColors.primary : AppColors.textSecondary;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Iconsax.calendar_tick, color: color, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name,
                    style: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(dates,
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _KindLabel(text: kindLabel, color: color),
                    if (!entry.isActive)
                      const _KindLabel(
                          text: 'Inactive', color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 8),
                Text(entry.reason, style: AppTextStyles.bodySm),
                if (entry.createdByName != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Added by ${entry.createdByName}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (canEdit || canDeactivate)
            PopupMenuButton<String>(
              tooltip: 'Entry actions',
              onSelected: (action) =>
                  action == 'edit' ? onEdit() : onDeactivate(),
              itemBuilder: (context) => [
                if (canEdit)
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                if (canDeactivate)
                  const PopupMenuItem(
                      value: 'deactivate', child: Text('Deactivate')),
              ],
            ),
        ],
      ),
    );
  }
}

class _KindLabel extends StatelessWidget {
  const _KindLabel({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: AppTextStyles.caption
              .copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      );
}

class _CalendarEntryDialog extends StatefulWidget {
  const _CalendarEntryDialog({
    required this.entry,
    required this.service,
    required this.tokenProvider,
  });

  final AttendanceCalendarEntry? entry;
  final AttendanceCalendarService service;
  final Future<String?> Function() tokenProvider;

  @override
  State<_CalendarEntryDialog> createState() => _CalendarEntryDialogState();
}

class _CalendarEntryDialogState extends State<_CalendarEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _reason;
  DateTimeRange? _range;
  late String _kind;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _name = TextEditingController(text: entry?.name ?? '');
    _reason = TextEditingController(text: entry?.reason ?? '');
    _kind = entry?.kind ?? 'public_holiday';
    if (entry != null) {
      _range = DateTimeRange(start: entry.startDate, end: entry.endDate);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _reason.dispose();
    super.dispose();
  }

  String _iso(DateTime value) => DateFormat('yyyy-MM-dd').format(value);

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10, 12, 31),
      initialDateRange: _range,
      helpText: 'Select closure dates',
      saveText: 'Use dates',
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final range = _range;
    if (range == null) {
      setState(() => _error = 'Select the date or date range.');
      return;
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final isPast =
        DateTime(range.start.year, range.start.month, range.start.day)
            .isBefore(todayDate);
    final policyChanged = widget.entry == null ||
        widget.entry!.kind != _kind ||
        widget.entry!.startDate != range.start ||
        widget.entry!.endDate != range.end;
    final affectsPastPolicy = policyChanged &&
        (isPast ||
            (widget.entry != null &&
                DateTime(
                  widget.entry!.startDate.year,
                  widget.entry!.startDate.month,
                  widget.entry!.startDate.day,
                ).isBefore(todayDate)));
    if (affectsPastPolicy) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Update a past date?'),
          content: const Text(
            'Attendance summaries and saved scorecards for these dates will be recalculated. Recorded clock-ins and clock-outs will not be changed.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Review dates')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue')),
          ],
        ),
      );
      if (proceed != true) return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final token = await widget.tokenProvider();
      if (token == null || token.isEmpty) throw Exception('Session expired');
      final values = {
        'name': _name.text.trim(),
        'kind': _kind,
        'startDate': _iso(range.start),
        'endDate': _iso(range.end),
        'reason': _reason.text.trim(),
      };
      if (widget.entry == null) {
        await widget.service.create(
          token,
          name: values['name']!,
          kind: values['kind']!,
          startDate: values['startDate']!,
          endDate: values['endDate']!,
          reason: values['reason']!,
        );
      } else {
        await widget.service.update(
          token,
          widget.entry!.id,
          name: values['name']!,
          kind: values['kind']!,
          startDate: values['startDate']!,
          endDate: values['endDate']!,
          reason: values['reason']!,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error =
              'The calendar entry could not be saved. Check the dates and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _range == null
        ? 'Choose date or date range'
        : _range!.start == _range!.end
            ? DateFormat('d MMM yyyy').format(_range!.start)
            : '${DateFormat('d MMM yyyy').format(_range!.start)} - ${DateFormat('d MMM yyyy').format(_range!.end)}';
    return AlertDialog(
      title: Text(
          widget.entry == null ? 'Add calendar dates' : 'Edit calendar entry'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                      labelText: 'Name', hintText: 'e.g. Public holiday'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a name.'
                      : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _kind,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(
                        value: 'public_holiday', child: Text('Public holiday')),
                    DropdownMenuItem(
                        value: 'company_closure',
                        child: Text('Company closure')),
                  ],
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _kind = value ?? _kind),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickRange,
                  icon: const Icon(Iconsax.calendar_1, size: 18),
                  label: Text(dateText, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reason,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: 'Reason', alignLabelWithHint: true),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a reason.'
                      : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!,
                      style: const TextStyle(color: AppColors.danger)),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save dates'),
        ),
      ],
    );
  }
}
