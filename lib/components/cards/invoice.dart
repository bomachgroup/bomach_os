import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class InvoiceCard extends StatelessWidget {
  const InvoiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: kDefaultSpace, horizontal: kDefaultSpace),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: SvgPicture.asset("assets/svg/pdf.svg"),
          ),
          kSizedBoxWidthSM,
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                'Invoice #1273636',
              ),
              MyText(
                'Chijiokeugo@nggs',
              ),
            ],
          ),
          const Spacer(),
          SvgPicture.asset("assets/svg/download2.svg"),
          kSizedBoxWidthSM,
          SvgPicture.asset("assets/svg/share.svg"),
        ],
      ),
    );
  }
}
