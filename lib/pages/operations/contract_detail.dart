import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/components/text/row_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/contract_controller.dart';
import 'models/models.dart';
import 'widget/add_contract_dialog.dart';

class ContractDetailPage extends StatelessWidget {
  final Contract? cont;

  const ContractDetailPage({super.key, this.cont});

  @override
  Widget build(BuildContext context) {
    final ContractController controller = Get.find<ContractController>();

    final Contract? contract =
        cont ?? ModalRoute.of(context)?.settings.arguments as Contract?;

    if (contract == null) {
      return const PageScaffold(
        children: [
          Center(
            child: MyText('Contract not found', style: AppTextStyles.bodyLg),
          ),
        ],
      );
    }

    return PageScaffold(
      header: PageHeader(
        title: contract.name,
        subtitle: 'Contract details, value, and scheduling',
        trailing: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AddContractDialog(contract: contract),
                );
              },
              icon: const Icon(Iconsax.edit, size: 18),
              label: const Text('Edit'),
            ),
            MyElevatedButton(
              bgColor: AppColors.danger,
              child: 'Delete',
              icon: const Icon(Iconsax.trash, size: 18, color: Colors.white),
              onTap: () => controller.deleteContract(
                  context, contract.id, contract.projectId),
            ),
          ],
        ),
      ),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Contract Information', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              RowText(label: "Contract Name", value: contract.name),
              RowText(label: "Contract Number", value: contract.contractNumber),
              RowText(label: "Contract Type", value: contract.contractType),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const SizedBox(
                        width: 200, child: Text("Value", style: AppTextStyles.label)),
                    Expanded(
                      child: Text(
                        "₦${contract.value.toStringAsFixed(2)}",
                        style: AppTextStyles.bodyLg.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const SizedBox(
                        width: 200,
                        child: Text("Status", style: AppTextStyles.label)),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: StatusChip(
                          label: contract.status,
                          tone: _getStatusTone(contract.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              RowText(label: "Start Date", value: contract.startDate),
              RowText(label: "End Date", value: contract.endDate),
              RowText(label: "Project ID", value: "#${contract.projectId}"),
              RowText(label: "Created At", value: contract.createdAt),
            ],
          ),
        )
      ],
    );
  }

  StatusTone _getStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'signed':
        return StatusTone.success;
      case 'pending':
        return StatusTone.warning;
      case 'expired':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }
}
