import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/dialog/dialog_scaffold.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/paginate/my_paginator.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/components/section/responsive_stat_row.dart';
import 'package:bms_front_end/pages/hr/widget/add_lead_dialog.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _pageSize = 10;
  int _currentPage = 1;

  // Demo data preserved from original implementation (UI-only page).
  static final List<_LeadRow> _demoLeads = List.generate(
    10,
    (i) => _LeadRow(
      id: (i + 1).toString().padLeft(3, '0'),
      name: 'Darlene Robertson',
      company: 'MTN Nigeria',
      email: 'Jennygroup45@gmail.com',
      phone: '+234 808 986 2487',
      owner: '--',
      createdAt: '27/09/2024',
      status: 'new',
    ),
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_LeadRow> _filterLeads(List<_LeadRow> leads) {
    if (_searchQuery.isEmpty) return leads;
    final q = _searchQuery.toLowerCase();
    return leads.where((l) {
      return l.name.toLowerCase().contains(q) ||
          l.company.toLowerCase().contains(q) ||
          l.email.toLowerCase().contains(q) ||
          l.phone.contains(q) ||
          l.id.contains(q);
    }).toList();
  }

  StatusTone _statusTone(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return StatusTone.info;
      case 'contacted':
        return StatusTone.primary;
      case 'qualified':
      case 'converted':
        return StatusTone.success;
      case 'disqualified':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterLeads(_demoLeads);
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, filtered.length);
    final pageItems = filtered.isEmpty
        ? const <_LeadRow>[]
        : filtered.sublist(startIndex, endIndex);

    return PageScaffold(
      maxContentWidth: 1440,
      header: PageHeader(
        title: 'Leads',
        subtitle: 'Track and convert recruitment leads through the pipeline.',
        trailing: MyElevatedButton(
          height: 48,
          icon: const Icon(Iconsax.add_circle,
              color: AppColors.textOnPrimary, size: 18),
          child: 'New Lead',
          onTap: () => showDialog(
            context: context,
            builder: (context) => const AddLeadDialog(),
          ),
        ),
      ),
      children: [
        _buildToolbar(),
        _buildTableCard(
          isEmpty: filtered.isEmpty,
          totalCount: filtered.length,
          body: _buildTable(pageItems),
          footer: filtered.isNotEmpty
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
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: AppCardElevation.sm,
      child: MyTextFormField(
        controller: _searchController,
        hintText: 'Search leads by name, email, phone or company',
        height: 48,
        leading: const Icon(Iconsax.search_normal,
            size: 18, color: AppColors.textMuted),
        onChanged: (v) => setState(() {
          _searchQuery = v;
          _currentPage = 1;
        }),
      ),
    );
  }

  Widget _buildTableCard({
    required bool isEmpty,
    required int totalCount,
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
                      const Text('Lead pipeline', style: AppText.h3),
                      const SizedBox(height: 4),
                      Text(
                        '$totalCount lead${totalCount == 1 ? '' : 's'} in the pipeline',
                        style: AppText.bodyMd.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Recruitment leads',
                  tone: StatusTone.primary,
                  icon: Iconsax.profile_2user,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          if (isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: EmptyState(
                icon: Iconsax.profile_2user,
                title: 'No leads found',
                subtitle: _searchQuery.isEmpty
                    ? 'Add new leads to start building your recruitment pipeline.'
                    : 'Try adjusting your search terms.',
                action: _searchQuery.isEmpty
                    ? MyElevatedButton(
                        height: 44,
                        icon: const Icon(Iconsax.add_circle,
                            color: AppColors.textOnPrimary, size: 18),
                        child: 'New Lead',
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => const AddLeadDialog(),
                        ),
                      )
                    : null,
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

  Widget _buildTable(List<_LeadRow> items) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: AppColors.surfaceMuted,
          child: Row(
            children: [
              _buildHeaderCell('Lead ID', flex: 2),
              _buildHeaderCell('Contact', flex: 4),
              _buildHeaderCell('Email', flex: 3),
              _buildHeaderCell('Phone', flex: 2),
              _buildHeaderCell('Status', flex: 2),
              _buildHeaderCell('Owner', flex: 2),
              _buildHeaderCell('Created', flex: 2),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.borderSubtle),
        ...items.map(_buildLeadRow),
      ],
    );
  }

  Widget _buildHeaderCell(String label, {double? width, int? flex}) {
    final content = Text(
      label,
      style: AppText.bodySm.copyWith(
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

  Widget _buildLeadRow(_LeadRow lead) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => _ViewLeadsDialog(lead: lead),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                lead.id,
                style: AppText.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primarySubtle,
                    child: Text(
                      lead.name.isNotEmpty ? lead.name[0].toUpperCase() : '?',
                      style: AppText.label.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.name,
                          style: AppText.bodyMd.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lead.company,
                          style: AppText.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                lead.email,
                style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                lead.phone,
                style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(
                  label: _statusLabel(lead.status),
                  tone: _statusTone(lead.status),
                  dense: true,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                lead.owner,
                style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                lead.createdAt,
                style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String s) {
    if (s.isEmpty) return 'New';
    return s[0].toUpperCase() + s.substring(1);
  }
}

/// Demo lead row — preserves the original UI-only data shape for the leads page.
class _LeadRow {
  final String id;
  final String name;
  final String company;
  final String email;
  final String phone;
  final String owner;
  final String createdAt;
  final String status;

  const _LeadRow({
    required this.id,
    required this.name,
    required this.company,
    required this.email,
    required this.phone,
    required this.owner,
    required this.createdAt,
    required this.status,
  });
}

// ─── View Lead Dialog ────────────────────────────────────────────────────────

class _ViewLeadsDialog extends StatelessWidget {
  final _LeadRow? lead;
  const _ViewLeadsDialog({this.lead});

  @override
  Widget build(BuildContext context) {
    final l = lead;
    final name = l?.name ?? 'Jane Okoro';
    final company = l?.company ?? 'Business';
    final email = l?.email ?? 'Janeokoro45@gmail.com';
    final phone = l?.phone ?? '+2349077745777';
    final id = l?.id ?? '001';
    final createdAt = l?.createdAt ?? '27/09/2024';
    final status = l?.status ?? 'new';

    return DialogScaffold(
      title: 'Lead Details',
      subtitle: '$name • $company',
      size: DialogSize.lg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryBanner(
            name: name,
            company: company,
            status: status,
            id: id,
            createdAt: createdAt,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            return const ResponsiveStatRow(
              cards: [
                _StatCard(
                  title: 'Total Leads',
                  count: '1,284',
                  icon: Iconsax.user_search,
                  accent: AppColors.primary,
                ),
                _StatCard(
                  title: 'Active Interviews',
                  count: '42',
                  icon: Iconsax.personalcard,
                  accent: AppColors.info,
                ),
                _StatCard(
                  title: 'Hired (Month)',
                  count: '12',
                  icon: Iconsax.user_tick,
                  accent: AppColors.success,
                ),
                _StatCard(
                  title: 'Drop-off Rate',
                  count: '18%',
                  icon: Iconsax.user_minus,
                  accent: AppColors.danger,
                ),
              ],
            );
          }),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Personal information',
            children: [
              _detailRow('Lead ID', id),
              _detailRow('Contact Name', name),
              _detailRow('Company', company),
              _detailRow('Phone', phone),
              _detailRow('Email', email),
              _detailRow('Date of creation', createdAt),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Detail',
            children: [
              Text(
                'Detail about this lead — enquiry notes, follow-ups, and other '
                'relevant context captured during outreach.',
                style: AppText.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Notes',
            children: [
              for (int i = 0; i < 5; i++) ...[
                _buildNote(i + 1,
                    'Follow-up note ${i + 1} — captured during recruitment outreach.'),
                if (i < 4) const SizedBox(height: 10),
              ],
            ],
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Close',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          icon: const Icon(Iconsax.add_circle,
              size: 18, color: AppColors.textOnPrimary),
          child: 'Add Note',
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => const AddNoteDialog(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSummaryBanner({
    required String name,
    required String company,
    required String status,
    required String id,
    required String createdAt,
  }) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brLg,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: AppText.h2.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppText.h3),
                const SizedBox(height: 2),
                Text(
                  company,
                  style:
                      AppText.bodySm.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(
                      label: status.isEmpty
                          ? 'New'
                          : status[0].toUpperCase() + status.substring(1),
                      tone: _toneFromStatus(status),
                    ),
                    _buildMetaChip(icon: Iconsax.hashtag, label: 'ID $id'),
                    _buildMetaChip(
                        icon: Iconsax.calendar_1, label: 'Created $createdAt'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brPill,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppText.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.h4),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppText.label.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppText.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNote(int index, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: AppRadii.brSm,
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: AppText.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  StatusTone _toneFromStatus(String s) {
    switch (s.toLowerCase()) {
      case 'new':
        return StatusTone.info;
      case 'contacted':
        return StatusTone.primary;
      case 'qualified':
      case 'converted':
        return StatusTone.success;
      case 'disqualified':
        return StatusTone.danger;
      default:
        return StatusTone.neutral;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: AppRadii.brSm,
                ),
                child: Icon(icon, size: 18, color: accent),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppText.bodySm.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: AppText.h1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Note Dialog ─────────────────────────────────────────────────────────

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final TextEditingController _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogScaffold(
      title: 'Add Note',
      subtitle: 'Capture a follow-up note for this lead.',
      size: DialogSize.md,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextFormField(
            controller: _noteCtrl,
            hintText: 'Enter note',
            title: 'Note',
            maxLines: 7,
          ),
        ],
      ),
      actions: [
        MyOutlinedButton(
          child: 'Cancel',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          onTap: () => Navigator.pop(context),
          textColor: AppColors.textSecondary,
          borderColor: AppColors.borderStrong,
        ),
        MyElevatedButton(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          icon: const Icon(Iconsax.send_1,
              size: 18, color: AppColors.textOnPrimary),
          child: 'Submit',
          onTap: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
