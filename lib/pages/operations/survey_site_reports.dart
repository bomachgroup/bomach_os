import 'package:bomach_os/components/dialog/dialog_scaffold.dart';
import 'package:bomach_os/components/input/my_date_field.dart';
import 'package:bomach_os/components/input/searchable_dropdown_form_field.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/auth/controller.dart';
import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:bomach_os/pages/operations/models/survey_site_report_model.dart';
import 'package:bomach_os/pages/operations/controllers/site_equipment_controller.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/model/employees_model.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/services/auth_service.dart';
import 'package:bomach_os/src/services/employees_services.dart';
import 'package:bomach_os/src/services/operations/operations_services.dart';
import 'package:bomach_os/src/services/operations/site_equipment_services.dart';
import 'package:bomach_os/src/services/operations/survey_site_report_service.dart';
import 'package:bomach_os/src/services/operations/tasks_services.dart';
import 'package:bomach_os/src/services/operations/works_services.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:bomach_os/src/utils/app_date_format.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'widget/report_editor_section.dart';

class SurveySiteReportsPage extends StatefulWidget {
  const SurveySiteReportsPage(
      {super.key,
      this.initialWorksiteId,
      this.initialProjectId,
      this.initialReportId});
  final int? initialWorksiteId, initialProjectId, initialReportId;
  @override
  State<SurveySiteReportsPage> createState() => _SurveySiteReportsPageState();
}

class _SurveySiteReportsPageState extends State<SurveySiteReportsPage> {
  final _service = SurveySiteReportService();
  final _storage = const FlutterSecureStorage();
  final _employeeService = EmployeeService();
  final _worksiteService = WorksiteService(baseUrl: ApiConstants.baseUrl);
  final _projectService = DashboardService(baseUrl: ApiConstants.baseUrl);
  final _fromFilter = TextEditingController(),
      _toFilter = TextEditingController();
  int? _employeeId, _worksiteFilterId, _projectFilterId;
  List<Employee> _employees = [];
  bool _employeesLoaded = false;
  String _status = 'all', _format = 'all';
  int _offset = 0, _count = 0;
  bool _loading = true, _openedInitial = false;
  String? _token;
  List<SurveySiteReport> _reports = [];
  List<Worksite> _worksites = [];
  List<Project> _projects = [];
  int get _userId => Get.isRegistered<AuthController>()
      ? Get.find<AuthController>().currentUser.value?.userId ?? 0
      : 0;
  PermissionService get _permissionService =>
      Get.isRegistered<PermissionService>()
          ? Get.find<PermissionService>()
          : PermissionService();
  bool _can(String action) => _permissionService
      .has(Permission(PermissionConstants.resSurveySiteReports, action));

  @override
  void initState() {
    super.initState();
    _worksiteFilterId = widget.initialWorksiteId;
    _projectFilterId = widget.initialProjectId;
    _load();
  }

  @override
  void dispose() {
    for (final c in [_fromFilter, _toFilter]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<String> _getToken() async =>
      _token ??= (await _storage.read(key: 'access_token'))
              ?.replaceFirst('Bearer ', '')
              .replaceAll('"', '')
              .trim() ??
          (throw Exception('Authentication token not found'));

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final token = await _getToken();
      final mayList = _can('list') || _can('list_own');
      if (mayList || _can('create')) {
        if (_worksites.isEmpty) {
          _worksites = await _loadAllWorksites(token);
        }
        if (_projects.isEmpty) {
          _projects = await _loadAllProjects(token);
        }
      }
      if (mayList && !_employeesLoaded) {
        try {
          _employees = await _loadAllEmployees(token);
          _employeesLoaded = true;
        } catch (e) {
          _employeesLoaded = true;
          if (mounted) {
            _toast('Could not load employee filter options: $e');
          }
        }
      }
      final page = mayList
          ? await _service.listReports(
              token: token,
              status: _status,
              employeeId: _employeeId,
              worksiteId: _worksiteFilterId,
              projectId: _projectFilterId,
              workDataType: _format,
              dateFrom: appDateToApiDate(_fromFilter.text) ?? _fromFilter.text,
              dateTo: appDateToApiDate(_toFilter.text) ?? _toFilter.text,
              limit: 20,
              offset: _offset)
          : (items: <SurveySiteReport>[], count: 0);
      SurveySiteReport? target;
      if (widget.initialReportId != null &&
          (_can('view') || _can('view_own'))) {
        target = await _service.getReport(
            token: token, reportId: widget.initialReportId!);
        if (!_can('view') && target.employeeId != _userId) {
          target = null;
          _toast('You do not have permission to view this survey report.');
        }
      } else if (widget.initialReportId != null) {
        _toast('You do not have permission to view survey reports.');
      }
      if (mounted)
        setState(() {
          _reports = target == null ? page.items : [target];
          _count = target == null ? page.count : 1;
        });
      if (target != null && mounted && !_openedInitial) {
        _openedInitial = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _detail(target!));
      }
    } catch (e) {
      if (mounted) _toast('Could not load survey reports: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<List<Worksite>> _loadAllWorksites(String token) async {
    final items = <Worksite>[];
    var offset = 0;
    while (true) {
      final page = await _worksiteService.getWorksites(
        accessToken: token,
        limit: 100,
        offset: offset,
      );
      items.addAll(page.items);
      if (items.length >= page.count || page.items.isEmpty) break;
      offset += page.items.length;
    }
    return items;
  }

  Future<List<Project>> _loadAllProjects(String token) async {
    final items = <Project>[];
    var offset = 0;
    while (true) {
      final page = await _projectService.getProjects(
        accessToken: token,
        limit: 100,
        offset: offset,
      );
      items.addAll(page.items);
      if (items.length >= page.count || page.items.isEmpty) break;
      offset += page.items.length;
    }
    return items;
  }

  Future<List<Employee>> _loadAllEmployees(String token) async {
    final employees = <Employee>[];
    var offset = 0;
    while (true) {
      final page = await _employeeService.getEmployees(
        token,
        limit: 100,
        offset: offset,
      );
      employees.addAll(page.list);
      if (employees.length >= page.count || page.list.isEmpty) break;
      offset += page.list.length;
    }
    return employees;
  }

  @override
  Widget build(BuildContext context) => PageScaffold(
          maxContentWidth: 1440,
          header: PageHeader(
              title: 'Survey Site Reports',
              subtitle:
                  'Record survey measurements, site activity, materials, and expenses.',
              trailing: _can('create')
                  ? FilledButton.icon(
                      onPressed: () => _edit(),
                      icon: const Icon(Iconsax.add),
                      label: const Text('New Report'))
                  : const SizedBox.shrink()),
          children: [
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(spacing: 10, runSpacing: 10, children: [
                            SizedBox(
                                width: 145,
                                child: DropdownButtonFormField<String>(
                                    value: _status,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                        labelText: 'Status'),
                                    items: [
                                      'all',
                                      'draft',
                                      'submitted',
                                      'approved',
                                      'rejected'
                                    ]
                                        .map((x) => DropdownMenuItem(
                                            value: x, child: Text(_title(x))))
                                        .toList(),
                                    onChanged: (v) {
                                      _status = v ?? 'all';
                                      _offset = 0;
                                      _load();
                                    })),
                            SizedBox(
                                width: 175,
                                child: DropdownButtonFormField<String>(
                                    value: _format,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                        labelText: 'Survey format'),
                                    items: const [
                                      ('all', 'All formats'),
                                      (
                                        'bearing_distance',
                                        'Bearing / distance'
                                      ),
                                      ('site_points_xyz', 'XYZ site points')
                                    ]
                                        .map((x) => DropdownMenuItem(
                                            value: x.$1,
                                            child: Text(x.$2,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis)))
                                        .toList(),
                                    onChanged: (v) {
                                      _format = v ?? 'all';
                                      _offset = 0;
                                      _load();
                                    })),
                            SizedBox(
                                width: 190,
                                child: SearchableDropdownFormField<int>(
                                  value: _employeeId ?? 0,
                                  decoration: const InputDecoration(
                                      labelText: 'Employee', isDense: true),
                                  options: [
                                    const SearchableDropdownOption(
                                        value: 0, label: 'All employees'),
                                    ..._employees
                                        .where((employee) =>
                                            int.tryParse(employee.id) != null)
                                        .map((employee) =>
                                            SearchableDropdownOption<int>(
                                              value: int.parse(employee.id),
                                              label: employee.fullName
                                                      .trim()
                                                      .isEmpty
                                                  ? employee.email
                                                  : employee.fullName.trim(),
                                            )),
                                  ],
                                  onChanged: (value) {
                                    setState(() => _employeeId =
                                        value == 0 ? null : value);
                                    _offset = 0;
                                    _load();
                                  },
                                )),
                            SizedBox(
                                width: 190,
                                child: SearchableDropdownFormField<int>(
                                  value: _worksites.any((worksite) =>
                                          worksite.id == _worksiteFilterId)
                                      ? _worksiteFilterId
                                      : 0,
                                  decoration: const InputDecoration(
                                      labelText: 'Worksite', isDense: true),
                                  options: [
                                    const SearchableDropdownOption(
                                        value: 0, label: 'All worksites'),
                                    ..._worksites.map((worksite) =>
                                        SearchableDropdownOption<int>(
                                            value: worksite.id,
                                            label: worksite.name)),
                                  ],
                                  onChanged: (value) {
                                    setState(() => _worksiteFilterId =
                                        value == 0 ? null : value);
                                    _offset = 0;
                                    _load();
                                  },
                                )),
                            SizedBox(
                                width: 190,
                                child: SearchableDropdownFormField<int>(
                                  value: _projects.any((project) =>
                                          project.id == _projectFilterId)
                                      ? _projectFilterId
                                      : 0,
                                  decoration: const InputDecoration(
                                      labelText: 'Project', isDense: true),
                                  options: [
                                    const SearchableDropdownOption(
                                        value: 0, label: 'All projects'),
                                    ..._projects.map((project) =>
                                        SearchableDropdownOption<int>(
                                            value: project.id,
                                            label: project.name)),
                                  ],
                                  onChanged: (value) {
                                    setState(() => _projectFilterId =
                                        value == 0 ? null : value);
                                    _offset = 0;
                                    _load();
                                  },
                                )),
                            SizedBox(
                                width: 190,
                                child: MyDateField(
                                    controller: _fromFilter,
                                    title: 'Date from (DD-MM-YYYY)',
                                    compact: true)),
                            SizedBox(
                                width: 190,
                                child: MyDateField(
                                    controller: _toFilter,
                                    title: 'Date to (DD-MM-YYYY)',
                                    compact: true)),
                            OutlinedButton.icon(
                                onPressed: () {
                                  _offset = 0;
                                  _load();
                                },
                                icon: const Icon(Iconsax.search_normal),
                                label: const Text('Apply'))
                          ]),
                          const SizedBox(height: 12),
                          if (_loading)
                            const LinearProgressIndicator()
                          else if (_reports.isEmpty)
                            const Padding(
                                padding: EdgeInsets.all(30),
                                child: Center(
                                    child: Text('No survey reports found.')))
                          else
                            ..._reports.map(_tile),
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
                                              _offset = (_offset - 20)
                                                  .clamp(0, _count);
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
                                ])
                        ])))
          ]);

  Widget _tile(SurveySiteReport r) => Card(
      margin: const EdgeInsets.only(top: 8),
      child: ListTile(
          leading: const Icon(Iconsax.map, color: AppColors.primary),
          title: Text(
              '${r.worksiteName.isEmpty ? 'Worksite ${r.worksiteId}' : r.worksiteName} · ${formatAppDateValue(r.date, fallback: r.date)}'),
          subtitle: Text(
              '${_title(r.status)} • ${r.employeeName} • ${r.workDataType == 'bearing_distance' ? 'Bearing / distance' : 'XYZ site points'} • Version ${r.submissionVersion}'),
          trailing: const Icon(Iconsax.arrow_right_3),
          onTap: _can('view') || (_can('view_own') && r.employeeId == _userId)
              ? () => _detail(r)
              : null));

  Future<void> _detail(SurveySiteReport listReport) async {
    if (!_can('view') &&
        (!_can('view_own') || listReport.employeeId != _userId)) {
      _toast('You do not have permission to view this survey report.');
      return;
    }
    SurveySiteReport report = listReport;
    try {
      report = await _service.getReport(
          token: await _getToken(), reportId: listReport.id);
    } catch (_) {}
    if (!mounted) return;
    showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
                title: Text('Survey Report · ${_title(report.status)}'),
                content: SizedBox(
                    width: 760,
                    child: SingleChildScrollView(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          Text('Employee: ${report.employeeName}'),
                          Text('Worksite: ${report.worksiteName}'),
                          if (report.projectName.isNotEmpty)
                            Text('Project: ${report.projectName}'),
                          if (report.taskName.isNotEmpty)
                            Text('Task: ${report.taskName}'),
                          Text(
                              'Date: ${formatAppDateValue(report.date, fallback: report.date)} • Version ${report.submissionVersion}'),
                          Text(
                              'Format: ${report.workDataType == 'bearing_distance' ? 'Bearing / distance' : 'XYZ site points'} • ${_title(report.measurementUnit)}'),
                          if (report.coordinateSystem.isNotEmpty)
                            Text(
                                'Coordinate system: ${report.coordinateSystem}'),
                          if (report.datum.isNotEmpty)
                            Text('Datum: ${report.datum}'),
                          if (report.coordinateZone.isNotEmpty)
                            Text('Zone: ${report.coordinateZone}'),
                          if (report.gpsLatitude != null &&
                              report.gpsLongitude != null)
                            Text(
                                'GPS: ${report.gpsLatitude}, ${report.gpsLongitude}'),
                          const _SurveySection('Activities'),
                          ...report.activities
                              .map((a) => Text('• ${a.description}')),
                          if (report.workDataType == 'bearing_distance') ...[
                            const _SurveySection('Bearing and distance points'),
                            ...report.bearingDistancePoints.map((p) => Text(
                                '${p.pointNumber}. ${p.azimuthDegrees}° ${p.azimuthMinutes}′ ${p.azimuthSeconds}″ · ${p.distance} ${report.measurementUnit}'))
                          ] else ...[
                            const _SurveySection('XYZ site points'),
                            ...report.xyzPoints.map((p) => Text(
                                '${p.pointNumber}. N ${p.northing} · E ${p.easting} · Z ${p.elevation}'))
                          ],
                          if (report.expenses.isNotEmpty) ...[
                            const _SurveySection('Expenses'),
                            ...report.expenses.map((e) => Text(
                                '• ${e.name} · ${_title(e.category)} · ₦${e.amount}\n  ${e.description}'))
                          ],
                          if (report.materialsUsed.isNotEmpty) ...[
                            const _SurveySection('Materials used'),
                            ...report.materialsUsed.map((m) => Text(
                                '• ${m.name} · ${m.quantityUsed} ${m.unit}'))
                          ],
                          if (report.attachments.isNotEmpty) ...[
                            const _SurveySection('Attachments'),
                            ...report.attachments.map((a) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(a.description.isEmpty
                                    ? a.url
                                    : a.description),
                                subtitle: SelectableText(a.url)))
                          ],
                          if (report.feedback.isNotEmpty) ...[
                            const _SurveySection('Review feedback'),
                            Text(report.feedback)
                          ],
                        ]))),
                actions: [
                  if ((report.status == 'draft' ||
                          report.status == 'rejected') &&
                      (_can('update') ||
                          (_can('update_own') && report.employeeId == _userId)))
                    TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _edit(report: report);
                        },
                        child: const Text('Edit')),
                  if ((report.status == 'draft' ||
                          report.status == 'rejected') &&
                      _can('submit'))
                    TextButton(
                        onPressed: () => _submit(report, dialogContext),
                        child: const Text('Submit')),
                  if (report.status == 'submitted' &&
                      report.employeeId != _userId &&
                      _can('approve'))
                    TextButton(
                        onPressed: () => _review(report,
                            approve: true, dialogContext: dialogContext),
                        child: const Text('Approve')),
                  if (report.status == 'submitted' &&
                      report.employeeId != _userId &&
                      _can('reject'))
                    TextButton(
                        onPressed: () => _review(report,
                            approve: false, dialogContext: dialogContext),
                        child: const Text('Reject')),
                  if ((report.status == 'draft' ||
                          report.status == 'rejected') &&
                      _can('delete'))
                    TextButton(
                        onPressed: () async {
                          try {
                            await _service.deleteReport(
                                token: await _getToken(), reportId: report.id);
                            if (mounted) Navigator.pop(dialogContext);
                            _load();
                          } catch (e) {
                            _toast('Could not delete report: $e');
                          }
                        },
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red))),
                  TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Close'))
                ]));
  }

  Future<void> _submit(
      SurveySiteReport report, BuildContext dialogContext) async {
    try {
      await _service.submitReport(
          token: await _getToken(), reportId: report.id);
      await _refreshInventory(report.worksiteId);
      if (mounted) Navigator.pop(dialogContext);
      await _load();
    } catch (e) {
      _toast('Submission failed: $e');
    }
  }

  Future<void> _review(SurveySiteReport report,
      {required bool approve, required BuildContext dialogContext}) async {
    final feedback = TextEditingController();
    int? rating;
    final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
                title: Text(
                    approve ? 'Approve survey report' : 'Reject survey report'),
                content: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (approve)
                    Column(children: [
                      DropdownButtonFormField<int>(
                          decoration: const InputDecoration(
                              labelText: 'Rating (optional)'),
                          items: [1, 2, 3, 4, 5]
                              .map((x) =>
                                  DropdownMenuItem(value: x, child: Text('$x')))
                              .toList(),
                          onChanged: (v) => rating = v),
                      TextField(
                          controller: feedback,
                          maxLines: 2,
                          decoration: const InputDecoration(
                              labelText: 'Feedback (optional)'))
                    ])
                  else
                    TextField(
                        controller: feedback,
                        maxLines: 3,
                        decoration: const InputDecoration(
                            labelText: 'Feedback required'))
                ]),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(c, false),
                      child: const Text('Cancel')),
                  FilledButton(
                      onPressed: () => Navigator.pop(c, true),
                      child: Text(approve ? 'Approve' : 'Reject'))
                ]));
    if (ok != true) {
      feedback.dispose();
      return;
    }
    if (!approve && feedback.text.trim().isEmpty) {
      _toast('Rejection feedback is required');
      feedback.dispose();
      return;
    }
    try {
      final token = await _getToken();
      if (approve)
        await _service.approveReport(
            token: token,
            reportId: report.id,
            rating: rating,
            feedback: feedback.text);
      else
        await _service.rejectReport(
            token: token, reportId: report.id, feedback: feedback.text);
      await _refreshInventory(report.worksiteId);
      if (mounted) Navigator.pop(dialogContext);
      await _load();
    } catch (e) {
      _toast('Review failed: $e');
    } finally {
      feedback.dispose();
    }
  }

  Future<void> _refreshInventory(int worksiteId) async {
    if (Get.isRegistered<SiteEquipmentController>()) {
      await Get.find<SiteEquipmentController>()
          .fetchEquipment(context, worksiteId: worksiteId);
    } else {
      final token = await _getToken();
      await SiteEquipmentService(baseUrl: ApiConstants.baseUrl)
          .getSiteEquipment(accessToken: token, worksiteId: worksiteId);
    }
  }

  void _toast(String message) {
    if (mounted)
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _edit({SurveySiteReport? report}) async {
    final token = await _getToken();
    if (!mounted) return;
    final saved = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SurveyReportEditor(
            token: token,
            service: _service,
            initialWorksiteId: widget.initialWorksiteId,
            initialProjectId: widget.initialProjectId,
            report: report));
    if (saved == true) _load();
  }
}

class _SurveyReportEditor extends StatefulWidget {
  const _SurveyReportEditor(
      {required this.token,
      required this.service,
      this.initialWorksiteId,
      this.initialProjectId,
      this.report});
  final String token;
  final SurveySiteReportService service;
  final int? initialWorksiteId, initialProjectId;
  final SurveySiteReport? report;
  @override
  State<_SurveyReportEditor> createState() => _SurveyReportEditorState();
}

class _SurveyReportEditorState extends State<_SurveyReportEditor> {
  final _form = GlobalKey<FormState>();
  final _worksitesService = WorksiteService(baseUrl: ApiConstants.baseUrl);
  final _projectsService = DashboardService(baseUrl: ApiConstants.baseUrl);
  final _tasksService = TaskService(baseUrl: ApiConstants.baseUrl);
  final _inventoryService = SiteEquipmentService(baseUrl: ApiConstants.baseUrl);
  final _auth = AuthService();
  final _date = TextEditingController(),
      _system = TextEditingController(),
      _datum = TextEditingController(),
      _zone = TextEditingController(),
      _lat = TextEditingController(),
      _lng = TextEditingController();
  List<Worksite> _worksites = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];
  List<SiteEquipment> _inventory = [];
  int? _worksiteId, _projectId, _taskId;
  String _dataType = 'bearing_distance', _unit = 'metres';
  bool _loading = true, _saving = false;
  final List<TextEditingController> _activities = [];
  final List<_BearingInput> _bearings = [];
  final List<_XyzInput> _xyz = [];
  final List<_ExpenseInput> _expenses = [];
  final List<_MaterialInput> _materials = [];
  final List<_AttachmentInput> _attachments = [];
  Worksite? get _selectedWorksite =>
      _worksites.where((x) => x.id == _worksiteId).firstOrNull;
  @override
  void initState() {
    super.initState();
    final r = widget.report;
    _dataType = r?.workDataType ?? 'bearing_distance';
    _unit = r?.measurementUnit ?? 'metres';
    _date.text = r == null
        ? formatAppDateValue(DateTime.now().toIso8601String())
        : formatAppDateValue(r.date, fallback: r.date);
    _system.text = r?.coordinateSystem ?? '';
    _datum.text = r?.datum ?? '';
    _zone.text = r?.coordinateZone ?? '';
    _lat.text = r?.gpsLatitude ?? '';
    _lng.text = r?.gpsLongitude ?? '';
    _worksiteId = r?.worksiteId ?? widget.initialWorksiteId;
    _projectId = r?.projectId ?? widget.initialProjectId;
    _taskId = r?.taskId;
    if (r != null) {
      _activities.addAll(
          r.activities.map((x) => TextEditingController(text: x.description)));
      _bearings.addAll(r.bearingDistancePoints.map(_BearingInput.from));
      _xyz.addAll(r.xyzPoints.map(_XyzInput.from));
      _expenses.addAll(r.expenses.map(_ExpenseInput.from));
      _materials.addAll(r.materialsUsed.map(_MaterialInput.from));
      _attachments.addAll(r.attachments.map(_AttachmentInput.from));
    }
    if (_activities.isEmpty) _activities.add(TextEditingController());
    if (_bearings.isEmpty) _bearings.add(_BearingInput());
    if (_xyz.isEmpty) _xyz.add(_XyzInput());
    _loadRefs();
  }

  @override
  void dispose() {
    for (final c in [
      _date,
      _system,
      _datum,
      _zone,
      _lat,
      _lng,
      ..._activities
    ]) {
      c.dispose();
    }
    for (final x in _bearings) x.dispose();
    for (final x in _xyz) x.dispose();
    for (final x in _expenses) x.dispose();
    for (final x in _materials) x.dispose();
    for (final x in _attachments) x.dispose();
    super.dispose();
  }

  Future<void> _loadRefs() async {
    try {
      final results = await Future.wait([
        _loadAllWorksites(),
        _loadAllProjects(),
      ]);
      _worksites = results[0] as List<Worksite>;
      _projects = results[1] as List<Project>;
      if (_worksiteId != null) await _loadContext();
    } catch (e) {
      _toast('Could not load survey references: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<List<Worksite>> _loadAllWorksites() async {
    final items = <Worksite>[];
    var offset = 0;
    while (true) {
      final page = await _worksitesService.getWorksites(
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
      final page = await _projectsService.getProjects(
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

  Future<void> _loadContext() async {
    final w = _selectedWorksite;
    _projectId = w != null && w.projectId > 0 ? w.projectId : null;
    if (w == null) {
      _tasks = [];
      _inventory = [];
      _taskId = null;
      return;
    }
    final values = await Future.wait([
      _inventoryService.getSiteEquipment(
          accessToken: widget.token, worksiteId: w.id),
      if (_projectId != null)
        _tasksService.getTasks(
            accessToken: widget.token, projectId: _projectId, limit: 500)
    ]);
    _inventory = values.first as List<SiteEquipment>;
    _tasks = values.length > 1
        ? (values.last as ({List<Task> items, int count})).items
        : [];
    if (!_tasks.any((x) => x.id == _taskId)) _taskId = null;
    if (mounted) setState(() {});
  }

  void _toast(String m) {
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final inputTheme = Theme.of(context).inputDecorationTheme.copyWith(
          filled: true,
          fillColor: AppColors.surface,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: const OutlineInputBorder(borderRadius: AppRadii.brMd),
          enabledBorder: const OutlineInputBorder(
            borderRadius: AppRadii.brMd,
            borderSide: BorderSide(color: AppColors.borderSubtle),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: AppRadii.brMd,
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
        );

    return DialogScaffold(
      title: widget.report == null
          ? 'New Survey Site Report'
          : 'Edit Survey Site Report',
      subtitle: 'Capture survey data and site activity for review.',
      size: DialogSize.xl,
      showCloseButton: true,
      scrollable: true,
      body: Theme(
        data: Theme.of(context).copyWith(inputDecorationTheme: inputTheme),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loading) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 16),
              ],
              ReportEditorSection(
                title: 'Site and schedule',
                description: 'Choose the worksite and reporting date.',
                icon: Iconsax.location,
                child: Column(
                  children: [
                    SearchableDropdownFormField<int>(
                      value: _worksites.any((x) => x.id == _worksiteId)
                          ? _worksiteId
                          : null,
                      decoration: const InputDecoration(labelText: 'Worksite*'),
                      options: _worksites
                          .map((x) => SearchableDropdownOption<int>(
                              value: x.id, label: x.name))
                          .toList(),
                      hint: const Text('Select a worksite'),
                      validator: (v) => v == null ? 'Select a worksite' : null,
                      enabled: !_loading,
                      onChanged: (v) async {
                        setState(() => _worksiteId = v);
                        await _loadContext();
                      },
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(builder: (context, constraints) {
                      final fields = [
                        InputDecorator(
                          decoration: const InputDecoration(
                              labelText: 'Project (from worksite)'),
                          child: Text(
                            _selectedWorksite == null
                                ? 'Select a worksite first'
                                : _selectedWorksite!.projectId == 0
                                    ? 'Standalone worksite'
                                    : _projects
                                            .where((p) =>
                                                p.id ==
                                                _selectedWorksite!.projectId)
                                            .map((p) => p.name)
                                            .firstOrNull ??
                                        'Project ${_selectedWorksite!.projectId}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SearchableDropdownFormField<int>(
                          value: _tasks.any((x) => x.id == _taskId)
                              ? _taskId
                              : null,
                          decoration: const InputDecoration(
                              labelText: 'Task (optional)'),
                          options: _tasks
                              .map((x) => SearchableDropdownOption<int>(
                                  value: x.id, label: x.name))
                              .toList(),
                          hint: const Text('Select a task'),
                          enabled: _projectId != null && !_loading,
                          onChanged: (v) => setState(() => _taskId = v),
                        ),
                      ];
                      if (constraints.maxWidth < 560) {
                        return Column(children: [
                          fields[0],
                          const SizedBox(height: 12),
                          fields[1],
                        ]);
                      }
                      return Row(children: [
                        Expanded(child: fields[0]),
                        const SizedBox(width: 12),
                        Expanded(child: fields[1]),
                      ]);
                    }),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: MyDateField(
                        controller: _date,
                        title: 'Date (DD-MM-YYYY)*',
                        validator: (value) => parseAppDate(value) == null
                            ? 'Enter a valid date'
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ReportEditorSection(
                title: 'Survey method and reference',
                description:
                    'Choose a measurement format, then add coordinate details.',
                icon: Iconsax.ruler,
                child: Column(
                  children: [
                    LayoutBuilder(builder: (context, constraints) {
                      final formatField = widget.report == null
                          ? DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _dataType,
                              decoration: const InputDecoration(
                                  labelText: 'Survey format*'),
                              items: const [
                                ('bearing_distance', 'Bearing and distance'),
                                ('site_points_xyz', 'XYZ / NEZ site points')
                              ]
                                  .map((x) => DropdownMenuItem(
                                        value: x.$1,
                                        child: Text(x.$2,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _dataType = v ?? _dataType),
                            )
                          : InputDecorator(
                              decoration: const InputDecoration(
                                  labelText: 'Survey format (fixed)'),
                              child: Text(
                                _dataType == 'bearing_distance'
                                    ? 'Bearing and distance'
                                    : 'XYZ / NEZ site points',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                      final unitField = DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _unit,
                        decoration: const InputDecoration(
                            labelText: 'Measurement unit'),
                        items: const [('metres', 'Metres'), ('feet', 'Feet')]
                            .map((x) => DropdownMenuItem(
                                value: x.$1, child: Text(x.$2)))
                            .toList(),
                        onChanged: (v) => setState(() => _unit = v ?? 'metres'),
                      );
                      if (constraints.maxWidth < 560) {
                        return Column(children: [
                          formatField,
                          const SizedBox(height: 12),
                          unitField,
                        ]);
                      }
                      return Row(children: [
                        Expanded(child: formatField),
                        const SizedBox(width: 12),
                        Expanded(child: unitField),
                      ]);
                    }),
                    const SizedBox(height: 12),
                    LayoutBuilder(builder: (context, constraints) {
                      final fields = [
                        _text(_system, 'Coordinate system (optional)'),
                        _text(_datum, 'Datum (optional)'),
                        _text(_zone, 'Coordinate zone (optional)'),
                      ];
                      if (constraints.maxWidth < 650) {
                        return Column(children: [
                          for (var i = 0; i < fields.length; i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            fields[i],
                          ],
                        ]);
                      }
                      return Row(children: [
                        for (var i = 0; i < fields.length; i++) ...[
                          if (i > 0) const SizedBox(width: 12),
                          Expanded(child: fields[i]),
                        ],
                      ]);
                    }),
                    const SizedBox(height: 12),
                    LayoutBuilder(builder: (context, constraints) {
                      final latitude =
                          _text(_lat, 'GPS latitude (optional)', numeric: true);
                      final longitude = _text(_lng, 'GPS longitude (optional)',
                          numeric: true);
                      if (constraints.maxWidth < 560) {
                        return Column(children: [
                          latitude,
                          const SizedBox(height: 12),
                          longitude,
                        ]);
                      }
                      return Row(children: [
                        Expanded(child: latitude),
                        const SizedBox(width: 12),
                        Expanded(child: longitude),
                      ]);
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ReportEditorSection(
                title: 'Activities',
                description: 'Describe the survey work completed on site.',
                icon: Iconsax.task_square,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ..._activities.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(children: [
                            Expanded(
                                child: TextFormField(
                                    controller: e.value,
                                    decoration: InputDecoration(
                                        labelText:
                                            'Activity ${e.key + 1} description*'),
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                            ? 'Required'
                                            : null)),
                            IconButton(
                                tooltip: 'Remove activity',
                                onPressed: _activities.length == 1
                                    ? null
                                    : () => setState(() =>
                                        _activities.removeAt(e.key).dispose()),
                                icon: const Icon(Iconsax.trash,
                                    color: AppColors.danger)),
                          ]),
                        )),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                          onPressed: () => setState(
                              () => _activities.add(TextEditingController())),
                          icon: const Icon(Iconsax.add),
                          label: const Text('Add activity')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ReportEditorSection(
                title: _dataType == 'bearing_distance'
                    ? 'Bearing and distance points'
                    : 'XYZ / NEZ survey points',
                description: _dataType == 'bearing_distance'
                    ? 'Enter a bearing and distance for each sequential point.'
                    : 'Enter northing, easting, and elevation for each point.',
                icon: Iconsax.map_1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_dataType == 'bearing_distance') ...[
                      ..._bearings
                          .asMap()
                          .entries
                          .map((e) => _bearingRow(e.key, e.value)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                            onPressed: () =>
                                setState(() => _bearings.add(_BearingInput())),
                            icon: const Icon(Iconsax.add),
                            label: const Text('Add survey point')),
                      ),
                    ] else ...[
                      ..._xyz
                          .asMap()
                          .entries
                          .map((e) => _xyzRow(e.key, e.value)),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                            onPressed: () =>
                                setState(() => _xyz.add(_XyzInput())),
                            icon: const Icon(Iconsax.add),
                            label: const Text('Add survey point')),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ReportEditorSection(
                title: 'Expenses',
                description: 'Add any costs related to this survey report.',
                icon: Iconsax.wallet_3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_expenses.isEmpty)
                      const Text('No expenses added.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ..._expenses
                        .asMap()
                        .entries
                        .map((e) => _expenseRow(e.key, e.value)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                          onPressed: () =>
                              setState(() => _expenses.add(_ExpenseInput())),
                          icon: const Icon(Iconsax.add),
                          label: const Text('Add expense')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ReportEditorSection(
                title: 'Materials used',
                description: 'Materials are selected from site inventory.',
                icon: Iconsax.box,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_inventory.isEmpty)
                      const Text(
                          'No inventory found for the selected worksite.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ..._materials
                        .asMap()
                        .entries
                        .map((e) => _materialRow(e.key, e.value)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                          onPressed: _inventory.isEmpty
                              ? null
                              : () => setState(() => _materials
                                  .add(_MaterialInput(_inventory.first.id))),
                          icon: const Icon(Iconsax.add),
                          label: const Text('Add material')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ReportEditorSection(
                title: 'Attachments',
                description: 'Add links or upload supporting files.',
                icon: Iconsax.document_upload,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_attachments.isEmpty)
                      const Text('No attachments added.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ..._attachments
                        .asMap()
                        .entries
                        .map((e) => _attachmentRow(e.key, e.value)),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                          onPressed: () => setState(
                              () => _attachments.add(_AttachmentInput())),
                          icon: const Icon(Iconsax.add),
                          label: const Text('Add attachment')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Iconsax.document_download, size: 17),
          label: Text(widget.report == null ? 'Save Draft' : 'Save Changes'),
        ),
      ],
    );
  }

  Widget _text(TextEditingController c, String label,
          {bool numeric = false, String? Function(String?)? validator}) =>
      Padding(
          padding: const EdgeInsets.only(top: 8),
          child: TextFormField(
              controller: c,
              keyboardType: numeric
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              validator: validator ??
                  (numeric
                      ? (v) => v == null ||
                              v.trim().isEmpty ||
                              double.tryParse(v) != null
                          ? null
                          : 'Enter a valid number'
                      : null),
              decoration: InputDecoration(
                  labelText: label,
                  border: const OutlineInputBorder(borderRadius: AppRadii.brMd),
                  isDense: true)));
  Widget _bearingRow(int i, _BearingInput p) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
          padding: const EdgeInsets.all(8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Point ${i + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                  child: _numeric(p.degrees, 'Degrees',
                      integer: true, min: 0, max: 359)),
              Expanded(
                  child: _numeric(p.minutes, 'Minutes',
                      integer: true, min: 0, max: 59)),
              Expanded(child: _numeric(p.seconds, 'Seconds')),
              Expanded(
                  child:
                      _numeric(p.distance, 'Distance', minExclusiveZero: true)),
              IconButton(
                  onPressed: _bearings.length == 1
                      ? null
                      : () => setState(() => _bearings.removeAt(i).dispose()),
                  icon: const Icon(Iconsax.trash, color: Colors.red))
            ])
          ])));
  Widget _xyzRow(int i, _XyzInput p) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(children: [
            Expanded(child: _numeric(p.northing, 'Northing')),
            Expanded(child: _numeric(p.easting, 'Easting')),
            Expanded(child: _numeric(p.elevation, 'Elevation')),
            IconButton(
                onPressed: _xyz.length == 1
                    ? null
                    : () => setState(() => _xyz.removeAt(i).dispose()),
                icon: const Icon(Iconsax.trash, color: Colors.red))
          ])));
  Widget _numeric(TextEditingController c, String label,
          {bool integer = false,
          int? min,
          int? max,
          bool minExclusiveZero = false}) =>
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: TextFormField(
              controller: c,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  labelText: label,
                  border:
                      const OutlineInputBorder(borderRadius: AppRadii.brMd)),
              validator: (v) {
                final value = double.tryParse(v ?? '');
                if (value == null) return 'Required number';
                if (integer && value.roundToDouble() != value)
                  return 'Whole number required';
                if (min != null && value < min || max != null && value > max)
                  return 'Out of range';
                if (minExclusiveZero && value <= 0) return 'Must be > 0';
                return null;
              }));
  Widget _expenseRow(int i, _ExpenseInput e) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: DropdownButtonFormField<String>(
                      value: e.category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        ('labour', 'Labour'),
                        ('material_equipment', 'Material / equipment')
                      ]
                          .map((x) =>
                              DropdownMenuItem(value: x.$1, child: Text(x.$2)))
                          .toList(),
                      onChanged: (v) => e.category = v ?? e.category)),
              Expanded(
                  child: TextFormField(
                      controller: e.name,
                      decoration: const InputDecoration(labelText: 'Name*'),
                      validator: _required)),
              Expanded(
                  child: TextFormField(
                      controller: e.amount,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Amount*'),
                      validator: (v) {
                        final x = double.tryParse(v ?? '');
                        return x == null || x <= 0
                            ? 'Enter an amount > 0'
                            : null;
                      })),
              IconButton(
                  onPressed: () =>
                      setState(() => _expenses.removeAt(i).dispose()),
                  icon: const Icon(Iconsax.trash, color: Colors.red))
            ]),
            const SizedBox(height: 12),
            TextFormField(
                controller: e.description,
                decoration:
                    const InputDecoration(labelText: 'Expense description*'),
                validator: _required)
          ])));
  Widget _materialRow(int i, _MaterialInput m) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Expanded(
            child: SearchableDropdownFormField<int>(
                value: _inventory.any((x) => x.id == m.id) ? m.id : null,
                decoration: const InputDecoration(labelText: 'Inventory item'),
                options: _inventory
                    .map((x) => SearchableDropdownOption<int>(
                        value: x.id,
                        label: '${x.name} (${x.quantity} ${x.unit})'))
                    .toList(),
                hint: const Text('Select an inventory item'),
                validator: (v) => v == null ? 'Select inventory item' : null,
                onChanged: (v) => m.id = v ?? m.id)),
        SizedBox(
            width: 155,
            child: TextFormField(
                controller: m.quantity,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Quantity used*'),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  final available = double.tryParse(_inventory
                          .where((item) => item.id == m.id)
                          .map((item) => item.quantity)
                          .firstOrNull ??
                      '');
                  if (n == null || n <= 0) return 'Enter quantity > 0';
                  if (available != null && n > available) {
                    return 'Exceeds available stock ($available)';
                  }
                  return null;
                })),
        IconButton(
            onPressed: () => setState(() => _materials.removeAt(i).dispose()),
            icon: const Icon(Iconsax.trash, color: Colors.red))
      ]));
  Widget _attachmentRow(int i, _AttachmentInput a) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: Text(a.url.isEmpty ? 'No file uploaded' : a.url,
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
              TextButton.icon(
                  onPressed: () => _upload(a),
                  icon: const Icon(Iconsax.document_upload),
                  label: const Text('Upload file')),
              IconButton(
                  onPressed: () =>
                      setState(() => _attachments.removeAt(i).dispose()),
                  icon: const Icon(Iconsax.trash, color: Colors.red))
            ]),
            TextFormField(
                controller: a.urlController,
                decoration: const InputDecoration(labelText: 'Attachment URL*'),
                validator: (v) => v == null || !isValidSurveyAttachmentUrl(v)
                    ? 'Enter a valid HTTP or HTTPS URL'
                    : null),
            const SizedBox(height: 12),
            TextFormField(
                controller: a.description,
                decoration: const InputDecoration(labelText: 'Description'))
          ])));
  Future<void> _upload(_AttachmentInput a) async {
    try {
      final f = await FilePicker.platform.pickFiles(withData: true);
      if (f == null || f.files.single.bytes == null) return;
      final url = await _auth.uploadFile(
          widget.token, f.files.single.bytes!, f.files.single.name);
      setState(() => a.urlController.text = url);
    } catch (e) {
      _toast('Upload failed: $e');
    }
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? 'Required' : null;
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if ((_lat.text.trim().isEmpty) != (_lng.text.trim().isEmpty)) {
      _toast('Enter both GPS latitude and longitude, or leave both empty.');
      return;
    }
    final pointsOkay = _dataType == 'bearing_distance'
        ? _bearings.every((x) =>
            double.tryParse(x.seconds.text) != null &&
            double.parse(x.seconds.text) < 60 &&
            double.parse(x.seconds.text) >= 0 &&
            double.tryParse(x.distance.text) != null &&
            double.parse(x.distance.text) > 0)
        : _xyz.every((x) => [x.northing, x.easting, x.elevation]
            .every((c) => double.tryParse(c.text) != null));
    if (!pointsOkay) {
      _toast('Check the survey measurements and values.');
      return;
    }
    setState(() => _saving = true);
    final r = SurveySiteReport(
        id: widget.report?.id ?? 0,
        reportType: 'survey_site',
        employeeId: widget.report?.employeeId ?? 0,
        employeeName: widget.report?.employeeName ?? '',
        status: widget.report?.status ?? 'draft',
        worksiteId: _worksiteId!,
        worksiteName: _selectedWorksite?.name ?? '',
        projectId: _projectId,
        projectName: '',
        taskId: _taskId,
        taskName: '',
        date: appDateToApiDate(_date.text) ?? _date.text,
        workDataType: _dataType,
        measurementUnit: _unit,
        coordinateSystem: _system.text.trim(),
        datum: _datum.text.trim(),
        coordinateZone: _zone.text.trim(),
        gpsLatitude: _lat.text.trim().isEmpty ? null : _lat.text.trim(),
        gpsLongitude: _lng.text.trim().isEmpty ? null : _lng.text.trim(),
        activities: _activities
            .map((c) => SurveyActivity(description: c.text.trim()))
            .toList(),
        expenses: _expenses
            .map((e) => SurveyExpenseLine(
                category: e.category,
                name: e.name.text.trim(),
                amount: double.parse(e.amount.text).toStringAsFixed(2),
                description: e.description.text.trim()))
            .toList(),
        materialsUsed: _materials
            .map((m) => SurveyMaterialUsed(
                equipmentId: m.id,
                quantityUsed: double.parse(m.quantity.text).toStringAsFixed(3)))
            .toList(),
        attachments: _attachments
            .map((a) => SurveyAttachment(
                url: a.urlController.text.trim(),
                description: a.description.text.trim()))
            .toList(),
        bearingDistancePoints: _dataType == 'bearing_distance'
            ? List.generate(_bearings.length, (i) {
                final p = _bearings[i];
                return BearingDistancePoint(
                    pointNumber: i + 1,
                    azimuthDegrees: int.parse(p.degrees.text),
                    azimuthMinutes: int.parse(p.minutes.text),
                    azimuthSeconds:
                        double.parse(p.seconds.text).toStringAsFixed(2),
                    distance: double.parse(p.distance.text).toStringAsFixed(3));
              })
            : [],
        xyzPoints: _dataType == 'site_points_xyz'
            ? List.generate(_xyz.length, (i) {
                final p = _xyz[i];
                return XyzSurveyPoint(
                    pointNumber: i + 1,
                    northing: double.parse(p.northing.text).toString(),
                    easting: double.parse(p.easting.text).toString(),
                    elevation: double.parse(p.elevation.text).toString());
              })
            : [],
        submissionVersion: widget.report?.submissionVersion ?? 0,
        createdAt: '',
        updatedAt: '');
    try {
      if (widget.report == null)
        await widget.service.createReport(token: widget.token, report: r);
      else
        await widget.service.updateReport(
            token: widget.token, reportId: widget.report!.id, report: r);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _toast('Could not save report: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _BearingInput {
  final degrees = TextEditingController(text: '0'),
      minutes = TextEditingController(text: '0'),
      seconds = TextEditingController(text: '0'),
      distance = TextEditingController();
  _BearingInput();
  factory _BearingInput.from(BearingDistancePoint p) => _BearingInput()
    ..degrees.text = '${p.azimuthDegrees}'
    ..minutes.text = '${p.azimuthMinutes}'
    ..seconds.text = p.azimuthSeconds
    ..distance.text = p.distance;
  void dispose() {
    for (final c in [degrees, minutes, seconds, distance]) {
      c.dispose();
    }
  }
}

class _XyzInput {
  final northing = TextEditingController(),
      easting = TextEditingController(),
      elevation = TextEditingController();
  _XyzInput();
  factory _XyzInput.from(XyzSurveyPoint p) => _XyzInput()
    ..northing.text = p.northing
    ..easting.text = p.easting
    ..elevation.text = p.elevation;
  void dispose() {
    for (final c in [northing, easting, elevation]) {
      c.dispose();
    }
  }
}

class _ExpenseInput {
  String category = 'labour';
  final name = TextEditingController(),
      amount = TextEditingController(),
      description = TextEditingController();
  _ExpenseInput();
  factory _ExpenseInput.from(SurveyExpenseLine e) => _ExpenseInput()
    ..category = e.category
    ..name.text = e.name
    ..amount.text = e.amount
    ..description.text = e.description;
  void dispose() {
    for (final c in [name, amount, description]) {
      c.dispose();
    }
  }
}

class _MaterialInput {
  _MaterialInput(this.id);
  factory _MaterialInput.from(SurveyMaterialUsed m) =>
      _MaterialInput(m.equipmentId)..quantity.text = m.quantityUsed;
  int id;
  final quantity = TextEditingController();
  void dispose() => quantity.dispose();
}

class _AttachmentInput {
  final urlController = TextEditingController(),
      description = TextEditingController();
  String get url => urlController.text;
  _AttachmentInput();
  factory _AttachmentInput.from(SurveyAttachment a) => _AttachmentInput()
    ..urlController.text = a.url
    ..description.text = a.description;
  void dispose() {
    urlController.dispose();
    description.dispose();
  }
}

class _SurveySection extends StatelessWidget {
  const _SurveySection(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Text(text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)));
}

String _title(String x) => x
    .split('_')
    .map((p) => p.isEmpty ? p : '${p[0].toUpperCase()}${p.substring(1)}')
    .join(' ');
