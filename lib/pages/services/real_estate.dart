import 'package:bms_front_end/components/button/sort_filter_bar2..dart';
import 'package:bms_front_end/components/cards/real_estate_card.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/pages/client/clients_database.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_svg/svg.dart';

import '../../components/button/icon_button.dart';
import '../../src/constants/colors.dart';

class RealEstateScreen extends StatefulWidget {
  const RealEstateScreen({super.key});

  @override
  State<RealEstateScreen> createState() => _RealEstateScreenState();
}

class _RealEstateScreenState extends State<RealEstateScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
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
        //real estate header
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Real Estate development",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
        ),

        //body
        SizedBox(
          height: isLargeScreen(context)
              ? 900
              : isMediumScreen(context)
                  ? 3000
                  : 1350,
          child: LayoutGrid(
            gridFit: GridFit.expand,
            columnSizes: isLargeScreen(context)
                ? [1.fr, 1.fr, 1.fr]
                : isMediumScreen(context)
                    ? [1.fr, 1.fr]
                    : [1.fr],
            rowSizes: isLargeScreen(context)
                ? [1.fr, 1.fr]
                : isMediumScreen(context)
                    ? [1.fr, 1.fr, 1.fr]
                    : [
                        1.fr,
                        1.fr,
                        1.fr,
                        1.fr,
                        1.fr,
                        1.fr,
                      ],
            children: List.generate(
                6,
                (index) => const RealEstateCard(
                      image: "assets/image/image.png",
                      title: "Aso villa Estate",
                      details:
                          "If you're visiting this page, you're likely here because you're searching for a random sentence. Sometimes a random word just isn't enough, and that is where the random sentence generator comes into play. By inputting the desired number, you can make a list of as many random sentences as you want or need. Producing random sentences can be helpful in a number of different ways.",
                      buttonText: "View estate Properties",
                    )),
          ),
        )
      ],
    );
  }
}
