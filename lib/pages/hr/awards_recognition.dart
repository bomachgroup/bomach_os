import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MyText(
                    'Awards & Recognition',
                    style: AppText.black_500_32,
                  ),
                  const SizedBox(height: 8),
                  MyText(
                    DateTime.now().year.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              MyElevatedButton(
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: AppColors.white),
                child: "New Award",
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
            ],
          ),
          kSizedBox,
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.awardsList.isEmpty) {
              return const Center(child: Text("No awards found."));
            }

            final sortedAwards = List<Award>.from(controller.awardsList);
            sortedAwards.sort((a, b) {
              DateTime dateA = a.dateAwarded ?? a.createdAt ?? DateTime(2000);
              DateTime dateB = b.dateAwarded ?? b.createdAt ?? DateTime(2000);
              return dateB.compareTo(dateA);
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecentAwardsSection(sortedAwards.take(5).toList()),
                kSizedBox,
                _buildAwardHistorySection(sortedAwards),
                kSizedBox,
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentAwardsSection(List<Award> recentAwards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'Recent Awards',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 16,
            children:
                recentAwards.map((award) => _buildAwardCard(award)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAwardCard(Award award) {
    const color = AppColors.blue;

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
        width: 220,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.emoji_events, color: Colors.white, size: 32),
              ),
            ),
            const SizedBox(height: 16),
            MyText(
              award.title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              maxLines: 2,
            ),
            const SizedBox(height: 4),
            MyText(
              award.category,
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 8),
            MyText(
              award.dateAwarded != null
                  ? DateFormat('MMM yyyy').format(award.dateAwarded!)
                  : 'N/A',
              style: TextStyle(
                  fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'Award History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        kSizedBox,
        Container(
          width: 200,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButton<String>(
            value: selectedMonth,
            isExpanded: true,
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.blue),
            onChanged: (newValue) => setState(() => selectedMonth = newValue!),
            items: ['All', ...awardsByMonth.keys]
                .map((month) => DropdownMenuItem(
                    value: month,
                    child: MyText(month, style: const TextStyle(fontSize: 14))))
                .toList(),
          ),
        ),
        kSizedBox,
        _buildAwardsTable(filteredAwards),
      ],
    );
  }

  Widget _buildAwardsTable(List<Award> awards) {
    if (awards.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
          ],
        ),
        child: Center(
          child: MyText('No awards found for this selection',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: MyText('Award Title',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700))),
                Expanded(
                    flex: 2,
                    child: MyText('Category',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700))),
                Expanded(
                    flex: 2,
                    child: MyText('Date',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700))),
                Expanded(
                    flex: 2,
                    child: MyText('Rank',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700))),
              ],
            ),
          ),
          ...awards.map((award) => GestureDetector(
                onTap: () async {
                  final token = await _getToken(context);
                  if (token != null && context.mounted) {
                    showDialog(
                        context: context,
                        builder: (c) =>
                            ViewAwardDialog(award: award, token: token));
                  }
                },
                child: _buildTableRow(award),
              )),
        ],
      ),
    );
  }

  Widget _buildTableRow(Award award) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: MyText(award.title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500))),
          Expanded(
              flex: 2,
              child: MyText(award.category,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
          Expanded(
              flex: 2,
              child: MyText(
                  award.dateAwarded != null
                      ? DateFormat('MMM dd, yyyy').format(award.dateAwarded!)
                      : '-',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
          Expanded(
              flex: 2,
              child: MyText(award.rankLevel,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
        ],
      ),
    );
  }
}
