import 'package:flutter/material.dart';

import '../../components/text/my_text.dart';
import '../../src/constants/colors.dart';
import 'dialogs/client_dialog.dart';
import 'dialogs/lead_dialog.dart' show AddNewLeadDialog;
import 'models.dart';
import 'widgets/widgets.dart';

class CrmLeadsPage extends StatelessWidget {
  const CrmLeadsPage({super.key});

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
        const LeadsTable()
      ],
    );
  }
}

Map<String, Color> _getStatusColors(String status) {
  switch (status.toLowerCase()) {
    case 'qualified':
      return {'bg': const Color(0xFFF6F0FF), 'text': const Color(0xFF9B59B6)};
    case 'proposal':
      return {'bg': const Color(0xFFFFFBE8), 'text': const Color(0xFFF1C40F)};
    case 'new':
    default:
      return {'bg': const Color(0xFFEEF7FF), 'text': const Color(0xFF3498DB)};
  }
}

class LeadsTable extends StatelessWidget {
  const LeadsTable({super.key});

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
            'Sales Pipeline',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track and manage your sales leads',
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
                    hintText: 'Search leads...',
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
                  value: 'All Status',
                  items: <String>['All Status', 'qualified', 'proposal', 'new']
                      .map<DropdownMenuItem<String>>((String value) {
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
          LeadDataTable(),
        ],
      ),
    );
  }
}

class LeadDataTable extends StatelessWidget {
  LeadDataTable({super.key});

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
                label: Text('Lead',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Contact',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Company',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Source',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Status',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Score',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Value',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Next Follow-up',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Actions',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: leadsMock.map((lead) => _buildDataRow(lead)).toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(SalesLead lead) {
    final statusColors = _getStatusColors(lead.status);

    return DataRow(
      cells: <DataCell>[
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                lead.leadName,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                lead.leadRepresentative,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: [
                  const Icon(Icons.mail_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(lead.contactEmail, style: const TextStyle(fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.phone_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(lead.contactPhone, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        DataCell(Text(lead.company)),
        DataCell(_buildSimpleTag(lead.source,
            backgroundColor: const Color(0xFFF7F7F7),
            textColor: Colors.black87)),
        DataCell(_buildStatusTag(
          lead.status,
          backgroundColor: statusColors['bg']!,
          textColor: statusColors['text']!,
        )),
        DataCell(
          Row(
            children: [
              Text(
                lead.score.toString(),
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(width: 8),
              _buildProgressBar(lead.score.toDouble()),
            ],
          ),
        ),
        DataCell(Text(lead.value,
            style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(lead.nextFollowUp)),
        const DataCell(
          IconButton(
            icon: Icon(Icons.remove_red_eye_outlined, color: Colors.grey),
            onPressed: null,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTag(String text,
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

  Widget _buildProgressBar(double score) {
    return SizedBox(
      width: 50,
      child: LinearProgressIndicator(
        value: score / 100,
        backgroundColor: Colors.grey[200],
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
        minHeight: 4,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
