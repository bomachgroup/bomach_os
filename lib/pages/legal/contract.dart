import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../components/button/my_elevated_button.dart';
import '../../components/input/my_textformfield.dart';
import '../../components/text/my_text.dart';
import '../../src/constants/colors.dart';
import '../../src/constants/spaces.dart';
import '../operations/models/models.dart';
import 'controllers/legal_contract_controller.dart';
import 'detailed_view.dart';
import 'widgets/status_tag.dart';

class ContractsPageView extends StatelessWidget {
  const ContractsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LegalContractController());
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Column(
          children: [
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Contract Management",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      const Text(
                          "Manage contracts, agreements, and legal documents",
                          style: TextStyle(
                              fontSize: 13, color: Colors.black54)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: MyTextFormField(
                              hintText: 'Search for contracts...',
                              onChanged: controller.onSearchChanged,
                              leading: Icon(
                                Iconsax.search_normal,
                                color: AppColors.neutral500.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          MyElevatedButton(
                            child: 'Filter',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Contract Management",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          SizedBox(height: 2),
                          MyText(
                              "Manage contracts, agreements, and legal documents",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: 250,
                              child: MyTextFormField(
                                hintText: 'Search for contracts...',
                                onChanged: controller.onSearchChanged,
                                leading: Icon(
                                  Iconsax.search_normal,
                                  color: AppColors.neutral500.withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            MyElevatedButton(
                              child: 'Filter',
                              onTap: () {},
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
            kSizedBoxBG,
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.contractList.isEmpty) {
                  return const Center(child: Text("No contracts found"));
                }
                return ListView.builder(
                  itemCount: controller.contractList.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final item = controller.contractList[index];
                    final contract = item.contract as Contract;
                    return ContractsCard(
                      contract: contract,
                      isMobile: isMobile,
                    );
                  },
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class ContractsCard extends StatelessWidget {
  final Contract contract;
  final bool isMobile;
  const ContractsCard({super.key, required this.contract, this.isMobile = false});

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(contract.status);
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final contractData = <String, String>{
            'Contract Number': contract.contractNumber,
            'Contract Name': contract.name,
            'Contract Type': contract.contractType,
            'Status': contract.status,
            'Value': '₦${_formatValue(contract.value)}',
            'Effective Date': contract.startDate,
            'Expiry Date': contract.endDate,
            'Created': contract.createdAt,
          };

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailsViewPage(
                  title: contract.name,
                  details: contractData),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      contract.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StatusTag(text: contract.status, color: statusColor),
                        const SizedBox(width: 8),
                        StatusTag(
                            text: contract.contractType, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text("Contract No: ${contract.contractNumber}"),
                    Text("Value: ₦${_formatValue(contract.value)}"),
                    const SizedBox(height: 8),
                    Text(
                      "Created: ${_formatDate(contract.createdAt)}",
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text("Effective: ${_formatDate(contract.startDate)}"),
                    Text("Expires: ${_formatDate(contract.endDate)}"),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            final contractData = <String, String>{
                              'Contract Number': contract.contractNumber,
                              'Contract Name': contract.name,
                              'Contract Type': contract.contractType,
                              'Status': contract.status,
                              'Value': '₦${_formatValue(contract.value)}',
                              'Effective Date': contract.startDate,
                              'Expiry Date': contract.endDate,
                              'Created': contract.createdAt,
                            };

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DetailsViewPage(
                                    title: contract.name,
                                    details: contractData),
                              ),
                            );
                          },
                          icon: const Icon(Iconsax.eye,
                              color: Colors.black),
                          label: const Text("View",
                              style: TextStyle(color: Colors.black)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Iconsax.edit,
                              color: Colors.black),
                          label: const Text("Edit",
                              style: TextStyle(color: Colors.black)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        MyText(contract.name,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        StatusTag(text: contract.status, color: statusColor),
                        const SizedBox(width: 8),
                        StatusTag(
                            text: contract.contractType, color: Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Contract No: ${contract.contractNumber}"),
                              Text("Value: ₦${_formatValue(contract.value)}"),
                              const SizedBox(height: 8),
                              Text(
                                "Created: ${_formatDate(contract.createdAt)}",
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Effective: ${_formatDate(contract.startDate)}"),
                              Text("Expires: ${_formatDate(contract.endDate)}"),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {
                                  final contractData = <String, String>{
                                    'Contract Number': contract.contractNumber,
                                    'Contract Name': contract.name,
                                    'Contract Type': contract.contractType,
                                    'Status': contract.status,
                                    'Value': '₦${_formatValue(contract.value)}',
                                    'Effective Date': contract.startDate,
                                    'Expiry Date': contract.endDate,
                                    'Created': contract.createdAt,
                                  };

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => DetailsViewPage(
                                          title: contract.name,
                                          details: contractData),
                                    ),
                                  );
                                },
                                icon: const Icon(Iconsax.eye,
                                    color: Colors.black),
                                label: const Text("View",
                                    style: TextStyle(color: Colors.black)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Iconsax.edit,
                                    color: Colors.black),
                                label: const Text("Edit",
                                    style: TextStyle(color: Colors.black)),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'terminated':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String _formatValue(double value) {
    return value.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)},',
    );
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '—';
    if (date.length >= 10) {
      final parts = date.substring(0, 10).split('-');
      if (parts.length == 3) {
        final months = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final month = int.tryParse(parts[1]) ?? 0;
        return '${int.tryParse(parts[2]) ?? 0} ${months[month]} ${parts[0]}';
      }
    }
    return date;
  }
}
