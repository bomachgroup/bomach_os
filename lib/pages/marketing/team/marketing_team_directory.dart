import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/marketing/controllers/marketing_module_controller.dart';
import 'package:bomach_os/pages/marketing/models/marketing_team.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketingTeamDirectory extends StatelessWidget {
  const MarketingTeamDirectory({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MarketingModuleController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText('Team Directory', style: AppTextStyles.displayLg),
                  SizedBox(height: 4),
                  MyText(
                    'Marketing team members and their performance',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            _buildStatusLegend(),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() => GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemCount: c.team.length,
            itemBuilder: (context, index) {
              return _buildTeamCard(c.team[index]);
            },
          )),
        ),
      ],
    );
  }

  Widget _buildStatusLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _legendDot(AppColors.success, 'Online'),
        const SizedBox(width: 12),
        _legendDot(AppColors.warning, 'Away'),
        const SizedBox(width: 12),
        _legendDot(AppColors.textMuted, 'Offline'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildTeamCard(MarketingTeamMember member) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: member.backgroundColor,
                child: Text(
                  member.initials,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: member.status == 'online'
                        ? AppColors.success
                        : member.status == 'away'
                            ? AppColors.warning
                            : AppColors.textMuted,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  member.role,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  member.stat,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (member.kpiPercentage > 0)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: member.kpiPercentage / 100,
                        strokeWidth: 4,
                        backgroundColor: AppColors.borderSubtle,
                        valueColor: AlwaysStoppedAnimation(member.kpiColor),
                      ),
                      Center(
                        child: Text(
                          '${member.kpiPercentage}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: member.kpiColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
