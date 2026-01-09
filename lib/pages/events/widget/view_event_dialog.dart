import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class ViewEventDialog extends StatelessWidget {
  final Map<String, dynamic> event;

  const ViewEventDialog({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    Color eventColor = _getEventColor(event['type']);

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
                            event['type'].toString().toUpperCase(),
                            size: 11,
                            weight: 600,
                            color: eventColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        MyText(
                          event['title'],
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
                        value: event['id'],
                      ),

                      const SizedBox(height: 20),

                      // Time Information
                      const MyText(
                        'Time & Duration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildDetailItem(
                        icon: Icons.access_time,
                        label: 'Start Time',
                        value: event['time'],
                      ),

                      const SizedBox(height: 12),

                      _buildDetailItem(
                        icon: Icons.hourglass_empty,
                        label: 'Duration',
                        value: event['duration'],
                      ),

                      const SizedBox(height: 20),

                      // Location
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
                        value: event['location'],
                      ),

                      const SizedBox(height: 20),

                      // Description
                      if (event['description'] != null) ...[
                        const MyText(
                          'Description',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        MyText(
                          event['description'],
                          size: 14,
                          weight: 400,
                          color: const Color(0xFF64748B),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Attendees
                      const MyText(
                        'Attendees',
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
                        children: (event['attendees'] as List<String>).map((attendee) {
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: MyText(
                                      attendee[0],
                                      size: 12,
                                      weight: 600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                MyText(
                                  attendee,
                                  size: 13,
                                  weight: 500,
                                  color: AppColors.blue,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
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
                    onPressed: () {
                      // Handle edit
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const MyText(
                      'Edit Event',
                      size: 14,
                      weight: 500,
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
}
