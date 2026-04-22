import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/components/text/row_text.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

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
      return const Center(
        child: MyText('Project not found', style: AppText.bodyLg),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  SvgPicture.asset("assets/svg/arrow-left.svg"),
                  kSizedBoxWidthSM,
                  const MyText('Back', style: AppText.h2),
                ],
              ),
            ),
            const Spacer(),
            MyElevatedButton(
              bgColor: AppColors.danger,
              child: 'Delete',
              onTap: () {
                controller.deleteProject(context, proj.id);
              },
            ),
          ],
        ),
        kSizedBox,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              RowText(label: "Project Name", value: proj.name),
              RowText(label: "Short Code", value: proj.shortCode),
              RowText(label: "Category", value: proj.category),
              RowText(label: "Department", value: proj.department),
              RowText(label: "Status", value: proj.status),
              RowText(label: "Priority", value: proj.priority),
              RowText(label: "Budget", value: proj.budget.toString()),
              RowText(label: "Start Date", value: proj.startDate),
              RowText(label: "Deadline", value: proj.deadline),
              RowText(label: "Location", value: proj.location),
              RowText(label: "Description", value: proj.summary),
            ],
          ),
        )
      ],
    );
  }
}
