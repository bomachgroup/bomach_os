import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/pages/hr/widget/add_associate_dialog.dart';
import 'package:bms_front_end/pages/hr/widget/view_associate_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'controller/associate_controller.dart';

class AssociatesPage extends StatefulWidget {
  const AssociatesPage({super.key});

  @override
  State<AssociatesPage> createState() => _AssociatesPageState();
}

class _AssociatesPageState extends State<AssociatesPage> {
  final AssociatesController controller = Get.put(AssociatesController());
  final _storage = const FlutterSecureStorage();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final token = await _getToken(context);
    if (token != null) {
      controller.fetchAssociates(token);
    }
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  Future<void> _openAddDialog() async {
    final token = await _getToken(context);
    if (token != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AddAssociateDialog(token: token),
      );
    }
  }

  List<Employee> _filterAssociates(List<Employee> associates) {
    if (_searchQuery.isEmpty) return associates;
    final q = _searchQuery.toLowerCase();
    return associates.where((a) {
      return a.firstName.toLowerCase().contains(q) ||
          a.lastName.toLowerCase().contains(q) ||
          a.email.toLowerCase().contains(q) ||
          (a.phoneNumber ?? '').toLowerCase().contains(q) ||
          (a.employmentType ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Associates',
        subtitle: 'Manage external partners and associates',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Associate',
          onTap: _openAddDialog,
        ),
      ),
      children: [
        _buildToolbar(),
        Obx(() {
          final loading =
              controller.isLoading.value && controller.associateList.isEmpty;
          final filtered = _filterAssociates(controller.associateList);
          final isEmpty = !controller.isLoading.value && filtered.isEmpty;

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
            totalCount: controller.associateList.length,
            body: _buildTable(filtered),
          );
        }),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: Row(
        children: [
          Expanded(
            child: MyTextFormField(
              controller: _searchController,
              hintText: 'Search associates by name, email or role',
              height: 48,
              leading: const Icon(Iconsax.search_normal,
                  size: 18, color: AppColors.textMuted),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppColors.surface,
            borderRadius: AppRadii.brMd,
            child: InkWell(
              onTap: _loadData,
              borderRadius: AppRadii.brMd,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: AppRadii.brMd,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                alignment: Alignment.center,
                child: const Icon(Iconsax.refresh,
                    size: 18, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard({
    required bool loading,
    required bool isEmpty,
    required int totalCount,
    required Widget body,
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
                      const Text('Associate directory', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        loading
                            ? 'Loading associates...'
                            : '$totalCount associate${totalCount == 1 ? '' : 's'} on record',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'External partners',
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
                title: 'No associates yet',
                subtitle:
                    'Add external partners, surveyors, lawyers and consultants.',
                action: MyElevatedButton(
                  height: 44,
                  icon: const Icon(Iconsax.add_circle,
                      color: AppColors.textOnPrimary, size: 18),
                  child: 'New Associate',
                  onTap: _openAddDialog,
                ),
              ),
            )
          else
            body,
        ],
      ),
    );
  }

  Widget _buildTable(List<Employee> items) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Associate', flex: 4),
              _buildHeaderCell('Email', flex: 3),
              _buildHeaderCell('Role', flex: 2),
              _buildHeaderCell('Phone', flex: 2),
              _buildHeaderCell('Status', flex: 2),
              _buildHeaderCell('', width: 80),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...items.map(_buildAssociateRow),
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

  Widget _buildAssociateRow(Employee associate) {
    final hasPicture = associate.profilePicture != null &&
        associate.profilePicture!.isNotEmpty;
    final initials = associate.firstName.isNotEmpty
        ? associate.firstName[0].toUpperCase()
        : '?';

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
                  backgroundColor: AppColors.primarySubtle,
                  backgroundImage:
                      hasPicture ? NetworkImage(associate.profilePicture!) : null,
                  child: !hasPicture
                      ? Text(
                          initials,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.primary,
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
                        '${associate.firstName} ${associate.lastName}',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((associate.employmentType ?? '').isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          associate.employmentType!,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              associate.email.isEmpty ? '—' : associate.email,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: (associate.employmentType ?? '-').isEmpty
                    ? '-'
                    : associate.employmentType!,
                tone: StatusTone.primary,
                dense: true,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              (associate.phoneNumber ?? '').isEmpty
                  ? '—'
                  : associate.phoneNumber!,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: associate.isActive ? 'Active' : 'Inactive',
                tone: associate.isActive
                    ? StatusTone.success
                    : StatusTone.neutral,
                dense: true,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: AppColors.surface,
                borderRadius: AppRadii.brMd,
                child: InkWell(
                  borderRadius: AppRadii.brMd,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (c) =>
                          ViewAssociateDialog(associate: associate),
                    );
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.brMd,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Iconsax.eye,
                        size: 18, color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
