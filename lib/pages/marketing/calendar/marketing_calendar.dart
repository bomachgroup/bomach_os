import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/marketing/controllers/marketing_module_controller.dart';
import 'package:bomach_os/pages/marketing/models/marketing_content.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketingCalendar extends StatelessWidget {
  const MarketingCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MarketingModuleController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(c),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildCalendarView(c)),
              const SizedBox(width: 16),
              SizedBox(width: 300, child: _buildUpcomingPanel(c)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(MarketingModuleController c) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText('Content Calendar', style: AppTextStyles.displayLg),
              SizedBox(height: 4),
              MyText(
                'Weekly content schedule across all channels',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        Obx(() {
          final pending = c.pendingContent;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: pending > 0 ? AppColors.warningSubtle : AppColors.successSubtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$pending items pending',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: pending > 0 ? AppColors.warning : AppColors.success,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCalendarView(MarketingModuleController c) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dates = [14, 15, 16, 17, 18, 19, 20];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: () {},
              ),
              const Text(
                'Jul 14 – Jul 20, 2025',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              final items = c.contentItems;
              return Row(
                children: List.generate(7, (dayIndex) {
                  final dayItems = items.where((item) {
                    final itemDay = _parseDay(item.dueDate);
                    return itemDay == dates[dayIndex];
                  }).toList();

                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: dayIndex < 6 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: dates[dayIndex] == 14 ? AppColors.primarySubtle : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Text(
                                  days[dayIndex],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: dates[dayIndex] == 14 ? AppColors.primary : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${dates[dayIndex]}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: dates[dayIndex] == 14 ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              itemCount: dayItems.length,
                              itemBuilder: (context, index) {
                                return _buildCalendarItem(dayItems[index]);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarItem(ContentCalendarItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4, left: 2, right: 2),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: item.status.bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: item.status.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: item.status.textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${item.format} · ${item.platform}',
            style: TextStyle(
              fontSize: 9,
              color: item.status.textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingPanel(MarketingModuleController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyText('Upcoming', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          Obx(() {
            final upcoming = c.contentItems
                .where((i) => i.status != ContentStatus.published && i.status != ContentStatus.overdue)
                .toList();
            if (upcoming.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('All caught up!', style: TextStyle(color: AppColors.textMuted)),
                ),
              );
            }
            return Column(
              children: upcoming.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 32,
                        decoration: BoxDecoration(
                          color: item.status.textColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.format} · ${item.platform} · Due ${item.dueDate}',
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.status.bgColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.status.label,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: item.status.textColor),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  int _parseDay(String date) {
    final match = RegExp(r'Jul (\d+)').firstMatch(date);
    if (match != null) return int.parse(match.group(1)!);
    return 0;
  }
}
