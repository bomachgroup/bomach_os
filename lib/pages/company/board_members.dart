import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/button/my_outlined_button.dart';
import 'package:bomach_os/components/cards/app_card.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/paginate/my_paginator.dart';
import 'package:bomach_os/components/section/empty_state.dart';
import 'package:bomach_os/components/section/loading_skeleton.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/company_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controllers/company_controller.dart';
import 'widget/shareholders_dialogs.dart';

/// Board members management page — curated list of shareholders flagged
/// as board members. Admins can add new members, edit roles, and remove
/// existing ones.
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
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Board Members',
        subtitle: 'Manage board members and their roles across the company.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Board Member',
          onTap: () => showDialog(
            context: context,
            builder: (c) =>
                const AddEditShareholderDialog(defaultIsBoardMember: true),
          ),
        ),
      ),
      children: [
        _buildToolbar(),
        Obx(() {
          final loading = controller.isShareholdersLoading.value &&
              controller.shareholders.isEmpty;
          final filtered = controller.filteredBoardMembers;
          final isEmpty = !loading && filtered.isEmpty;

          final startIndex = (_currentPage - 1) * _pageSize;
          final endIndex = (startIndex + _pageSize).clamp(0, filtered.length);
          final pageItems = filtered.isEmpty
              ? const <Shareholder>[]
              : filtered.sublist(startIndex, endIndex);

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
            filtered: filtered,
            body: _buildTable(pageItems, startIndex),
            footer: (!loading && filtered.isNotEmpty)
                ? _tablePaginator(
                    PaginatorFooter(
                      totalItems: filtered.length,
                      limit: _pageSize,
                      currentPage: _currentPage,
                      onPageChanged: (page) =>
                          setState(() => _currentPage = page),
                      onLimitChanged: (newLimit) => setState(() {
                        _pageSize = newLimit;
                        _currentPage = 1;
                      }),
                    ),
                  )
                : null,
          );
        }),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: MyTextFormField(
        controller: searchController,
        hintText: 'Search board members by name, role or email',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: (val) {
          controller.boardSearchQuery.value = val;
          setState(() => _currentPage = 1);
        },
      ),
    );
  }

  Widget _buildTableCard({
    required bool loading,
    required bool isEmpty,
    required List<Shareholder> filtered,
    required Widget body,
    Widget? footer,
  }) {
    return AppCard(
      padding: EdgeInsets.zero,
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Board directory', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        loading
                            ? 'Loading board members...'
                            : '${filtered.length} board member${filtered.length == 1 ? '' : 's'} on record',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Governance council',
                  tone: StatusTone.primary,
                  icon: Iconsax.people,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          if (loading)
            Padding(
              padding: const EdgeInsets.all(20),
              child: LoadingSkeleton.listRows(count: 5),
            )
          else if (isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.people,
                title: 'No board members yet',
                subtitle:
                    'Add shareholders as board members to populate this directory.',
                action: MyOutlinedButton(
                  child: 'New Board Member',
                  icon: const Icon(Iconsax.add_circle,
                      size: 18, color: AppColors.primary),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) =>
                        const AddEditShareholderDialog(defaultIsBoardMember: true),
                  ),
                ),
              ),
            )
          else
            body,
          if (footer != null) ...[
            const Divider(height: 1, color: AppColors.borderSubtle),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _buildTable(List<Shareholder> pageItems, int startIndex) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Member', flex: 4),
              _buildHeaderCell('Role', flex: 2),
              _buildHeaderCell('Email', flex: 3),
              _buildHeaderCell('Status', flex: 2),
              _buildHeaderCell('', width: 180),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...pageItems
            .asMap()
            .entries
            .map((e) => _buildMemberRow(e.value, startIndex + e.key)),
      ],
    );
  }

  Widget _buildHeaderCell(String label, {double? width, int? flex}) {
    final content = Text(
      label,
      style: AppTextStyles.bodySm.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
    if (width != null) return SizedBox(width: width, child: content);
    return Expanded(flex: flex ?? 1, child: content);
  }

  Widget _tablePaginator(Widget child) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: child,
    );
  }

  Widget _buildMemberRow(Shareholder member, int index) {
    final color = _avatarColor(index);
    final hasPicture =
        member.profilePicture != null && member.profilePicture!.isNotEmpty;
    final roleLabel = member.titleDisplay.isNotEmpty
        ? member.titleDisplay
        : (member.title.isNotEmpty ? member.title : 'Member');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withValues(alpha: 0.15),
                  backgroundImage:
                      hasPicture ? NetworkImage(member.profilePicture!) : null,
                  child: !hasPicture
                      ? Text(
                          member.firstName.isNotEmpty
                              ? member.firstName[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.label.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName,
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${member.sharePercentage}% share',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: StatusChip(
                  label: roleLabel,
                  tone: StatusTone.primary,
                  dense: true,
                  icon: Iconsax.briefcase,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              member.email.isEmpty ? '—' : member.email,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: StatusChip(
                  label: member.isActive ? 'Active' : 'Inactive',
                  tone: member.isActive
                      ? StatusTone.success
                      : StatusTone.neutral,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (c) => AddEditShareholderDialog(shareholder: member),
                  ),
                  icon: const Icon(Iconsax.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderStrong),
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                        borderRadius: AppRadii.brMd),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Remove',
                  onPressed: () => _confirmDelete(member),
                  icon: const Icon(Iconsax.trash,
                      size: 18, color: AppColors.danger),
                  style: IconButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadii.brMd,
                      side: BorderSide(color: AppColors.borderSubtle),
                    ),
                    minimumSize: const Size(42, 42),
                  ),
                ),
              ],
            ),
          ),
        ],
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
