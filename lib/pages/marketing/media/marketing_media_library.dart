import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/pages/marketing/controllers/marketing_module_controller.dart';
import 'package:bomach_os/pages/marketing/models/marketing_misc.dart';
import 'package:bomach_os/pages/marketing/models/marketing_content.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/utils/app_date_format.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketingMediaLibrary extends StatelessWidget {
  const MarketingMediaLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<MarketingModuleController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText('Media Library', style: AppTextStyles.displayLg),
        const SizedBox(height: 4),
        const MyText(
          'Design tasks, media assets, and creative files',
          style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDesignTasks(c),
                const SizedBox(height: 20),
                _buildMediaAssets(c),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesignTasks(MarketingModuleController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Design Board',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Obx(() {
            final todo =
                c.designTasks.where((t) => t.status == 'todo').toList();
            final review =
                c.designTasks.where((t) => t.status == 'review').toList();
            final done =
                c.designTasks.where((t) => t.status == 'done').toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todo.isNotEmpty) ...[
                  _sectionHeader('To Do', todo.length, AppColors.warning),
                  ...todo.map((t) => _designTaskCard(t)),
                ],
                if (review.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _sectionHeader('In Review', review.length, AppColors.info),
                  ...review.map((t) => _designTaskCard(t)),
                ],
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _sectionHeader('Done', done.length, AppColors.success),
                  ...done.map((t) => _designTaskCard(t)),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(width: 6),
          Text('($count)',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _designTaskCard(DesignTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: task.isOverdue
            ? Border.all(color: AppColors.danger.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: task.thumbBg, borderRadius: BorderRadius.circular(8)),
            child: Center(
              child: Text(
                task.thumbLabel,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: task.thumbTextColor),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  task.brief,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                task.platform,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                formatAppDateValue(task.dueDate, fallback: task.dueDate),
                style: TextStyle(
                  fontSize: 11,
                  color:
                      task.isOverdue ? AppColors.danger : AppColors.textMuted,
                  fontWeight:
                      task.isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaAssets(MarketingModuleController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Media Assets',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: c.mediaAssets.map((asset) {
                  return _mediaAssetCard(asset);
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _mediaAssetCard(MediaAsset asset) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: asset.bgColor, borderRadius: BorderRadius.circular(8)),
            child: Icon(
              asset.type == 'video'
                  ? Icons.videocam
                  : asset.type == 'doc'
                      ? Icons.description
                      : Icons.photo,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            asset.title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                asset.type.toUpperCase(),
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
              const Spacer(),
              Text(
                asset.size,
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            asset.division.label,
            style: TextStyle(fontSize: 10, color: asset.division.pillTextColor),
          ),
        ],
      ),
    );
  }
}
