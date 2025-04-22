import 'package:bms_front_end/components/cards/real_estate_card.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
      ),
      child: Column(
        children: [
          //header
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
                    icon: const Icon(
                      Icons.add_outlined,
                      size: 20,
                      color: Color(0xFFFFFFFF),
                    ),
                    colorBackground: const Color(0xFF0055FF),
                    onPressed: () {},
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  MyIconButton(
                    icon: const Icon(
                      Icons.notes,
                      size: 20,
                      color: Color(0xFFFFFFFF),
                    ),
                    colorBackground: const Color(0xFF0055FF),
                    onPressed: () {},
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  MyIconButton(
                    icon: const Icon(
                      Icons.notifications,
                      size: 20,
                      color: Color(0xFFFFFFFF),
                    ),
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
                width: 217,
                height: 45,
                child: MyTextFormField(
                  hintText: 'Search...',
                  leading: Icon(
                    Icons.search,
                    color: AppColors.grey1.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                padding: const EdgeInsets.all(5),
                height: 50,
                width: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    width: 0.6,
                    color: AppColors.borderColor,
                  ),
                  color: const Color(0XFFF5F6FA),
                ),
                child: Row(
                  children: [
                    const Text(
                      "Branch",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    const VerticalDivider(
                      color: AppColors.borderColor,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    DropdownButton(
                        // value: ,
                        icon: const Icon(
                          Icons.arrow_downward,
                          size: 20,
                        ),
                        items: null,
                        onChanged: null)
                  ],
                ),
              )
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
      ),
    );
  }
}
