import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/assets_model.dart';

// ═══════════════════════════════════════════════════════════════════════
//  VIEW ASSET DIALOG
// ═══════════════════════════════════════════════════════════════════════

class ViewAssetDialog extends StatelessWidget {
  final Asset asset;
  const ViewAssetDialog({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    String displayDate = '';
    try {
      displayDate = DateFormat('MMM d, yyyy').format(asset.purchaseDate);
    } catch (_) {
      displayDate = '–';
    }

    String warrantyDate = '';
    try {
      warrantyDate =
          DateFormat('MMM d, yyyy').format(asset.warrantyExpiryDate);
    } catch (_) {
      warrantyDate = '–';
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title bar
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      asset.name,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                  _buildStatusBadge(asset.status),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Asset Information
                    const Text('Asset Information',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildDetailRow('Type', asset.assetType),
                    _buildDetailRow('Serial Number',
                        asset.serialNumber.isNotEmpty ? asset.serialNumber : '–'),
                    _buildDetailRow('Manufacturer',
                        asset.manufacturer.isNotEmpty ? asset.manufacturer : '–'),

                    const Divider(height: 32),

                    // Location & Assignment
                    const Text('Location & Assignment',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildDetailRow('Branch', asset.branch),
                    _buildDetailRow('Assigned To',
                        asset.assignedToId.isNotEmpty
                            ? asset.assignedToId
                            : 'Unassigned'),
                    _buildDetailRow('Department',
                        asset.departmentId.isNotEmpty
                            ? asset.departmentId
                            : '–'),

                    const Divider(height: 32),

                    // Financial
                    const Text('Financial',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 12),
                    _buildDetailRow('Purchase Date', displayDate),
                    _buildDetailRow('Value', asset.value.toStringAsFixed(2)),
                    _buildDetailRow('Vendor',
                        asset.vendor.isNotEmpty ? asset.vendor : '–'),
                    _buildDetailRow('Invoice Number',
                        asset.invoiceNumber.isNotEmpty
                            ? asset.invoiceNumber
                            : '–'),
                    _buildDetailRow('Warranty Expiry', warrantyDate),

                    if (asset.notes.isNotEmpty) ...[
                      const Divider(height: 32),
                      const Text('Notes',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(asset.notes,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF475569))),
                    ],
                  ],
                ),
              ),
            ),

            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Color color = _getStatusColor(status);
    final String display =
        status.isNotEmpty ? status[0].toUpperCase() + status.substring(1) : status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 7, color: color),
          const SizedBox(width: 5),
          Text(
            display,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'available':
        return Colors.green;
      case 'in-use':
        return Colors.blue;
      case 'maintenance':
        return Colors.orange;
      case 'retired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
