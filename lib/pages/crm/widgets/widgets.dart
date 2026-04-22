import 'package:bms_front_end/pages/crm/models.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';

import '../../../components/text/my_text.dart';

Widget buildTag(String text, Color color,
    {Color? textColor, bool filled = true}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: filled ? color : color.withValues(alpha: 0.1),
      border: filled ? null : Border.all(color: color),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        color: textColor ?? (filled ? Colors.white : color),
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class StandardMetricCard extends StatelessWidget {
  final MetricData data;
  final bool isMobile;

  const StandardMetricCard(
      {super.key, required this.data, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      constraints: const BoxConstraints(maxHeight: 130),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: MyText(
                  data.title,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ),
              CircleAvatar(
                radius: 12,
                backgroundColor: data.color.withValues(alpha: 0.1),
                child: Icon(data.icon, size: 14, color: data.color),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                data.value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (data.subtitle.isNotEmpty)
                MyText(
                  data.subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ContactDetails extends StatelessWidget {
  final String contact;

  const ContactDetails({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    // Just to extract the data instead of stressing to start seperation it from mock data
    final email = contact.split('\n').first;
    final phone =
        contact.split('\n').length > 1 ? contact.split('\n')[1] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.sms, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Expanded(
              child: Text(email,
                  style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ),
          ],
        ),
        if (phone != null)
          Row(
            children: [
              Icon(Iconsax.call, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(phone,
                  style: const TextStyle(fontSize: 13, color: Colors.black87)),
            ],
          ),
      ],
    );
  }
}

Color getPriorityColor(String priority) {
  switch (priority) {
    case 'High':
      return Colors.red.shade700;
    case 'Medium':
      return Colors.orange.shade700;
    case 'Critical':
      return Colors.red.shade900;
    default:
      return Colors.purple.shade700;
  }
}

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
    case 'active':
    case 'success':
      return Colors.green.shade600;
    case 'pending':
    case 'new':
    case 'warning':
      return Colors.orange.shade600;
    case 'in progress':
    case 'qualified':
      return Colors.purple.shade600;
    case 'proposal':
      return Colors.blue.shade600;
    default:
      return Colors.grey.shade600;
  }
}
