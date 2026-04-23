import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/components/text/row_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/work_site_controller.dart';
import 'models/models.dart';

class WorksiteDetailPage extends StatelessWidget {
  final Worksite? worksite;
  const WorksiteDetailPage({super.key, this.worksite});

  @override
  Widget build(BuildContext context) {
    final WorksiteController controller = Get.find<WorksiteController>();

    final Worksite? ws =
        worksite ?? ModalRoute.of(context)?.settings.arguments as Worksite?;

    if (ws == null) {
      return const PageScaffold(
        children: [
          Center(
            child: MyText('Worksite not found', style: AppTextStyles.bodyLg),
          ),
        ],
      );
    }

    return PageScaffold(
      header: PageHeader(
        title: ws.name,
        subtitle: 'Worksite location and operational status',
        trailing: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Iconsax.edit, size: 18),
              label: const Text('Edit'),
            ),
            MyElevatedButton(
              bgColor: AppColors.danger,
              child: 'Delete',
              icon: const Icon(Iconsax.trash, size: 18, color: Colors.white),
              onTap: () => controller.deleteWorksite(context, ws.id, ws.projectId),
            ),
          ],
        ),
      ),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Worksite Overview', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              RowText(label: "Site Name", value: ws.name),
              RowText(label: "Location", value: ws.location),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const SizedBox(
                        width: 200, child: Text("Status", style: AppTextStyles.label)),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: StatusChip(
                          label: ws.status,
                          tone: _getStatusTone(ws.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              RowText(
                  label: "Created At",
                  value: ws.createdAt.isEmpty ? 'N/A' : ws.createdAt),
              const Divider(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Description", style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  Text(
                      ws.description.isEmpty
                          ? 'No description provided.'
                          : ws.description,
                      style: AppTextStyles.bodyMd),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  StatusTone _getStatusTone(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return StatusTone.success;
      case 'pending':
        return StatusTone.warning;
      case 'inactive':
        return StatusTone.neutral;
      default:
        return StatusTone.neutral;
    }
  }
}
