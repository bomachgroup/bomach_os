import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/sort_bar.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/services/controller/estate_controller.dart';
import 'package:bms_front_end/pages/services/models/estate_models.dart';
import 'package:bms_front_end/pages/services/widget/add_estate_dialog.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class EstateManagementPage extends StatelessWidget {
  const EstateManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(EstateController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Row(
          children: [
            Expanded(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.start,
                spacing: 10,
                runSpacing: 10,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        'Estate Management',
                        style: AppText.black_500_32,
                      ),
                      SizedBox(height: 8),
                      MyText(
                        'Manage your real estate developments',
                        style: AppText.black_400_14,
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    children: [
                      SizedBox(
                        width: 200,
                        child: MyTextFormField(
                          hintText: 'Search estates...',
                          leading: Icon(
                            Icons.search,
                            color: AppColors.grey1.withValues(alpha: 0.5),
                          ),
                          onChanged: (value) {
                            ctrl.onSearchChanged(value ?? '');
                          },
                        ),
                      ),
                      const SortBar(text: "Sort"),
                      MyElevatedButton(
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.white,
                        ),
                        child: "Add Estate",
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => const AddEstateDialog(),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        kSizedBox,

        // Stats Cards
        Obx(() => _buildStatsCards(ctrl)),

        kSizedBox,

        // Filter chips
        _buildFilterRow(ctrl),

        kSizedBox,

        // Estate list
        Obx(() {
          if (ctrl.isLoading.value && ctrl.estates.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (ctrl.estates.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.domain_disabled,
                      size: 64,
                      color: AppColors.grey1.withValues(alpha: 0.5),
                    ),
                    kSizedBox,
                    const MyText(
                      'No estates found',
                      style: TextStyle(fontSize: 18, color: AppColors.grey1),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ctrl.estates.length,
            separatorBuilder: (context, index) => kSizedBoxSM,
            itemBuilder: (context, index) {
              return _buildEstateListItem(context, ctrl.estates[index]);
            },
          );
        }),
      ],
    );
  }

  Widget _buildStatsCards(EstateController ctrl) {
    final total = ctrl.estateCount.value;
    final active = ctrl.estates.where((e) => e.isActive).length;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatCard('Total Estates', '$total', Icons.domain, AppColors.blue),
        _buildStatCard(
            'Active', '$active', Icons.check_circle, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            radius: 20,
            child: Icon(icon, color: color, size: 20),
          ),
          kSizedBoxSM,
          MyText(value,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          MyText(label,
              style: const TextStyle(fontSize: 14, color: AppColors.grey1)),
        ],
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
      return Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: filters.map((f) {
                final isSelected =
                    (f == 'All' && current.isEmpty) || f == current;
                return GestureDetector(
                  onTap: () =>
                      ctrl.onStatusFilterChanged(f == 'All' ? '' : f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.blue : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.blue : AppColors.grey4,
                      ),
                    ),
                    child: MyText(
                      labels[f] ?? f,
                      style: TextStyle(
                        color: isSelected ? AppColors.white : AppColors.grey1,
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEstateListItem(BuildContext context, Estate estate) {
    final statusColor = _getStatusColor(estate.estateStatus);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.go(RouteConstants.estateDetail, extra: estate);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estate icon placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.domain, size: 40, color: AppColors.blue),
            ),
            kSizedBoxWidthSM,
            // Estate Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: MyText(
                          estate.estateName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: MyText(
                          estate.estateStatusDisplay,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: AppColors.grey1),
                      const SizedBox(width: 4),
                      Expanded(
                        child: MyText(
                          estate.location,
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.grey1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.business,
                          size: 16, color: AppColors.grey1),
                      const SizedBox(width: 4),
                      MyText(
                        estate.developerCompanyName,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.grey1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _infoChip(estate.estateTypeDisplay),
                      const SizedBox(width: 8),
                      if (estate.isOurEstate)
                        _infoChip('Our Estate',
                            color: Colors.green.shade700,
                            bg: Colors.green.shade50),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String text, {Color? color, Color? bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg ?? const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 11,
            color: color ?? const Color(0xFF475569),
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'under_development':
        return Colors.orange;
      case 'planning':
        return Colors.blue;
      case 'completed':
        return Colors.purple;
      default:
        return AppColors.grey1;
    }
  }
}
