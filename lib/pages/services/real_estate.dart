import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/cards/real_estate_card.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/services/controller/estate_controller.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class RealEstateScreen extends StatelessWidget {
  const RealEstateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(EstateController());

    return PageScaffold(
      maxContentWidth: 1440,
      header: const PageHeader(
        title: 'Real Estate Development',
        subtitle: 'Discover estates and developments available for sale.',
      ),
      children: [
        _buildToolbar(ctrl),
        Obx(() {
          if (ctrl.isLoading.value && ctrl.estates.isEmpty) {
            return const AppCard(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (ctrl.estates.isEmpty) {
            return AppCard(
              padding: EdgeInsets.zero,
              child: EmptyState.empty(
                title: 'No estates found',
                subtitle:
                    'Try adjusting your search terms or check back shortly.',
              ),
            );
          }

          return AppCard(
            padding: const EdgeInsets.all(20),
            elevation: AppCardElevation.md,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              childAspectRatio: isLargeScreen(context)
                  ? 0.86
                  : isMediumScreen(context)
                      ? 0.86
                      : 0.75,
              shrinkWrap: true,
              crossAxisCount: isLargeScreen(context)
                  ? 3
                  : isMediumScreen(context)
                      ? 2
                      : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: ctrl.estates.map((estate) {
                return RealEstateCard(
                  image: "assets/image/man-demo.png",
                  title: estate.estateName,
                  details:
                      '${estate.location}\n${estate.estateTypeDisplay}',
                  buttonText: "View Estate",
                  onTap: () {
                    context.go(RouteConstants.estateDetailPath(estate.id));
                  },
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildToolbar(EstateController ctrl) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: MyTextFormField(
        hintText: 'Search by estate name, location or type',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: (value) => ctrl.onSearchChanged(value),
      ),
    );
  }
}
