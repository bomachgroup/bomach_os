import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/auth/controller.dart';
import 'package:bomach_os/pages/operations/models/engineering_site_report_model.dart';
import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:bomach_os/pages/operations/controllers/site_equipment_controller.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/services/operations/engineering_site_report_service.dart';
import 'package:bomach_os/src/services/operations/site_equipment_services.dart';
import 'package:bomach_os/src/services/operations/works_services.dart';
import 'package:bomach_os/src/services/operations/operations_services.dart';
import 'package:bomach_os/src/services/operations/tasks_services.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:bomach_os/src/utils/app_date_format.dart';
class EngineeringSiteReportsPage extends StatefulWidget {
  const EngineeringSiteReportsPage(
      {super.key,
      this.initialWorksiteId,
      this.initialProjectId,
      this.initialReportId});
  final int? initialWorksiteId;
  final int? initialProjectId;
  final int? initialReportId;
  @override
  State<EngineeringSiteReportsPage> createState() =>
      _EngineeringSiteReportsPageState();
}

class _EngineeringSiteReportsPageState
    extends State<EngineeringSiteReportsPage> {
  final _service = EngineeringSiteReportService();
  final _inventory = SiteEquipmentService(baseUrl: ApiConstants.baseUrl);
  final _storage = const FlutterSecureStorage();
  List<EngineeringSiteReport> _reports = [];
  int _count = 0, _offset = 0;
  bool _loading = true;
  bool _didAutoOpen = false;
  String _status = 'all';
  final _employee = TextEditingController(),
      _worksite = TextEditingController(),
      _project = TextEditingController(),
      _from = TextEditingController(),
      _to = TextEditingController();
  String? _token;
  int get _userId => Get.isRegistered<AuthController>()
      ? Get.find<AuthController>().currentUser.value?.userId ?? 0
      : 0;
  PermissionService get _permissions => Get.isRegistered<PermissionService>()
      ? Get.find<PermissionService>()
      : PermissionService();

  @override
  void initState() {
    super.initState();
    if (widget.initialWorksiteId != null)
      _worksite.text = '${widget.initialWorksiteId}';
    if (widget.initialProjectId != null)
      _project.text = '${widget.initialProjectId}';
    _load();
  }

  @override
  void dispose() {
    for (final c in [_employee, _worksite, _project, _from, _to]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _token ??= (await _storage.read(key: 'access_token'))
          ?.replaceFirst('Bearer ', '')
          .replaceAll('"', '')
          .trim();
      if (_token == null) throw Exception('Authentication token not found');
      final mayList =
          _can('list') || _can('list_own') || _can('view') || _can('view_own');
      final page = mayList
          ? await _service.listReports(
              accessToken: _token!,
              status: _status,
              employeeId: int.tryParse(_employee.text),
              worksiteId: int.tryParse(_worksite.text),
              projectId: int.tryParse(_project.text),
              dateFrom: appDateToApiDate(_from.text) ?? _from.text,
              dateTo: appDateToApiDate(_to.text) ?? _to.text,
              limit: 20,
              offset: _offset)
          : (items: <EngineeringSiteReport>[], count: 0);
      final target = widget.initialReportId == null
          ? null
          : await _service.getReport(
              accessToken: _token!, reportId: widget.initialReportId!);
      if (mounted)
        setState(() {
          _reports = target == null ? page.items : [target];
          _count = target == null ? page.count : 1;
        });
      if (target != null && mounted && !_didAutoOpen) {
        _didAutoOpen = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _detail(target));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not load reports: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _can(String action) => _permissions
      .has(Permission(PermissionConstants.resEngineeringSiteReports, action));

  @override
  Widget build(BuildContext context) => PageScaffold(
        maxContentWidth: 1440,
        header: PageHeader(
            title: 'Engineering Site Reports',
            subtitle:
                'Record site activity, materials, and expenses, then submit reports for review.',
            trailing: ifCreateButton()),
        children: [
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(spacing: 12, runSpacing: 10, children: [
                          SizedBox(
                              width: 150,
                              child: DropdownButtonFormField<String>(
                                  value: _status,
                                  decoration: const InputDecoration(
                                      labelText: 'Status'),
                                  items: [
                                    'all',
                                    'draft',
                                    'submitted',
                                    'approved',
                                    'rejected'
                                  ]
                                      .map((s) => DropdownMenuItem(
                                          value: s, child: Text(_title(s))))
                                      .toList(),
                                  onChanged: (v) {
                                    _status = v ?? 'all';
                                    _offset = 0;
                                    _load();
                                  })),
                          _filterField(_employee, 'Employee ID'),
                          _filterField(_worksite, 'Worksite ID'),
                          _filterField(_project, 'Project ID'),
                          _filterField(_from, 'Date from (DD-MM-YYYY)'),
                          _filterField(_to, 'Date to (DD-MM-YYYY)'),
                          OutlinedButton.icon(
                              onPressed: () {
                                _offset = 0;
                                _load();
                              },
                              icon: const Icon(Iconsax.search_normal),
                              label: const Text('Apply')),
                        ]),
                        const SizedBox(height: 12),
                        if (_loading)
                          const LinearProgressIndicator()
                        else if (_reports.isEmpty)
                          const Padding(
                              padding: EdgeInsets.all(30),
                              child: Center(
                                  child: Text('No engineering reports found.')))
                        else
                          ..._reports.map(_reportTile),
                        if (_count > 20)
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                    '${_offset + 1}–${(_offset + _reports.length).clamp(0, _count)} of $_count'),
                                IconButton(
                                    onPressed: _offset == 0
                                        ? null
                                        : () {
                                            _offset =
                                                (_offset - 20).clamp(0, _count);
                                            _load();
                                          },
                                    icon: const Icon(Iconsax.arrow_left_2)),
                                IconButton(
                                    onPressed: _offset + 20 >= _count
                                        ? null
                                        : () {
                                            _offset += 20;
                                            _load();
                                          },
                                    icon: const Icon(Iconsax.arrow_right_3))
                              ]),
                      ]))),
        ],
      );

  Widget ifCreateButton() => _can('create')
      ? MyElevatedButton(
          child: 'New Report',
          icon: const Icon(Iconsax.add, size: 18, color: Colors.white),
          onTap: () => _edit())
      : const SizedBox.shrink();
  Widget _filterField(TextEditingController c, String label) => SizedBox(
      width: 190,
      child: TextField(
          controller: c,
          decoration: InputDecoration(labelText: label, isDense: true)));

  Widget _reportTile(EngineeringSiteReport r) => Card(
      margin: const EdgeInsets.only(top: 10),
      child: ListTile(
        leading: const Icon(Iconsax.document_text, color: AppColors.primary),
        title: Text(
            '${r.worksiteName.isEmpty ? 'Worksite ${r.worksiteId}' : r.worksiteName} · ${formatAppDateValue(r.date, fallback: r.date)}',
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${_title(r.status)}  •  ${r.employeeName}  •  ${r.activities.length} activities  •  Version ${r.submissionVersion}'),
        trailing: const Icon(Iconsax.arrow_right_3),
        onTap: _can('view') || (_can('view_own') && r.employeeId == _userId)
            ? () => _detail(r)
            : null,
      ));

  void _detail(EngineeringSiteReport report) => showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            title: Text('Engineering Report · ${_title(report.status)}'),
            content: SizedBox(
                width: 650,
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      Text(
                          'Worksite: ${report.worksiteName}   •   ${formatAppDateValue(report.date, fallback: report.date)}'),
                      Text('Employee: ${report.employeeName}'),
                      Text('Version: ${report.submissionVersion}'),
                      const SizedBox(height: 12),
                      const Text('Activities',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...report.activities.map((a) => Text(
                          '• ${_title(a.activityType)}: ${a.description}')),
                      if (report.tomorrowActivities.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Tomorrow: ${report.tomorrowActivities}')
                      ],
                      if (report.commentsSuggestions.isNotEmpty)
                        Text('Comments: ${report.commentsSuggestions}'),
                      if (report.expenses.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Expenses',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ...report.expenses.map((e) => Text(
                            '• ${e.name} · ${_title(e.expenseCategory)} · ₦${e.amount} · ${e.description}'))
                      ],
                      if (report.materialsUsed.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Materials used',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ...report.materialsUsed.map((m) =>
                            Text('• ${m.name} · ${m.quantityUsed} ${m.unit}'))
                      ],
                      if (report.attachments.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Attachments',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        ...report.attachments.map((url) => SelectableText(url))
                      ],
                    ]))),
            actions: [
              if ((report.status == 'draft' || report.status == 'rejected') &&
                  (_can('update') ||
                      (_can('update_own') && report.employeeId == _userId)))
                TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _edit(report: report);
                    },
                    child: const Text('Edit')),
              if ((report.status == 'draft' || report.status == 'rejected') &&
                  (_can('submit')))
                TextButton(
                    onPressed: () async {
                      try {
                        await _service.submitReport(
                            accessToken: _token!, reportId: report.id);
                        await _refreshInventory(report.worksiteId);
                        if (mounted) Navigator.pop(ctx);
                        await _load();
                      } catch (e) {
                        _toast('Submit failed: $e');
                      }
                    },
                    child: const Text('Submit')),
              if (report.status == 'submitted' &&
                  report.employeeId != _userId &&
                  _can('approve'))
                TextButton(
                    onPressed: () =>
                        _review(report, approve: true, dialogContext: ctx),
                    child: const Text('Approve')),
              if (report.status == 'submitted' &&
                  report.employeeId != _userId &&
                  _can('reject'))
                TextButton(
                    onPressed: () =>
                        _review(report, approve: false, dialogContext: ctx),
                    child: const Text('Reject')),
              if ((report.status == 'draft' || report.status == 'rejected') &&
                  _can('delete'))
                TextButton(
                    onPressed: () async {
                      try {
                        await _service.deleteReport(
                            accessToken: _token!, reportId: report.id);
                        if (mounted) Navigator.pop(ctx);
                        await _load();
                      } catch (e) {
                        _toast('Delete failed: $e');
                      }
                    },
                    child: const Text('Delete',
                        style: TextStyle(color: Colors.red))),
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close')),
            ],
          ));

  Future<void> _review(EngineeringSiteReport report,
      {required bool approve, required BuildContext dialogContext}) async {
    final feedback = TextEditingController(),
        rating = ValueNotifier<int?>(null);
    final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
                title: Text(approve ? 'Approve report' : 'Reject report'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (approve)
                    DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                            labelText: 'Rating (optional)'),
                        items: [1, 2, 3, 4, 5]
                            .map((x) =>
                                DropdownMenuItem(value: x, child: Text('$x')))
                            .toList(),
                        onChanged: (v) => rating.value = v)
                  else
                    TextField(
                        controller: feedback,
                        maxLines: 3,
                        decoration: const InputDecoration(
                            labelText: 'Feedback required')),
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(approve ? 'Approve' : 'Reject'))
                ]));
    if (result == true) {
      try {
        if (approve) {
          await _service.approveReport(
              accessToken: _token!, reportId: report.id, rating: rating.value);
        } else {
          if (feedback.text.trim().isEmpty) {
            _toast('Rejection feedback is required');
            return;
          }
          await _service.rejectReport(
              accessToken: _token!,
              reportId: report.id,
              feedback: feedback.text);
        }
        await _refreshInventory(report.worksiteId);
        if (mounted) Navigator.pop(dialogContext);
        await _load();
      } catch (e) {
        _toast('Review failed: $e');
      }
    }
    feedback.dispose();
    rating.dispose();
  }

  Future<void> _edit({EngineeringSiteReport? report}) async {
    _token ??= (await _storage.read(key: 'access_token'))
        ?.replaceFirst('Bearer ', '')
        .replaceAll('"', '')
        .trim();
    if (_token == null || _token!.isEmpty) return;
    final worksiteId = report?.worksiteId ??
        int.tryParse(_worksite.text) ??
        widget.initialWorksiteId;
    final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => EngineeringReportEditor(
            report: report,
            initialWorksiteId: worksiteId,
            initialProjectId: report?.projectId ?? widget.initialProjectId,
            token: _token ?? '',
            service: _service,
            inventoryService: _inventory));
    if (result == true) await _load();
  }

  Future<void> _refreshInventory(int worksiteId) async {
    if (Get.isRegistered<SiteEquipmentController>()) {
      await Get.find<SiteEquipmentController>()
          .fetchEquipment(context, worksiteId: worksiteId);
    } else {
      await _inventory.getSiteEquipment(
          accessToken: _token!, worksiteId: worksiteId);
    }
  }

  void _toast(String message) {
    if (mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
  }

  String _title(String value) => value
      .split('_')
      .map((x) => x.isEmpty ? '' : '${x[0].toUpperCase()}${x.substring(1)}')
      .join(' ');
}

class EngineeringReportEditor extends StatefulWidget {
  const EngineeringReportEditor(
      {super.key,
      this.report,
      this.initialWorksiteId,
      this.initialProjectId,
      required this.token,
      required this.service,
      required this.inventoryService});
  final EngineeringSiteReport? report;
  final int? initialWorksiteId;
  final int? initialProjectId;
  final String token;
  final EngineeringSiteReportService service;
  final SiteEquipmentService inventoryService;
  @override
  State<EngineeringReportEditor> createState() =>
      _EngineeringReportEditorState();
}

class _EngineeringReportEditorState extends State<EngineeringReportEditor> {
  final _form = GlobalKey<FormState>();
  final _date = TextEditingController();
  late final WorksiteService _worksiteService;
  late final DashboardService _projectService;
  late final TaskService _taskService;
  int? _selectedWorksiteId;
  int? _selectedProjectId;
  int? _selectedTaskId;
  List<Worksite> _worksites = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];
  bool _loadingReferences = true;
  final _tomorrow = TextEditingController();
  final _comments = TextEditingController();
  final _attachment = TextEditingController();
  final List<_ActivityInput> _activities = [];
  final List<_ExpenseInput> _expenses = [];
  final List<_MaterialInput> _materials = [];
  List<SiteEquipment> _inventory = [];
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    _worksiteService = WorksiteService(baseUrl: ApiConstants.baseUrl);
    _projectService = DashboardService(baseUrl: ApiConstants.baseUrl);
    _taskService = TaskService(baseUrl: ApiConstants.baseUrl);
    final r = widget.report;
    _date.text = r == null
        ? formatAppDate(DateTime.now())
        : formatAppDateValue(r.date, fallback: r.date);
    _selectedWorksiteId = r?.worksiteId ?? widget.initialWorksiteId;
    _selectedProjectId = r?.projectId ?? widget.initialProjectId;
    _selectedTaskId = r?.taskId;
    _tomorrow.text = r?.tomorrowActivities ?? '';
    _comments.text = r?.commentsSuggestions ?? '';
    for (final a in r?.activities ?? []) {
      _activities.add(_ActivityInput(a.activityType, a.description));
    }
    if (_activities.isEmpty)
      _activities.add(_ActivityInput('concrete_work', ''));
    for (final e in r?.expenses ?? []) {
      _expenses.add(
          _ExpenseInput(e.expenseCategory, e.name, e.amount, e.description));
    }
    for (final m in r?.materialsUsed ?? []) {
      _materials.add(_MaterialInput(m.equipmentId, m.quantityUsed));
    }
    _loadReferences();
  }

  Future<void> _loadReferences() async {
    try {
      final results = await Future.wait([
        _loadAllWorksites(),
        _loadAllProjects(),
      ]);
      if (!mounted) return;
      setState(() {
        _worksites = results[0] as List<Worksite>;
        _projects = results[1] as List<Project>;
        final selectedWorksite = _selectedWorksite;
        if (selectedWorksite != null && selectedWorksite.projectId != 0) {
          _selectedProjectId = selectedWorksite.projectId;
        }
        if (!_projects.any((project) => project.id == _selectedProjectId)) {
          _selectedProjectId = null;
        }
        _loadingReferences = false;
      });
      await Future.wait([_loadInventory(), _loadTasks()]);
    } catch (e) {
      if (mounted) {
        setState(() => _loadingReferences = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load report options: $e')),
        );
      }
    }
  }

  Future<List<Worksite>> _loadAllWorksites() async {
    final items = <Worksite>[];
    var offset = 0;
    while (true) {
      final page = await _worksiteService.getWorksites(
        accessToken: widget.token,
        limit: 100,
        offset: offset,
      );
      items.addAll(page.items);
      if (items.length >= page.count || page.items.isEmpty) break;
      offset += page.items.length;
    }
    return items;
  }

  Future<List<Project>> _loadAllProjects() async {
    final items = <Project>[];
    var offset = 0;
    while (true) {
      final page = await _projectService.getProjects(
        accessToken: widget.token,
        limit: 100,
        offset: offset,
      );
      items.addAll(page.items);
      if (items.length >= page.count || page.items.isEmpty) break;
      offset += page.items.length;
    }
    return items;
  }

  Worksite? get _selectedWorksite {
    for (final worksite in _worksites) {
      if (worksite.id == _selectedWorksiteId) return worksite;
    }
    return null;
  }

  List<Project> get _selectableProjects {
    final linkedProjectId = _selectedWorksite?.projectId ?? 0;
    if (linkedProjectId == 0) return _projects;
    return _projects.where((project) => project.id == linkedProjectId).toList();
  }

  Worksite? _worksiteById(int? id) {
    for (final worksite in _worksites) {
      if (worksite.id == id) return worksite;
    }
    return null;
  }

  Future<void> _loadInventory() async {
    final id = _selectedWorksiteId;
    if (id == null) return;
    try {
      final rows = await widget.inventoryService
          .getSiteEquipment(accessToken: widget.token, worksiteId: id);
      if (mounted) setState(() => _inventory = rows);
    } catch (_) {}
  }

  Future<void> _loadTasks() async {
    final tasks = <Task>[];
    var offset = 0;
    try {
      while (true) {
        final page = await _taskService.getTasks(
          accessToken: widget.token,
          projectId: _selectedProjectId,
          limit: 100,
          offset: offset,
        );
        tasks.addAll(page.items);
        if (tasks.length >= page.count || page.items.isEmpty) break;
        offset += page.items.length;
      }
      if (mounted) {
        setState(() {
          _tasks = tasks;
          if (!_tasks.any((task) => task.id == _selectedTaskId)) {
            _selectedTaskId = null;
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _tasks = []);
    }
  }

  @override
  void dispose() {
    for (final c in [_date, _tomorrow, _comments, _attachment]) {
      c.dispose();
    }
    for (final x in _activities) {
      x.dispose();
    }
    for (final x in _expenses) {
      x.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: Text(widget.report == null
              ? 'New Engineering Report'
              : 'Edit Engineering Report'),
          content: SizedBox(
            width: 720,
            child: Form(
                key: _form,
                child: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                      if (_loadingReferences)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: LinearProgressIndicator(),
                        ),
                      DropdownButtonFormField<int>(
                        value: _worksites.any((worksite) =>
                                worksite.id == _selectedWorksiteId)
                            ? _selectedWorksiteId
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Worksite*',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: _worksites
                            .map((worksite) => DropdownMenuItem(
                                  value: worksite.id,
                                  child: Text(worksite.name),
                                ))
                            .toList(),
                        validator: (value) =>
                            value == null ? 'Select a worksite' : null,
                        onChanged: _loadingReferences
                            ? null
                            : (value) async {
                                final worksite = _worksiteById(value);
                                setState(() {
                                  _selectedWorksiteId = value;
                                  _selectedProjectId = worksite?.projectId == 0
                                      ? null
                                      : worksite?.projectId;
                                  _selectedTaskId = null;
                                  _tasks = [];
                                  _inventory = [];
                                });
                                await Future.wait(
                                    [_loadInventory(), _loadTasks()]);
                              },
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: _selectableProjects.any((project) =>
                                    project.id == _selectedProjectId)
                                ? _selectedProjectId
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'Project (optional)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: _selectableProjects
                                .map((project) => DropdownMenuItem(
                                    value: project.id,
                                    child: Text(project.name)))
                                .toList(),
                            onChanged: _loadingReferences ||
                                    (_selectedWorksite?.projectId ?? 0) != 0
                                ? null
                                : (value) async {
                                    setState(() {
                                      _selectedProjectId = value;
                                      _selectedTaskId = null;
                                      _tasks = [];
                                    });
                                    await _loadTasks();
                                  },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value:
                                _tasks.any((task) => task.id == _selectedTaskId)
                                    ? _selectedTaskId
                                    : null,
                            decoration: const InputDecoration(
                              labelText: 'Task (optional)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: _tasks
                                .map((task) => DropdownMenuItem(
                                    value: task.id, child: Text(task.name)))
                                .toList(),
                            onChanged: _loadingReferences
                                ? null
                                : (value) =>
                                    setState(() => _selectedTaskId = value),
                          ),
                        )
                      ]),
                      _field(_date, 'Date (DD-MM-YYYY)*',
                          validator: (value) =>
                              parseAppDate(value) == null
                                  ? 'Enter a valid date'
                                  : null),
                      const _SectionTitle('Activities'),
                      ..._activities
                          .asMap()
                          .entries
                          .map((entry) => _activityRow(entry.key, entry.value)),
                      TextButton.icon(
                          onPressed: () => setState(() => _activities
                              .add(_ActivityInput('concrete_work', ''))),
                          icon: const Icon(Iconsax.add),
                          label: const Text('Add activity')),
                      const _SectionTitle('Expenses'),
                      ..._expenses
                          .asMap()
                          .entries
                          .map((entry) => _expenseRow(entry.key, entry.value)),
                      TextButton.icon(
                          onPressed: () => setState(() => _expenses
                              .add(_ExpenseInput('labour', '', '', ''))),
                          icon: const Icon(Iconsax.add),
                          label: const Text('Add expense')),
                      const _SectionTitle('Materials used'),
                      if (_inventory.isEmpty)
                        const Text(
                            'No inventory found for the selected worksite.'),
                      ..._materials
                          .asMap()
                          .entries
                          .map((entry) => _materialRow(entry.key, entry.value)),
                      TextButton.icon(
                          onPressed: _inventory.isEmpty
                              ? null
                              : () => setState(() => _materials.add(
                                  _MaterialInput(_inventory.first.id, ''))),
                          icon: const Icon(Iconsax.add),
                          label: const Text('Add material')),
                      _field(_tomorrow, 'Tomorrow activities'),
                      _field(_comments, 'Comments and suggestions',
                          maxLines: 3),
                      TextFormField(
                          controller: _attachment,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          decoration: const InputDecoration(
                              labelText:
                                  'Attachment URLs (optional, one per line)'),
                          validator: (value) {
                            final urls = (value ?? '')
                                .split('\n')
                                .map((url) => url.trim())
                                .where((url) => url.isNotEmpty);
                            for (final url in urls) {
                              if (!isValidEngineeringAttachmentUrl(url))
                                return 'Enter valid HTTP or HTTPS URLs';
                            }
                            return null;
                          }),
                    ]))),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(
                        widget.report == null ? 'Save Draft' : 'Save Changes'))
          ]);
  Widget _field(TextEditingController c, String label,
          {bool numeric = false,
          int maxLines = 1,
          String? Function(String?)? validator,
          void Function(String)? onChanged}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextFormField(
              controller: c,
              maxLines: maxLines,
              keyboardType: numeric ? TextInputType.number : TextInputType.text,
              validator: validator,
              onChanged: onChanged,
              decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(),
                  isDense: true)));
  Widget _activityRow(int i, _ActivityInput a) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
                value: a.type,
                decoration: const InputDecoration(labelText: 'Activity type'),
                items: engineeringActivityTypes
                    .toList()
                    .map((x) => DropdownMenuItem(
                        value: x, child: Text(x.replaceAll('_', ' '))))
                    .toList(),
                onChanged: (v) => a.type = v ?? a.type)),
        const SizedBox(width: 8),
        Expanded(
            flex: 4,
            child: TextFormField(
                controller: a.description,
                decoration: const InputDecoration(labelText: 'Description*'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null)),
        IconButton(
            onPressed: _activities.length == 1
                ? null
                : () => setState(() => _activities.removeAt(i).dispose()),
            icon: const Icon(Iconsax.trash, color: Colors.red))
      ]);
  Widget _expenseRow(int i, _ExpenseInput e) => Card(
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  child: DropdownButtonFormField<String>(
                      value: e.category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: engineeringExpenseCategories
                          .toList()
                          .map((x) => DropdownMenuItem(
                              value: x, child: Text(x.replaceAll('_', ' '))))
                          .toList(),
                      onChanged: (v) => e.category = v ?? e.category)),
              const SizedBox(width: 6),
              Expanded(
                  child: TextFormField(
                      controller: e.name,
                      decoration: const InputDecoration(labelText: 'Name*'),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null)),
              const SizedBox(width: 6),
              Expanded(
                  child: TextFormField(
                      controller: e.amount,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Amount*'),
                      validator: (v) => double.tryParse(v ?? '') == null ||
                              double.parse(v!) <= 0
                          ? 'Must be > 0'
                          : null)),
              IconButton(
                  onPressed: () =>
                      setState(() => _expenses.removeAt(i).dispose()),
                  icon: const Icon(Iconsax.trash, color: Colors.red)),
            ]),
            TextFormField(
                controller: e.description,
                decoration:
                    const InputDecoration(labelText: 'Expense description*'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null)
          ])));
  Widget _materialRow(int i, _MaterialInput m) => Row(children: [
        Expanded(
            child: DropdownButtonFormField<int>(
                value: _inventory.any((x) => x.id == m.id) ? m.id : null,
                decoration:
                    const InputDecoration(labelText: 'Site inventory item'),
                items: _inventory
                    .map((x) => DropdownMenuItem(
                        value: x.id,
                        child: Text('${x.name} (${x.quantity} ${x.unit})')))
                    .toList(),
                onChanged: (v) => m.id = v ?? m.id)),
        const SizedBox(width: 8),
        SizedBox(
            width: 160,
            child: TextFormField(
                controller: m.quantity,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Quantity used'),
                validator: (v) => double.tryParse(v ?? '') == null ||
                        double.parse(v!) <= 0 ||
                        !_validQuantity(v)
                    ? 'Enter positive quantity'
                    : null)),
        IconButton(
            onPressed: () => setState(() => _materials.removeAt(i).dispose()),
            icon: const Icon(Iconsax.trash, color: Colors.red))
      ]);
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final activities = _activities
        .map((x) => EngineeringReportActivity(
            activityType: x.type, description: x.description.text.trim()))
        .toList();
    if (!hasValidEngineeringActivity(activities)) return;
    final urls = [
      ..._attachment.text
          .split('\n')
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
    ];
    setState(() => _saving = true);
    final report = EngineeringSiteReport(
        id: widget.report?.id ?? 0,
        employeeId: widget.report?.employeeId ?? 0,
        employeeName: widget.report?.employeeName ?? '',
        status: widget.report?.status ?? 'draft',
        worksiteId: _selectedWorksiteId!,
        worksiteName: _selectedWorksite?.name ?? '',
        projectId: _selectedProjectId,
        taskId: _selectedTaskId,
        date: appDateToApiDate(_date.text) ?? _date.text,
        tomorrowActivities: _tomorrow.text,
        commentsSuggestions: _comments.text,
        submissionVersion: widget.report?.submissionVersion ?? 0,
        activities: activities,
        expenses: _expenses
            .map((x) => EngineeringReportExpense(
                expenseCategory: x.category,
                name: x.name.text.trim(),
                amount: double.parse(x.amount.text).toStringAsFixed(2),
                description: x.description.text.trim()))
            .toList(),
        materialsUsed: _materials
            .map((x) => EngineeringReportMaterial(
                equipmentId: x.id,
                quantityUsed: double.parse(x.quantity.text).toStringAsFixed(3)))
            .toList(),
        attachments: urls,
        createdAt: '',
        updatedAt: '');
    try {
      if (widget.report == null) {
        await widget.service
            .createReport(accessToken: widget.token, report: report);
      } else {
        await widget.service.updateReport(
            accessToken: widget.token,
            reportId: widget.report!.id,
            report: report);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

bool _validQuantity(String? value) {
  final normalized = value?.trim() ?? '';
  return RegExp(r'^\d+(\.\d{1,3})?$').hasMatch(normalized);
}

class _ActivityInput {
  _ActivityInput(this.type, String value)
      : description = TextEditingController(text: value);
  String type;
  final TextEditingController description;
  void dispose() => description.dispose();
}

class _ExpenseInput {
  _ExpenseInput(this.category, String name, String amount, String description)
      : name = TextEditingController(text: name),
        amount = TextEditingController(text: amount),
        description = TextEditingController(text: description);
  String category;
  final TextEditingController name, amount, description;
  void dispose() {
    name.dispose();
    amount.dispose();
    description.dispose();
  }
}

class _MaterialInput {
  _MaterialInput(this.id, String quantity)
      : quantity = TextEditingController(text: quantity);
  int id;
  final TextEditingController quantity;
  void dispose() => quantity.dispose();
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(title, style: AppTextStyles.h3));
}
