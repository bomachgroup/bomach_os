import 'package:bms_front_end/components/input/custom_search_field.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';

class TopNavigationBar extends StatelessWidget {
  const TopNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      color: AppColors.whiteColor,
      height: 70,
      child: Row(
        children: [
          if (!isLargeScreen(context)) ...[
            IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            ),
            kSizedBoxWidth,
          ],
          const CustomSearchField(),
          kSizedBoxWidthBG,
          if (isLargeScreen(context)) const Spacer(),
          Row(
            children: [
              const Icon(Icons.notifications),
              const SizedBox(
                width: 20,
              ),
              Image.asset('assets/icons/english-flag.png'),
              const SizedBox(
                width: kDefaultSpaceSM,
              ),
              if (!isSmallScreen(context)) const Text('English'),
              if (!isSmallScreen(context))
                const SizedBox(
                  width: 10,
                ),
              const Icon(
                Icons.keyboard_arrow_down_outlined,
                size: 20,
                color: AppColors.grey1,
              ),
              kSizedBoxWidth,
              SizedBox(
                width: isSmallScreen(context) ? 50 : 150,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/icons/profile-icon.png'),
                        ),
                        // color: AppColors.secondaryColor,
                        shape: BoxShape.circle),
                  ),
                  title: isSmallScreen(context)
                      ? null
                      : const Text(
                          'Moni Roy',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.black_600_14,
                        ),
                  subtitle: isSmallScreen(context)
                      ? null
                      : const Text(
                          'Admin',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
              ),
              if (!isSmallScreen(context)) ...[
                kSizedBoxWidthSM,
                Image.asset(
                  'assets/icons/arrow-down-outline.png',
                  width: 20,
                )
              ],
            ],
          )
        ],
      ),
    );
  }
}
