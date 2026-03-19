import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class MyTasksController extends GetxController {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://bomachauth.bgbot.app/api/v1/',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  final _storage = const FlutterSecureStorage();

  var tasks = <Task>[].obs;
  var isLoading = false.obs;
  var isUpdating = false.obs;
  var errorMessage = ''.obs;
  var selectedFilter = 'all'.obs;

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }

  Options _authOptions(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<void> fetchMyTasks() async {
    try {
      isLoading(true);
      errorMessage('');
      final token = await _getToken();
      if (token == null) return;

      final queryParams = <String, dynamic>{
        'limit': 100,
        'offset': 0,
      };
      final statusFilter =
          selectedFilter.value == 'all' ? null : selectedFilter.value;
      if (statusFilter != null) queryParams['status'] = statusFilter;

      final response = await _dio.get(
        'my-tasks',
        queryParameters: queryParams,
        options: _authOptions(token),
      );

      final data = response.data;
      final List items = data is Map ? (data['items'] ?? []) : (data ?? []);
      tasks.assignAll(items.map((e) => Task.fromJson(e)).toList());
    } catch (e) {
      debugPrint("Fetch my tasks error: $e");
      if (e is DioException && e.response?.statusCode == 403) {
        errorMessage('You do not have permission to view tasks.');
      } else {
        errorMessage('Failed to load tasks.');
      }
    } finally {
      isLoading(false);
    }
  }

  Future<bool> updateTaskStatus(
      BuildContext context, Task task, String newStatus) async {
    try {
      isUpdating(true);
      final token = await _getToken();
      if (token == null) return false;

      await _dio.patch(
        'my-tasks/${task.id}/status',
        data: {'status': newStatus},
        options: _authOptions(token),
      );

      await fetchMyTasks();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Task status updated to $newStatus'),
              backgroundColor: const Color(0xFF10B981)),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update: $e'),
              backgroundColor: const Color(0xFFEF4444)),
        );
      }
      return false;
    } finally {
      isUpdating(false);
    }
  }
}

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage> {
  final ScrollController _scrollController = ScrollController();
  final MyTasksController controller = Get.put(MyTasksController());

  @override
  void initState() {
    super.initState();
    controller.fetchMyTasks();
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
        _buildTasksTable(),
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
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.task_alt_rounded,
                    color: Color(0xFF6366F1), size: 24),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText('My Tasks',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B))),
                  SizedBox(height: 2),
                  MyText('Manage and track your assigned tasks',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF94A3B8))),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF64748B), size: 22),
            onPressed: () => controller.fetchMyTasks(),
            tooltip: 'Refresh',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      final all = controller.tasks.length;
      final pending = controller.tasks
          .where((t) => t.status.toLowerCase() == 'pending')
          .length;
      final inProgress = controller.tasks
          .where((t) => t.status.toLowerCase() == 'in_progress')
          .length;
      final completed = controller.tasks
          .where((t) => t.status.toLowerCase() == 'completed')
          .length;

      return Row(
        children: [
          Expanded(
              child: _buildSummaryCard('Total Tasks', '$all',
                  Icons.list_alt_rounded, const Color(0xFF6366F1))),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard('Pending', '$pending',
                  Icons.hourglass_empty_rounded, const Color(0xFFF59E0B))),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard('In Progress', '$inProgress',
                  Icons.autorenew_rounded, const Color(0xFF0EA5E9))),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard('Completed', '$completed',
                  Icons.check_circle_rounded, const Color(0xFF10B981))),
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
      {'key': 'all', 'label': 'All Tasks', 'icon': Icons.list_alt_rounded},
      {
        'key': 'pending',
        'label': 'Pending',
        'icon': Icons.hourglass_empty_rounded
      },
      {
        'key': 'in_progress',
        'label': 'In Progress',
        'icon': Icons.autorenew_rounded
      },
      {
        'key': 'completed',
        'label': 'Completed',
        'icon': Icons.check_circle_rounded
      },
    ];
    return Obx(() => Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: filters.map((f) {
              final isActive = controller.selectedFilter.value == f['key'];
              return Expanded(
                child: InkWell(
                  onTap: () {
                    controller.selectedFilter.value = f['key'] as String;
                    controller.fetchMyTasks();
                  },
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
                          color: isActive
                              ? const Color(0xFF6366F1)
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        MyText(
                          f['label'] as String,
                          isSelectable: false,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? const Color(0xFF1E293B)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }

  Widget _buildTasksTable() {
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

        if (controller.errorMessage.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.all(60),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.error_outline_rounded,
                        size: 48, color: Color(0xFFEF4444)),
                  ),
                  const SizedBox(height: 16),
                  MyText(controller.errorMessage.value,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFEF4444))),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => controller.fetchMyTasks(),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.tasks.isEmpty) {
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
                    child: const Icon(Icons.task_alt_rounded,
                        size: 48, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 16),
                  const MyText('No tasks found',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  const MyText('Tasks assigned to you will appear here',
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
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
                    DataColumn(label: Text("Task")),
                    DataColumn(label: Text("Priority")),
                    DataColumn(label: Text("Due Date")),
                    DataColumn(label: Text("Est. Hours")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Action")),
                  ],
                  rows: _buildRows(controller.tasks),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  List<DataRow> _buildRows(List<Task> tasks) {
    return tasks.map((task) {
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
                    color:
                        _getPriorityColor(task.priority).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(Icons.assignment_rounded,
                        size: 18, color: _getPriorityColor(task.priority)),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 180,
                      child: MyText(task.name,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B)),
                          maxLines: 1),
                    ),
                    const SizedBox(height: 2),
                    MyText('#${task.id}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
          ),
          DataCell(_buildPriorityBadge(task.priority)),
          DataCell(MyText(task.dueDate.isNotEmpty ? task.dueDate : '\u2014',
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)))),
          DataCell(MyText(
              task.estimatedHours > 0 ? '${task.estimatedHours}h' : '\u2014',
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569)))),
          DataCell(_buildStatusBadge(task.status)),
          DataCell(_buildActionMenu(task)),
        ],
      );
    }).toList();
  }

  Widget _buildPriorityBadge(String priority) {
    final color = _getPriorityColor(priority);
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
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          MyText(
              priority.isNotEmpty
                  ? priority[0].toUpperCase() + priority.substring(1)
                  : 'Low',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 12)),
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

  Widget _buildActionMenu(Task task) {
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
      onSelected: (value) {
        if (value == 'start') {
          controller.updateTaskStatus(context, task, 'in_progress');
        } else if (value == 'complete') {
          controller.updateTaskStatus(context, task, 'completed');
        } else if (value == 'details') {
          _showTaskDetails(task);
        }
      },
      itemBuilder: (context) => [
        _buildMenuItem(Icons.visibility_rounded, 'View Details', 'details',
            const Color(0xFF6366F1)),
        if (task.status.toLowerCase() == 'pending')
          _buildMenuItem(Icons.play_circle_rounded, 'Start Task', 'start',
              const Color(0xFF0EA5E9)),
        if (task.status.toLowerCase() == 'in_progress')
          _buildMenuItem(Icons.check_circle_rounded, 'Mark Complete',
              'complete', const Color(0xFF10B981)),
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

  void _showTaskDetails(Task task) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 550),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.assignment_rounded,
                          color: Color(0xFF6366F1), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: MyText('Task Details',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B))),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 18, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailItem(Icons.badge_rounded, 'Task Name', task.name),
                    _detailItem(Icons.notes_rounded, 'Description',
                        task.description.isNotEmpty ? task.description : 'N/A'),
                    Row(
                      children: [
                        Expanded(
                            child: _detailItem(
                                Icons.flag_rounded, 'Priority', task.priority,
                                badge: _buildPriorityBadge(task.priority))),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _detailItem(
                                Icons.circle_rounded, 'Status', task.status,
                                badge: _buildStatusBadge(task.status))),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: _detailItem(
                                Icons.calendar_month_rounded,
                                'Due Date',
                                task.dueDate.isNotEmpty
                                    ? task.dueDate
                                    : 'Not set')),
                        const SizedBox(width: 16),
                        Expanded(
                            child: _detailItem(
                                Icons.timer_rounded,
                                'Est. Hours',
                                task.estimatedHours > 0
                                    ? '${task.estimatedHours}h'
                                    : 'Not set')),
                      ],
                    ),
                    if (task.assignedTo.isNotEmpty)
                      _detailItem(Icons.people_rounded, 'Assigned To',
                          task.assignedTo.join(', ')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value,
      {Widget? badge}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 6),
              MyText(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 6),
          badge ??
              MyText(value,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'in_progress':
        return const Color(0xFF0EA5E9);
      case 'pending':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'in_progress':
        return Icons.autorenew_rounded;
      case 'pending':
        return Icons.hourglass_empty_rounded;
      default:
        return Icons.circle_outlined;
    }
  }
}
