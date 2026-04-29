import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:flutter/material.dart';

class ViewPaymentDialog extends StatefulWidget {
  const ViewPaymentDialog({super.key});

  @override
  State<ViewPaymentDialog> createState() => _ViewPaymentDialogState();
}

class _ViewPaymentDialogState extends State<ViewPaymentDialog> {
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
                      'Payment Details',
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
                                  "Client",
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
                                  "Amount Received",
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
                                  "Notes",
                                  weight: 300,
                                  size: 16,
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: MyText(
                                  "This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. This is mock text to show that this is an input field. ",
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
