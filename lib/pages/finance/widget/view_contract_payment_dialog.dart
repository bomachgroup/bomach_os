import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class ViewContractPaymentDialog extends StatefulWidget {
  const ViewContractPaymentDialog({super.key});

  @override
  State<ViewContractPaymentDialog> createState() =>
      _ViewContractPaymentDialogState();
}

class _ViewContractPaymentDialogState extends State<ViewContractPaymentDialog> {
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
                      'New Vendor Payment',
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
            const Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Vendor",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "MTN Group",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Invoice ID",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "FJ9387HDS",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Amount Due",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "15000",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Payment Date",
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
                          Row(
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
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: MyText(
                                  "Transaction ID",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "393JSK93J3",
                                  weight: 400,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                          kSizedBox,
                          Row(
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
