import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

import '../model/anl_model.dart';

class PortalUsageDashboard extends StatelessWidget {
  final bool isMobile;

  const PortalUsageDashboard({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricsGrid(context),
            SizedBox(height: isMobile ? 24 : 32),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 1;
    if (screenWidth >= 1200) {
      crossAxisCount = 3;
    } else if (screenWidth >= 700) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 20.0,
      mainAxisSpacing: 20.0,
      childAspectRatio: isMobile ? 0.9 : 1.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricCard(
          title: 'Portal Usage',
          children: [
            _buildMetricDetail(label: 'Total Users', value: '0'),
            _buildMetricDetail(label: 'Active This Month', value: '0'),
            _buildMetricDetail(label: 'New Users', value: '0'),
            _buildMetricDetail(label: 'Login Sessions', value: '0'),
          ],
        ),
        _buildMetricCard(
          title: 'User Engagement',
          isGraph: true,
          children: [
            _buildMetricDetail(label: 'Document Downloads', value: '342'),
            _buildMetricDetail(label: 'Messages Sent', value: '0'),
            _buildMetricDetail(label: 'Avg. Session (min)', value: '0'),
            const SizedBox(height: 10),
            _buildProgressDetail(
                label: 'User Activity', value: 0.78, valueText: '78%'),
          ],
        ),
        _buildMetricCard(
          title: 'Content Performance',
          children: [
            _buildMetricDetail(
                label: 'Most Downloaded', value: 'Project Reports'),
            _buildMetricDetail(label: 'Avg. Downloads/Doc', value: '5.2'),
            _buildMetricDetail(label: 'Active Features', value: '6/7'),
            const SizedBox(height: 10),
            _buildProgressDetail(
                label: 'Portal Health', value: 0.92, valueText: '92%'),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      {required String title,
      required List<Widget> children,
      bool isGraph = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16),
      constraints: const BoxConstraints(maxHeight: 130),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isGraph ? Icons.show_chart : Icons.dashboard,
                  color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const Spacer(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMetricDetail({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildProgressDetail(
      {required String label,
      required double value,
      required String valueText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text(valueText,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          'Latest portal activities and client interactions',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: mockActivities
                .map((activity) => ActivityTile(activity: activity))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class ActivityTile extends StatelessWidget {
  final ActivityItem activity;

  const ActivityTile({super.key, required this.activity});

  Color _getIconColor(String type) {
    switch (type) {
      case 'Update':
        return AppColors.blue;
      case 'Review':
        return Colors.green;
      case 'Feature':
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
      case 'Update':
        return Icons.notifications_none;
      case 'Review':
        return Icons.insert_drive_file_outlined;
      case 'Feature':
        return Icons.fiber_new;
      case 'Reminder':
        return Icons.access_time;
      case 'Welcome':
        return Icons.tag_faces;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildStatusTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getIconColor(activity.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Icon(
              _getIcon(activity.type),
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activity.metadata,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          _buildStatusTag(activity.status, Colors.black, Colors.white),
        ],
      ),
    );
  }
}
