import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:flutter/material.dart';

import 'package:bms_front_end/components/cards/invoice.dart';

/// Compact list of invoice cards wrapped in the shared [AppCard] surface.
class InvoiceList extends StatelessWidget {
  const InvoiceList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 12,
      spacing: 12,
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          borderColor: AppColors.borderSubtle,
          child: InvoiceCard(),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          borderColor: AppColors.borderSubtle,
          child: InvoiceCard(),
        ),
      ],
    );
  }
}
