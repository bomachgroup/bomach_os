import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/services/widget/image_slider.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';

class LandSurveyDetailScreen extends StatefulWidget {
  const LandSurveyDetailScreen({super.key});

  @override
  State<LandSurveyDetailScreen> createState() => _LandSurveyDetailScreenState();
}

class _LandSurveyDetailScreenState extends State<LandSurveyDetailScreen> {
  final PageController imageController = PageController();

  @override
  void dispose() {
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: const PageHeader(
        title: 'Serenity bungalow',
        subtitle: 'Property overview, key features and pricing details.',
      ),
      children: [
        _buildOverviewCard(),
        _buildGallery(),
        _buildDetailsRow(),
        _buildPricingSection(),
      ],
    );
  }

  Widget _buildOverviewCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 16,
        spacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusChip(
                    label: 'Residential',
                    tone: StatusTone.primary,
                    icon: Iconsax.home,
                  ),
                  SizedBox(width: 8),
                  StatusChip(
                    label: 'For Sale',
                    tone: StatusTone.success,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.location,
                      size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'Nike, Enugu',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Price',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              const Text('N58,000,000', style: AppTextStyles.h1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGallery() {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: SizedBox(
        height: (isSmallScreen(context) ? 500 : 672) + 114,
        child: const ImageCarousel(),
      ),
    );
  }

  Widget _buildDetailsRow() {
    final isLarge = isLargeScreen(context);
    if (!isLarge) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _descriptionCard(),
          const SizedBox(height: 16),
          _keyFeaturesCard(),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _descriptionCard()),
        const SizedBox(width: 16),
        Expanded(child: _keyFeaturesCard()),
      ],
    );
  }

  Widget _descriptionCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Text(
            'Discover your own piece of paradise with the Seaside Serenity Villa. With an open floor plan, breathtaking ocean views from every room, and direct access to a pristine sandy beach, this property is the epitome of coastal living.',
            style: AppTextStyles.bodyMd
                .copyWith(color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _specStat('Bedrooms', '04', 'assets/svg/bed.svg')),
              Container(
                width: 1,
                height: 48,
                color: AppColors.borderSubtle,
              ),
              Expanded(
                child: _specStat(
                  'Bathrooms',
                  '03',
                  'assets/svg/bath-tub.svg',
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: AppColors.borderSubtle,
              ),
              Expanded(
                child: _specStat(
                  'Area',
                  '1,500 sqft',
                  'assets/svg/area.svg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _specStat(String label, String value, String iconAsset) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                iconAsset,
                colorFilter: const ColorFilter.mode(
                  AppColors.textMuted,
                  BlendMode.srcIn,
                ),
                width: 16,
                height: 16,
              ),
              if (!isSmallScreen(context)) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.h2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _keyFeaturesCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Key Features and Amenities', style: AppTextStyles.h3),
          const SizedBox(height: 12),
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
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.tick_circle,
              size: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMd
                  .copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pricing Details', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brMd,
              border: Border.all(color: AppColors.primarySoft),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Iconsax.info_circle,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Note',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pricing is indicative and may be adjusted following site inspection and due diligence.',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Listing Price',
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          const Text('N58,000,000', style: AppTextStyles.h1),
          const SizedBox(height: 20),
          const Text('Additional Fees', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _feeRow('Rent', 'N58,000,000')),
              Container(
                width: 1,
                height: 48,
                color: AppColors.borderSubtle,
              ),
              Expanded(child: _feeRow('Brokerage Fees', '15%')),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _feeRow('Caution Fees', 'N25,000')),
              Container(
                width: 1,
                height: 48,
                color: AppColors.borderSubtle,
              ),
              Expanded(child: _feeRow('Legal Fees', 'N50,000')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _feeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.h3),
        ],
      ),
    );
  }
}
