import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';

class TopNavigationBar extends StatelessWidget {
  const TopNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 23),
      // Set color to transparent or match scaffold to "integrate" it
      color: Colors.transparent,
      height: 70,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hamburger Menu (Small Screens)
          if (!isLargeScreen(context)) ...[
            IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(
                Iconsax.menu,
                color: Colors.black,
              ),
            ),
            kSizedBoxWidth,
          ],

          // Breadcrumbs (Placeholder)
          const _Breadcrumbs(),

          const Spacer(),
          
          // The Top Bar is now clean of global profile/notifications
          // Future page-specific actions can be added here.
        ],
      ),
    );
  }
}

class _Breadcrumbs extends StatelessWidget {
  const _Breadcrumbs();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Workspace',
          style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Iconsax.arrow_right_3, size: 12, color: AppColors.neutral400),
        ),
        Text(
          'Overview',
          style: AppText.bodySm.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
