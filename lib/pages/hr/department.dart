import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class DepartmentPage extends StatelessWidget {
  const DepartmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Enugu Branch',
              style: AppText.black_600_32,
            ),
            kSizedBoxWidthSM,
            Icon(
              Icons.keyboard_arrow_down_outlined,
              size: 24,
            )
          ],
        ),
        kSizedBox,
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            MyElevatedButton(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.whiteColor,
              ),
              child: 'New Department',
              onTap: () {},
            ),
            SizedBox(
              width: 217,
              child: MyTextFormField(
                hintText: 'Search...',
                leading: Icon(
                  Icons.search,
                  color: AppColors.grey1.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SortBar(
              text: "Sort",
            ),
          ],
        ),
        kSizedBoxBG,
        LayoutGrid(
          columnSizes: isSmallScreen(context) ? [1.fr] : [1.fr, 1.fr],
          rowSizes: const [
            auto,
            auto,
            auto,
            auto,
          ],
          columnGap: kDefaultSpaceBG,
          rowGap: kDefaultSpaceBG,
          children: const [
            DepartmentCard(),
            DepartmentCard(),
            DepartmentCard(),
          ],
        ),
      ],
    );
  }
}

class DepartmentCard extends StatelessWidget {
  const DepartmentCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: kDefaultSpace, vertical: kDefaultSpace),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.whiteColor,
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Design Department',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '20 Members',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.grey2,
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              kSizedBoxWidthSM,
              Text(
                'View All',
                style: TextStyle(
                  color: AppColors.blueColor,
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const Divider(),
          kSizedBoxSM,
          Column(
            children: List.generate(
              3,
              (index) => Column(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: Image.asset(
                          'assets/logo/bomach.png',
                          height: 40,
                          width: 40,
                        ),
                      ),
                      kSizedBoxWidth,
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dianne Russell',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Lead UI/UX Designer',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.grey2,
                                fontWeight: FontWeight.w300,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      kSizedBoxWidthSM,
                      if (index == 0) ...[
                        const Text(
                          'HOD 👑',
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        kSizedBoxWidth,
                      ],
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 13,
                      )
                    ],
                  ),
                  kSizedBox,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
