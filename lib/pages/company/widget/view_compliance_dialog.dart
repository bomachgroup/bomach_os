import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';

class ViewComplianceDialog extends StatelessWidget {
  final Map<String, dynamic> record;

  const ViewComplianceDialog({
    super.key,
    required this.record,
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
                    'Compliance Details',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
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
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 0.6,
                            color: getRandomColorFromList(record['status']),
                          ),
                          color: getRandomColorFromList(record['status'])
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: MyText(
                          record['status'] == 'approved'
                              ? 'Approved'
                              : record['status'] == 'pending'
                                  ? 'Pending'
                                  : 'Expired',
                          size: 14,
                          weight: 500,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Compliance ID
                      _buildDetailItem(
                        'Compliance ID',
                        record['id'],
                      ),

                      const SizedBox(height: 16),

                      // Type
                      _buildDetailItem(
                        'Compliance Type',
                        record['type'],
                      ),

                      const SizedBox(height: 24),

                      // Submitted By Section
                      const MyText(
                        'Submitted By',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            width: 48,
                            height: 48,
                            child: Center(
                              child: MyText(
                                record['user'][0],
                                size: 20,
                                weight: 600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                record['user'],
                                size: 16,
                                weight: 500,
                              ),
                              MyText(
                                record['userEmail'],
                                size: 14,
                                weight: 400,
                                color: AppColors.neutral500,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Dates
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailItem(
                              'Date Submitted',
                              record['dateSubmitted'],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDetailItem(
                              'Expiry Date',
                              record['expiryDate'],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Additional Information
                      const MyText(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildDetailItem(
                        'Issuing Authority',
                        'National Compliance Agency',
                      ),

                      const SizedBox(height: 16),

                      _buildDetailItem(
                        'Reference Number',
                        'REF-${record['id']}-2025',
                      ),

                      const SizedBox(height: 16),

                      _buildDetailItem(
                        'Priority Level',
                        'High',
                      ),

                      const SizedBox(height: 16),

                      _buildDetailItem(
                        'Description',
                        'This compliance record contains all necessary documentation and certifications required by regulatory authorities.',
                      ),

                      const SizedBox(height: 24),

                      // Documents Section
                      const MyText(
                        'Attached Documents',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDocumentItem('Certificate.pdf', '2.5 MB'),
                      const SizedBox(height: 8),
                      _buildDocumentItem('Supporting_Document.pdf', '1.8 MB'),
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
            color: AppColors.neutral500,
          ),
        ),
        const SizedBox(height: 4),
        MyText(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.neutral900,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentItem(String name, String size) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Iconsax.document_text,
            color: AppColors.primary,
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
                  color: AppColors.neutral500,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Iconsax.document_download),
            onPressed: () {
              // Handle download
            },
          ),
        ],
      ),
    );
  }
}
