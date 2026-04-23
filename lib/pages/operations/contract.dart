import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'controllers/contract_controller.dart';
import 'models/models.dart';
import 'widget/add_contract_dialog.dart';

class ContractPage extends StatefulWidget {
  final int? projectId; // Optional: to filter by project
  const ContractPage({super.key, this.projectId});

  @override
  State<ContractPage> createState() => ContractPageState();
}

class ContractPageState extends State<ContractPage> {
  final ScrollController _scrollController = ScrollController();
  final ContractController controller = Get.put(ContractController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchContracts(context, projectId: widget.projectId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      header: PageHeader(
        title: 'Contracts',
        subtitle: 'Management of legal contracts and agreements',
        trailing: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 250,
              child: MyTextFormField(
                hintText: 'Search contracts...',
                leading: const Icon(Iconsax.search_normal, size: 18, color: AppColors.textMuted),
                onChanged: (val) => controller.fetchContracts(context,
                    projectId: widget.projectId, search: val),
              ),
            ),
            const SortBar(text: "Sort"),
            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const AddContractDialog(),
                );
              },
              icon: const Icon(Iconsax.add_circle, size: 18),
              label: const Text('Create Contract'),
            ),
          ],
        ),
      ),
      children: [
        AppCard(
          padding: const EdgeInsets.all(0),
          child: Obx(() {
            if (controller.isLoading.value) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: LoadingSkeleton.listRows(count: 8),
              );
            }

            if (controller.contracts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(48),
                child: EmptyState.empty(
                  title: 'No contracts found',
                  subtitle: 'Create a new contract to manage agreements.',
                ),
              );
            }

            return Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.resolveWith(
                        (states) => AppColors.surfaceMuted.withValues(alpha: 0.5)),
                    headingTextStyle: AppText.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    dataTextStyle: AppText.bodyMd.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    dataRowMinHeight: 64,
                    dataRowMaxHeight: 64,
                    columnSpacing: 24,
                    horizontalMargin: 20,
                    dividerThickness: 1.0,
                    columns: _createColumns(),
                    rows: _createRows(context, controller.contracts),
                    showBottomBorder: false,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  List<DataColumn> _createColumns() {
    return const [
      DataColumn(label: Text("Name")),
      DataColumn(label: Text("Contract No.")),
      DataColumn(label: Text("Type")),
      DataColumn(label: Text("Value")),
      DataColumn(label: Text("Start Date")),
      DataColumn(label: Text("End Date")),
      DataColumn(label: Text("Status")),
    ];
  }

  List<DataRow> _createRows(BuildContext context, List<Contract> contracts) {
    return contracts.map((contract) {
      return DataRow(cells: <DataCell>[
        DataCell(
          onTap: () {
            context.push(RouteConstants.operationsContractDetail,
                extra: contract);
          },
          Text(contract.name.isEmpty ? '-' : contract.name,
              style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600, color: AppColors.primary)),
        ),
        DataCell(Text(contract.contractNumber)),
        DataCell(Text(contract.contractType)),
        DataCell(Text("₦${contract.value.toStringAsFixed(2)}", style: AppText.bodyMd.copyWith(fontWeight: FontWeight.w600))),
        DataCell(Text(contract.startDate)),
        DataCell(Text(contract.endDate)),
        DataCell(StatusChip(
          label: contract.status,
          tone: _getStatusTone(contract.status),
        )),
      ]);
    }).toList();
  }

  StatusTone _getStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return StatusTone.success;
      case 'pending':
        return StatusTone.warning;
      case 'terminated':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }
}
