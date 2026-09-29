import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/company_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'controllers/company_controller.dart';

/// Audit log page — read-only list of every system activity logged for
/// compliance tracking. Columns: actor (user), activity, audit type,
/// status, IP, and timestamp.
class AuditLogPage extends StatefulWidget {
  const AuditLogPage({super.key});

  @override
  State<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage> {
  final CompanyController controller = Get.put(CompanyController());
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _userId = '';
  String? _auditType;
  String? _auditStatus;
  String? _startDate;
  String? _endDate;

  @override
  void initState() {
    super.initState();
    controller.fetchAuditLogs(page: 0);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('MMM d, yyyy  h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  List<AuditLog> _filtered(List<AuditLog> logs) {
    if (_searchQuery.isEmpty) return logs;
    final q = _searchQuery.toLowerCase();
    return logs.where((l) {
      return l.activity.toLowerCase().contains(q) ||
          l.userEmail.toLowerCase().contains(q) ||
          l.userFullName.toLowerCase().contains(q) ||
          l.auditTypeDisplay.toLowerCase().contains(q) ||
          l.ipAddress.contains(q);
    }).toList();
  }

  StatusTone _typeTone(String type) {
    switch (type) {
      case 'login':
        return StatusTone.primary;
      case 'create':
        return StatusTone.success;
      case 'update':
        return StatusTone.warning;
      case 'delete':
        return StatusTone.danger;
      case 'logout':
      default:
        return StatusTone.neutral;
    }
  }

  StatusTone _statusTone(String status) {
    switch (status) {
      case 'success':
        return StatusTone.success;
      case 'failure':
      case 'failed':
        return StatusTone.danger;
      default:
        return StatusTone.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: const PageHeader(
        title: 'Audit Log',
        subtitle: 'Track all changes and activities in the system.',
      ),
      children: [
        _buildToolbar(),
        Obx(() {
          final loading =
              controller.isAuditLoading.value && controller.auditLogs.isEmpty;
          final filtered = _filtered(controller.auditLogs);
          final isEmpty = !controller.isAuditLoading.value && filtered.isEmpty;

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
            body: _buildAuditTable(filtered),
            footer: _searchQuery.isEmpty
                ? _tablePaginator(
                    Obx(() => PaginatorFooter(
                          totalItems: controller.auditLogsTotal.value,
                          limit: CompanyController.auditPageSize,
                          currentPage: controller.auditPage.value + 1,
                          onPageChanged: (page) =>
                              controller.fetchAuditLogs(page: page - 1),
                        )),
                  )
                : null,
          );
        }),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyTextFormField(
            controller: _searchController,
            hintText: 'Search by user, activity, type or IP address',
            height: 48,
            leading: const Icon(Iconsax.search_normal,
                size: 18, color: AppColors.textMuted),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 12),
          AuditLogFilterBar(
            onChanged: (userId, auditType, auditStatus, startDate, endDate) {
              _userId = userId;
              _auditType = auditType;
              _auditStatus = auditStatus;
              _startDate = startDate;
              _endDate = endDate;
            },
            onApply: () {
              controller.fetchAuditLogs(
                page: 0,
                search: _searchQuery,
                userId: _userId,
                auditType: _auditType,
                auditStatus: _auditStatus,
                startDate: _startDate,
                endDate: _endDate,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard({
    required bool loading,
    required bool isEmpty,
    required Widget body,
    Widget? footer,
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
                      const Text('Activity register', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            loading
                                ? 'Loading audit logs...'
                                : '${controller.auditLogsTotal.value} events recorded',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Compliance trail',
                  tone: StatusTone.primary,
                  icon: Iconsax.shield_tick,
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
                icon: Iconsax.document_text_1,
                title: 'No audit logs found',
                subtitle:
                    'System activities will appear here as users interact with the platform.',
              ),
            )
          else
            body,
          if (footer != null) ...[
            const Divider(height: 1, color: AppColors.borderSubtle),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _buildAuditTable(List<AuditLog> filtered) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('User', flex: 3),
              _buildHeaderCell('Activity', flex: 4),
              _buildHeaderCell('Type', flex: 3),
              _buildHeaderCell('Status', flex: 2),
              _buildHeaderCell('IP Address', flex: 2),
              _buildHeaderCell('Date & Time', flex: 3),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...filtered.map(_buildDataRow),
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

  Widget _tablePaginator(Widget child) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: child,
    );
  }

  Widget _buildDataRow(AuditLog log) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.userFullName,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  log.userEmail,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              log.activity,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style:
                  AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: log.auditTypeDisplay.isEmpty
                    ? log.auditType
                    : log.auditTypeDisplay,
                tone: _typeTone(log.auditType),
                dense: true,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: log.auditStatusDisplay.isEmpty
                    ? log.auditStatus
                    : log.auditStatusDisplay,
                tone: _statusTone(log.auditStatus),
                dense: true,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              log.ipAddress.isEmpty ? '—' : log.ipAddress,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _formatDate(log.createdAt),
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

typedef AuditLogFiltersChanged = void Function(
  String userId,
  String? auditType,
  String? auditStatus,
  String? startDate,
  String? endDate,
);

/// Server-side filters supported by GET /api/v1/audit-logs/.
class AuditLogFilterBar extends StatefulWidget {
  final AuditLogFiltersChanged onChanged;
  final VoidCallback onApply;

  const AuditLogFilterBar({
    super.key,
    required this.onChanged,
    required this.onApply,
  });

  @override
  State<AuditLogFilterBar> createState() => _AuditLogFilterBarState();
}

class _AuditLogFilterBarState extends State<AuditLogFilterBar> {
  final _userIdController = TextEditingController();
  String? _auditType;
  String? _auditStatus;
  String? _startDate;
  String? _endDate;

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(
      _userIdController.text.trim(),
      _auditType,
      _auditStatus,
      _startDate,
      _endDate,
    );
  }

  Future<void> _pickDate({required bool start}) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (picked == null) return;
    final value = DateFormat('yyyy-MM-dd').format(picked);
    setState(() {
      if (start) {
        _startDate = value;
      } else {
        _endDate = value;
      }
    });
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 150,
          child: TextField(
            controller: _userIdController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'User ID',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (_) => _notify(),
          ),
        ),
        SizedBox(
          width: 160,
          child: DropdownButtonFormField<String>(
            value: _auditType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Audit type',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: 'auth', child: Text('Authentication')),
              DropdownMenuItem(value: 'create', child: Text('Create')),
              DropdownMenuItem(value: 'update', child: Text('Update')),
              DropdownMenuItem(value: 'delete', child: Text('Delete')),
              DropdownMenuItem(value: 'logout', child: Text('Logout')),
            ],
            onChanged: (value) {
              setState(() => _auditType = value);
              _notify();
            },
          ),
        ),
        SizedBox(
          width: 160,
          child: DropdownButtonFormField<String>(
            value: _auditStatus,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Audit status',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: 'success', child: Text('Success')),
              DropdownMenuItem(value: 'failure', child: Text('Failure')),
            ],
            onChanged: (value) {
              setState(() => _auditStatus = value);
              _notify();
            },
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _pickDate(start: true),
          icon: const Icon(Iconsax.calendar_1, size: 16),
          label: Text(_startDate ?? 'Start date'),
        ),
        OutlinedButton.icon(
          onPressed: () => _pickDate(start: false),
          icon: const Icon(Iconsax.calendar_1, size: 16),
          label: Text(_endDate ?? 'End date'),
        ),
        FilledButton.icon(
          onPressed: widget.onApply,
          icon: const Icon(Iconsax.filter, size: 16),
          label: const Text('Apply filters'),
        ),
      ],
    );
  }
}
