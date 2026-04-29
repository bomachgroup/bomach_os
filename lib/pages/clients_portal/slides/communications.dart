import 'package:bomach_os/pages/clients_portal/model/coms_model.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:flutter/material.dart';
import '../dialog/send_message.dart';

class ClientCommunicationsScreen extends StatelessWidget {
  final bool isMobile;

  const ClientCommunicationsScreen({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool mobile = isMobile || constraints.maxWidth < 500;
        final double headerFontSize = mobile ? 18 : 24;
        final double subHeaderFontSize = mobile ? 12 : 14;
        final double horizontalPadding = mobile ? 12.0 : 24.0;
        final double searchWidth = mobile ? 140 : 250;
        final double buttonPadding = mobile ? 10 : 16;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: _buildHeaderAndActions(context, mobile, headerFontSize,
                    subHeaderFontSize, searchWidth, buttonPadding),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.neutral200),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: mobile ? 4.0 : 8.0),
                  itemCount: mockCommunications.length,
                  itemBuilder: (context, index) {
                    return CommunicationTile(
                      communication: mockCommunications[index],
                      isMobile: mobile,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderAndActions(
      BuildContext context,
      bool mobile,
      double headerFontSize,
      double subHeaderFontSize,
      double searchWidth,
      double buttonPadding) {
    final children = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Client Communications',
            style: TextStyle(
                fontSize: headerFontSize, fontWeight: FontWeight.bold),
          ),
          Text(
            'Messages and notifications sent through the portal',
            style:
                TextStyle(fontSize: subHeaderFontSize, color: Colors.grey[600]),
          ),
        ],
      ),
      if (!mobile) const Spacer(),
      SizedBox(
        height: mobile ? 10 : 0,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: searchWidth,
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.neutral100,
                contentPadding: EdgeInsets.symmetric(
                    vertical: 0, horizontal: mobile ? 6 : 10),
              ),
            ),
          ),
          SizedBox(
            width: mobile ? 6 : 10,
          ),
          ElevatedButton.icon(
            onPressed: () {
              SendMessageDialog.show(context);
            },
            icon: Icon(Iconsax.send_2, size: mobile ? 16 : 20),
            label: Text('Send Message',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: mobile ? 12 : 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: buttonPadding, vertical: buttonPadding),
            ),
          ),
        ],
      ),
    ];
    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }
  }
}

class CommunicationTile extends StatelessWidget {
  final Communication communication;
  final bool isMobile;

  const CommunicationTile({
    super.key,
    required this.communication,
    required this.isMobile,
  });

  Color _getIconColor(String type) {
    switch (type) {
      case 'Notification':
        return AppColors.primary;
      case 'Message':
        return Colors.green;
      case 'Announcement':
        return Colors.purple;
      case 'Reminder':
        return Colors.deepOrange;
      case 'Welcome':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'Notification':
        return Iconsax.notification;
      case 'Message':
        return Iconsax.sms;
      case 'Announcement':
        return Iconsax.flash;
      case 'Reminder':
        return Iconsax.clock;
      case 'Welcome':
        return Iconsax.emoji_happy;
      default:
        return Iconsax.info_circle;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red.shade600;
      case 'Low':
        return Colors.grey.shade600;
      case 'Normal':
      default:
        return AppColors.primary.withValues(alpha: 0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getIconColor(communication.type);
    final priorityColor = _getPriorityColor(communication.priority);
    final bool isUnread = communication.status == 'Unread';
    final double fontSize = isMobile ? 13 : 16;
    final double tagFontSize = isMobile ? 9 : 10;
    final double metaFontSize = isMobile ? 10 : 12;
    final double iconSize = isMobile ? 16 : 20;
    final double horizontalPadding = isMobile ? 12.0 : 24.0;
    final double verticalPadding = isMobile ? 10.0 : 16.0;

    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      decoration: BoxDecoration(
        color: isUnread ? AppColors.primary.withValues(alpha: 0.03) : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: isMobile ? 2.0 : 4.0),
            child: Icon(
              _getIcon(communication.type),
              color: iconColor,
              size: iconSize,
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      communication.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                        color: isUnread ? Colors.black : Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(width: isMobile ? 4 : 8),
                    _buildTag(communication.priority, priorityColor,
                        Colors.white, tagFontSize),
                    if (isUnread) ...[
                      SizedBox(width: isMobile ? 4 : 8),
                      _buildTag(communication.status, Colors.red.shade700,
                          Colors.white, tagFontSize),
                    ],
                  ],
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  communication.content,
                  style: TextStyle(fontSize: fontSize - 2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isMobile ? 4 : 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    Text(
                      'To: ${communication.recipient}',
                      style:
                          TextStyle(color: Colors.grey, fontSize: metaFontSize),
                    ),
                    if (communication.type != 'Notification')
                      Text(
                        '| From: ${communication.sender}',
                        style: TextStyle(
                            color: Colors.grey, fontSize: metaFontSize),
                      ),
                    Text(
                      '| ${communication.date}',
                      style:
                          TextStyle(color: Colors.grey, fontSize: metaFontSize),
                    ),
                    if (communication.attachments > 0)
                      Text(
                        '| ${communication.attachments} attachment(s)',
                        style: TextStyle(
                            color: Colors.grey, fontSize: metaFontSize),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTag('Delivered', Colors.black, Colors.white, tagFontSize),
              SizedBox(height: isMobile ? 4 : 8),
              _buildTag(communication.type, Colors.grey.shade200, Colors.black,
                  tagFontSize),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(
      String text, Color bgColor, Color textColor, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
