import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/components/text/row_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

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
      return const Center(
        child: MyText('Contract not found', style: AppText.black_500_16),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset("assets/svg/arrow-left.svg",
                                colorFilter: const ColorFilter.mode(
                                    AppColors.black, BlendMode.srcIn)),
                            kSizedBoxWidthSM,
                            const MyText('Back', style: AppText.black_500_20),
                          ],
                        ),
                      ),
                      Row(
                        spacing: 10,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MyElevatedButton(
                            child: 'Edit',
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) =>
                                    AddContractDialog(contract: contract),
                              );
                            },
                          ),
                          MyElevatedButton(
                            bgColor: AppColors.red,
                            child: 'Delete',
                            onTap: () => controller.deleteContract(
                                context, contract.id, contract.projectId),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            kSizedBox,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  RowText(
                      label: "Contract Number", value: contract.contractNumber),
                  RowText(label: "Contract Type", value: contract.contractType),
                  RowText(
                      label: "Value",
                      value: "₦${contract.value.toStringAsFixed(2)}"),
                  RowText(label: "Status", value: contract.status),
                  const Divider(height: 30),
                  RowText(label: "Start Date", value: contract.startDate),
                  RowText(label: "End Date", value: contract.endDate),
                  RowText(
                      label: "Project ID",
                      value: contract.projectId.toString()),
                  RowText(label: "Created At", value: contract.createdAt),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
