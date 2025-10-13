import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';

class ViewAssociateDialog extends StatelessWidget {
  final Map<String, dynamic> associate;

  const ViewAssociateDialog({
    super.key,
    required this.associate,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText(
                    'Associate Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Section with Avatar
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.blue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            width: 80,
                            height: 80,
                            child: Center(
                              child: MyText(
                                associate['name'][0],
                                size: 32,
                                weight: 600,
                                color: AppColors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  associate['name'],
                                  size: 20,
                                  weight: 600,
                                ),
                                const SizedBox(height: 4),
                                MyText(
                                  associate['role'],
                                  size: 16,
                                  weight: 400,
                                  color: const Color(0xFF64748B),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 0.6,
                                      color:
                                          getRandomColorFromList(associate['status']),
                                    ),
                                    color: getRandomColorFromList(associate['status'])
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: MyText(
                                    associate['status'] == 'active'
                                        ? 'Active'
                                        : associate['status'] == 'pending'
                                            ? 'Pending'
                                            : 'Expired',
                                    size: 14,
                                    weight: 500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Personal Information Section
                      const MyText(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildDetailItem(
                        'Associate ID',
                        associate['id'],
                      ),

                      const SizedBox(height: 16),

                      _buildDetailItem(
                        'Email Address',
                        associate['email'],
                      ),

                      const SizedBox(height: 16),

                      _buildDetailItem(
                        'Phone Number',
                        associate['phone'],
                      ),

                      const SizedBox(height: 24),

                      // Professional Information Section
                      const MyText(
                        'Professional Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildDetailItem(
                        'Company',
                        associate['company'],
                      ),

                      const SizedBox(height: 16),

                      _buildDetailItem(
                        'Role/Position',
                        associate['role'],
                      ),

                      const SizedBox(height: 16),

                      _buildDetailItem(
                        'Specialization',
                        'Technical Consulting & Implementation',
                      ),

                      const SizedBox(height: 24),

                      // Contract Information Section
                      const MyText(
                        'Contract Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              'Start Date',
                              associate['startDate'],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailItem(
                              'End Date',
                              associate['endDate'],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildDetailItem(
                        'Contract Value',
                        '₦2,500,000',
                      ),

                      const SizedBox(height: 16),

                      _buildDetailItem(
                        'Payment Terms',
                        'Monthly',
                      ),

                      const SizedBox(height: 16),

                      _buildDetailItem(
                        'Supervisor/Point of Contact',
                        'Sarah Johnson (HR Manager)',
                      ),

                      const SizedBox(height: 16),

                      _buildDetailItem(
                        'Scope of Work',
                        'Provide consulting services for digital transformation initiatives, including system analysis, implementation planning, and technical advisory.',
                      ),

                      const SizedBox(height: 24),

                      // Documents Section
                      const MyText(
                        'Attached Documents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDocumentItem('Contract_Agreement.pdf', '1.2 MB'),
                      const SizedBox(height: 8),
                      _buildDocumentItem('Resume_CV.pdf', '856 KB'),
                      const SizedBox(height: 8),
                      _buildDocumentItem('NDA_Signed.pdf', '324 KB'),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
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

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        MyText(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A202C),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItem(String name, String size) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.description_outlined,
            color: AppColors.blue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  name,
                  size: 14,
                  weight: 500,
                ),
                MyText(
                  size,
                  size: 12,
                  weight: 400,
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () {
              // Handle download
            },
          ),
        ],
      ),
    );
  }
}
