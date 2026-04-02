import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

import '../../../src/model/employees_model.dart';

class ViewAssociateDialog extends StatelessWidget {
  final Employee associate;

  const ViewAssociateDialog({super.key, required this.associate});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText('Associate Details',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.greyBg,
                        backgroundImage: associate.profilePicture != null
                            ? NetworkImage(associate.profilePicture!)
                            : null,
                        child: associate.profilePicture == null
                            ? Text(associate.firstName[0],
                                style: const TextStyle(fontSize: 24))
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText('${associate.firstName} ${associate.lastName}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          MyText(associate.employmentType ?? 'Associate',
                              color: Colors.grey),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('Email', associate.email),
                  _buildDetailRow('Phone', associate.phoneNumber ?? '-'),
                  _buildDetailRow('Address', associate.address ?? '-'),
                  _buildDetailRow(
                      'Status', associate.isActive ? 'Active' : 'Inactive'),
                  _buildDetailRow(
                      'Contract Value',
                      associate.grossSalary != null
                          ? '₦${associate.grossSalary}'
                          : '-'),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: MyText(label, color: const Color(0xFF64748B), size: 14),
          ),
          Expanded(
            child: MyText(value, weight: 500, size: 14),
          ),
        ],
      ),
    );
  }
}
