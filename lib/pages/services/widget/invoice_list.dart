import 'package:bms_front_end/components/cards/invoice.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

class InvoiceList extends StatelessWidget {
  const InvoiceList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 10,
                spacing: 10,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.darkGrey2),
                    ),
                    child: const InvoiceCard(),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.darkGrey2),
                    ),
                    child: const InvoiceCard(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
