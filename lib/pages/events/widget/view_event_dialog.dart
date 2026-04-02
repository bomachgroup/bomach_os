import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/events/controller/event_controller.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/services/events/event_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ViewEventDialog extends StatelessWidget {
  final Event event;

  const ViewEventDialog({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    Color eventColor = _getEventColor(event.eventType);

    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with colored bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: eventColor,
                    width: 4,
                  ),
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: eventColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: MyText(
                            _formatEventType(event.eventType),
                            size: 11,
                            weight: 600,
                            color: eventColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        MyText(
                          event.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event ID
                      _buildDetailItem(
                        icon: Icons.tag,
                        label: 'Event ID',
                        value: event.eventId,
                      ),

                      const SizedBox(height: 12),

                      // Status
                      _buildDetailItem(
                        icon: Icons.info_outline,
                        label: 'Status',
                        value: event.status,
                      ),

                      const SizedBox(height: 20),

                      // Time Information
                      const MyText(
                        'Time',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildDetailItem(
                        icon: Icons.access_time,
                        label: 'From',
                        value: _formatDateTime(event.eventTimeFrom),
                      ),

                      const SizedBox(height: 12),

                      _buildDetailItem(
                        icon: Icons.access_time_filled,
                        label: 'To',
                        value: _formatDateTime(event.eventTimeTo),
                      ),

                      const SizedBox(height: 20),

                      // Location
                      if (event.meetingLocation != null &&
                          event.meetingLocation!.isNotEmpty) ...[
                        const MyText(
                          'Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailItem(
                          icon: Icons.location_on_outlined,
                          label: 'Venue',
                          value: event.meetingLocation!,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Organizer
                      if (event.organizerName != null &&
                          event.organizerName!.isNotEmpty) ...[
                        _buildDetailItem(
                          icon: Icons.person_outline,
                          label: 'Organizer',
                          value: event.organizerName!,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Recurrence
                      if (event.isRecurring) ...[
                        const MyText(
                          'Recurrence',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDetailItem(
                          icon: Icons.repeat,
                          label: 'Recurring',
                          value: event.recurrence ?? 'Yes',
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Target Audience
                      if (event.targetAudience.isNotEmpty) ...[
                        const MyText(
                          'Target Audience',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: event.targetAudience.map((audience) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.blue.withValues(alpha: 0.3),
                                ),
                              ),
                              child: MyText(
                                audience,
                                size: 13,
                                weight: 500,
                                color: AppColors.blue,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete Event'),
                          content: const Text(
                              'Are you sure you want to delete this event?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        final controller = Get.find<EventController>();
                        await controller.deleteEvent(event.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const MyText(
                      'Delete Event',
                      size: 14,
                      weight: 500,
                      color: Colors.red,
                    ),
                  ),
                  MyElevatedButton(
                    child: 'Close',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              MyText(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A202C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatEventType(String type) {
    return type.replaceAll('_', ' ');
  }

  String _formatDateTime(String dateTimeStr) {
    final dt = DateTime.tryParse(dateTimeStr);
    if (dt == null) return dateTimeStr;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} at $hour:$minute $period';
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
}
