import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/text/my_text.dart';
import '../../src/constants/colors.dart';
import '../../src/services/crm/crm_service.dart';
import 'controllers/crm_controller.dart';
import 'dialogs/client_dialog.dart';
import 'dialogs/lead_dialog.dart' show AddNewLeadDialog;
import 'models.dart';
import 'widgets/widgets.dart';

class CrmClientsPage extends StatelessWidget {
  const CrmClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CrmController());
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
        Obx(() {
          final metrics = [
            MetricData(
                title: 'Total Clients',
                value: controller.totalClients.value.toString(),
                icon: Icons.people_alt,
                color: Colors.blue.shade600,
                subtitle: 'Active client base'),
            MetricData(
                title: 'Total Leads',
                value: controller.totalLeads.value.toString(),
                icon: Icons.trending_up,
                color: Colors.green.shade600,
                subtitle: 'Current leads'),
            MetricData(
                title: 'Conversion Rate',
                value: controller.totalLeads.value > 0
                    ? '${((controller.totalClients.value / (controller.totalClients.value + controller.totalLeads.value)) * 100).toStringAsFixed(1)}%'
                    : '0%',
                icon: Icons.attach_money,
                color: Colors.purple.shade600,
                subtitle: 'Lead to client'),
            MetricData(
                title: 'Retention Rate',
                value: '—',
                icon: Icons.star,
                color: Colors.orange.shade600,
                subtitle: 'Client retention'),
          ];

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: metrics.length,
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
                StandardMetricCard(data: metrics[index]),
          );
        }),
        const SizedBox(height: 32),
        _ClientsTableLive(controller: controller),
      ],
    );
  }
}

class _ClientsTableLive extends StatelessWidget {
  final CrmController controller;
  const _ClientsTableLive({required this.controller});

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
        children: [
          const Text('Clients',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          const Text('Manage your client relationships',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search clients...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Color(0xFFF7F7F7),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: controller.onClientSearchChanged,
          ),
          const SizedBox(height: 24),
          Obx(() {
            if (controller.isLoadingClients.value) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ));
            }
            if (controller.clientList.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                    child: Text('No clients found.',
                        style: TextStyle(color: Colors.grey))),
              );
            }
            return _ClientDataTableLive(clients: controller.clientList);
          }),
        ],
      ),
    );
  }
}

class _ClientDataTableLive extends StatelessWidget {
  final List<CrmClient> clients;
  _ClientDataTableLive({required this.clients});

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
          columns: const [
            DataColumn(
                label: Text('Client',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Email',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Phone',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Balance',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: clients.map((c) {
            return DataRow(cells: [
              DataCell(Text(c.fullName,
                  style: const TextStyle(fontWeight: FontWeight.w600))),
              DataCell(Text(c.email)),
              DataCell(Text(c.phoneNumber ?? '—')),
              DataCell(Text('₦${c.balance.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w600))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
