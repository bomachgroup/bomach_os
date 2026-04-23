import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'controller/disciplinary_controller.dart';
import 'models/disciplinary_cases_model.dart';
import 'widget/add_disciplinary_case_dialog.dart';
import 'widget/appeal_disciplinary_case_dialog.dart';

class DisciplinaryProcessPage extends StatefulWidget {
  const DisciplinaryProcessPage({super.key});

  @override
  State<DisciplinaryProcessPage> createState() =>
      _DisciplinaryProcessPageState();
}

class _DisciplinaryProcessPageState extends State<DisciplinaryProcessPage> {
  final DisciplinaryController controller = Get.put(DisciplinaryController());
  final _storage = const FlutterSecureStorage();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final token = await _getToken(context);
    if (token != null) {
      controller.fetchCases(token);
    }
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DisciplinaryCase> _filtered(List<DisciplinaryCase> cases) {
    if (_searchQuery.isEmpty) return cases;
    final q = _searchQuery.toLowerCase();
    return cases.where((c) {
      return c.employeeId.toLowerCase().contains(q) ||
          c.violationTitle.toLowerCase().contains(q) ||
          c.violationCategory.toLowerCase().contains(q) ||
          c.actionType.toLowerCase().contains(q);
    }).toList();
  }

  StatusTone _actionTone(String actionType) {
    final type = actionType.toLowerCase();
    if (type.contains('termination') || type.contains('dismissal')) {
      return StatusTone.danger;
    }
    if (type.contains('final')) return StatusTone.danger;
    if (type.contains('suspension')) return StatusTone.warning;
    if (type.contains('written')) return StatusTone.warning;
    if (type.contains('warning')) return StatusTone.info;
    return StatusTone.neutral;
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Disciplinary Process',
        subtitle: 'Track and manage disciplinary cases',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Case',
          onTap: () async {
            final token = await _getToken(context);
            if (token != null && mounted) {
              showDialog(
                context: context,
                builder: (c) => AddDisciplinaryCaseDialog(token: token),
              );
            }
          },
        ),
      ),
      children: [
        _buildToolbar(),
        Obx(() {
          final loading =
              controller.isLoading.value && controller.caseList.isEmpty;
          final filtered = _filtered(controller.caseList);
          final isEmpty = !loading && filtered.isEmpty;

          return _buildTableCard(
            loading: loading,
            isEmpty: isEmpty,
            filtered: filtered,
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
              hintText: 'Search cases by employee, title or type',
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
    required List<DisciplinaryCase> filtered,
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
                      const Text('Cases register', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Text(
                        loading
                            ? 'Loading disciplinary cases...'
                            : '${filtered.length} case${filtered.length == 1 ? '' : 's'} on record',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'HR review',
                  tone: StatusTone.primary,
                  icon: Iconsax.shield_tick,
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
            const Padding(
              padding: EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.shield_cross,
                title: 'No disciplinary cases found',
                subtitle:
                    'Cases logged by HR and managers will appear here for review and tracking.',
              ),
            )
          else
            body,
        ],
      ),
    );
  }

  Widget _buildTable(List<DisciplinaryCase> cases) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Employee ID', flex: 2),
              _buildHeaderCell('Action Type', flex: 2),
              _buildHeaderCell('Category', flex: 2),
              _buildHeaderCell('Violation Title', flex: 3),
              _buildHeaderCell('Date', flex: 2),
              _buildHeaderCell('', width: 64),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...cases.map(_buildDataRow),
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

  Widget _buildDataRow(DisciplinaryCase kase) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              kase.employeeId,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: kase.actionType,
                tone: _actionTone(kase.actionType),
                dense: true,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              kase.violationCategory,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              kase.violationTitle,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              kase.actionDate != null
                  ? DateFormat('dd MMM yyyy').format(kase.actionDate!)
                  : '—',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 64,
            child: Align(
              alignment: Alignment.centerRight,
              child: Material(
                color: Colors.transparent,
                borderRadius: AppRadii.brMd,
                child: InkWell(
                  borderRadius: AppRadii.brMd,
                  onTap: () async {
                    final token = await _getToken(context);
                    if (token != null && mounted) {
                      showDialog(
                        context: context,
                        builder: (c) => ViewDisciplinaryCaseDialog(
                          kase: kase,
                          token: token,
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.brMd,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(Iconsax.eye,
                        size: 16, color: AppColors.primary),
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
