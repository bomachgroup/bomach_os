import 'package:bms_front_end/components/input/my_dropdown.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/text/my_text.dart';
import '../controllers/security_controller.dart';

class SecurityLogs extends StatelessWidget {
  final bool isMobile;
  const SecurityLogs({super.key, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SecurityController());
    final screenWidth = MediaQuery.of(context).size.width;
    final bool mobile = isMobile || screenWidth < 500;

    return Container(
      padding: const EdgeInsets.all(24.0),
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
        children: [
          _buildHeaderAndActions(mobile, controller),
          const SizedBox(height: 16),
          Container(
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
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ));
              }
              if (controller.auditLogs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                      child: Text('No audit logs found.',
                          style: TextStyle(color: Colors.grey))),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.auditLogs.length,
                itemBuilder: (context, index) {
                  return _AuditLogTileLive(
                    log: controller.auditLogs[index],
                    isMobile: mobile,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAndActions(bool mobile, SecurityController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Iconsax.document_text,
                      color: Colors.black, size: 24),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Obx(() => MyText(
                          'Security Audit Logs (${controller.totalLogs.value})',
                          style: TextStyle(
                            fontSize: mobile ? 15 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                ],
              ),
              MyText(
                'Complete security event history and audit trail',
                style: TextStyle(
                    fontSize: mobile ? 12 : 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        if (!mobile)
          Row(
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search logs...',
                    prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.neutral100,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  ),
                  onChanged: controller.onSearchChanged,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: MyDropdown(
                  hintText: 'All Status',
                  items: const ['All Status', 'Success', 'Failure', 'Warning'],
                  onChanged: (String? newValue) {},
                  fillColor: AppColors.neutral100,
                  height: 48,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Iconsax.document_download, size: 20),
                label: const Text('Export',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Iconsax.search_normal, size: 20),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Iconsax.textalign_left, size: 20),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Iconsax.document_download, size: 20),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ],
          )
      ],
    );
  }
}

class _AuditLogTileLive extends StatelessWidget {
  final AuditLogEntry log;
  final bool isMobile;

  const _AuditLogTileLive({required this.log, this.isMobile = false});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'failure':
      case 'failed':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Iconsax.tick_circle;
      case 'failure':
      case 'failed':
        return Iconsax.close_circle;
      case 'warning':
        return Iconsax.warning_2;
      default:
        return Iconsax.info_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(log.auditStatusDisplay);
    final double fontSize = isMobile ? 13 : 15;
    final double metaFontSize = isMobile ? 11 : 13;
    final double iconSize = isMobile ? 16 : 20;
    final double padding = isMobile ? 10 : 16;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: isMobile ? 8.0 : 12.0),
            child: Icon(
              _getStatusIcon(log.auditStatusDisplay),
              color: statusColor,
              size: iconSize,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.activity,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: fontSize),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  'User: ${log.userFullName ?? 'System'} • Type: ${log.auditTypeDisplay}${log.ipAddress != null ? ' • IP: ${log.ipAddress}' : ''}',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: metaFontSize),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                log.createdAt.length > 16
                    ? log.createdAt.substring(0, 16).replaceAll('T', ' ')
                    : log.createdAt,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: metaFontSize),
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  log.auditStatusDisplay,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
