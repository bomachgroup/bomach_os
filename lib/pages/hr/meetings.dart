import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/pages/hr/controller/meeting_controller.dart';
import 'package:bms_front_end/pages/hr/models/meeting_model.dart';
import 'package:bms_front_end/pages/hr/widget/add_meeting_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class Meetings extends StatefulWidget {
  const Meetings({super.key});

  @override
  State<Meetings> createState() => _MeetingsState();
}

class _MeetingsState extends State<Meetings> {
  final MeetingController controller = Get.put(MeetingController());
  final _storage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return StatusTone.primary;
      case 'ongoing':
      case 'in_progress':
        return StatusTone.warning;
      case 'completed':
        return StatusTone.success;
      case 'cancelled':
        return StatusTone.danger;
      case 'postponed':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Meetings',
        subtitle: 'Schedule and manage team meetings.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'Schedule Meeting',
          onTap: () => showDialog(
            context: context,
            builder: (_) => const AddMeetingDialog(),
          ),
        ),
      ),
      children: [
        _buildToolbar(),
        Obx(() {
          final loading =
              controller.isLoading.value && controller.meetings.isEmpty;
          final isEmpty =
              !controller.isLoading.value && controller.meetings.isEmpty;

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
            body: _buildTable(controller.meetings),
          );
        }),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: MyTextFormField(
        controller: _searchController,
        hintText: 'Search meetings by title or agenda',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: (val) => _loadData(search: val),
      ),
    );
  }

  Widget _buildTableCard({
    required bool loading,
    required bool isEmpty,
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
                      const Text('Meetings register', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            loading
                                ? 'Loading meetings...'
                                : '${controller.meetings.length} meeting${controller.meetings.length == 1 ? '' : 's'} scheduled',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Team schedule',
                  tone: StatusTone.primary,
                  icon: Iconsax.calendar_1,
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.calendar_1,
                title: 'No meetings scheduled',
                subtitle:
                    'Create a meeting to plan discussions with your team.',
                action: MyOutlinedButton(
                  child: 'Schedule Meeting',
                  icon: const Icon(Iconsax.add_circle,
                      size: 18, color: AppColors.primary),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => const AddMeetingDialog(),
                  ),
                ),
              ),
            )
          else
            body,
        ],
      ),
    );
  }

  Widget _buildTable(List<Meeting> meetings) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Title', flex: 3),
              _buildHeaderCell('Date', flex: 2),
              _buildHeaderCell('Time', flex: 2),
              _buildHeaderCell('Duration', flex: 2),
              _buildHeaderCell('Location', flex: 2),
              _buildHeaderCell('Attendees', flex: 2),
              _buildHeaderCell('Status', flex: 2),
              _buildHeaderCell('', width: 60),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...meetings.map(_buildMeetingRow),
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

  Widget _buildMeetingRow(Meeting m) {
    final statusLabel = m.statusDisplay.isNotEmpty ? m.statusDisplay : m.status;
    final locationLabel = m.locationTypeDisplay.isNotEmpty
        ? m.locationTypeDisplay
        : m.locationType;
    final durationLabel = m.durationDisplay.isNotEmpty
        ? m.durationDisplay
        : '${m.durationMinutes} min';

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
            child: Text(
              m.title,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              m.meetingDate.isEmpty ? '—' : m.meetingDate,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatTime(m.meetingTime),
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              durationLabel,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              locationLabel.isEmpty ? '—' : locationLabel,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${m.attendeeCount}',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: statusLabel,
                tone: _statusTone(m.status),
                dense: true,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                tooltip: 'More',
                position: PopupMenuPosition.under,
                shape: const RoundedRectangleBorder(
                    borderRadius: AppRadii.brMd),
                icon: const Icon(Iconsax.more,
                    size: 18, color: AppColors.textSecondary),
                onSelected: (value) {
                  if (value == 'edit') {
                    showDialog(
                      context: context,
                      builder: (_) => AddMeetingDialog(meeting: m),
                    );
                  } else if (value == 'cancel') {
                    controller.deleteMeeting(context, m.id);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Iconsax.edit,
                            size: 16, color: AppColors.textSecondary),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Iconsax.close_circle,
                            size: 16, color: AppColors.danger),
                        SizedBox(width: 8),
                        Text('Cancel',
                            style: TextStyle(color: AppColors.danger)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    if (time.isEmpty) return '—';
    final parts = time.split(':');
    if (parts.length < 2) return time;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m $period';
  }
}
