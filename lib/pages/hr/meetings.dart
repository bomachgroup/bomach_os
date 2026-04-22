import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/hr/controller/meeting_controller.dart';
import 'package:bms_front_end/pages/hr/models/meeting_model.dart';
import 'package:bms_front_end/pages/hr/widget/add_meeting_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class Meetings extends StatefulWidget {
  const Meetings({super.key});

  @override
  State<Meetings> createState() => _MeetingsState();
}

class _MeetingsState extends State<Meetings> {
  final ScrollController _scrollController = ScrollController();
  final MeetingController controller = Get.put(MeetingController());
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({String? search}) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return;
    if (token.startsWith('Bearer ')) token = token.replaceFirst('Bearer ', '');
    token = token.replaceAll('"', '').trim();
    controller.fetchMeetings(context, search: search);
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
        // Header
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText('Meetings', style: AppText.displayLg),
                      SizedBox(height: 8),
                      MyText('Schedule and manage team meetings',
                          style: AppText.bodyMd),
                    ],
                  ),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      SizedBox(
                        width: 180,
                        child: MyTextFormField(
                          hintText: 'Search...',
                          leading: Icon(Iconsax.search_normal,
                              color: AppColors.neutral500.withValues(alpha: 0.5)),
                          onChanged: (val) => _loadData(search: val),
                        ),
                      ),
                      MyElevatedButton(
                        icon: const Icon(Iconsax.add_circle,
                            color: AppColors.white),
                        child: 'Schedule Meeting',
                        onTap: () => showDialog(
                          context: context,
                          builder: (_) => const AddMeetingDialog(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        kSizedBox,
        kSizedBoxSM,

        // Table
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.meetings.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('No meetings found.'),
                ),
              );
            }
            return Column(
              children: [
                Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: bodySpace(context)),
                      child: DataTable(
                        dataRowMinHeight: 68,
                        dataRowMaxHeight: 68,
                        columnSpacing: 24,
                        horizontalMargin: 12,
                        showBottomBorder: true,
                        columns: const [
                          DataColumn(label: MyText('Title')),
                          DataColumn(label: MyText('Date')),
                          DataColumn(label: MyText('Time')),
                          DataColumn(label: MyText('Duration')),
                          DataColumn(label: MyText('Location')),
                          DataColumn(label: MyText('Attendees')),
                          DataColumn(label: MyText('Status')),
                          DataColumn(label: MyText('Action')),
                        ],
                        rows: _buildRows(context, controller.meetings),
                      ),
                    ),
                  ),
                ),
                // PaginatorFooter(
                //   totalRecords: controller.totalCount.value,
                //   onPageChanged: (page, limit) {
                //     controller.currentLimit.value = limit;
                //     controller.currentOffset.value = (page - 1) * limit;
                //     controller.fetchMeetings(context);
                //   },
                // ),
              ],
            );
          }),
        ),
      ],
    );
  }

  List<DataRow> _buildRows(BuildContext context, List<Meeting> meetings) {
    return meetings.map((m) {
      return DataRow(cells: [
        DataCell(
          MyText(m.title, size: 16, weight: 500),
        ),
        DataCell(MyText(m.meetingDate)),
        DataCell(MyText(_formatTime(m.meetingTime))),
        DataCell(MyText(m.durationDisplay.isNotEmpty
            ? m.durationDisplay
            : '${m.durationMinutes} min')),
        DataCell(MyText(
          m.locationTypeDisplay.isNotEmpty
              ? m.locationTypeDisplay
              : m.locationType,
        )),
        DataCell(MyText('${m.attendeeCount}')),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(m.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                  color: _statusColor(m.status).withValues(alpha: 0.5)),
            ),
            child: MyText(
              m.statusDisplay.isNotEmpty ? m.statusDisplay : m.status,
              color: _statusColor(m.status),
            ),
          ),
        ),
        DataCell(PopupMenuButton(
          itemBuilder: (ctx) => [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AddMeetingDialog(meeting: m),
              ),
            ),
            PopupMenuItem(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onTap: () => controller.deleteMeeting(context, m.id),
            ),
          ],
          child: const Icon(Iconsax.more),
        )),
      ]);
    }).toList();
  }

  String _formatTime(String time) {
    if (time.isEmpty) return '-';
    final parts = time.split(':');
    if (parts.length < 2) return time;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m $period';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return AppColors.primary;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.neutral500;
    }
  }
}
