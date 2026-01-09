import 'package:flutter/material.dart';

import '../../components/input/my_dropdown.dart';
import '../../components/text/my_text.dart';
import '../../src/constants/colors.dart';
import 'dialogs/client_dialog.dart';
import 'dialogs/lead_dialog.dart';
import 'models.dart';
import 'widgets/widgets.dart';

class CrmClientsPage extends StatelessWidget {
  const CrmClientsPage({super.key});

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
        const ClientsTable(),
      ],
    );
  }
}

class ClientsTable extends StatelessWidget {
  const ClientsTable({super.key});

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
            'Clients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Manage your client relationships',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              if (isMobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search clients...',
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
                    const SizedBox(height: 12),
                    MyDropdown(
                      hintText: 'All Status',
                      items: const ['All Status', 'active', 'inactive'],
                      onChanged: (String? newValue) {},
                      fillColor: const Color(0xFFF7F7F7),
                    ),
                    const SizedBox(height: 12),
                    MyDropdown(
                      hintText: 'All Types',
                      items: const [
                        'All Types',
                        'Government',
                        'Corporate',
                        'Institution'
                      ],
                      onChanged: (String? newValue) {},
                      fillColor: const Color(0xFFF7F7F7),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: <Widget>[
                    const Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search clients...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
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
                    Flexible(
                      child: MyDropdown(
                        hintText: 'All Status',
                        items: const ['All Status', 'active', 'inactive'],
                        onChanged: (String? newValue) {},
                        fillColor: const Color(0xFFF7F7F7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: MyDropdown(
                        hintText: 'All Types',
                        items: const [
                          'All Types',
                          'Government',
                          'Corporate',
                          'Institution'
                        ],
                        onChanged: (String? newValue) {},
                        fillColor: const Color(0xFFF7F7F7),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),
          ClientDataTable(),
        ],
      ),
    );
  }
}

class ClientDataTable extends StatelessWidget {
  ClientDataTable({super.key});
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor:
              WidgetStateProperty.resolveWith((states) => Colors.transparent),
          columnSpacing: 40,
          dataRowMinHeight: 60,
          dataRowMaxHeight: 80,
          dividerThickness: 1.0,
          columns: const <DataColumn>[
            DataColumn(
                label: Text('Client',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Contact',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Type',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Industry',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Status',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Value',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Projects',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Actions',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: mockClients.map((client) => _buildDataRow(client)).toList(),
        ),
      ),
    );
  }

  DataRow _buildDataRow(ClientItem client) {
    final email = client.contact.split('\n').first;
    final phone = client.contact.split('\n').length > 1
        ? client.contact.split('\n')[1]
        : null;

    return DataRow(
      cells: <DataCell>[
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                client.name,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                client.type,
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
                  Text(email, style: const TextStyle(fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.phone_outlined,
                      size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(phone ?? 'none', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        DataCell(_buildStatusTag(client.type,
            backgroundColor: const Color(0xFFF0F0F0),
            textColor: Colors.black87)),
        DataCell(Text(client.industry)),
        DataCell(_buildStatusTag(client.status,
            backgroundColor: const Color(0xFFE6FFF2),
            textColor: const Color(0xFF00B062))),
        DataCell(Text(client.value,
            style: const TextStyle(fontWeight: FontWeight.w600))),
        DataCell(Text(client.projects.toString())),
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
}
