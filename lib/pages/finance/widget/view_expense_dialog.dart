import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class ViewExpenseDialog extends StatefulWidget {
  const ViewExpenseDialog({super.key});

  @override
  State<ViewExpenseDialog> createState() => _ViewExpenseDialogState();
}

class _ViewExpenseDialogState extends State<ViewExpenseDialog> {
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
                      'Expense Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
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
                                  "Amount",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "120000",
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
                                  "Category",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "Travel",
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
                                  "Description",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "Purchase of flight tickets",
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
                                  "Date",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "22th July 2025",
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
                                  "Branch",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "Independence Layout",
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
                                  "Department",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "Operations",
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
                                  "Operational Status",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "Inverter Installation",
                                  weight: 300,
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
                                  "Receipt ID",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "393JSK93J3",
                                  weight: 300,
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
                                  "Paid By",
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
                                  "Payment Method",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "Transfer",
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
                                  "Status",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "Pending",
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
                                  "Notes",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. ",
                                  weight: 400,
                                  size: 16,
                                  maxLines: 5,
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
                          bgColor: AppColors.danger,
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
