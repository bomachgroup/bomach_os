import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/marketing/controllers/marketing_module_controller.dart';
import 'package:bomach_os/pages/marketing/models/marketing_lead.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketingPipeline extends StatelessWidget {
  const MarketingPipeline({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MarketingModuleController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(c),
        const SizedBox(height: 16),
        _buildDivisionTabs(c),
        const SizedBox(height: 16),
        Expanded(child: _buildKanbanBoard(c)),
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
              MyText('Lead Pipeline', style: AppTextStyles.displayLg),
              SizedBox(height: 4),
              MyText(
                'Drag and manage leads across pipeline stages',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Obx(() => Text(
            '${c.activeLeads} active leads',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
          )),
        ),
      ],
    );
  }

  Widget _buildDivisionTabs(MarketingModuleController c) {
    return Obx(() {
      final divCounts = c.divisionLeadCounts;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTab('All Divisions', c.leads.length, true),
            ...MarketingDivision.values.map((div) =>
              _buildTab(div.label, divCounts[div] ?? 0, false),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTab(String label, int count, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isActive ? AppColors.primary : AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ($count)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKanbanBoard(MarketingModuleController c) {
    return Obx(() {
      final counts = c.pipelineCounts;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: LeadStage.values.map((stage) {
            final stageLeads = c.leads.where((l) => l.stage == stage).toList();
            return _buildKanbanColumn(stage, stageLeads, counts[stage] ?? 0);
          }).toList(),
        ),
      );
    });
  }

  Widget _buildKanbanColumn(LeadStage stage, List<MarketingLead> leads, int count) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: stage.pillColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: stage.pillColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  stage.label,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: stage.pillColor),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: stage.pillColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: stage.pillColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...leads.map((lead) => _buildLeadCard(lead)),
        ],
      ),
    );
  }

  Widget _buildLeadCard(MarketingLead lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [
          BoxShadow(color: Color(0x05000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: lead.division.pillColor.withValues(alpha: 0.15),
                child: Text(
                  lead.name.split(' ').map((w) => w[0]).take(2).join(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: lead.division.pillColor),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lead.name,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (lead.isOverdue)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSubtle,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Overdue', style: TextStyle(fontSize: 10, color: AppColors.danger, fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              lead.value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
          Row(
            children: [
              _tag(lead.source, AppColors.infoSubtle, AppColors.info),
              if (lead.budget != '—') ...[
                const SizedBox(width: 6),
                _tag(lead.budget, AppColors.surfaceMuted, AppColors.textSecondary),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(lead.assignedTo, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const Spacer(),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: lead.division.pillColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(lead.division.label, style: TextStyle(fontSize: 10, color: lead.division.pillTextColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: fg)),
    );
  }
}
