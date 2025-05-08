import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_svg/svg.dart';

class DepartmentPage extends StatelessWidget {
  const DepartmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            MyText(
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
                color: AppColors.white,
              ),
              child: 'New Department',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const CreateDepartmentDialog();
                  },
                );
              },
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
        color: AppColors.white,
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
                    MyText(
                      'Design Department',
                      maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    MyText(
                      '20 Members',
                      maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
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
              MyText(
                'View All',
                isSelectable: false,
                style: TextStyle(
                  color: AppColors.blue,
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
                          'assets/image/man-demo.png',
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                      kSizedBoxWidth,
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              'Dianne Russell',
                              maxLines: 1,
                              // overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                            MyText(
                              'Lead UI/UX Designer',
                              maxLines: 1,
                              // overflow: TextOverflow.ellipsis,
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
                        const MyText(
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

class CreateDepartmentDialog extends StatefulWidget {
  const CreateDepartmentDialog({super.key});

  @override
  State<CreateDepartmentDialog> createState() => _CreateDepartmentDialogState();
}

class _CreateDepartmentDialogState extends State<CreateDepartmentDialog> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _leaveDateController =
      TextEditingController(text: '12-12-2024');
  final TextEditingController _startDateController =
      TextEditingController(text: '12-10-2024');
  final TextEditingController _endDateController =
      TextEditingController(text: '12-10-2024');
  final TextEditingController _durationController =
      TextEditingController(text: '5days');

  @override
  void dispose() {
    _reasonController.dispose();
    _leaveDateController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 846),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.grey4),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MyText(
                    'Add Department',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Form fields
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      const MyTextFormField(
                        hintText: "----",
                        spaceBetweenText: 10,
                        title: 'Name*',
                      ),
                      const SizedBox(height: 24),
                      MyTextFormField(
                        controller: _reasonController,
                        maxLines: 4,
                        hintText: '----',
                        spaceBetweenText: 10,
                        title: 'Description',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  MyOutlinedButton(
                    textColor: AppColors.darkGrey1,
                    borderColor: null,
                    child: 'Cancel',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 16),
                  MyElevatedButton(
                    icon: SvgPicture.asset(
                      "assets/svg/check.svg",
                      colorFilter: const ColorFilter.mode(
                          AppColors.white, BlendMode.srcIn),
                    ),
                    child: 'Save',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
