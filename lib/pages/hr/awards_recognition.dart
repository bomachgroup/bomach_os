import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_dropdown.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'controller/awards_controller.dart';
import 'models/awards_model.dart';
import 'widget/add_award_widget.dart';
import 'widget/view_award_widget.dart';

class AwardsRecognitionPage extends StatefulWidget {
  const AwardsRecognitionPage({super.key});

  @override
  State<AwardsRecognitionPage> createState() => _AwardsRecognitionPageState();
}

class _AwardsRecognitionPageState extends State<AwardsRecognitionPage> {
  final AwardsController controller = Get.put(AwardsController());
  final _storage = const FlutterSecureStorage();

  String selectedMonth = 'All';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await _getToken(context);
    if (token != null) {
      controller.fetchAwards(token);
    }
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  StatusTone _awardTone(String category) {
    final c = category.toLowerCase().replaceAll(' ', '_');
    if (c.contains('employee_of_month') || c.contains('month')) {
      return StatusTone.primary;
    }
    if (c.contains('excellence')) return StatusTone.success;
    if (c.contains('innovation')) return StatusTone.info;
    if (c.contains('leadership')) return StatusTone.warning;
    if (c.contains('service')) return StatusTone.neutral;
    return StatusTone.primary;
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Awards & Recognition',
        subtitle:
            'Celebrate and track employee achievements across the organisation.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Award',
          onTap: () async {
            final token = await _getToken(context);
            if (token != null && context.mounted) {
              showDialog(
                context: context,
                builder: (context) => AddAwardDialog(token: token),
              );
            }
          },
        ),
      ),
      children: [
        Obx(() {
          if (controller.isLoading.value && controller.awardsList.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LoadingSkeleton.statRow(count: 3),
                const SizedBox(height: 24),
                LoadingSkeleton.listRows(count: 5),
              ],
            );
          }

          if (controller.awardsList.isEmpty) {
            return AppCard(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.cup,
                title: 'No awards yet',
                subtitle:
                    'Create the first award to celebrate an achievement.',
                action: MyElevatedButton(
                  icon: const Icon(Iconsax.add_circle,
                      size: 18, color: AppColors.textOnPrimary),
                  child: 'New Award',
                  onTap: () async {
                    final token = await _getToken(context);
                    if (token != null && context.mounted) {
                      showDialog(
                        context: context,
                        builder: (c) => AddAwardDialog(token: token),
                      );
                    }
                  },
                ),
              ),
            );
          }

          final sortedAwards = List<Award>.from(controller.awardsList);
          sortedAwards.sort((a, b) {
            DateTime dateA = a.dateAwarded ?? a.createdAt ?? DateTime(2000);
            DateTime dateB = b.dateAwarded ?? b.createdAt ?? DateTime(2000);
            return dateB.compareTo(dateA);
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRecentAwardsSection(sortedAwards.take(5).toList()),
              const SizedBox(height: 24),
              _buildAwardHistorySection(sortedAwards),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildRecentAwardsSection(List<Award> recentAwards) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recent Awards', style: AppTextStyles.h3),
                    const SizedBox(height: 4),
                    Text(
                      DateTime.now().year.toString(),
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: '${recentAwards.length} showing',
                tone: StatusTone.primary,
                icon: Iconsax.cup,
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: recentAwards
                  .map((award) => Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: _buildAwardCard(award),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAwardCard(Award award) {
    return GestureDetector(
      onTap: () async {
        final token = await _getToken(context);
        if (token != null && context.mounted) {
          showDialog(
            context: context,
            builder: (context) => ViewAwardDialog(award: award, token: token),
          );
        }
      },
      child: Container(
        width: 230,
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadii.brLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.cup,
                  color: AppColors.textOnPrimary, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              award.title,
              style: AppTextStyles.h4.copyWith(color: AppColors.textOnPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              award.category,
              style: AppTextStyles.bodySm.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              award.dateAwarded != null
                  ? DateFormat('MMM yyyy').format(award.dateAwarded!)
                  : 'N/A',
              style: AppTextStyles.bodySm.copyWith(
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAwardHistorySection(List<Award> allAwards) {
    Map<String, List<Award>> awardsByMonth = {};
    for (var award in allAwards) {
      if (award.dateAwarded != null) {
        String month = DateFormat('MMMM').format(award.dateAwarded!);
        if (!awardsByMonth.containsKey(month)) {
          awardsByMonth[month] = [];
        }
        awardsByMonth[month]!.add(award);
      }
    }

    List<Award> filteredAwards = [];
    if (selectedMonth == 'All') {
      filteredAwards = allAwards;
    } else {
      filteredAwards = awardsByMonth[selectedMonth] ?? [];
    }

    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Award History', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        '${filteredAwards.length} award${filteredAwards.length == 1 ? '' : 's'} recorded',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: MyDropdown(
                    hintText: selectedMonth,
                    items: ['All', ...awardsByMonth.keys],
                    initialSelection: selectedMonth,
                    onChanged: (val) {
                      if (val != null) setState(() => selectedMonth = val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          if (filteredAwards.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.cup,
                title: 'No awards for this selection',
                subtitle:
                    'Choose a different month or reset the filter to view all records.',
              ),
            )
          else
            _buildAwardsTable(filteredAwards),
        ],
      ),
    );
  }

  Widget _buildAwardsTable(List<Award> awards) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: awards.map((award) => _buildAwardMobileCard(award)).toList(),
      ),
    );
  }

  Widget _buildAwardMobileCard(Award award) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final token = await _getToken(context);
            if (token != null && context.mounted) {
              showDialog(
                context: context,
                builder: (c) => ViewAwardDialog(award: award, token: token),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        award.title,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(
                      label: award.category.isEmpty ? '—' : award.category,
                      tone: _awardTone(award.category),
                      dense: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      award.dateAwarded != null
                          ? DateFormat('dd-MM-yyyy').format(award.dateAwarded!)
                          : '—',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      'Rank: ${award.rankLevel.isEmpty ? '—' : award.rankLevel}',
                      style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
