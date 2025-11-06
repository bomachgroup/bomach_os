import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/helper/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ViewAssetDialog extends StatelessWidget {
  final Map<String, dynamic> asset;

  const ViewAssetDialog({
    super.key,
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            asset['name'],
                            size: 20,
                            weight: 600,
                          ),
                          const SizedBox(height: 4),
                          MyText(
                            asset['id'],
                            size: 14,
                            weight: 400,
                            color: const Color(0xFF64748B),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.6,
                          color: getRandomColorFromList(asset['status']),
                        ),
                        color: getRandomColorFromList(asset['status'])
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: MyText(
                        asset['status'] == 'in-use'
                            ? 'In Use'
                            : asset['status'] == 'maintenance'
                                ? 'Maintenance'
                                : 'Available',
                        size: 12,
                        weight: 500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Asset Information Section
                    const MyText(
                      'Asset Information',
                      size: 16,
                      weight: 600,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Asset Type', asset['type']),
                    const SizedBox(height: 12),
                    _buildInfoRow('Asset ID', asset['id']),
                    const SizedBox(height: 12),
                    _buildInfoRow('Asset Name', asset['name']),
                    const Divider(height: 32),

                    // Location & Assignment Section
                    const MyText(
                      'Location & Assignment',
                      size: 16,
                      weight: 600,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Branch', asset['branch']),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 150,
                          child: MyText(
                            'Assigned To',
                            size: 14,
                            weight: 400,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.blue.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                width: 36,
                                height: 36,
                                child: Center(
                                  child: MyText(
                                    asset['assignedTo'][0],
                                    size: 16,
                                    weight: 600,
                                    color: AppColors.blue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    asset['assignedTo'],
                                    size: 14,
                                    weight: 500,
                                  ),
                                  MyText(
                                    asset['assignedEmail'],
                                    size: 12,
                                    weight: 300,
                                    color: const Color(0xFF64748B),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Financial Information Section
                    const MyText(
                      'Financial Information',
                      size: 16,
                      weight: 600,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Purchase Date', asset['purchaseDate']),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 150,
                          child: MyText(
                            'Asset Value',
                            size: 14,
                            weight: 400,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Expanded(
                          child: MyText(
                            asset['value'],
                            size: 14,
                            weight: 600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),

                    // Documents Section
                    const MyText(
                      'Documents',
                      size: 16,
                      weight: 600,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildDocumentChip('Invoice.pdf', Icons.picture_as_pdf),
                        _buildDocumentChip(
                            'Warranty.pdf', Icons.picture_as_pdf),
                        _buildDocumentChip('Manual.pdf', Icons.picture_as_pdf),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Action Buttons
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyOutlinedButton(
                      textColor: AppColors.darkGrey1,
                      borderColor: null,
                      child: 'Maintenance Log',
                      onTap: () {
                        // Handle maintenance log
                      },
                    ),
                    const SizedBox(width: 16),
                    MyElevatedButton(
                      icon: SvgPicture.asset(
                        "assets/svg/edit-pencil.svg",
                        colorFilter: const ColorFilter.mode(
                            AppColors.white, BlendMode.srcIn),
                      ),
                      child: 'Edit',
                      onTap: () {
                        // Handle edit
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: MyText(
            label,
            size: 14,
            weight: 400,
            color: const Color(0xFF64748B),
          ),
        ),
        Expanded(
          child: MyText(
            value,
            size: 14,
            weight: 500,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentChip(String name, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          MyText(
            name,
            size: 12,
            weight: 400,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.download, size: 16, color: AppColors.blue),
        ],
      ),
    );
  }
}
