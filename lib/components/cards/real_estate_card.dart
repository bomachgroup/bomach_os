import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:readmore/readmore.dart';

import '../../src/constants/colors.dart';

class RealEstateCard extends StatelessWidget {
  final String image, title, details, buttonText;
  final num? price, bedRoom, bathRoom, sqm;
  final dynamic Function()? onTap;

  const RealEstateCard({
    super.key,
    required this.image,
    required this.title,
    required this.details,
    required this.buttonText,
    this.onTap,
    this.price,
    this.bedRoom,
    this.bathRoom,
    this.sqm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          width: 0.6,
          color: AppColors.borderSubtle,
        ),
        color: AppColors.white,
      ),
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.asset(
              image,
              width: 400,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: MyText(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ReadMoreText(
              details,
              trimLines: 2,
              trimMode: TrimMode.Line,
              trimCollapsedText: "Read more",
              trimExpandedText: "Less",
              style: const TextStyle(
                  fontSize: 12, overflow: TextOverflow.ellipsis),
              moreStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  overflow: TextOverflow.ellipsis),
              lessStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  overflow: TextOverflow.ellipsis),
            ),
          ),
          kSizedBox,
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 10,
            runSpacing: 10,
            children: [
              if (bedRoom != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset("assets/svg/bed.svg"),
                      kSizedBoxWidthTiny,
                      MyText(
                        "$bedRoom-Bedroom",
                        size: 12,
                        weight: 400,
                        color: AppColors.white,
                      )
                    ],
                  ),
                ),
              if (bathRoom != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset("assets/svg/bath-tub.svg"),
                      kSizedBoxWidthTiny,
                      MyText(
                        "$bathRoom-Bathroom",
                        size: 12,
                        weight: 400,
                        color: AppColors.white,
                      )
                    ],
                  ),
                ),
              if (sqm != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset("assets/svg/closet.svg"),
                      kSizedBoxWidthTiny,
                      MyText(
                        "${sqm}sqm",
                        size: 12,
                        weight: 400,
                        color: AppColors.white,
                      )
                    ],
                  ),
                ),
            ],
          ),
          kSizedBox,
          Row(
            children: [
              if (price != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MyText("Price", size: 14, weight: 400),
                    MyText("N$price", size: 20, weight: 500),
                  ],
                ),
                kSizedBoxWidth,
              ],
              Expanded(
                child: MyElevatedButton(
                  onTap: onTap,
                  child: buttonText,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
