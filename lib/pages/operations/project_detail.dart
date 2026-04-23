import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/components/text/row_text.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/project_controller.dart';

class ProjectDetailPage extends StatelessWidget {
  final Project? project;
  const ProjectDetailPage({super.key, this.project});

  @override
  Widget build(BuildContext context) {
    final ProjectController controller = Get.find<ProjectController>();

    final Project? proj =
        project ?? ModalRoute.of(context)?.settings.arguments as Project?;

    if (proj == null) {
      return const PageScaffold(
        children: [
          Center(
            child: MyText('Project not found', style: AppText.bodyLg),
          ),
        ],
      );
    }

    return PageScaffold(
      header: PageHeader(
        title: proj.name,
        subtitle: 'Project details and configuration',
        trailing: MyElevatedButton(
          bgColor: AppColors.danger,
          child: 'Delete Project',
          icon: const Icon(Iconsax.trash, size: 18, color: Colors.white),
          onTap: () {
            controller.deleteProject(context, proj.id);
          },
        ),
      ),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Project Overview', style: AppText.h3),
              const SizedBox(height: 16),
              RowText(label: "Project Name", value: proj.name),
              RowText(label: "Short Code", value: proj.shortCode),
              RowText(label: "Category", value: proj.category),
              RowText(label: "Department", value: proj.department),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const SizedBox(
                        width: 200, child: Text("Status", style: AppText.label)),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: StatusChip(
                          label: proj.status,
                          tone: _getStatusTone(proj.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              RowText(label: "Priority", value: proj.priority),
              RowText(
                  label: "Budget", value: "₦${proj.budget.toStringAsFixed(2)}"),
              RowText(label: "Start Date", value: proj.startDate),
              RowText(label: "Deadline", value: proj.deadline),
              RowText(label: "Location", value: proj.location),
              const Divider(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Description", style: AppText.label),
                  const SizedBox(height: 8),
                  Text(proj.summary, style: AppText.bodyMd),
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
      case 'completed':
        return StatusTone.success;
      case 'ongoing':
      case 'in progress':
        return StatusTone.primary;
      case 'on hold':
        return StatusTone.warning;
      case 'cancelled':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }
}
