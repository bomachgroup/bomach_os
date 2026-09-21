import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/events/controller/event_controller.dart';
import 'package:bomach_os/pages/events/widget/add_event_dialog.dart';
import 'package:bomach_os/pages/events/widget/view_event_dialog.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/services/events/event_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final controller = Get.put(EventController());
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedDayEvents =
          controller.getEventsForDay(_selectedDay ?? _focusedDay);
      final totalEvents = controller.events.length;

      return PageScaffold(
        scrollable: false,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
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
                                MyText(
                                  'Events & Calendar',
                                  style: AppTextStyles.displayLg,
                                ),
                                SizedBox(height: 8),
                                MyText(
                                  'Manage and track all company events',
                                  size: 14,
                                  weight: 400,
                                  color: AppColors.neutral500,
                                ),
                              ],
                            ),
                            MyElevatedButton(
                              icon: const Icon(
                                Iconsax.add_circle,
                                color: AppColors.white,
                              ),
                              child: "New Event",
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return const AddEventDialog();
                                  },
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  kSizedBox,

                  // Loading indicator
                  if (controller.isLoading.value && controller.events.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else ...[
                    // Calendar Section
                    _buildCalendarSection(totalEvents),
                    kSizedBox,

                    // Events List Section
                    _buildEventsListSection(selectedDayEvents),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCalendarSection(int totalEvents) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const MyText(
                  'Calendar',
                  size: 18,
                  weight: 600,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: MyText(
                    '$totalEvents Events',
                    size: 12,
                    weight: 500,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) => controller.getEventsForDay(day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(Iconsax.arrow_left_2),
                rightChevronIcon: Icon(Iconsax.arrow_right_3),
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                outsideDaysVisible: false,
              ),
            ),
          ),
          const Divider(height: 1),
          // Legend
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem('General Meeting', Colors.blue),
                _buildLegendItem('Board Meeting', Colors.red),
                _buildLegendItem('Training', Colors.orange),
                _buildLegendItem('Conference', Colors.green),
                _buildLegendItem('Social Event', Colors.purple),
                _buildLegendItem('Other', Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        MyText(
          label,
          size: 12,
          weight: 400,
          color: AppColors.neutral500,
        ),
      ],
    );
  }

  Widget _buildEventsListSection(List<Event> events) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 0.6, color: const Color(0XFFD5D5D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const MyText(
                      'Events',
                      size: 18,
                      weight: 600,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neutral50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.neutral200,
                        ),
                      ),
                      child: MyText(
                        _selectedDay != null
                            ? _formatDate(_selectedDay!)
                            : _formatDate(_focusedDay),
                        size: 12,
                        weight: 500,
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          events.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Iconsax.calendar_remove,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        MyText(
                          'No events scheduled',
                          size: 16,
                          weight: 400,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(height: 4),
                        MyText(
                          'Select a different date to view events',
                          size: 14,
                          weight: 400,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: events.asMap().entries.map((entry) {
                    final index = entry.key;
                    final event = entry.value;
                    return Column(
                      children: [
                        _buildEventItem(event),
                        if (index < events.length - 1) const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildEventItem(Event event) {
    Color eventColor = _getEventColor(event.eventType);
    final fromTime = _formatTime(event.eventTimeFrom);
    final toTime = _formatTime(event.eventTimeTo);

    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return ViewEventDialog(event: event);
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: eventColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MyText(
                          event.title,
                          size: 16,
                          weight: 600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: eventColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            width: 0.6,
                            color: eventColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: MyText(
                          _formatEventType(event.eventType),
                          size: 10,
                          weight: 600,
                          color: eventColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Iconsax.clock,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      MyText(
                        '$fromTime - $toTime',
                        size: 13,
                        weight: 400,
                        color: AppColors.neutral500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (event.meetingLocation != null &&
                      event.meetingLocation!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Iconsax.location,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: MyText(
                            event.meetingLocation!,
                            size: 13,
                            weight: 400,
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'GENERAL_MEETING':
        return Colors.blue;
      case 'BOARD_MEETING':
        return Colors.red;
      case 'TRAINING':
        return Colors.orange;
      case 'CONFERENCE':
        return Colors.green;
      case 'SOCIAL_EVENT':
        return Colors.purple;
      case 'OTHER':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  String _formatEventType(String type) {
    return type.replaceAll('_', ' ');
  }

  String _formatTime(String dateTimeStr) {
    final dt = DateTime.tryParse(dateTimeStr);
    if (dt == null) return dateTimeStr;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
