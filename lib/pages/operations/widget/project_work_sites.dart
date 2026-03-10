import 'package:bms_front_end/components/nav/employee_stepper.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/operations/controllers/work_site_controller.dart';
import 'package:bms_front_end/pages/operations/models/models.dart';
import 'package:bms_front_end/pages/operations/widget/site_equipment_table.dart';
import 'package:bms_front_end/pages/operations/widget/project_task_table.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ProjectWorkSite extends StatefulWidget {
  final int projectId;
  const ProjectWorkSite({super.key, required this.projectId});

  @override
  State<ProjectWorkSite> createState() => _ProjectWorkSiteState();
}

class _ProjectWorkSiteState extends State<ProjectWorkSite> {
  int selectionStepperState = 0;
  Worksite? selectedWorksite;
  late final WorksiteController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<WorksiteController>()
        ? Get.find<WorksiteController>()
        : Get.put(WorksiteController());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchWorksites(context, projectId: widget.projectId);
      if (controller.worksites.isNotEmpty) {
        setState(() => selectedWorksite = controller.worksites.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        kSizedBoxBG,
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.worksites.isEmpty) {
            return const Center(
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                        "No worksites for this project yet. Add one above.")));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Worksite selector
              Row(
                children: [
                  const MyText("Worksite:", size: 16, weight: 500),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<Worksite>(
                      isExpanded: true,
                      value: selectedWorksite,
                      items: controller.worksites
                          .map((ws) => DropdownMenuItem(
                                value: ws,
                                child: Text(
                                    "${ws.name} — ${ws.location}",
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (ws) =>
                          setState(() => selectedWorksite = ws),
                    ),
                  ),
                ],
              ),
              kSizedBox,

              // Sub-tabs
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EmployeeInfoStepper(
                        isActive: selectionStepperState == 0,
                        icon: SvgPicture.asset("assets/svg/person.svg"),
                        activeIcon:
                            SvgPicture.asset("assets/svg/person-filled.svg"),
                        title: 'Employees',
                        onTap: () =>
                            setState(() => selectionStepperState = 0),
                      ),
                      kSizedBoxWidth,
                      EmployeeInfoStepper(
                        isActive: selectionStepperState == 1,
                        icon: SvgPicture.asset("assets/svg/settings.svg"),
                        activeIcon: SvgPicture.asset(
                            "assets/svg/settings-filled.svg"),
                        title: 'Site Equipments',
                        onTap: () =>
                            setState(() => selectionStepperState = 1),
                      ),
                      kSizedBoxWidth,
                      EmployeeInfoStepper(
                        isActive: selectionStepperState == 2,
                        icon: SvgPicture.asset("assets/svg/document.svg"),
                        activeIcon: SvgPicture.asset(
                            "assets/svg/document-filled.svg"),
                        title: 'Site Task',
                        onTap: () =>
                            setState(() => selectionStepperState = 2),
                      ),
                    ],
                  ),
                ),
              ),
              kSizedBoxBG,

              // Sub-tab content
              if (selectionStepperState == 0)  Container(),
              if (selectionStepperState == 1 && selectedWorksite != null)
                SiteEquipmentTable(worksiteId: selectedWorksite!.id),
              if (selectionStepperState == 1 && selectedWorksite == null)
                const Center(child: Text("Select a worksite first.")),
              if (selectionStepperState == 2)
                ProjectTaskTable(projectId: widget.projectId),
            ],
          );
        }),
      ],
    );
  }
}

/// Dialog used from the Add Worksite button on the Work site tab
class CreateWorkSiteReport extends StatelessWidget {
  final int projectId;
  const CreateWorkSiteReport({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // redirected — use AddWorksiteDialog
  }
}
