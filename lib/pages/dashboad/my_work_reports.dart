import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/controller/work_report_controller.dart';
import 'package:bms_front_end/pages/hr/models/work_report_model.dart';
import 'package:bms_front_end/pages/hr/widget/daily_work_report_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/work_report_review_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
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
  final ScrollController _scrollController = ScrollController();
  final WorkReportController controller = Get.put(WorkReportController());
  final _storage = const FlutterSecureStorage();

  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await _getToken();
    if (token != null) {
      controller.fetchReports(token);
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
        .where(
            (r) => r.status.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPageHeader(),
        const SizedBox(height: 20),
        _buildSummaryCards(),
        const SizedBox(height: 20),
        _buildFilterBar(),
        const SizedBox(height: 16),
        _buildReportsTable(),
      ],
    );
  }

  Widget _buildPageHeader() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_rounded,
                    color: Color(0xFF0EA5E9), size: 24),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText('My Work Reports',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B))),
                  SizedBox(height: 2),
                  MyText('Submit and track your daily work reports',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded,
                    color: Color(0xFF64748B), size: 22),
                onPressed: _loadData,
                tooltip: 'Refresh',
              ),
            ),
            const SizedBox(width: 10),
            MyElevatedButton(
              icon: const Icon(Icons.add_rounded,
                  color: AppColors.white, size: 20),
              child: "New Report",
              borderCurve: 12,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              onTap: () async {
                final token = await _getToken();
                if (token != null && context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        DailyWorkReportDialog(token: token),
                  );
                }
              },
            ),
          ],
        ),
      ],
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

      return Row(
        children: [
          Expanded(
              child: _buildSummaryCard('Total Reports', '$all',
                  Icons.description_rounded, const Color(0xFF6366F1))),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard('Pending Review', '$submitted',
                  Icons.schedule_rounded, const Color(0xFF0EA5E9))),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard('Approved', '$approved',
                  Icons.check_circle_rounded, const Color(0xFF10B981))),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard('Rejected', '$rejected',
                  Icons.cancel_rounded, const Color(0xFFEF4444))),
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
        border: Border.all(color: const Color(0xFFF0F0F0)),
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
                        color: Color(0xFF1E293B))),
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
        'icon': Icons.list_alt_rounded,
        'color': const Color(0xFF6366F1)
      },
      {
        'key': 'submitted',
        'label': 'Pending Review',
        'icon': Icons.schedule_rounded,
        'color': const Color(0xFF0EA5E9)
      },
      {
        'key': 'approved',
        'label': 'Approved',
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF10B981)
      },
      {
        'key': 'rejected',
        'label': 'Rejected',
        'icon': Icons.cancel_rounded,
        'color': const Color(0xFFEF4444)
      },
      {
        'key': 'draft',
        'label': 'Draft',
        'icon': Icons.edit_note_rounded,
        'color': const Color(0xFF64748B)
      },
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: filters.map((f) {
          final isActive = _selectedFilter == f['key'];
          final color = f['color'] as Color;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedFilter = f['key'] as String),
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
                      color: isActive ? color : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: MyText(
                        f['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w500,
                          color: isActive
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReportsTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
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
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.description_rounded,
                        size: 48, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 16),
                  MyText(
                    _selectedFilter == 'all'
                        ? 'No work reports found'
                        : 'No $_selectedFilter reports',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  const MyText('Submit a new report to get started',
                      style:
                          TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: bodySpace(context)),
                child: DataTable(
                  headingRowColor:
                      WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                  headingTextStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                  dataRowMinHeight: 72,
                  dataRowMaxHeight: 72,
                  columnSpacing: 28,
                  horizontalMargin: 20,
                  dividerThickness: 0.5,
                  columns: const [
                    DataColumn(label: Text("Date")),
                    DataColumn(label: Text("Hours")),
                    DataColumn(label: Text("Mood")),
                    DataColumn(label: Text("Achievements")),
                    DataColumn(label: Text("Challenges")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Rating")),
                    DataColumn(label: Text("Action")),
                  ],
                  rows: _buildRows(reports),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  List<DataRow> _buildRows(List<WorkReport> reports) {
    return reports.map((report) {
      return DataRow(
        cells: [
          DataCell(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.calendar_today_rounded,
                        size: 16, color: Color(0xFF0EA5E9)),
                  ),
                ),
                const SizedBox(width: 10),
                MyText(
                  report.day != null
                      ? DateFormat('dd MMM yyyy').format(report.day!)
                      : '-',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          ),
          DataCell(_buildMoodChip(report.mood)),
          DataCell(SizedBox(
            width: 150,
            child: MyText(report.achievements ?? '-',
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF475569)),
                maxLines: 1),
          )),
          DataCell(SizedBox(
            width: 150,
            child: MyText(report.challenges ?? '-',
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF475569)),
                maxLines: 1),
          )),
          DataCell(_buildStatusBadge(report.status)),
          DataCell(_buildRating(report.rating)),
          DataCell(_buildActionMenu(report)),
        ],
      );
    }).toList();
  }

  Widget _buildMoodChip(String mood) {
    final emoji = _getMoodEmoji(mood);
    final label =
        mood.isNotEmpty ? mood[0].toUpperCase() + mood.substring(1) : 'Neutral';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          MyText(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569))),
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
          style: TextStyle(color: Color(0xFF94A3B8)));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          return Icon(
            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < rating
                ? const Color(0xFFF59E0B)
                : const Color(0xFFE2E8F0),
            size: 18,
          );
        }),
        const SizedBox(width: 6),
        MyText('$rating/5',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569))),
      ],
    );
  }

  Widget _buildActionMenu(WorkReport report) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.more_horiz_rounded,
            size: 18, color: Color(0xFF64748B)),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      onSelected: (value) async {
        final token = await _getToken();
        if (token == null || !context.mounted) return;

        if (value == 'view') {
          showDialog(
            context: context,
            builder: (context) =>
                WorkReportReviewDialog(report: report, token: token),
          );
        } else if (value == 'edit') {
          showDialog(
            context: context,
            builder: (context) =>
                DailyWorkReportDialog(existingReport: report, token: token),
          );
        }
      },
      itemBuilder: (context) => [
        _buildMenuItem(Icons.visibility_rounded, 'View Details', 'view',
            const Color(0xFF6366F1)),
        if (report.status.toLowerCase() == 'draft' ||
            report.status.toLowerCase() == 'rejected')
          _buildMenuItem(Icons.edit_rounded, 'Edit & Resubmit', 'edit',
              const Color(0xFF0EA5E9)),
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
                  color: Color(0xFF334155))),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF10B981);
      case 'submitted':
        return const Color(0xFF0EA5E9);
      case 'draft':
        return const Color(0xFF64748B);
      case 'rejected':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Icons.check_circle_rounded;
      case 'submitted':
        return Icons.schedule_rounded;
      case 'draft':
        return Icons.edit_note_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return '\u{1F60A}';
      case 'neutral':
        return '\u{1F610}';
      case 'sad':
        return '\u{1F614}';
      case 'stressed':
        return '\u{1F62B}';
      case 'tired':
        return '\u{1F634}';
      case 'frustrated':
        return '\u{1F61E}';
      default:
        return '\u{1F610}';
    }
  }
}
