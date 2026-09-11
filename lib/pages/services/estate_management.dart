import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/pages/services/controller/estate_controller.dart';
import 'package:bomach_os/pages/services/models/estate_models.dart';
import 'package:bomach_os/pages/services/widget/add_estate_dialog.dart';
import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class EstateManagementPage extends StatelessWidget {
  const EstateManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(EstateController());

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Estate Management',
        subtitle: 'Manage your real estate developments and plots.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'Add Estate',
          onTap: () => showDialog(
            context: context,
            builder: (_) => const AddEstateDialog(),
          ),
        ),
      ),
      children: [
        Obx(() => _buildStatsCards(ctrl)),
        _buildToolbar(ctrl),
        _buildFilterRow(ctrl),
        Obx(() {
          if (ctrl.isLoading.value && ctrl.estates.isEmpty) {
            return LoadingSkeleton.listRows(count: 5, rowHeight: 96);
          }

          if (ctrl.estates.isEmpty) {
            return AppCard(
              padding: const EdgeInsets.all(12),
              child: EmptyState(
                icon: Iconsax.building_4,
                title: 'No estates found',
                subtitle:
                    'Adjust your filters or add a new estate to get started.',
                action: MyOutlinedAddButton(
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => const AddEstateDialog(),
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ctrl.estates.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildEstateCard(context, ctrl.estates[index]);
            },
          );
        }),
      ],
    );
  }

  Widget _buildStatsCards(EstateController ctrl) {
    final total = ctrl.estateCount.value;
    final active = ctrl.estates.where((e) => e.isActive).length;
    final development = ctrl.estates
        .where((e) => e.estateStatus == 'under_development')
        .length;
    final completed =
        ctrl.estates.where((e) => e.estateStatus == 'completed').length;

    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 760;
      final perRow = isWide ? 4 : 2;
      const spacing = 16.0;
      final cardWidth =
          (constraints.maxWidth - ((perRow - 1) * spacing)) / perRow;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          SizedBox(
            width: cardWidth,
            child: _statCard(
              label: 'Total Estates',
              value: '$total',
              icon: Iconsax.building_4,
              tone: StatusTone.primary,
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: _statCard(
              label: 'Active',
              value: '$active',
              icon: Iconsax.tick_circle,
              tone: StatusTone.success,
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: _statCard(
              label: 'Under Development',
              value: '$development',
              icon: Iconsax.timer_1,
              tone: StatusTone.warning,
            ),
          ),
          SizedBox(
            width: cardWidth,
            child: _statCard(
              label: 'Completed',
              value: '$completed',
              icon: Iconsax.verify,
              tone: StatusTone.info,
            ),
          ),
        ],
      );
    });
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required StatusTone tone,
  }) {
    final palette = _tonePalette(tone);

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: palette.$1,
              borderRadius: AppRadii.brMd,
            ),
            child: Icon(icon, color: palette.$2, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _tonePalette(StatusTone tone) {
    switch (tone) {
      case StatusTone.success:
        return (AppColors.successSubtle, AppColors.success);
      case StatusTone.warning:
        return (AppColors.warningSubtle, AppColors.warning);
      case StatusTone.danger:
        return (AppColors.dangerSubtle, AppColors.danger);
      case StatusTone.info:
        return (AppColors.infoSubtle, AppColors.info);
      case StatusTone.primary:
        return (AppColors.primarySubtle, AppColors.primary);
      case StatusTone.neutral:
        return (AppColors.surfaceMuted, AppColors.textSecondary);
    }
  }

  Widget _buildToolbar(EstateController ctrl) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: MyTextFormField(
        hintText: 'Search estates by name, code, location...',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: (value) => ctrl.onSearchChanged(value),
      ),
    );
  }

  Widget _buildFilterRow(EstateController ctrl) {
    final filters = ['All', 'active', 'under_development', 'completed'];
    final labels = {
      'All': 'All',
      'active': 'Active',
      'under_development': 'Under Development',
      'completed': 'Completed',
    };

    return Obx(() {
      final current = ctrl.statusFilter.value;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: filters.map((f) {
          final isSelected =
              (f == 'All' && current.isEmpty) || f == current;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => ctrl.onStatusFilterChanged(f == 'All' ? '' : f),
              borderRadius: AppRadii.brPill,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius: AppRadii.brPill,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Text(
                  labels[f] ?? f,
                  style: AppTextStyles.bodySm.copyWith(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textSecondary,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildEstateCard(BuildContext context, Estate estate) {
    final statusTone = _statusTone(estate.estateStatus);

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => context.go(RouteConstants.estateDetailPath(estate.id)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brMd,
            ),
            child: const Icon(Iconsax.building_4,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        estate.estateName,
                        style: AppTextStyles.h4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    StatusChip(
                      label: estate.estateStatusDisplay.isNotEmpty
                          ? estate.estateStatusDisplay
                          : estate.estateStatus,
                      tone: statusTone,
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Iconsax.location,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        estate.location,
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Iconsax.building,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        estate.developerCompanyName,
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (estate.estateTypeDisplay.isNotEmpty)
                      StatusChip(
                        label: estate.estateTypeDisplay,
                        tone: StatusTone.neutral,
                        dense: true,
                      ),
                    if (estate.isOurEstate)
                      const StatusChip(
                        label: 'Our Estate',
                        tone: StatusTone.success,
                        dense: true,
                        icon: Iconsax.verify,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Iconsax.arrow_right_3,
              size: 18, color: AppColors.textMuted),
        ],
      ),
    );
  }

  StatusTone _statusTone(String status) {
    switch (status) {
      case 'active':
        return StatusTone.success;
      case 'development':
      case 'under_development':
        return StatusTone.warning;
      case 'sold_out':
        return StatusTone.primary;
      case 'completed':
        return StatusTone.info;
      case 'suspended':
        return StatusTone.danger;
      case 'inactive':
      default:
        return StatusTone.neutral;
    }
  }
}

/// Small helper wrapper used by empty state action.
class MyOutlinedAddButton extends StatelessWidget {
  const MyOutlinedAddButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: const Icon(Iconsax.add_circle, size: 18),
      label: const Text('Add Estate'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
      ),
    );
  }
}
