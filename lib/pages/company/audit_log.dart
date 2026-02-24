import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/company_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'controllers/company_controller.dart';

class AuditLogPage extends StatefulWidget {
  const AuditLogPage({super.key});

  @override
  State<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage> {
  final CompanyController controller = Get.put(CompanyController());
  final _searchController = TextEditingController();
  String _searchQuery = '';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText('Audit Log', style: AppText.black_600_32),
        const SizedBox(height: 8),
        const Text('Track all changes and activities in the system',
            style: TextStyle(color: Color(0xFF64748B))),
        kSizedBox,

        // Search bar
        SizedBox(
          width: 320,
          child: MyTextFormField(
            controller: _searchController,
            hintText: 'Search by user, activity or IP...',
            leading: const Icon(Icons.search, color: Colors.grey),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        kSizedBox,

        // Table
        Obx(() {
          if (controller.isAuditLoading.value) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator()));
          }

          final filtered = _filtered(controller.auditLogs);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(child: Text('No audit logs found.')))
                    : LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minWidth: constraints.maxWidth),
                            child: DataTable(
                          headingRowColor: WidgetStateProperty.all(
                              Colors.grey.shade50),
                          columnSpacing: 24,
                          dataRowMinHeight: 52,
                          dataRowMaxHeight: 64,
                          columns: const [
                            DataColumn(label: Text('User')),
                            DataColumn(label: Text('Activity')),
                            DataColumn(label: Text('Type')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('IP Address')),
                            DataColumn(label: Text('Date & Time')),
                          ],
                          rows: filtered.map((log) {
                            return DataRow(cells: [
                              // User
                              DataCell(Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(log.userFullName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  Text(log.userEmail,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B))),
                                ],
                              )),
                              // Activity
                              DataCell(SizedBox(
                                  width: 240,
                                  child: Text(log.activity,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style:
                                          const TextStyle(fontSize: 13)))),
                              // Type badge
                              DataCell(_TypeBadge(log.auditTypeDisplay,
                                  log.auditType)),
                              // Status badge
                              DataCell(_StatusBadge(log.auditStatusDisplay,
                                  log.auditStatus)),
                              // IP
                              DataCell(Text(log.ipAddress,
                                  style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12))),
                              // Date
                              DataCell(Text(_formatDate(log.createdAt),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B)))),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
              ),

              // Pagination
              if (_searchQuery.isEmpty) ...[
                kSizedBoxSM,
                _PaginationBar(controller: controller),
              ],
            ],
          );
        }),
      ],
    );
  }
}

// ── Type badge ────────────────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final String label;
  final String type;
  const _TypeBadge(this.label, this.type);

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (type) {
      'login' => (const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
      'logout' => (const Color(0xFFF8FAFC), const Color(0xFF64748B)),
      'create' => (const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
      'update' => (const Color(0xFFFFFBEB), const Color(0xFFD97706)),
      'delete' => (const Color(0xFFFFF1F2), const Color(0xFFE11D48)),
      _ => (const Color(0xFFF1F5F9), const Color(0xFF475569)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final String status;
  const _StatusBadge(this.label, this.status);

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'success' => (const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
      'failure' || 'failed' => (const Color(0xFFFFF1F2), const Color(0xFFE11D48)),
      _ => (const Color(0xFFFFFBEB), const Color(0xFFD97706)),
    };
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    ]);
  }
}

// ── Pagination bar ────────────────────────────────────────────────────────────

class _PaginationBar extends StatelessWidget {
  final CompanyController controller;
  const _PaginationBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final page = controller.auditPage.value;
      final total = controller.auditLogsTotal.value;
      const pageSize = CompanyController.auditPageSize;
      final totalPages = (total / pageSize).ceil();
      final from = total == 0 ? 0 : page * pageSize + 1;
      final to = ((page + 1) * pageSize).clamp(0, total);

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Showing $from–$to of $total entries',
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF64748B))),
          Row(children: [
            _PageBtn(
              icon: Icons.chevron_left,
              enabled: page > 0,
              onTap: () => controller.fetchAuditLogs(page: page - 1),
            ),
            const SizedBox(width: 4),
            ...List.generate(totalPages, (i) {
              final active = i == page;
              return GestureDetector(
                onTap: () => controller.fetchAuditLogs(page: i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF005CE8)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: active
                          ? null
                          : Border.all(color: const Color(0xFFE2E8F0))),
                  child: Center(
                      child: Text('${i + 1}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFF475569)))),
                ),
              );
            }),
            const SizedBox(width: 4),
            _PageBtn(
              icon: Icons.chevron_right,
              enabled: page < totalPages - 1,
              onTap: () => controller.fetchAuditLogs(page: page + 1),
            ),
          ]),
        ],
      );
    });
  }
}

class _PageBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _PageBtn(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Icon(icon,
            size: 18,
            color:
                enabled ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
      ),
    );
  }
}
