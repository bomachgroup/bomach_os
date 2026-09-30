import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/hr/widget/daily_work_report_dialog.dart';
import 'package:bomach_os/pages/hr/widget/work_report_review_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'controller/work_report_controller.dart';
import 'models/work_report_model.dart';

class WorkReportPage extends StatefulWidget {
  const WorkReportPage({super.key});

  @override
  State<WorkReportPage> createState() => _WorkReportPageState();
}

class _WorkReportPageState extends State<WorkReportPage> {
  final WorkReportController controller = Get.put(WorkReportController());
  final _storage = const FlutterSecureStorage();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await _getToken(context);
    if (token != null) {
      controller.fetchReports(token);
    }
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<WorkReport> _filtered(List<WorkReport> reports) {
    if (_searchQuery.isEmpty) return reports;
    final q = _searchQuery.toLowerCase();
    return reports.where((r) {
      return r.employeeId.toString().toLowerCase().contains(q) ||
          controller
              .employeeDisplayName(r.employeeId)
              .toLowerCase()
              .contains(q) ||
          (r.operationalBase ?? '').toLowerCase().contains(q) ||
          (r.workActivities ?? '').toLowerCase().contains(q) ||
          r.status.toLowerCase().contains(q);
    }).toList();
  }

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return StatusTone.success;
      case 'submitted':
        return StatusTone.info;
      case 'rejected':
        return StatusTone.danger;
      case 'pending_review':
      case 'revision_requested':
        return StatusTone.warning;
      case 'draft':
      default:
        return StatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Daily Work Reports',
        subtitle: 'Track and manage employee work activities',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'Submit Report',
          onTap: () async {
            final token = await _getToken(context);
            if (token != null && mounted) {
              showDialog(
                context: context,
                builder: (c) => DailyWorkReportDialog(token: token),
              );
            }
          },
        ),
      ),
      children: [
        _buildToolbar(),
        Obx(() {
          final loading =
              controller.isLoading.value && controller.workReports.isEmpty;
          final filtered = _filtered(controller.workReports);
          final isEmpty = !loading && filtered.isEmpty;

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
            filtered: filtered,
            body: _buildTable(filtered),
          );
        }),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: Row(
        children: [
          Expanded(
            child: MyTextFormField(
              controller: _searchController,
              hintText: 'Search by employee, base or activity',
              height: 48,
              leading: const Icon(Iconsax.search_normal,
                  size: 18, color: AppColors.textMuted),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppColors.surface,
            borderRadius: AppRadii.brMd,
            child: InkWell(
              onTap: _loadData,
              borderRadius: AppRadii.brMd,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: AppRadii.brMd,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Icon(Iconsax.refresh,
                    size: 18, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard({
    required bool loading,
    required bool isEmpty,
    required List<WorkReport> filtered,
    required Widget body,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reports timeline', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        loading
                            ? 'Loading work reports...'
                            : '${filtered.length} report${filtered.length == 1 ? '' : 's'} on record',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Daily submissions',
                  tone: StatusTone.primary,
                  icon: Iconsax.task_square,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          if (loading)
            Padding(
              padding: const EdgeInsets.all(20),
              child: LoadingSkeleton.listRows(count: 5),
            )
          else if (isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.task_square,
                title: 'No work reports found',
                subtitle:
                    'Employees submit daily reports here for review and feedback.',
              ),
            )
          else
            body,
        ],
      ),
    );
  }

  Widget _buildTable(List<WorkReport> reports) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Employee', flex: 2),
              _buildHeaderCell('Date', flex: 2),
              _buildHeaderCell('Hours', flex: 1),
              _buildHeaderCell('Submitted', flex: 2),
              _buildHeaderCell('Updated', flex: 2),
              _buildHeaderCell('Status', flex: 2),
              _buildHeaderCell('', width: 48),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...reports.map(_buildDataRow),
      ],
    );
  }

  Widget _buildHeaderCell(String label, {double? width, int? flex}) {
    final content = Text(
      label,
      style: AppTextStyles.bodySm.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
    if (width != null) return SizedBox(width: width, child: content);
    return Expanded(flex: flex ?? 1, child: content);
  }

  Widget _buildDataRow(WorkReport report) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.employeeDisplayName(report.employeeId),
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  (report.workActivities?.trim().isNotEmpty ?? false)
                      ? report.workActivities!
                          .split('\n')
                          .firstWhere((l) => l.trim().isNotEmpty,
                              orElse: () => report.workActivities!)
                          .trim()
                      : 'No activity summary',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              report.day != null
                  ? DateFormat('dd-MM-yyyy').format(report.day!)
                  : '—',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${report.hoursWorked.toStringAsFixed(1)} hrs',
              style:
                  AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              report.createdAt != null
                  ? DateFormat('dd-MM-yyyy HH:mm').format(report.createdAt!)
                  : '—',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              report.updatedAt != null
                  ? DateFormat('dd-MM-yyyy HH:mm').format(report.updatedAt!)
                  : '—',
              style:
                  AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: report.status,
                tone: _statusTone(report.status),
                dense: true,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildActionMenu(context, report),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, WorkReport report) {
    return PopupMenuButton<String>(
      tooltip: 'Actions',
      icon: const Icon(Iconsax.more, size: 18, color: AppColors.textSecondary),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
      onSelected: (String result) async {
        final token = await _getToken(context);
        if (token == null || !context.mounted) return;

        if (result == 'view') {
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
            final fullReport =
                await controller.getReportForViewing(token, report);
            if (mounted) {
              Navigator.of(context, rootNavigator: true).pop();
              showDialog<void>(
                context: context,
                builder: (context) => WorkReportReviewDialog(
                  report: fullReport,
                  token: token,
                  employeeName:
                      controller.employeeDisplayName(fullReport.employeeId),
                ),
              );
            }
          } catch (e) {
            debugPrint("View Error: $e");
            if (mounted) {
              Navigator.of(context, rootNavigator: true).pop();
              AppToast.error(context, 'View report failed. Please try again.');
            }
          }
        } else if (result == 'edit') {
          await _openReportForEdit(report, token);
        } else if (result == 'delete') {
          await controller.deleteReport(token, report.id);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'view',
          child: Row(
            children: [
              Icon(Iconsax.task_square, size: 18),
              SizedBox(width: 8),
              Text('Review / View'),
            ],
          ),
        ),
        if (report.status.toLowerCase() == 'draft' ||
            report.status.toLowerCase() == 'rejected')
          const PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(Iconsax.edit, size: 18),
                SizedBox(width: 8),
                Text('Edit Report'),
              ],
            ),
          ),
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Iconsax.trash, size: 18, color: AppColors.danger),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: AppColors.danger)),
            ],
          ),
        ),
      ],
    );
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
      showDialog<void>(
        context: context,
        builder: (context) =>
            DailyWorkReportDialog(existingReport: fullReport, token: token),
      );
    } catch (e) {
      debugPrint('Edit Error: $e');
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();
      AppToast.error(context, 'Edit report failed. Please try again.');
    }
  }
}
