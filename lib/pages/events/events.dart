import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/events/widget/add_event_dialog.dart';
import 'package:bms_front_end/pages/events/widget/view_event_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMockEvents();
  }

  void _loadMockEvents() {
    final now = DateTime.now();
    _events = {
      DateTime(now.year, now.month, now.day): [
        {
          'id': 'EVT-001',
          'title': 'Team Meeting',
          'description': 'Weekly team sync-up meeting',
          'time': '09:00 AM',
          'duration': '1 hour',
          'location': 'Conference Room A',
          'attendees': ['John Doe', 'Sarah Johnson', 'Michael Brown'],
          'type': 'meeting',
        },
        {
          'id': 'EVT-002',
          'title': 'Project Deadline',
          'description': 'CRM Module Phase 1 delivery',
          'time': '05:00 PM',
          'duration': 'All day',
          'location': 'Development Department',
          'attendees': ['Development Team'],
          'type': 'deadline',
        },
      ],
      DateTime(now.year, now.month, now.day + 2): [
        {
          'id': 'EVT-003',
          'title': 'Client Presentation',
          'description': 'Q4 Progress presentation to stakeholders',
          'time': '02:00 PM',
          'duration': '2 hours',
          'location': 'Board Room',
          'attendees': ['Management Team', 'Stakeholders'],
          'type': 'presentation',
        },
      ],
      DateTime(now.year, now.month, now.day + 5): [
        {
          'id': 'EVT-004',
          'title': 'Training Session',
          'description': 'New software tools training',
          'time': '10:00 AM',
          'duration': '3 hours',
          'location': 'Training Center',
          'attendees': ['All Staff'],
          'type': 'training',
        },
      ],
      DateTime(now.year, now.month, now.day + 7): [
        {
          'id': 'EVT-005',
          'title': 'Company Event',
          'description': 'Annual company gathering',
          'time': '06:00 PM',
          'duration': '4 hours',
          'location': 'Main Hall',
          'attendees': ['All Staff'],
          'type': 'event',
        },
      ],
    };
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final selectedDayEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    return SingleChildScrollView(
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
                          style: AppText.black_500_32,
                        ),
                        SizedBox(height: 8),
                        MyText(
                          'Manage and track all company events',
                          size: 14,
                          weight: 400,
                          color: Color(0xFF64748B),
                        ),
                      ],
                    ),
                    MyElevatedButton(
                      icon: const Icon(
                        Icons.add_circle_outline_rounded,
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

          // Calendar Section
          _buildCalendarSection(),
          kSizedBox,

          // Events List Section
          _buildEventsListSection(selectedDayEvents),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
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
                    color: AppColors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: MyText(
                    '${_events.values.expand((e) => e).length} Events',
                    size: 12,
                    weight: 500,
                    color: AppColors.blue,
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
              eventLoader: _getEventsForDay,
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
                leftChevronIcon: Icon(Icons.chevron_left),
                rightChevronIcon: Icon(Icons.chevron_right),
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.blue,
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
                _buildLegendItem('Meeting', Colors.blue),
                _buildLegendItem('Deadline', Colors.red),
                _buildLegendItem('Training', Colors.orange),
                _buildLegendItem('Presentation', Colors.green),
                _buildLegendItem('Event', Colors.purple),
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
          color: const Color(0xFF64748B),
        ),
      ],
    );
  }

  Widget _buildEventsListSection(List<Map<String, dynamic>> events) {
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
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: MyText(
                        _selectedDay != null
                            ? _formatDate(_selectedDay!)
                            : _formatDate(_focusedDay),
                        size: 12,
                        weight: 500,
                        color: const Color(0xFF64748B),
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
                          Icons.event_busy_outlined,
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
                  children: events
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        final event = entry.value;
                        return Column(
                          children: [
                            _buildEventItem(event),
                            if (index < events.length - 1)
                              const Divider(height: 1),
                          ],
                        );
                      })
                      .toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildEventItem(Map<String, dynamic> event) {
    Color eventColor = _getEventColor(event['type']);

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
                          event['title'],
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
                          event['type'].toString().toUpperCase(),
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
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      MyText(
                        '${event['time']} • ${event['duration']}',
                        size: 13,
                        weight: 400,
                        color: const Color(0xFF64748B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: MyText(
                          event['location'],
                          size: 13,
                          weight: 400,
                          color: const Color(0xFF64748B),
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
      case 'meeting':
        return Colors.blue;
      case 'deadline':
        return Colors.red;
      case 'training':
        return Colors.orange;
      case 'presentation':
        return Colors.green;
      case 'event':
        return Colors.purple;
      default:
        return Colors.grey;
    }
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
