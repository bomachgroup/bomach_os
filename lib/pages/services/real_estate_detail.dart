import 'package:bms_front_end/components/button/sort_filter_bar2..dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/client/clients_database.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../components/button/icon_button.dart';
import '../../src/constants/colors.dart';

class RealEstateDetailScreen extends StatefulWidget {
  const RealEstateDetailScreen({super.key});

  @override
  State<RealEstateDetailScreen> createState() => _RealEstateDetailScreenState();
}

class _RealEstateDetailScreenState extends State<RealEstateDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //header
            const Text(
              "Services",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyIconButton(
                  icon: SvgPicture.asset("assets/svg/plus.svg"),
                  colorBackground: const Color(0xFF0055FF),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AddInvoiceDialog();
                      },
                    );
                  },
                ),
                kSizedBoxWidthSM,
                MyIconButton(
                  icon: SvgPicture.asset("assets/svg/note2.svg"),
                  colorBackground: const Color(0xFF0055FF),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const InvoiceContent();
                      },
                    );
                  },
                ),
                kSizedBoxWidthSM,
                MyIconButton(
                  icon: SvgPicture.asset("assets/svg/notification.svg"),
                  colorBackground: const Color(0xFF0055FF),
                  onPressed: () {},
                ),
              ],
            )
          ],
        ),
        //search
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            SizedBox(
              width: 200,
              child: MyTextFormField(
                hintText: "Search...",
                leading: Icon(
                  Icons.search,
                  color: AppColors.grey1.withValues(alpha: 0.5),
                ),
              ),
            ),
            kSizedBoxWidth,
            const SortFilterBar2(),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        kSizedBox,
        kSizedBoxSM,

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Aso villa Estate",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),
        kSizedBox,
        //body
        Wrap(
          alignment: WrapAlignment.start,
          spacing: 20,
          runSpacing: 20,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/image/image.png",
                width: 413,
                height: 341,
                fit: BoxFit.cover,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/image/image.png",
                width: 413,
                height: 341,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),

        kSizedBoxBG,
        const MyText("Description", size: 24, weight: 500),
        kSizedBox,

        const MyText(
            "A shvivdosv hivosfgp ovshogu vousvbov uovsbo vogvsibhxo ogousvou ovusbvoxd...",
            size: 16,
            weight: 400),
      ],
    );
  }
}
