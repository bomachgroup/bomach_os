import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

import 'models/awards_recognition_models.dart';

class AwardsRecognitionPage extends StatefulWidget {
  const AwardsRecognitionPage({super.key});

  @override
  State<AwardsRecognitionPage> createState() => _AwardsRecognitionPageState();
}

class _AwardsRecognitionPageState extends State<AwardsRecognitionPage> {
  String selectedMonth = 'All';
  late EmployeeAwardsProfile employeeProfile;

  @override
  void initState() {
    super.initState();
    employeeProfile = _getMockEmployeeProfile();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and profile
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
            ],
          ),
          kSizedBox,

          // Recent Awards Section
          _buildRecentAwardsSection(),
          kSizedBox,

          // Award History Section
          _buildAwardHistorySection(),
          kSizedBox,
        ],
      ),
    );
  }

  Widget _buildRecentAwardsSection() {
    final recentAwards = employeeProfile.getRecentAwards();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    final color = Color(
      int.parse(award.color.replaceFirst('#', '0xff')),
    );

    return Container(
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
          // Award Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: MyText(
                award.awardIcon,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Award Name
          MyText(
            award.awardName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Award Category
          MyText(
            award.awardCategory,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),

          // Award Date
          MyText(
            award.getFormattedDate(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          if (award.location != null) ...[
            const SizedBox(height: 4),
            MyText(
              award.location ?? '',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAwardHistorySection() {
    final awardsByMonth = employeeProfile.getAwardsByMonth();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MyText(
          'Award History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        kSizedBox,

        // Month Filter
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
            onChanged: (newValue) {
              if (newValue != null) {
                setState(() => selectedMonth = newValue);
              }
            },
            items: ['All', ...awardsByMonth.keys]
                .map((month) => DropdownMenuItem(
                      value: month,
                      child:
                          MyText(month, style: const TextStyle(fontSize: 14)),
                    ))
                .toList(),
          ),
        ),
        kSizedBox,

        // Awards Table
        _buildAwardsTable(awardsByMonth),
      ],
    );
  }

  Widget _buildAwardsTable(Map<String, List<Award>> awardsByMonth) {
    List<Award> filteredAwards = [];

    if (selectedMonth == 'All') {
      for (var awards in awardsByMonth.values) {
        filteredAwards.addAll(awards);
      }
    } else {
      filteredAwards = awardsByMonth[selectedMonth] ?? [];
    }

    // Sort by date descending
    filteredAwards.sort((a, b) => b.awardDate.compareTo(a.awardDate));

    if (filteredAwards.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: MyText(
            'No awards found for this period',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: MyText(
                    'Award',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: MyText(
                    'Month',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: MyText(
                    'Rank/Level',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Table Rows
          ...filteredAwards.map((award) => _buildTableRow(award)),
        ],
      ),
    );
  }

  Widget _buildTableRow(Award award) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              spacing: 8,
              children: [
                MyText(
                  award.awardIcon,
                  style: const TextStyle(fontSize: 20),
                ),
                Expanded(
                  child: MyText(
                    award.awardName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: MyText(
              award.getFormattedDate(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: MyText(
              award.location ?? '-',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mock employee profile data
  EmployeeAwardsProfile _getMockEmployeeProfile() {
    return EmployeeAwardsProfile(
      employeeId: 'emp-001',
      employeeEmail: 'tochukwu@company.com',
      employeeRole: 'Regional Manager',
      awards: [
        Award(
          id: 'award-001',
          awardName: 'Employee of the Month',
          awardCategory: 'Monthly Recognition',
          awardIcon: '🏆',
          description: 'Outstanding performance and dedication',
          awardDate: DateTime(2024, 4),
          location: 'April',
          awardedBy: 'Management',
          color: '#F4C430',
        ),
        Award(
          id: 'award-002',
          awardName: 'State Excellence Winner',
          awardCategory: 'Excellence',
          awardIcon: '👑',
          description: 'Achieved state-level excellence in operations',
          awardDate: DateTime(2024, 3),
          location: 'Enugu State',
          awardedBy: 'Regional Leadership',
          color: '#E74C3C',
        ),
        Award(
          id: 'award-003',
          awardName: 'Dependable Team Player',
          awardCategory: 'Team Collaboration',
          awardIcon: '👥',
          description: 'Exceptional teamwork and collaboration skills',
          awardDate: DateTime(2024, 1),
          location: 'Headquarters',
          awardedBy: 'HR Department',
          color: '#3498DB',
        ),
        Award(
          id: 'award-004',
          awardName: 'Best Branch Representative',
          awardCategory: 'Branch Excellence',
          awardIcon: '🌟',
          description: 'Best representing branch standards',
          awardDate: DateTime(2024, 3),
          location: 'Enugu',
          awardedBy: 'Branch Manager',
          color: '#2ECC71',
        ),
        Award(
          id: 'award-005',
          awardName: 'Regional Leader',
          awardCategory: 'Leadership',
          awardIcon: '🎖️',
          description: 'Outstanding regional leadership',
          awardDate: DateTime(2024, 2),
          location: 'South East',
          awardedBy: 'Executive Team',
          color: '#34495E',
        ),
      ],
      totalAwards: 5,
    );
  }
}
