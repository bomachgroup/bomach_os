import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/company_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/company_controller.dart';
import 'widget/shareholders_dialogs.dart';

class BoardMembersPage extends StatefulWidget {
  const BoardMembersPage({super.key});

  @override
  State<BoardMembersPage> createState() => _BoardMembersPageState();
}

class _BoardMembersPageState extends State<BoardMembersPage> {
  final CompanyController controller = Get.find<CompanyController>();
  final searchController = TextEditingController();

  int _pageSize = 10;
  int _currentPage = 1;

  static const _avatarColors = [
    AppColors.warning,
    Color(0xFFC026D3),
    AppColors.info,
    AppColors.success,
    AppColors.warning,
    Color(0xFF7C3AED),
  ];

  Color _avatarColor(int index) => _avatarColors[index % _avatarColors.length];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        const MyText('Board Members', style: AppText.h4),
        const SizedBox(height: 4),
        const MyText(
          'Manage board members and their roles',
          size: 12,
          color: Colors.grey,
        ),
        kSizedBox,

        // Search + Add button
        Row(
          children: [
            Expanded(
              child: SizedBox(
                width: 300,
                child: MyTextFormField(
                  controller: searchController,
                  hintText: 'Search board members...',
                  leading: const Icon(Iconsax.search_normal, color: Colors.grey),
                  onChanged: (val) {
                    controller.boardSearchQuery.value = val;
                    setState(() => _currentPage = 1);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            MyElevatedButton(
              height: 40,
              icon: const Icon(Iconsax.add, color: Colors.white, size: 18),
              child: "Add Board Member",
              onTap: () => showDialog(
                context: context,
                builder: (c) =>
                    const AddEditShareholderDialog(defaultIsBoardMember: true),
              ),
            ),
          ],
        ),
        kSizedBox,

        // Content
        Obx(() {
          if (controller.isShareholdersLoading.value &&
              controller.shareholders.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(60),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final filtered = controller.filteredBoardMembers;

          if (filtered.isEmpty) {
            return _buildEmptyState();
          }

          final startIndex = (_currentPage - 1) * _pageSize;
          final endIndex = (startIndex + _pageSize).clamp(0, filtered.length);
          final pageItems = filtered.sublist(startIndex, endIndex);

          return Column(
            children: [
              ...pageItems.asMap().entries.map(
                    (entry) => _buildBoardMemberCard(entry.value, entry.key),
                  ),
              const SizedBox(height: 16),
              PaginatorFooter(
                totalItems: filtered.length,
                limit: _pageSize,
                currentPage: _currentPage,
                onPageChanged: (page) => setState(() => _currentPage = page),
                onLimitChanged: (newLimit) => setState(() {
                  _pageSize = newLimit;
                  _currentPage = 1;
                }),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        children: [
          Icon(Iconsax.people, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const MyText(
            'No board members found',
            size: 14,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          const MyText(
            'Add shareholders as board members to see them here',
            size: 12,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildBoardMemberCard(Shareholder member, int index) {
    final color = _avatarColor(index);

    Color roleColor;
    switch (member.titleDisplay.toLowerCase()) {
      case 'founder':
        roleColor = Colors.green;
        break;
      case 'co-founder':
        roleColor = Colors.blue;
        break;
      case 'investor':
        roleColor = Colors.orange;
        break;
      case 'director':
        roleColor = Colors.purple;
        break;
      default:
        roleColor = Colors.grey;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.15),
            child: member.profilePicture != null
                ? ClipOval(
                    child: Image.network(
                      member.profilePicture!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(
                        member.firstName.isNotEmpty
                            ? member.firstName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : Text(
                    member.firstName.isNotEmpty
                        ? member.firstName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: MyText(
                        member.fullName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        member.titleDisplay.isNotEmpty
                            ? member.titleDisplay
                            : member.title,
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                MyText(
                  member.email,
                  size: 12,
                  color: Colors.grey[600]!,
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: member.isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              member.isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                color: member.isActive ? Colors.green : Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Actions
          _buildActionButton(
            icon: Iconsax.edit,
            tooltip: 'Edit',
            onTap: () => showDialog(
              context: context,
              builder: (c) => AddEditShareholderDialog(shareholder: member),
            ),
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Iconsax.trash,
            tooltip: 'Remove',
            onTap: () => _confirmDelete(member),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderSubtle),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.grey[700]),
      ),
    );
  }

  void _confirmDelete(Shareholder member) async {
    final confirmed =
        await showDeleteShareholderDialog(context, member.fullName);
    if (confirmed == true && mounted) {
      controller.deleteShareholder(context, member.id);
    }
  }
}
