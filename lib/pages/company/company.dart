import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/pages/company/board_members.dart';
import 'package:bms_front_end/pages/company/compliance.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/shadows.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/company_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import 'controllers/company_controller.dart';
import 'widget/edit_company_dialog.dart';
import 'widget/shareholders_dialogs.dart';

const List<String> _companyTabs = [
  'Profile',
  'Global Business',
  'Ownership & Shareholders',
  'Board Members',
  'Compliance & Registration',
];

const Color _accentBlue = AppColors.primary;
const Color _accentGreen = AppColors.success;
const Color _accentAmber = AppColors.warning;
const Color _accentIndigo = Color(0xFF4F46E5);

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  final CompanyController controller = Get.put(CompanyController());
  String currentTab = _companyTabs.first;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.companySettings.value;

      return PageScaffold(
        maxContentWidth: 1440,
        header: PageHeader(
          title: 'Company Profile',
          subtitle:
              'Organization identity, governance, and operating defaults.',
          trailing: data == null ? null : _buildHeaderAction(context),
        ),
        children: [
          if (controller.isLoading.value && data == null)
            _buildLoadingState()
          else if (data == null)
            _buildErrorState()
          else
            _buildLoadedState(context, data),
        ],
      );
    });
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoadingSkeleton.card(lines: 5),
        const SizedBox(height: 20),
        LoadingSkeleton.statRow(),
        const SizedBox(height: 20),
        LoadingSkeleton.card(lines: 8),
      ],
    );
  }

  Widget _buildErrorState() {
    return EmptyState(
      icon: Iconsax.warning_2,
      title: 'Could not load company profile',
      subtitle: controller.errorMessage.value.isNotEmpty
          ? controller.errorMessage.value
          : 'Please try again.',
      action: ElevatedButton(
        onPressed: controller.fetchCompanyProfile,
        child: const Text('Retry'),
      ),
    );
  }

  Widget _buildLoadedState(BuildContext context, CompanySettings data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatsSection(),
        const SizedBox(height: 24),
        _buildTabBar(),
        const SizedBox(height: 24),
        _buildCurrentTab(context, data),
      ],
    );
  }

  Widget? _buildHeaderAction(BuildContext context) {
    switch (currentTab) {
      case 'Profile':
        return MyElevatedButton(
          child: 'Edit Profile',
          icon: const Icon(Iconsax.edit,
              size: 16, color: AppColors.textOnPrimary),
          onTap: () => showDialog(
            context: context,
            builder: (_) => const EditProfileDialog(),
          ),
        );
      case 'Global Business':
        return MyElevatedButton(
          child: 'Edit Settings',
          icon: const Icon(Iconsax.setting_2,
              size: 16, color: AppColors.textOnPrimary),
          onTap: () => showDialog(
            context: context,
            builder: (_) => const EditGlobalBusinessDialog(),
          ),
        );
      case 'Ownership & Shareholders':
        return MyElevatedButton(
          child: 'Edit Shareholders',
          icon: const Icon(Iconsax.people,
              size: 16, color: AppColors.textOnPrimary),
          onTap: () => showDialog(
            context: context,
            builder: (_) => const EditShareHoldersDialog(),
          ),
        );
      default:
        return null;
    }
  }

  Widget _buildOverviewHero(CompanySettings data) {
    final primary = controller.getColorFromHex(data.primaryColorCode);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;
        final address = _normalizedValue(data.companyAddresses);

        final identityBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogoPanel(data, primary),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayValue(data.companyName),
                        style: AppText.displayMd.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _displayValue(
                          data.companySlogan,
                          fallback:
                              'A central record for identity, governance, and brand operations.',
                        ),
                        style: AppText.bodyLg.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildMetaChip(
                            icon: Iconsax.briefcase,
                            label: controller.industry.value,
                          ),
                          _buildMetaChip(
                            icon: Iconsax.money_2,
                            label: data.defaultCurrency,
                          ),
                          _buildMetaChip(
                            icon: Iconsax.global,
                            label: controller.timeZone.value,
                          ),
                          _buildMetaChip(
                            icon: Iconsax.shield_tick,
                            label: controller.approvalType.value,
                            foregroundColor: AppColors.primary,
                            backgroundColor: AppColors.primarySubtle,
                            borderColor: AppColors.primarySoft,
                          ),
                        ],
                      ),
                      if (address != null) ...[
                        const SizedBox(height: 18),
                        Text(
                          address,
                          style: AppText.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        );

        final summaryPanel = Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: AppRadii.brMd,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const StatusChip(
                    label: 'Profile live',
                    tone: StatusTone.success,
                    icon: Iconsax.tick_circle,
                  ),
                  StatusChip(
                    label: data.languagePreference,
                    tone: StatusTone.neutral,
                    icon: Iconsax.translate,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSummaryRow('RC Number', data.rcNumber),
              _buildSummaryRow('Industry', controller.industry.value),
              _buildSummaryRow('Updated', _formatDate(data.updatedAt)),
              _buildSummaryRow('Created', _formatDate(data.createdAt)),
            ],
          ),
        );

        return AppCard(
          padding: EdgeInsets.all(compact ? 20 : 24),
          elevation: AppCardElevation.md,
          borderColor: AppColors.borderSubtle,
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    identityBlock,
                    const SizedBox(height: 18),
                    summaryPanel,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: identityBlock),
                    const SizedBox(width: 24),
                    SizedBox(width: 290, child: summaryPanel),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildLogoPanel(CompanySettings data, Color accent) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: accent.withValues(alpha: 0.18)),
        boxShadow: AppShadows.sm,
      ),
      child: ClipRRect(
        borderRadius: AppRadii.brLg,
        child: data.companyLogo != null && data.companyLogo!.isNotEmpty
            ? Image.network(
                data.companyLogo!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildLogoFallback(accent),
              )
            : _buildLogoFallback(accent),
      ),
    );
  }

  Widget _buildLogoFallback(Color accent) {
    return Center(
      child: Icon(
        Iconsax.building_3,
        size: 34,
        color: accent,
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    Color? foregroundColor,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceMuted,
        borderRadius: AppRadii.brPill,
        border: Border.all(color: borderColor ?? AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14, color: foregroundColor ?? AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            _displayValue(label),
            style: AppText.bodySm.copyWith(
              color: foregroundColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: AppText.caption.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              _displayValue(value),
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

  Widget _buildStatsSection() {
    return Obx(() {
      if (controller.isDashboardLoading.value &&
          controller.dashboardStats.value == null) {
        return LoadingSkeleton.statRow();
      }

      final stats = controller.dashboardStats.value;
      final cards = <Widget>[
        DashboardStatCard(
          title: 'Total Employees',
          count: stats != null ? '${stats.totalEmployees}' : '--',
          accentColor: _accentGreen,
          subtext: stats != null && stats.newEmployeesCount > 0
              ? '+${stats.newEmployeesCount} recently added'
              : 'Directory coverage',
          icon: Iconsax.profile_2user,
        ),
        DashboardStatCard(
          title: 'Total Branches',
          count: stats != null ? '${stats.totalBranches}' : '--',
          accentColor: _accentBlue,
          subtext: stats != null && stats.removedBranchesCount > 0
              ? '${stats.removedBranchesCount} recently removed'
              : 'Operational footprint',
          icon: Iconsax.buildings,
        ),
        DashboardStatCard(
          title: 'Pending Approvals',
          count: stats != null ? '${stats.pendingApprovals}' : '--',
          accentColor: _accentAmber,
          subtext: stats != null && stats.overdueTasksCount > 0
              ? '${stats.overdueTasksCount} overdue tasks'
              : 'Workflow queue',
          icon: Iconsax.timer_1,
        ),
        DashboardStatCard(
          title: 'Asset Inventory',
          count: stats != null ? '${stats.assetInventory}' : '--',
          accentColor: _accentIndigo,
          subtext: stats != null && stats.newInventoryCount > 0
              ? '+${stats.newInventoryCount} new records'
              : 'Tracked resources',
          icon: Iconsax.box,
        ),
      ];
      return ResponsiveStatRow(cards: cards);
    });
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _companyTabs
              .map((label) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildTabButton(label),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label) {
    final isActive = currentTab == label;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadii.brMd,
        onTap: () => setState(() => currentTab = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: AppRadii.brMd,
            boxShadow: isActive ? AppShadows.sm : const <BoxShadow>[],
          ),
          child: Text(
            label,
            style: AppText.bodyMd.copyWith(
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab(BuildContext context, CompanySettings data) {
    switch (currentTab) {
      case 'Global Business':
        return _buildGlobalBusinessTab(context, data);
      case 'Ownership & Shareholders':
        return _buildOwnershipTab(context);
      case 'Board Members':
        return const BoardMembersPage();
      case 'Compliance & Registration':
        return const CompliancePage();
      case 'Profile':
      default:
        return _buildProfileTab(context, data);
    }
  }

  Widget _buildProfileTab(BuildContext context, CompanySettings data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildOverviewHero(data),
        const SizedBox(height: 20),
        AppCard(
          padding: const EdgeInsets.all(24),
          backgroundColor: AppColors.surfaceMuted,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final title = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Company information', style: AppText.h2),
                  const SizedBox(height: 6),
                  Text(
                    'Core records for communications and registration details.',
                    style: AppText.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: 16),
                    _buildInlineProfileActions(context),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: 16),
                  _buildInlineProfileActions(context),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildProfileSupportCards(data),
      ],
    );
  }

  Widget _buildInlineProfileActions(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        MyElevatedButton(
          height: 48,
          child: 'Edit Profile',
          icon: const Icon(Iconsax.edit,
              size: 16, color: AppColors.textOnPrimary),
          onTap: () => showDialog(
            context: context,
            builder: (_) => const EditProfileDialog(),
          ),
        ),
        OutlinedButton.icon(
          onPressed: controller.fetchCompanyProfile,
          icon: const Icon(Iconsax.refresh, size: 16),
          label: const Text('Refresh'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.borderStrong),
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
            alignment: Alignment.center,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSupportCards(CompanySettings data) {
    final cards = <Widget>[
      _buildSupportCard(
        title: 'Identity',
        icon: Iconsax.building_3,
        children: [
          _buildDetailEntry('Company Name', data.companyName),
          _buildDetailEntry('Industry', controller.industry.value),
          _buildDetailEntry('Slogan', data.companySlogan),
          if (_normalizedValue(data.companyAddresses) != null)
            _buildDetailEntry('Address', data.companyAddresses),
        ],
      ),
      _buildSupportCard(
        title: 'Contact & registration',
        icon: Iconsax.message_text,
        children: [
          _buildDetailEntry('Email', data.companyEmail),
          _buildDetailEntry('Phone', data.companyPhone),
          _buildDetailEntry('RC Number', data.rcNumber),
          _buildDetailEntry('Updated', _formatDate(data.updatedAt)),
          _buildDetailEntry('Created', _formatDate(data.createdAt)),
        ],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
            ],
          );
        }

        return Column(
          children: [
            cards[0],
            const SizedBox(height: 16),
            cards[1],
          ],
        );
      },
    );
  }

  Widget _buildSupportCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.primarySubtle,
                  borderRadius: AppRadii.brMd,
                ),
                child: Icon(icon, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: AppText.h4)),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailEntry(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppText.caption.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(
            _displayValue(value),
            style: AppText.bodyMd.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorEntry(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppText.caption.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: AppRadii.brSm,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _displayValue(value),
                style: AppText.bodyMd.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalBusinessTab(BuildContext context, CompanySettings data) {
    final cards = <Widget>[
      _buildSupportCard(
        title: 'Brand palette',
        icon: Iconsax.colorfilter,
        children: [
          _buildColorEntry(
            'Primary Color',
            data.primaryColorCode,
            controller.getColorFromHex(data.primaryColorCode),
          ),
          _buildColorEntry(
            'Secondary Color',
            data.secondaryColorCode,
            controller.getColorFromHex(data.secondaryColorCode),
          ),
          _buildDetailEntry('Slogan', data.companySlogan),
        ],
      ),
      _buildSupportCard(
        title: 'Regional defaults',
        icon: Iconsax.global,
        children: [
          _buildDetailEntry('Default Currency', data.defaultCurrency),
          _buildDetailEntry('Language Preference', data.languagePreference),
          _buildDetailEntry('Time Zone', controller.timeZone.value),
        ],
      ),
      _buildSupportCard(
        title: 'Governance rules',
        icon: Iconsax.setting_2,
        children: [
          _buildDetailEntry('Business Rules', data.businessRules),
          _buildDetailEntry('Approval Flow', controller.approvalType.value),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (controller.notifyEmail.value)
                  _buildStaticPill('Email', true),
                if (controller.notifySMS.value) _buildStaticPill('SMS', true),
                if (controller.notifyPush.value) _buildStaticPill('Push', true),
                if (!controller.notifyEmail.value &&
                    !controller.notifySMS.value &&
                    !controller.notifyPush.value)
                  _buildStaticPill('No notification channels', false),
              ],
            ),
          ),
        ],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: AppColors.surfaceMuted,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;

              final intro = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Global business settings', style: AppText.h2),
                  const SizedBox(height: 6),
                  Text(
                    'Brand presentation, operating defaults, and approval behavior live here.',
                    style: AppText.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );

              final action = MyElevatedButton(
                child: 'Edit Settings',
                icon: const Icon(Iconsax.setting_2,
                    size: 16, color: AppColors.textOnPrimary),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => const EditGlobalBusinessDialog(),
                ),
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    intro,
                    const SizedBox(height: 16),
                    action,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: intro),
                  const SizedBox(width: 16),
                  action,
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildResponsiveCardGrid(cards),
      ],
    );
  }

  Widget _buildOwnershipTab(BuildContext context) {
    final numberFormat = NumberFormat('#,###');

    return Obx(() {
      if (controller.isShareholdersLoading.value &&
          controller.shareholders.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: LoadingSkeleton.listRows(count: 5),
        );
      }

      final list = controller.shareholders;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            backgroundColor: AppColors.surfaceMuted,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 780;

                final intro = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ownership & shareholders', style: AppText.h2),
                    const SizedBox(height: 6),
                    Text(
                      'Track equity distribution, active shareholders, and board-linked ownership records.',
                      style: AppText.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );

                final actions = Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    MyElevatedButton(
                      child: 'Edit Shareholders',
                      icon: const Icon(Iconsax.edit,
                          size: 16, color: AppColors.textOnPrimary),
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => const EditShareHoldersDialog(),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const EditEquityDialog(),
                      ),
                      icon: const Icon(Iconsax.chart_2, size: 16),
                      label: const Text('Update Shares'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.borderStrong),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.brMd,
                        ),
                      ),
                    ),
                  ],
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      intro,
                      const SizedBox(height: 16),
                      actions,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: intro),
                    const SizedBox(width: 16),
                    actions,
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildResponsiveCardGrid([
            DashboardStatCard(
              title: 'Authorized Shares',
              count: controller.isEquityLoading.value
                  ? '--'
                  : numberFormat.format(controller.authorizedShares.value),
              accentColor: _accentBlue,
              subtext: 'Total equity available',
              icon: Iconsax.medal_star,
            ),
            DashboardStatCard(
              title: 'Issued Shares',
              count: numberFormat.format(controller.issuedShares),
              accentColor: _accentGreen,
              subtext: 'Allocated to shareholders',
              icon: Iconsax.receipt_2_1,
            ),
            DashboardStatCard(
              title: 'Unissued Shares',
              count: numberFormat.format(controller.unissuedShares),
              accentColor: _accentAmber,
              subtext: 'Available for future allocation',
              icon: Iconsax.chart_success,
            ),
          ]),
          const SizedBox(height: 20),
          if (list.isEmpty)
            _buildEmptyState(
              context,
              icon: Iconsax.people,
              title: 'No shareholders yet',
              subtitle:
                  'Add shareholders to track ownership and share distribution.',
              buttonLabel: 'Add Shareholder',
              onAdd: () => showDialog(
                context: context,
                builder: (_) => const AddEditShareholderDialog(),
              ),
            )
          else
            AppCard(
              padding: EdgeInsets.zero,
              elevation: AppCardElevation.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceMuted,
                      border: Border(
                        bottom: BorderSide(color: AppColors.borderSubtle),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Shareholder register',
                                  style: AppText.h3),
                              const SizedBox(height: 4),
                              Text(
                                '${list.length} active ownership records',
                                style: AppText.bodyMd.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusChip(
                          label:
                              '${controller.boardMembers.length} board-linked',
                          tone: StatusTone.info,
                          icon: Iconsax.user_octagon,
                        ),
                      ],
                    ),
                  ),
                  ResponsiveTableWrapper(
                    minWidth: 920,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          color: AppColors.surface,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text('Shareholder',
                                    style: AppText.label.copyWith(
                                      color: AppColors.textSecondary,
                                    )),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('Role',
                                    style: AppText.label.copyWith(
                                      color: AppColors.textSecondary,
                                    )),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('Shares',
                                    style: AppText.label.copyWith(
                                      color: AppColors.textSecondary,
                                    )),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('Ownership',
                                    style: AppText.label.copyWith(
                                      color: AppColors.textSecondary,
                                    )),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text('Status',
                                    style: AppText.label.copyWith(
                                      color: AppColors.textSecondary,
                                    )),
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),
                        const Divider(height: 1, color: AppColors.borderSubtle),
                        ...list.asMap().entries.map((entry) {
                          return _buildShareholderRow(
                            context,
                            entry.value,
                            entry.key,
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildShareholderRow(
      BuildContext context, Shareholder shareholder, int index) {
    final numberFormat = NumberFormat('#,###');
    final avatarColor = _avatarColor(index);
    final roleTone = _roleTone(shareholder.titleDisplay);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: avatarColor.withValues(alpha: 0.14),
                  child: shareholder.profilePicture != null &&
                          shareholder.profilePicture!.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            shareholder.profilePicture!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildAvatarInitial(shareholder, avatarColor),
                          ),
                        )
                      : _buildAvatarInitial(shareholder, avatarColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shareholder.fullName,
                        style: AppText.bodyMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shareholder.email,
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
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusChip(
                  label: shareholder.titleDisplay.isNotEmpty
                      ? shareholder.titleDisplay
                      : shareholder.title,
                  tone: roleTone,
                ),
                if (shareholder.isBoardMember) ...[
                  const SizedBox(height: 6),
                  const StatusChip(
                    label: 'Board member',
                    tone: StatusTone.info,
                    dense: true,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              numberFormat.format(shareholder.shareCount),
              style: AppText.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${shareholder.sharePercentage}%',
              style: AppText.bodyMd.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: StatusChip.fromStatus(
              shareholder.isActive ? 'Active' : 'Inactive',
            ),
          ),
          SizedBox(
            width: 48,
            child: PopupMenuButton<String>(
              icon: const Icon(Iconsax.more, size: 18),
              shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
              onSelected: (value) async {
                switch (value) {
                  case 'view':
                    _showShareholderDetails(context, shareholder);
                    break;
                  case 'edit':
                    showDialog(
                      context: context,
                      builder: (_) =>
                          AddEditShareholderDialog(shareholder: shareholder),
                    );
                    break;
                  case 'delete':
                    final confirmed = await showDeleteShareholderDialog(
                        context, shareholder.fullName);
                    if (confirmed == true && context.mounted) {
                      controller.deleteShareholder(context, shareholder.id);
                    }
                    break;
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Iconsax.eye,
                          size: 18, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Iconsax.edit,
                          size: 18, color: AppColors.textSecondary),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Iconsax.trash, size: 18, color: AppColors.danger),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppColors.danger)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarInitial(Shareholder shareholder, Color color) {
    final initial = shareholder.firstName.isNotEmpty
        ? shareholder.firstName[0].toUpperCase()
        : '?';
    return Text(
      initial,
      style: AppText.label.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  void _showShareholderDetails(BuildContext context, Shareholder shareholder) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brLg),
        backgroundColor: AppColors.surface,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Shareholder details', style: AppText.h2),
                        const SizedBox(height: 6),
                        Text(
                          'A closer look at role, contact information, and ownership position.',
                          style: AppText.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    color: AppColors.textMuted,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Name', shareholder.fullName),
              _buildDetailRow('Email', shareholder.email),
              _buildDetailRow('Phone', shareholder.phoneNumber),
              _buildDetailRow('Role', shareholder.titleDisplay),
              _buildDetailRow('Shares',
                  NumberFormat('#,###').format(shareholder.shareCount)),
              _buildDetailRow('Percentage', '${shareholder.sharePercentage}%'),
              _buildDetailRow(
                  'Board Member', shareholder.isBoardMember ? 'Yes' : 'No'),
              _buildDetailRow(
                  'Status', shareholder.isActive ? 'Active' : 'Inactive'),
              if (shareholder.notes != null && shareholder.notes!.isNotEmpty)
                _buildDetailRow('Notes', shareholder.notes!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppText.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              _displayValue(value),
              style: AppText.bodyMd.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onAdd,
  }) {
    return EmptyState(
      icon: icon,
      title: title,
      subtitle: subtitle,
      action: MyElevatedButton(
        child: buttonLabel,
        icon: const Icon(Iconsax.add, size: 18, color: AppColors.textOnPrimary),
        onTap: onAdd,
      ),
    );
  }

  Widget _buildResponsiveCardGrid(List<Widget> cards) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= 1100) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                Expanded(child: cards[i]),
              ],
            ],
          );
        }

        if (width >= 720 && cards.length > 1) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: cards
                .map((card) => SizedBox(
                      width: (width - 16) / 2,
                      child: card,
                    ))
                .toList(),
          );
        }

        return Column(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(height: 16),
              cards[i],
            ],
          ],
        );
      },
    );
  }

  Widget _buildStaticPill(String text, bool active) {
    return StatusChip(
      label: text,
      tone: active ? StatusTone.primary : StatusTone.neutral,
    );
  }

  String _displayValue(String? value, {String fallback = 'Not set'}) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? fallback : trimmed;
  }

  String? _normalizedValue(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  String _formatDate(String? rawDate) {
    final parsed = rawDate == null || rawDate.trim().isEmpty
        ? null
        : DateTime.tryParse(rawDate);
    if (parsed == null) return 'Not set';
    return DateFormat('d MMM yyyy').format(parsed.toLocal());
  }

  static const _avatarColors = [
    AppColors.warning,
    Color(0xFFC026D3),
    AppColors.info,
    AppColors.success,
    AppColors.warning,
    Color(0xFF7C3AED),
  ];

  Color _avatarColor(int index) => _avatarColors[index % _avatarColors.length];

  StatusTone _roleTone(String role) {
    switch (role.toLowerCase()) {
      case 'founder':
        return StatusTone.success;
      case 'co-founder':
        return StatusTone.info;
      case 'investor':
        return StatusTone.warning;
      default:
        return StatusTone.neutral;
    }
  }
}

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    this.title = '',
    this.count = '',
    this.accentColor,
    this.subtext,
    this.icon,
    this.label,
    this.value,
    this.borderColor,
    this.countColor,
    this.isPositive = true,
    this.isWarning = false,
  });

  final String title;
  final String count;
  final Color? accentColor;
  final String? subtext;
  final IconData? icon;
  final String? label;
  final String? value;
  final Color? borderColor;
  final Color? countColor;
  final bool isPositive;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title.isNotEmpty ? title : (label ?? '');
    final resolvedCount = count.isNotEmpty ? count : (value ?? '--');
    final resolvedAccent = accentColor ?? borderColor ?? _legacyAccentColor();
    final resolvedSubtext = subtext ?? '';
    final resolvedIcon = icon ?? _legacyIcon();

    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.md,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  resolvedTitle,
                  style: AppText.bodySm.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: resolvedAccent.withValues(alpha: 0.12),
                  borderRadius: AppRadii.brMd,
                ),
                child: Icon(resolvedIcon, size: 18, color: resolvedAccent),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            resolvedCount,
            style: AppText.displayMd.copyWith(
              color: countColor ?? AppColors.textPrimary,
              height: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 28,
                height: 4,
                decoration: BoxDecoration(
                  color: resolvedAccent,
                  borderRadius: AppRadii.brPill,
                ),
              ),
              const SizedBox(width: 10),
              if (resolvedSubtext.isNotEmpty)
                Expanded(
                  child: Text(
                    resolvedSubtext,
                    style: AppText.bodySm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  Color _legacyAccentColor() {
    if (borderColor != null) return borderColor!;
    if (isWarning) return AppColors.warning;
    return isPositive ? AppColors.success : AppColors.danger;
  }

  IconData _legacyIcon() {
    if (isWarning) return Iconsax.timer_1;
    return isPositive ? Iconsax.chart_success : Iconsax.chart_fail;
  }
}

class ResponsiveStatRow extends StatelessWidget {
  const ResponsiveStatRow({super.key, required this.cards});

  final List<Widget> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;

      if (width >= 1100) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(child: cards[i]),
            ],
          ],
        );
      }

      if (width >= 720) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map((card) => SizedBox(
                    width: (width - 16) / 2,
                    child: card,
                  ))
              .toList(),
        );
      }

      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            cards[i],
          ],
        ],
      );
    });
  }
}

class ResponsiveSubheader extends StatelessWidget {
  const ResponsiveSubheader({
    super.key,
    required this.title,
    this.search,
    this.action,
  });

  final Widget title;
  final Widget? search;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 700;

      if (isCompact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            title,
            const SizedBox(height: 12),
            Row(
              children: [
                if (search != null) Expanded(child: search!),
                if (action != null) ...[
                  const SizedBox(width: 12),
                  action!,
                ],
              ],
            ),
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: title),
          if (search != null) SizedBox(width: 220, child: search!),
          if (action != null) ...[
            const SizedBox(width: 12),
            action!,
          ],
        ],
      );
    });
  }
}

class ResponsiveTableWrapper extends StatelessWidget {
  const ResponsiveTableWrapper({
    super.key,
    required this.child,
    this.breakpoint = 720,
    this.minWidth = 840,
  });

  final Widget child;
  final double breakpoint;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < breakpoint) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minWidth, child: child),
        );
      }
      return child;
    });
  }
}
