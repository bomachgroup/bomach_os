import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/company_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/company_controller.dart';
import 'widget/add_compliance_dialog.dart';

class CompliancePage extends StatefulWidget {
  const CompliancePage({super.key});

  @override
  State<CompliancePage> createState() => _CompliancePageState();
}

class _CompliancePageState extends State<CompliancePage> {
  final CompanyController controller = Get.find<CompanyController>();
  final searchController = TextEditingController();

  int _pageSize = 10;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    controller.fetchComplianceRecords();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const MyText(
          'Compliance & Registration',
          style: AppText.black_600_16,
        ),
        const SizedBox(height: 4),
        const MyText(
          'CAC, Tax ID, Trademarks, Certifications',
          size: 12,
          color: Colors.grey,
        ),
        kSizedBox,

        // Search + New button
        Row(
          children: [
            Expanded(
              child: SizedBox(
                width: 300,
                child: MyTextFormField(
                  controller: searchController,
                  hintText: 'Search',
                  leading: const Icon(Icons.search, color: Colors.grey),
                  onChanged: (val) {
                    controller.complianceSearchQuery.value = val;
                    setState(() => _currentPage = 1);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            MyElevatedButton(
              height: 40,
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              child: "New Compliance",
              onTap: () => showDialog(
                context: context,
                builder: (c) => const AddComplianceDialog(),
              ),
            ),
          ],
        ),
        kSizedBox,

        // Content
        Obx(() {
          if (controller.isComplianceLoading.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final filtered = controller.filteredComplianceList;

          if (filtered.isEmpty) {
            return _buildEmptyState();
          }

          final startIndex = (_currentPage - 1) * _pageSize;
          final endIndex = (startIndex + _pageSize).clamp(0, filtered.length);
          final pageItems = filtered.sublist(startIndex, endIndex);

          return Column(
            children: [
              ...pageItems.map((item) => _buildComplianceCard(item)),
              const SizedBox(height: 16),
              PaginatorFooter(
                totalItems: filtered.length,
                limit: _pageSize,
                currentPage: _currentPage,
                onPageChanged: (page) => setState(() => _currentPage = page),
                onLimitChanged: (newLimit) => setState(() {
                  _pageSize = newLimit;
                  _currentPage = 1;
                }),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const MyText(
            'No compliance records found',
            size: 14,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          const MyText(
            'Add a new compliance record to get started',
            size: 12,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceCard(Compliance item) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  item.complianceType.isNotEmpty
                      ? '${item.complianceType} (${_typeAbbreviation(item.complianceType)})'
                      : 'Untitled',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Reference Number', item.referenceNumber),
                _buildInfoRow('Issuing Authority', item.issuingAuthority),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoRow('Date of Issue', item.dateOfIssue),
                    const SizedBox(width: 24),
                    _buildInfoRow('Expiry Date', item.expiryDate),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionButton(
                icon: Icons.edit_outlined,
                tooltip: 'Edit',
                onTap: () => showDialog(
                  context: context,
                  builder: (c) => AddComplianceDialog(compliance: item),
                ),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete_outline,
                tooltip: 'Delete',
                onTap: () => _confirmDelete(item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MyText(
            '$label: ',
            size: 12,
            color: Colors.grey[600]!,
          ),
          MyText(
            value.isNotEmpty ? value : '-',
            size: 12,
            weight: 500,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.card),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.grey[700]),
      ),
    );
  }

  void _confirmDelete(Compliance item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Compliance Record'),
        content: Text(
            'Are you sure you want to delete "${item.complianceType} - ${item.referenceNumber}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteCompliance(context, item.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _typeAbbreviation(String type) {
    switch (type.toLowerCase()) {
      case 'corporate affairs commission':
      case 'cac':
        return 'CAC';
      case 'tax id':
      case 'tax':
        return 'Tax';
      case 'trademark':
        return 'TM';
      case 'certification':
      case 'iso certification':
        return 'Cert';
      case 'license':
        return 'Lic';
      default:
        return type.length > 4 ? type.substring(0, 4) : type;
    }
  }
}
