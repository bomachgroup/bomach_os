import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/feedback/app_toast.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class MyTasksController extends GetxController {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: '${ApiConstants.baseUrl}/api/v1/',
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
        AppToast.success(context, 'Task status updated to $newStatus');
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        AppToast.error(context, 'Failed to update: $e');
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
  static const _accentIndigo = Color(0xFF6366F1);
  static const _accentCyan = AppColors.info;
  static const _accentAmber = AppColors.warning;
  static const _accentGreen = AppColors.success;
  static const _accentRed = AppColors.danger;

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
                  color: _accentIndigo.withValues(alpha: 0.1),
                  borderRadius: AppRadii.brMd,
                ),
                child: const Icon(Iconsax.task_square,
                    color: _accentIndigo, size: 24),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MyText('My Tasks', style: AppText.h1),
                  const SizedBox(height: 2),
                  MyText(
                    'Manage and track your assigned tasks',
                    style: AppText.bodyMd.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: AppRadii.brMd,
          ),
          child: IconButton(
            icon: const Icon(Iconsax.refresh,
                color: AppColors.textSecondary, size: 20),
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
                  Iconsax.task_square, _accentIndigo)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard('Pending', '$pending',
                  Iconsax.hashtag_1, _accentAmber)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard('In Progress', '$inProgress',
                  Iconsax.refresh_2, _accentCyan)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildSummaryCard('Completed', '$completed',
                  Iconsax.tick_circle, _accentGreen)),
        ],
      );
    });
  }

  Widget _buildSummaryCard(
      String label, String count, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      elevation: AppCardElevation.sm,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppRadii.brMd,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  count,
                  style: AppText.h2.copyWith(
                    fontSize: 22,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                MyText(
                  label,
                  style: AppText.caption.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = [
      {'key': 'all', 'label': 'All Tasks', 'icon': Iconsax.task_square},
      {'key': 'pending', 'label': 'Pending', 'icon': Iconsax.hashtag_1},
      {'key': 'in_progress', 'label': 'In Progress', 'icon': Iconsax.refresh_2},
      {'key': 'completed', 'label': 'Completed', 'icon': Iconsax.tick_circle},
    ];
    return Obx(() => Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: AppRadii.brMd,
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
                  borderRadius: AppRadii.brSm,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.surface : Colors.transparent,
                      borderRadius: AppRadii.brSm,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.neutral900
                                    .withValues(alpha: 0.06),
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
                          color: isActive ? _accentIndigo : AppColors.textMuted,
                        ),
                        const SizedBox(width: 6),
                        MyText(
                          f['label'] as String,
                          isSelectable: false,
                          style: AppText.label.copyWith(
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
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
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.sm,
      clipBehavior: Clip.antiAlias,
      child: Obx(() {
        if (controller.isLoading.value) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: LoadingSkeleton.listRows(count: 6),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return EmptyState(
            title: 'Could not load tasks',
            subtitle: controller.errorMessage.value,
            icon: Iconsax.warning_2,
            action: OutlinedButton.icon(
              onPressed: () => controller.fetchMyTasks(),
              icon: const Icon(Iconsax.refresh, size: 18),
              label: const Text('Retry'),
            ),
          );
        }

        if (controller.tasks.isEmpty) {
          return const EmptyState(
            title: 'No tasks found',
            subtitle: 'Tasks assigned to you will appear here',
            icon: Iconsax.task_square,
          );
        }

        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: bodySpace(context)),
              child: DataTable(
                headingRowColor:
                    WidgetStateProperty.all(AppColors.surfaceMuted),
                headingTextStyle: AppText.label.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
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
                    color: _getPriorityColor(task.priority)
                        .withValues(alpha: 0.1),
                    borderRadius: AppRadii.brSm,
                  ),
                  child: Center(
                    child: Icon(Iconsax.task_square,
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
                      child: MyText(
                        task.name,
                        style: AppText.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    MyText(
                      '#${task.id}',
                      style: AppText.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          DataCell(_buildPriorityChip(task.priority)),
          DataCell(MyText(
              task.dueDate.isNotEmpty ? task.dueDate : '\u2014',
              style: AppText.bodySm.copyWith(color: AppColors.textSecondary))),
          DataCell(MyText(
              task.estimatedHours > 0 ? '${task.estimatedHours}h' : '\u2014',
              style: AppText.bodySm.copyWith(color: AppColors.textSecondary))),
          DataCell(StatusChip.fromStatus(task.status)),
          DataCell(_buildActionMenu(task)),
        ],
      );
    }).toList();
  }

  Widget _buildPriorityChip(String priority) {
    StatusTone tone;
    switch (priority.toLowerCase()) {
      case 'high':
        tone = StatusTone.danger;
        break;
      case 'medium':
        tone = StatusTone.warning;
        break;
      default:
        tone = StatusTone.success;
    }
    final label = priority.isNotEmpty
        ? priority[0].toUpperCase() + priority.substring(1)
        : 'Low';
    return StatusChip(label: label, tone: tone);
  }

  Widget _buildActionMenu(Task task) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadii.brSm,
        ),
        child: const Icon(Iconsax.more,
            size: 18, color: AppColors.textSecondary),
      ),
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
      elevation: 8,
      shadowColor: AppColors.neutral900.withValues(alpha: 0.1),
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
        _buildMenuItem(Iconsax.eye, 'View Details', 'details', _accentIndigo),
        if (task.status.toLowerCase() == 'pending')
          _buildMenuItem(
              Iconsax.play_circle, 'Start Task', 'start', _accentCyan),
        if (task.status.toLowerCase() == 'in_progress')
          _buildMenuItem(Iconsax.tick_circle, 'Mark Complete', 'complete',
              _accentGreen),
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
              borderRadius: AppRadii.brSm,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppText.bodySm.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskDetails(Task task) {
    DialogScaffold.show(
      context,
      title: 'Task Details',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _detailItem(Iconsax.document_text, 'Task Name', task.name),
          _detailItem(Iconsax.note_1, 'Description',
              task.description.isNotEmpty ? task.description : 'N/A'),
          Row(
            children: [
              Expanded(
                  child: _detailItem(
                      Iconsax.flag, 'Priority', task.priority,
                      badge: _buildPriorityChip(task.priority))),
              const SizedBox(width: 16),
              Expanded(
                  child: _detailItem(
                      Iconsax.record_circle, 'Status', task.status,
                      badge: StatusChip.fromStatus(task.status))),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: _detailItem(
                      Iconsax.calendar_1,
                      'Due Date',
                      task.dueDate.isNotEmpty ? task.dueDate : 'Not set')),
              const SizedBox(width: 16),
              Expanded(
                  child: _detailItem(
                      Iconsax.clock,
                      'Est. Hours',
                      task.estimatedHours > 0
                          ? '${task.estimatedHours}h'
                          : 'Not set')),
            ],
          ),
          if (task.assignedTo.isNotEmpty)
            _detailItem(Iconsax.people, 'Assigned To',
                task.assignedTo.join(', ')),
        ],
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
              Icon(icon, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              MyText(
                label,
                style: AppText.caption.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          badge ??
              MyText(
                value,
                style: AppText.bodyMd.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return _accentRed;
      case 'medium':
        return _accentAmber;
      default:
        return _accentGreen;
    }
  }
}
