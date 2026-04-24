import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: const PageHeader(
        title: 'Aso villa Estate',
        subtitle: 'Property details, gallery and description.',
      ),
      children: [
        _buildHeaderCard(),
        _buildGallery(),
        _buildDescriptionCard(),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.building_4,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Property Overview',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                const Text('Aso villa Estate', style: AppTextStyles.h3),
              ],
            ),
          ),
          const StatusChip(
            label: 'Active',
            tone: StatusTone.success,
          ),
        ],
      ),
    );
  }

  Widget _buildGallery() {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gallery', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 16,
            runSpacing: 16,
            children: [
              ClipRRect(
                borderRadius: AppRadii.brMd,
                child: Image.asset(
                  "assets/image/image.png",
                  width: 413,
                  height: 341,
                  fit: BoxFit.cover,
                ),
              ),
              ClipRRect(
                borderRadius: AppRadii.brMd,
                child: Image.asset(
                  "assets/image/image.png",
                  width: 413,
                  height: 341,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return AppCard(
      padding: const EdgeInsets.all(24),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Description', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Text(
            'A shvivdosv hivosfgp ovshogu vousvbov uovsbo vogvsibhxo ogousvou ovusbvoxd...',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
