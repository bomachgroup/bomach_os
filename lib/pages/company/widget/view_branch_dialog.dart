import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class ViewBranchDialog extends StatefulWidget {
  const ViewBranchDialog({super.key});

  @override
  State<ViewBranchDialog> createState() => _ViewBranchDialogState();
}

class _ViewBranchDialogState extends State<ViewBranchDialog> {
  int employeeProfileSelectionStepperState = 0;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: MyText(
                      'Mock Branch Name',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
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
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Branch Name",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "Mock Branch Name",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Country",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "Nigeria",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "State",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "Enugu",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "L.G.A",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "Enugu south",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Office Address",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "gfvdcisvyif viyfgdsykgogl fyifds9yifvy viyfdsykfgovldsg fy9ivsyvog higvysidyobu ihbsfbvyou hivscy9bvxog isziyvkg 8 isvxyiy9ikx y8svicxb8yh9b y8svcyfgz9c7ioh y8vsiby9gox ",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Branch ID",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "#SSC23",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: MyText(
                                  "Operational Status",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Row(
                                  children: [
                                    Container(
                                      height: 10,
                                      width: 10,
                                      decoration: const ShapeDecoration(
                                        color: AppColors.green,
                                        shape: OvalBorder(),
                                      ),
                                    ),
                                    kSizedBoxWidthTiny,
                                    const MyText("Active"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          Row(
                            children: [
                              const Expanded(
                                flex: 3,
                                child: MyText(
                                  "Manager",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      width: 36,
                                      height: 36,
                                      child: Image.asset(
                                          'assets/icons/profile-icon.png'),
                                    ),
                                    kSizedBoxWidth,
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText(
                                          "Nicholas Chidera Ani",
                                          weight: 400,
                                          size: 16,
                                        ),
                                        MyText(
                                          "MTN Nigeria",
                                          weight: 400,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Contact Email",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "branchemail5@mail.com",
                                  weight: 400,
                                  size: 16,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Contact Phone",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "+234 123 4567 890",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Uploaded Branch File",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                  flex: 5,
                                  child: Row(
                                    children: [
                                      // SvgPicture.asset(
                                      //   "assets/svg/file-icon.svg",
                                      //   height: 24,
                                      //   width: 24,
                                      // ),
                                      // kSizedBoxWidthTiny,
                                      // const MyText(
                                      //   "branch-document.pdf",
                                      //   weight: 400,
                                      //   size: 16,
                                      // ),
                                    ],
                                  )),
                            ],
                          ),
                          kSizedBox,
                          const Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Date Created",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "12th July 2021 : 20:15:13",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                        ],
                      ),
                    ),
                  ],
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
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      alignment: WrapAlignment.end,
                      children: [
                        MyElevatedButton(
                          bgColor: AppColors.red,
                          child: 'Delete',
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        MyElevatedButton(
                          child: 'Edit',
                          onTap: () {},
                        ),
                      ],
                    ),
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
