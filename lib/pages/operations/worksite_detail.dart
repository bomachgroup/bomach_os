import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/components/text/row_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

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
      return const Scaffold(
        body: Center(
          child: MyText('Worksite not found', style: AppText.black_500_20),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
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
                            onTap: () {},
                          ),
                          MyElevatedButton(
                            bgColor: AppColors.red,
                            child: 'Delete',
                            onTap: () => controller.deleteWorksite(
                                context, ws.id, ws.projectId),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            kSizedBox,

            // Details Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  RowText(label: "Site Name", value: ws.name),
                  RowText(label: "Location", value: ws.location),
                  RowText(label: "Status", value: ws.status),
                  RowText(
                      label: "Created At",
                      value: ws.createdAt.isEmpty ? 'N/A' : ws.createdAt),
                  const Divider(height: 30),
                  RowText(label: "Description", value: ws.description),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
