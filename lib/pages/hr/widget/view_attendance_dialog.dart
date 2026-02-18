import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';

import '../controller/biometrics_controller.dart';
import '../models/attendance_models.dart';

class ViewAttendanceDialog extends StatelessWidget {
  final BiometricAttendanceRecord record;
  final String token;

  const ViewAttendanceDialog({super.key, required this.record, required this.token});

  @override
  Widget build(BuildContext context) {
    final BiometricsController controller = Get.find<BiometricsController>();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Entry Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            
            _buildRow('ID', record.id.toString()),
            _buildRow('Type', record.attendanceType),
            _buildRow('Date', DateFormat('yyyy-MM-dd').format(record.timestamp)),
            _buildRow('Time', DateFormat('hh:mm a').format(record.timestamp)),
            _buildRow('Method', record.verificationMethod),
            if (record.notes != null) _buildRow('Notes', record.notes!),
            
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(() => MyOutlinedButton(
                  textColor: Colors.red,
                  child: controller.isLoading.value ? 'Deleting...' : 'Delete Entry',
                  onTap: controller.isLoading.value ? null : () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Delete Entry'),
                        content: const Text('Are you sure you want to delete this log?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('No')),
                          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Yes')),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      final success = await controller.deleteAttendance(token, record.id);
                      if (context.mounted) {
                        if (success) {
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: ${controller.errorMessage.value}"), backgroundColor: Colors.red)
                          );
                        }
                      }
                    }
                  },
                )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}