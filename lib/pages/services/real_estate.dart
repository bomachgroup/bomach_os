import 'package:bms_front_end/components/cards/real_estate_card.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/controller/estate_controller.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class RealEstateScreen extends StatelessWidget {
  const RealEstateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(EstateController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          "Services",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        kSizedBox,
        SizedBox(
          width: isSmallScreen(context) ? null : 200,
          child: MyTextFormField(
            hintText: "Search...",
            leading: Icon(
              Icons.search,
              color: AppColors.grey1.withValues(alpha: 0.5),
            ),
            onChanged: (value) => ctrl.onSearchChanged(value ?? ''),
          ),
        ),
        const SizedBox(height: 15),
        const Align(
          alignment: Alignment.centerLeft,
          child: MyText(
            "Real Estate Development",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        kSizedBoxSM,
        Obx(() {
          if (ctrl.isLoading.value && ctrl.estates.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (ctrl.estates.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: MyText(
                  'No estates found',
                  style: TextStyle(fontSize: 16, color: AppColors.grey1),
                ),
              ),
            );
          }

          return GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            childAspectRatio: isLargeScreen(context)
                ? 0.86
                : isMediumScreen(context)
                    ? 0.86
                    : 0.75,
            shrinkWrap: true,
            crossAxisCount: isLargeScreen(context)
                ? 3
                : isMediumScreen(context)
                    ? 2
                    : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: ctrl.estates.map((estate) {
              return RealEstateCard(
                image: "assets/image/man-demo.png",
                title: estate.estateName,
                details: '${estate.location}\n${estate.estateTypeDisplay}',
                buttonText: "View Estate",
                onTap: () {
                  context.go(RouteConstants.estateDetail, extra: estate);
                },
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
