import 'package:bms_front_end/components/button/sort_filter_bar2..dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/client/clients_database.dart';
import 'package:bms_front_end/pages/services/widget/image_slider.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../components/button/icon_button.dart';
import '../../src/constants/colors.dart';

class LandSurveyDetailScreen extends StatefulWidget {
  const LandSurveyDetailScreen({super.key});

  @override
  State<LandSurveyDetailScreen> createState() => _LandSurveyDetailScreenState();
}

class _LandSurveyDetailScreenState extends State<LandSurveyDetailScreen> {
  PageController imageController = PageController();

  @override
  void dispose() {
    imageController.dispose();
    super.dispose();
  }

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

        kSizedBox,
        kSizedBoxSM,

        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 20,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Serenity bungalow",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                      kSizedBoxWidth,
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.grey1.withValues(alpha: 0.5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset("assets/svg/map-pin.svg"),
                            kSizedBoxWidthTiny,
                            const MyText(
                              "Nike, Enugu",
                              size: 18,
                              weight: 400,
                              color: AppColors.black,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        "Price",
                        size: 18,
                        weight: 400,
                        color: AppColors.grey2,
                      ),
                      MyText(
                        "N58,000,000",
                        size: 24,
                        weight: 500,
                        color: AppColors.black,
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 672,
          child: ImageCarousel(),
        ),

        kSizedBoxBG,
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.grey4,
                ),
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Discover your own piece of paradise with the Seaside Serenity Villa. With an open floor plan, breathtaking ocean views from every room, and direct access to a pristine sandy beach, this property is the epitome of coastal living.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(
                    height: 1,
                    color: AppColors.black,
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    alignment: Alignment.center,
                    height: 105,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Bedrooms
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/svg/bed.svg",
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.black,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Bedrooms',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '04',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const VerticalDivider(
                            color: AppColors.black,
                            thickness: 1,
                            width: 20,
                          ),
                          // Bathrooms
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/svg/bath-tub.svg",
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.black,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Bathrooms',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '03',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const VerticalDivider(
                            color: AppColors.black,
                            thickness: 1,
                            width: 20,
                          ),
                          // Area
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/svg/area.svg",
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.black,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Area',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Column(
                                  children: [
                                    Text(
                                      '1,500',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Square Feet',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  // Property Details Row
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Features and Amenities
                  const Text(
                    'Key Features and Amenities',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Column(
                      children: [
                        // Feature Items
                        _buildFeatureItem(
                          'Expansive oceanfront terrace for outdoor entertaining',
                        ),
                        _buildFeatureItem(
                          'Gourmet kitchen with top-of-the-line appliances',
                        ),
                        _buildFeatureItem(
                          'Private beach access for morning strolls and sunset views',
                        ),
                        _buildFeatureItem(
                          'Master suite with a spa-inspired bathroom and ocean-facing balcony',
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),

        kSizedBoxBG,

        Row(
          children: [
            SvgPicture.asset(
              "assets/svg/square-star.svg",
            ),
            kSizedBoxWidthTiny,
            SvgPicture.asset(
              "assets/svg/square-filled.svg",
            ),
            kSizedBoxWidthTiny,
            SvgPicture.asset(
              "assets/svg/square-filled.svg",
              height: 7,
              width: 7,
            ),
          ],
        ),
        kSizedBoxSM,
        const MyText(
          "Pricing Details",
          size: 38,
          weight: 500,
        ),
        kSizedBox,
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.black2,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              MyText(
                "Note",
                size: 20,
                weight: 500,
                color: AppColors.white,
              ),
              kSizedBoxWidthSM,
              VerticalDivider(
                color: AppColors.white,
                thickness: 1,
                width: 20,
              ),
              kSizedBoxWidthSM,
              Expanded(
                child: MyText(
                  "hvfiodbh phbgdip jbof0gopd bpuighb jv0fgdsohgh8i jvof7s9g0ogbpx oug0dsfo v0ggp80h ig7s0gho hnxci",
                  size: 16,
                  weight: 400,
                  color: AppColors.white,
                  maxLines: 2,
                ),
              )
            ],
          ),
        ),
        kSizedBox,
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              "Listing Price",
              size: 18,
              weight: 400,
              color: AppColors.grey2,
            ),
            MyText(
              "N58,000,000",
              size: 24,
              weight: 500,
              color: AppColors.black,
            )
          ],
        ),

        kSizedBox,
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.grey4,
            ),
            borderRadius: BorderRadius.circular(24.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Additional Fees',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),

              const Divider(
                height: 1,
                color: AppColors.black,
              ),
              Container(
                padding: const EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                height: 105,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rent',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'N58,000,000',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(
                      color: AppColors.black,
                      thickness: 1,
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Brokerage Fees',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '15%',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              kSizedBox,
              const Divider(
                height: 1,
                color: AppColors.black,
              ),
              Container(
                padding: const EdgeInsets.only(top: 10),
                alignment: Alignment.center,
                height: 105,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Caution Fees',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'N25,000',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const VerticalDivider(
                      color: AppColors.black,
                      thickness: 1,
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Legal Fees',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'N50,000',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              // Property Details Row
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            "assets/svg/thunder.svg",
            colorFilter: const ColorFilter.mode(
              AppColors.black,
              BlendMode.srcIn,
            ),
          ),
          kSizedBoxWidthSM,
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
