import 'package:bms_front_end/src/constants/colors.dart' show AppColors;
import 'package:flutter/material.dart';

import '../../components/text/my_text.dart';
import 'dialogs/client_dialog.dart';
import 'dialogs/lead_dialog.dart';
import 'models.dart';
import 'widgets/widgets.dart';

class InteractionsPage extends StatelessWidget {
  const InteractionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth < 900;

    Widget buildActionButton({
      required IconData icon,
      required String label,
      required bool isWide,
      void Function()? onPressed,
      Color? foregroundColor,
      Color? backgroundColor,
    }) {
      if (isWide) {
        return ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.white,
            foregroundColor: foregroundColor ?? Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          icon: Icon(icon, size: 18),
          label: Text(label, style: const TextStyle(fontSize: 12)),
          onPressed: onPressed,
        );
      } else {
        return IconButton(
          tooltip: label,
          style: IconButton.styleFrom(
            backgroundColor: backgroundColor ?? Colors.white,
            foregroundColor: foregroundColor ?? Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
        );
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 12,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MyText(
                    'Customer Relationship Management',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  MyText(
                    'Manage clients, leads, and customer interactions',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Row(
              spacing: 8,
              children: [
                buildActionButton(
                    onPressed: () {},
                    icon: Icons.message,
                    label: 'Log Interactions',
                    isWide: !isMobile),
                buildActionButton(
                    onPressed: () {
                      AddNewLeadDialog.show(context);
                    },
                    icon: Icons.control_point_duplicate_sharp,
                    label: 'Add Lead',
                    isWide: !isMobile),
                buildActionButton(
                    onPressed: () {
                      AddNewClientDialog.show(context);
                    },
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Add Client',
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    isWide: !isMobile),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: crmMetrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 4,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: isMobile
                ? 1.5
                : isTablet
                    ? 1
                    : 1.8,
          ),
          itemBuilder: (context, index) =>
              StandardMetricCard(data: crmMetrics[index]),
        ),
        const SizedBox(height: 32),
        const InteractonsWidget()
      ],
    );
  }
}

Map<String, Color> _getPriorityColors(String priority) {
  switch (priority.toLowerCase()) {
    case 'critical':
      return {'bg': const Color(0xFFFFE6E6), 'text': const Color(0xFFE74C3C)};
    case 'high':
      return {'bg': const Color(0xFFFFEFEB), 'text': const Color(0xFFF39C12)};
    case 'medium':
    default:
      return {'bg': const Color(0xFFE6F3FF), 'text': const Color(0xFF3498DB)};
  }
}

Map<String, Color> _getStatusColors(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return {'bg': const Color(0xFFE6FFF2), 'text': const Color(0xFF00B062)};
    case 'pending':
      return {'bg': const Color(0xFFF7F7F7), 'text': Colors.black87};
    case 'in progress':
      return {'bg': const Color(0xFFFFFBE8), 'text': const Color(0xFFF1C40F)};
    default:
      return {'bg': const Color(0xFFF7F7F7), 'text': Colors.black87};
  }
}

class InteractonsWidget extends StatelessWidget {
  const InteractonsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Client Interactions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track all client communications and activities',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              const Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search interactions...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF7F7F7),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFFF7F7F7),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  value: 'All Types',
                  items: <String>[
                    'All Types',
                    'Meeting',
                    'Call',
                    'Email',
                    'Site Visit'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          InteractionDataTable(),
        ],
      ),
    );
  }
}

class InteractionDataTable extends StatelessWidget {
  InteractionDataTable({super.key});
  final scrollControler = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollControler,
      child: SingleChildScrollView(
        controller: scrollControler,
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              WidgetStateProperty.resolveWith((states) => Colors.transparent),
          columnSpacing: 35,
          dataRowMinHeight: 60,
          dataRowMaxHeight: 80,
          dividerThickness: 1.0,
          columns: const <DataColumn>[
            DataColumn(
                label: Text('Client',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Type',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Subject',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Priority',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Status',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Date',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Created By',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Actions',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: interactionsMock
              .map((interaction) => _buildDataRow(interaction))
              .toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(ClientInteraction interaction) {
    final priorityColors = _getPriorityColors(interaction.priority);
    final statusColors = _getStatusColors(interaction.status);

    return DataRow(
      cells: <DataCell>[
        DataCell(Text(interaction.client,
            style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(_buildSimpleTag(interaction.type,
            backgroundColor: const Color(0xFFF0F0F0),
            textColor: Colors.black87)),
        DataCell(
          SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  interaction.subject,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  interaction.details,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        DataCell(_buildColoredTag(
          interaction.priority,
          backgroundColor: priorityColors['bg']!,
          textColor: priorityColors['text']!,
        )),
        DataCell(_buildColoredTag(
          interaction.status,
          backgroundColor: statusColors['bg']!,
          textColor: statusColors['text']!,
        )),
        DataCell(Text(interaction.date)),
        DataCell(Text(interaction.createdBy)),
        const DataCell(
          IconButton(
            icon: Icon(Icons.remove_red_eye_outlined, color: Colors.grey),
            onPressed: null,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleTag(String text,
      {required Color backgroundColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildColoredTag(String text,
      {required Color backgroundColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
