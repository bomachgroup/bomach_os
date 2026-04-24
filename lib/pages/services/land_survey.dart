import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/cards/real_estate_card.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/pages/client/clients_database.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class LandSurveyScreen extends StatefulWidget {
  const LandSurveyScreen({super.key});

  @override
  State<LandSurveyScreen> createState() => _LandSurveyScreenState();
}

class _LandSurveyScreenState extends State<LandSurveyScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Land Survey',
        subtitle: 'Browse land and property listings available for survey.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Invoice',
          onTap: () => showDialog(
            context: context,
            builder: (_) => const AddInvoiceDialog(),
          ),
        ),
      ),
      children: [
        _buildToolbar(),
        _buildGrid(),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: MyTextFormField(
        controller: _searchController,
        hintText: 'Search by estate name, location or property type',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildGrid() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.md,
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        childAspectRatio: isLargeScreen(context)
            ? 0.7
            : isMediumScreen(context)
                ? 0.7
                : 0.6,
        shrinkWrap: true,
        crossAxisCount: isLargeScreen(context)
            ? 3
            : isMediumScreen(context)
                ? 2
                : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: List.generate(
          6,
          (index) => RealEstateCard(
            image: "assets/image/image.png",
            title: "Aso villa Estate",
            details:
                "If you're visiting this page, you're likely here because you're searching for a random sentence...",
            buttonText: "View estate Properties",
            bedRoom: 3,
            bathRoom: 5,
            sqm: 500,
            price: 100,
            onTap: () {
              context.push(RouteConstants.landSurveyDetail);
            },
          ),
        ),
      ),
    );
  }
}
