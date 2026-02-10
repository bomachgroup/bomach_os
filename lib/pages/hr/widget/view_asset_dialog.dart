import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controller/assets_controller.dart';
import '../models/assets_model.dart';
import 'add_asset_dialog.dart';

class ViewAssetDialog extends StatelessWidget {
  final Asset asset;
  final String token;

  const ViewAssetDialog({
    super.key,
    required this.asset,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final AssetController controller = Get.find();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 700),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(asset.name, size: 20, weight: 600),
                          const SizedBox(height: 4),
                          MyText(asset.id, size: 14, weight: 400, color: const Color(0xFF64748B)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: MyText(asset.status.toUpperCase(), size: 12, weight: 500, color: Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MyText('Asset Information', size: 16, weight: 600),
                    const SizedBox(height: 12),
                    _buildInfoRow('Type', asset.assetType),
                    _buildInfoRow('Serial Number', asset.serialNumber ?? '-'),
                    _buildInfoRow('Manufacturer', asset.manufacturer ?? '-'),

                    const Divider(height: 32),
                    const MyText('Location & Assignment', size: 16, weight: 600),
                    const SizedBox(height: 12),
                    _buildInfoRow('Branch', asset.branch),
                    _buildInfoRow('Assigned To ID', asset.assignedToId ?? 'Unassigned'),
                    _buildInfoRow('Department ID', asset.departmentId ?? '-'),

                    const Divider(height: 32),
                    const MyText('Financial', size: 16, weight: 600),
                    const SizedBox(height: 12),
                    _buildInfoRow('Purchase Date', asset.purchaseDate != null ? DateFormat('yyyy-MM-dd').format(asset.purchaseDate!) : '-'),
                    _buildInfoRow('Value', asset.value.toStringAsFixed(2)),
                    _buildInfoRow('Invoice Number', asset.invoiceNumber ?? '-'),

                    const Divider(height: 32),
                    const MyText('Notes', size: 16, weight: 600),
                    const SizedBox(height: 12),
                    MyText(asset.notes ?? 'No notes', size: 14, weight: 400),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade300))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyOutlinedButton(
                      textColor: AppColors.red,
                      child: 'Delete',
                      onTap: () async {
                         final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text("Delete Asset"),
                            content: const Text("Are you sure?"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("No")),
                              TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Yes")),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          await controller.deleteAsset(token, asset.id);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Asset Deleted"), backgroundColor: Colors.red));
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    MyElevatedButton(
                      icon: SvgPicture.asset("assets/svg/edit-pencil.svg", colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn)),
                      child: 'Edit',
                      onTap: () {
                        Navigator.pop(context); 
                        showDialog(
                          context: context,
                          builder: (c) => AddAssetDialog(token: token, assetToEdit: asset),
                        );
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: MyText(label, size: 14, weight: 400, color: const Color(0xFF64748B)),
          ),
          Expanded(child: MyText(value, size: 14, weight: 500)),
        ],
      ),
    );
  }
}