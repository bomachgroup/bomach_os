import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/section/responsive_stat_row.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/hr/controller/work_report_controller.dart';
import 'package:bomach_os/pages/hr/models/work_report_model.dart';
import 'package:bomach_os/pages/hr/widget/daily_work_report_dialog.dart';
import 'package:bomach_os/pages/hr/widget/work_report_review_dialog.dart';
import 'package:bomach_os/pages/operations/engineering_site_reports.dart';
import 'package:bomach_os/pages/operations/models/engineering_site_report_model.dart';
import 'package:bomach_os/pages/operations/models/survey_site_report_model.dart';
import 'package:bomach_os/pages/operations/survey_site_reports.dart';
import 'package:bomach_os/src/services/operations/engineering_site_report_service.dart';
import 'package:bomach_os/src/services/operations/survey_site_report_service.dart';
import 'package:bomach_os/pages/auth/controller.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MyWorkReportsPage extends StatefulWidget {
  const MyWorkReportsPage({super.key});

  @override
  State<MyWorkReportsPage> createState() => _MyWorkReportsPageState();
}

class _MyWorkReportsPageState extends State<MyWorkReportsPage> {
  final WorkReportController controller = Get.put(WorkReportController());
  final _storage = const FlutterSecureStorage();

  String _selectedFilter = 'all';
  List<UnifiedReportSummary> _engineeringReports = [];
  List<SurveyUnifiedReport> _surveyReports = [];

  PermissionService get _permissions => Get.isRegistered<PermissionService>()
      ? Get.find<PermissionService>()
      : PermissionService();
  bool get _canListSurvey =>
      _permissions.has(Perms.surveySiteReportsList) ||
      _permissions.has(Perms.surveySiteReportsListOwn);
  bool get _canViewSurvey =>
      _permissions.has(Perms.surveySiteReportsView) ||
      _permissions.has(Perms.surveySiteReportsViewOwn);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await _getToken();
    if (token != null) {
      controller.fetchReports(token);
      final storedId = await _storage.read(key: 'user_id');
      final employeeId = (Get.isRegistered<AuthController>()
              ? Get.find<AuthController>().currentUser.value?.userId
              : null) ??
          int.tryParse(storedId ?? '');
      try {
        final reportService = EngineeringSiteReportService();
        final firstPage = await reportService.listUnifiedReports(
            accessToken: token, limit: 100);
        final allFeed = [...firstPage.items];
        for (var offset = 100; offset < firstPage.count; offset += 100) {
          final page = await reportService.listUnifiedReports(
              accessToken: token, limit: 100, offset: offset);
          allFeed.addAll(page.items);
        }
        if (mounted)
          setState(() => _engineeringReports = allFeed
              .where((r) =>
                  r.reportType == 'engineering_site' &&
                  employeeId != null &&
                  r.employeeId == employeeId)
              .toList());
      } catch (_) {
        if (mounted) setState(() => _engineeringReports = []);
      }
      if (_canListSurvey) {
        try {
          final surveyService = SurveySiteReportService();
          final surveyPage =
              await surveyService.listUnifiedReports(token: token, limit: 100);
          final surveyFeed = [...surveyPage.items];
          for (var offset = 100; offset < surveyPage.count; offset += 100) {
            final page = await surveyService.listUnifiedReports(
                token: token, limit: 100, offset: offset);
            surveyFeed.addAll(page.items);
          }
          if (mounted) {
            setState(() => _surveyReports = surveyFeed
                .where((r) => employeeId != null && r.employeeId == employeeId)
                .toList());
          }
        } catch (_) {
          if (mounted) setState(() => _surveyReports = []);
        }
      } else if (mounted) {
        setState(() => _surveyReports = []);
      }
    }
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  List<WorkReport> get _filteredReports {
    if (_selectedFilter == 'all') return controller.workReports;
    return controller.workReports
        .where((r) => r.status.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      gap: 16,
      scrollable: true,
      children: [
        _buildPageHeader(),
        const SizedBox(height: 20),
        _buildSummaryCards(),
        const SizedBox(height: 20),
        _buildFilterBar(),
        const SizedBox(height: 16),
        _buildReportsTable(),
        const SizedBox(height: 18),
        _buildEngineeringReports(),
        if (_canListSurvey) _buildSurveyReports(),
      ],
    );
  }

  Widget _buildSurveyReports() {
    final reports = _selectedFilter == 'all'
        ? _surveyReports
        : _surveyReports
            .where((r) => r.status.toLowerCase() == _selectedFilter)
            .toList();
    return Container(
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral100)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Padding(
            padding: EdgeInsets.all(18),
            child: Row(children: [
              Icon(Iconsax.map, color: AppColors.info),
              SizedBox(width: 10),
              Text('Survey Site Reports',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral800))
            ])),
        const Divider(height: 1),
        if (reports.isEmpty)
          const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No survey site reports in your reports feed.'))
        else
          ...reports.map((report) => ListTile(
                leading:
                    const Icon(Iconsax.document_text, color: AppColors.info),
                title: Text(
                    report.summary.isEmpty
                        ? 'Survey Site Report'
                        : report.summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                subtitle: Text(
                    'Survey Site · ${report.employeeName} · ${report.status}'),
                trailing: const Icon(Iconsax.arrow_right_3),
                onTap: _canViewSurvey
                    ? () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            SurveySiteReportsPage(initialReportId: report.id)))
                    : null,
              )),
      ]),
    );
  }

  Widget _buildEngineeringReports() {
    final reports = _selectedFilter == 'all'
        ? _engineeringReports
        : _engineeringReports
            .where((r) => r.status.toLowerCase() == _selectedFilter)
            .toList();
    return Container(
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral100)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Padding(
            padding: EdgeInsets.all(18),
            child: Row(children: [
              Icon(Iconsax.buildings_2, color: AppColors.info),
              SizedBox(width: 10),
              Text('Engineering Site Reports',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral800))
            ])),
        const Divider(height: 1),
        if (reports.isEmpty)
          const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No engineering site reports in your reports feed.'))
        else
          ...reports.map((report) => ListTile(
                leading:
                    const Icon(Iconsax.document_text, color: AppColors.info),
                title: Text(
                    report.summary.isEmpty
                        ? 'Engineering Site Report'
                        : report.summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                subtitle: Text(
                    'Engineering Site · ${report.employeeName} · ${report.status}'),
                trailing: const Icon(Iconsax.arrow_right_3),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => EngineeringSiteReportsPage(
                        initialReportId: report.id))),
              )),
      ]),
    );
  }

  Widget _buildPageHeader() {
    final title = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Iconsax.document_text,
              color: AppColors.info, size: 24),
        ),
        const SizedBox(width: 14),
        const Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText('My Work Reports',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral800)),
              SizedBox(height: 2),
              MyText('Submit and track your daily work reports',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.neutral400)),
            ],
          ),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Iconsax.refresh,
                color: AppColors.neutral500, size: 22),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ),
        MyElevatedButton(
          icon: const Icon(Iconsax.add, color: AppColors.white, size: 20),
          child: "New Report",
          borderCurve: 12,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          onTap: () async {
            final token = await _getToken();
            if (token != null && context.mounted) {
              showDialog(
                context: context,
                builder: (context) => DailyWorkReportDialog(token: token),
              );
            }
          },
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [title, const SizedBox(height: 12), actions],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: title), actions],
        );
      },
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      final all = controller.workReports.length;
      final submitted = controller.workReports
          .where((r) => r.status.toLowerCase() == 'submitted')
          .length;
      final approved = controller.workReports
          .where((r) => r.status.toLowerCase() == 'approved')
          .length;
      final rejected = controller.workReports
          .where((r) => r.status.toLowerCase() == 'rejected')
          .length;

      return ResponsiveStatRow(
        cards: [
          _buildSummaryCard('Total Reports', '$all', Iconsax.document_text,
              const Color(0xFF6366F1)),
          _buildSummaryCard(
              'Pending Review', '$submitted', Iconsax.clock, AppColors.info),
          _buildSummaryCard(
              'Approved', '$approved', Iconsax.tick_circle, AppColors.success),
          _buildSummaryCard(
              'Rejected', '$rejected', Iconsax.close_circle, AppColors.danger),
        ],
      );
    });
  }

  Widget _buildSummaryCard(
      String label, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(count,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral800)),
                MyText(label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      {
        'key': 'all',
        'label': 'All Reports',
        'icon': Iconsax.task_square,
        'color': const Color(0xFF6366F1)
      },
      {
        'key': 'submitted',
        'label': 'Pending Review',
        'icon': Iconsax.clock,
        'color': AppColors.info
      },
      {
        'key': 'approved',
        'label': 'Approved',
        'icon': Iconsax.tick_circle,
        'color': AppColors.success
      },
      {
        'key': 'rejected',
        'label': 'Rejected',
        'icon': Iconsax.close_circle,
        'color': AppColors.danger
      },
      {
        'key': 'draft',
        'label': 'Draft',
        'icon': Iconsax.edit_2,
        'color': AppColors.neutral500
      },
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final row = Row(
            children: filters.map((f) {
              final isActive = _selectedFilter == f['key'];
              final color = f['color'] as Color;
              return Expanded(
                child: InkWell(
                  onTap: () =>
                      setState(() => _selectedFilter = f['key'] as String),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          f['icon'] as IconData,
                          size: 16,
                          color: isActive ? color : AppColors.neutral400,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: MyText(
                            f['label'] as String,
                            isSelectable: false,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500,
                              color: isActive
                                  ? AppColors.neutral800
                                  : AppColors.neutral400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
          if (constraints.maxWidth < 600) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: 620, child: row),
            );
          }
          return row;
        },
      ),
    );
  }

  Widget _buildReportsTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final reports = _filteredReports;

        if (reports.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(60),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Iconsax.document_text,
                        size: 48, color: AppColors.neutral400),
                  ),
                  const SizedBox(height: 16),
                  MyText(
                    _selectedFilter == 'all'
                        ? 'No work reports found'
                        : 'No $_selectedFilter reports',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral500),
                  ),
                  const SizedBox(height: 6),
                  const MyText('Submit a new report to get started',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.neutral400)),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: reports.map((r) => _buildMobileCard(r)).toList(),
          ),
        );
      }),
    );
  }

  Widget _buildMobileCard(WorkReport report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.calendar_1,
                      size: 16, color: AppColors.info),
                  const SizedBox(width: 6),
                  MyText(
                    report.day != null
                        ? DateFormat('dd-MM-yyyy').format(report.day!)
                        : '-',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral800,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(report.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: MyText(
                  '${report.hoursWorked.toStringAsFixed(1)} hrs',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6366F1)),
                ),
              ),
              _buildRating(report.rating ?? 0),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Base: ${report.operationalBase ?? '-'}',
            style: const TextStyle(fontSize: 13, color: AppColors.neutral600),
          ),
          const SizedBox(height: 6),
          Text(
            'Activities: ${report.workActivities ?? '-'}',
            style: const TextStyle(fontSize: 13, color: AppColors.neutral600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            'Task details: ${report.taskDetails ?? '-'}',
            style: const TextStyle(fontSize: 13, color: AppColors.neutral600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.neutral200),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: _buildActionMenu(report),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    final icon = _getStatusIcon(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          MyText(
              status.isNotEmpty
                  ? status[0].toUpperCase() + status.substring(1)
                  : 'Unknown',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRating(int rating) {
    if (rating == 0) {
      return const MyText('\u2014',
          style: TextStyle(color: AppColors.neutral400));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          return Icon(
            i < rating ? Iconsax.star1 : Iconsax.star,
            color: i < rating ? AppColors.warning : AppColors.neutral200,
            size: 18,
          );
        }),
        const SizedBox(width: 6),
        MyText('$rating/5',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral600)),
      ],
    );
  }

  Widget _buildActionMenu(WorkReport report) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Iconsax.more, size: 18, color: AppColors.neutral500),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      onSelected: (value) async {
        final token = await _getToken();
        if (token == null || !context.mounted) return;

        if (value == 'view') {
          await _openReportDetails(report, token);
        } else if (value == 'edit') {
          await _openReportForEdit(report, token);
        }
      },
      itemBuilder: (context) => [
        _buildMenuItem(
            Iconsax.eye, 'View Details', 'view', const Color(0xFF6366F1)),
        if (report.status.toLowerCase() == 'draft' ||
            report.status.toLowerCase() == 'rejected')
          _buildMenuItem(
              Iconsax.edit, 'Edit & Resubmit', 'edit', AppColors.info),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
      IconData icon, String label, String value, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.neutral700)),
        ],
      ),
    );
  }

  Future<void> _openReportDetails(WorkReport report, String token) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    try {
      final fullReport = await controller.getReportForViewing(token, report);
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
        context: context,
        builder: (context) => WorkReportReviewDialog(
          report: fullReport,
          token: token,
          employeeName: controller.employeeDisplayName(fullReport.employeeId),
        ),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        AppToast.error(context, 'View report failed. Please try again.');
      }
    }
  }

  Future<void> _openReportForEdit(WorkReport report, String token) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );

    try {
      final fullReport = await controller.getReportForViewing(token, report);
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();
      showDialog(
        context: context,
        builder: (context) =>
            DailyWorkReportDialog(existingReport: fullReport, token: token),
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        AppToast.error(context, 'Edit report failed. Please try again.');
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'submitted':
        return AppColors.info;
      case 'draft':
        return AppColors.neutral500;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.neutral400;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Iconsax.tick_circle;
      case 'submitted':
        return Iconsax.clock;
      case 'draft':
        return Iconsax.edit_2;
      case 'rejected':
        return Iconsax.close_circle;
      default:
        return Iconsax.record;
    }
  }
}
