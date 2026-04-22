import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/pages/company/board_members.dart';
import 'package:bms_front_end/pages/company/compliance.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/company_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'controllers/company_controller.dart';
import 'widget/edit_company_dialog.dart';
import 'widget/shareholders_dialogs.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:bms_front_end/components/section/responsive_widget.dart';
import 'package:intl/intl.dart';

// Local accent palette for stat cards & shareholder avatars.
const Color _accentBlue = AppColors.primary;
const Color _accentGreen = AppColors.success;
const Color _accentAmber = AppColors.warning;
const Color _accentIndigo = Color(0xFF6366F1);

class CompanyProfilePage extends StatelessWidget {
  const CompanyProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final CompanyController controller = Get.put(CompanyController());
    final RxString currentTab = 'Profile'.obs;

    // use ResponsiveWidget so the page can adapt at route level if needed
    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const PageHeader(
            title: 'Company Profile',
            subtitle:
                'Organization details, shareholders, and governance',
          ),
          const SizedBox(height: 24),

          // Stats Row (wrap so cards flow on smaller widths)
          _buildStatsSection(controller),

          const SizedBox(height: 32),

          // Tabs
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: AppColors.borderSubtle))),
            child: Obx(() => Wrap(
                  spacing: 8,
                  children: [
                    _buildTabButton('Profile', currentTab),
                    _buildTabButton('Global Business', currentTab),
                    _buildTabButton('Ownership & Shareholders', currentTab),
                    _buildTabButton('Board Members', currentTab),
                    _buildTabButton('Compliance & Registration', currentTab),
                  ],
                )),
          ),

          const SizedBox(height: 24),

          // Body Content
          Obx(() {
            if (controller.isLoading.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: LoadingSkeleton.card(lines: 4),
              );
            }
            if (controller.companySettings.value == null) {
              return EmptyState(
                icon: Iconsax.warning_2,
                title: 'Could not load company profile',
                subtitle: 'Please try again.',
                action: ElevatedButton(
                  onPressed: controller.fetchCompanyProfile,
                  child: const Text('Retry'),
                ),
              );
            }

            final data = controller.companySettings.value!;

            switch (currentTab.value) {
              case 'Global Business':
                return _buildGlobalBusinessTab(context, controller, data);
              case 'Ownership & Shareholders':
                return _buildOwnershipTab(context, controller);
              case 'Board Members':
                return const BoardMembersPage();
              case 'Compliance & Registration':
                return const CompliancePage();
              case 'Profile':
              default:
                return _buildProfileTab(context, controller, data);
            }
          }),
        ],
      ),
    );

    // wrap body in responsive widget so wide/kind sizes can customize if needed
    return ResponsiveWidget(
      largeScreen: body,
      mediumScreen: body,
      smallScreen: body,
    );
  }

  // --- TAB BUILDERS ---

  Widget _buildProfileTab(
      BuildContext context, CompanyController controller, dynamic data) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Company Information', style: AppText.h3),
            MyElevatedButton(
              icon: const Icon(Iconsax.edit,
                  size: 16, color: AppColors.textOnPrimary),
              child: 'Edit Profile',
              onTap: () => showDialog(
                  context: context,
                  builder: (_) => const EditProfileDialog()),
            ),
          ]),
            const SizedBox(height: 24),
            Builder(builder: (layoutContext) {
              bool small = isSmallScreen(layoutContext);

              // logo widget definition for reuse
              Widget logoWidget = Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderSubtle),
                    borderRadius: AppRadii.brMd),
                child: Center(
                    child: data.companyLogo != null
                        ? Image.network(data.companyLogo!,
                            errorBuilder: (c, e, s) =>
                                const Icon(Iconsax.building, size: 28,
                                    color: AppColors.textMuted))
                        : const Icon(Iconsax.building, size: 28,
                            color: AppColors.textMuted)),
              );

              Widget infoWidget = Expanded(
                  child: Wrap(runSpacing: 24, spacing: 40, children: [
                _buildInfoField("Company Name", data.companyName),
                _buildInfoField("Company Email", data.companyEmail),
                _buildInfoField("Company Phone", data.companyPhone),
                _buildInfoField("RC Number", data.rcNumber),
                _buildInfoField("Industry", controller.industry.value),
                _buildInfoField("Slogan", data.companySlogan),
                SizedBox(
                    width: double.infinity,
                    child: _buildInfoField(
                        "Company Address", data.companyAddresses)),
              ]));

              return small
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        logoWidget,
                        const SizedBox(height: 24),
                        infoWidget,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        logoWidget,
                        const SizedBox(width: 24),
                        infoWidget,
                      ],
                    );
            })
          ],
        ),
      );
  }

  Widget _buildGlobalBusinessTab(
      BuildContext context, CompanyController controller, dynamic data) {
    return Column(children: [
      Builder(builder: (layoutContext) {
        bool small = isSmallScreen(layoutContext);
        Widget title = const Text('Global Business Settings', style: AppText.h3);
        Widget button = MyElevatedButton(
          child: 'Edit Settings',
          onTap: () => showDialog(
              context: context,
              builder: (_) => const EditGlobalBusinessDialog()),
        );
        return small
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 8), button])
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [title, button],
              );
      }),
      const SizedBox(height: 20),
      AppCard(
        padding: const EdgeInsets.all(24),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(children: [
                SizedBox(
                    width: 260,
                    child: _buildColorField(
                        "Primary Color",
                        data.primaryColorCode,
                        controller.getColorFromHex(data.primaryColorCode))),
                SizedBox(
                    width: 260,
                    child: _buildColorField(
                        "Secondary Color",
                        data.secondaryColorCode,
                        controller.getColorFromHex(data.secondaryColorCode))),
              ]),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Wrap(children: [
                SizedBox(
                    width: 260,
                    child: _buildInfoField(
                        "Default Currency", data.defaultCurrency)),
                SizedBox(
                    width: 260,
                    child: _buildInfoField(
                        "Language Preference", data.languagePreference)),
              ]),
              const SizedBox(height: 24),
              _buildInfoField("Time Zone", controller.timeZone.value),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              // Settings toggles visualization
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Approvals',
                          style: AppText.caption
                              .copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      _buildStaticPill(controller.approvalType.value, true),
                    ])),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Notifications',
                          style: AppText.caption
                              .copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      Row(children: [
                        if (controller.notifyEmail.value)
                          _buildStaticPill("Email", true),
                        if (controller.notifySMS.value)
                          _buildStaticPill("SMS", true),
                        if (controller.notifyPush.value)
                          _buildStaticPill("Push", true),
                      ])
                    ])),
              ])
            ])),
    ]);
  }

  Widget _buildOwnershipTab(
      BuildContext context, CompanyController controller) {
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

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row with title and search + edit button
        Builder(builder: (layoutContext) {
          bool small = isSmallScreen(layoutContext);
          Widget title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ownership & Shareholders', style: AppText.h3),
              const SizedBox(height: 4),
              Text('Bomach Group of Companies',
                  style: AppText.bodySm.copyWith(
                      color: AppColors.textSecondary)),
            ],
          );
          Widget actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyElevatedButton(
                child: 'Edit Share Holders',
                icon: const Icon(Iconsax.edit,
                    size: 16, color: AppColors.textOnPrimary),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => const EditShareHoldersDialog(),
                ),
              ),
            ],
          );
          return small
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 12), actions])
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Expanded(child: title), actions],
                );
        }),

        const SizedBox(height: 24),

        // Equity section
        AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Equity', style: AppText.h4),
                  TextButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const EditEquityDialog(),
                    ),
                    icon: const Icon(Iconsax.edit, size: 14),
                    label: const Text('Update Shares'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle:
                          AppText.bodySm.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Authorized Shares',
                  style: AppText.bodySm
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              controller.isEquityLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(
                      controller.authorizedShares.value > 0
                          ? numberFormat
                              .format(controller.authorizedShares.value)
                          : '—',
                      style: AppText.h2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      )),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Shareholders table
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
            child: Column(
              children: [
                // Table header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 40),
                      Expanded(
                          flex: 3,
                          child: Text('Name',
                              style: AppText.label.copyWith(
                                  color: AppColors.textSecondary))),
                      Expanded(
                          flex: 2,
                          child: Text('Role',
                              style: AppText.label.copyWith(
                                  color: AppColors.textSecondary))),
                      Expanded(
                          flex: 2,
                          child: Text('Shares',
                              style: AppText.label.copyWith(
                                  color: AppColors.textSecondary))),
                      Expanded(
                          flex: 2,
                          child: Text('Percentage',
                              style: AppText.label.copyWith(
                                  color: AppColors.textSecondary))),
                      SizedBox(
                          width: 48,
                          child: Text('Action',
                              style: AppText.label.copyWith(
                                  color: AppColors.textSecondary))),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                // Table rows
                ...list.asMap().entries.map((entry) {
                  final i = entry.key;
                  final s = entry.value;
                  return _buildShareholderRow(context, controller, s, i);
                }),
              ],
            ),
          ),
      ]);
    });
  }

  Widget _buildShareholderRow(BuildContext context,
      CompanyController controller, Shareholder s, int index) {
    final numberFormat = NumberFormat('#,###');
    final color = _avatarColor(index);

    StatusTone roleTone;
    switch (s.titleDisplay.toLowerCase()) {
      case 'founder':
        roleTone = StatusTone.success;
        break;
      case 'co-founder':
        roleTone = StatusTone.info;
        break;
      case 'investor':
        roleTone = StatusTone.warning;
        break;
      default:
        roleTone = StatusTone.neutral;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          // Checkbox placeholder
          SizedBox(
            width: 40,
            child: Checkbox(
              value: false,
              onChanged: (_) {},
              activeColor: AppColors.primary,
            ),
          ),
          // Name + avatar
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: s.profilePicture != null
                      ? ClipOval(
                          child: Image.network(s.profilePicture!,
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text(
                                  s.firstName.isNotEmpty
                                      ? s.firstName[0].toUpperCase()
                                      : '?',
                                  style: AppText.label.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w700))))
                      : Text(
                          s.firstName.isNotEmpty
                              ? s.firstName[0].toUpperCase()
                              : '?',
                          style: AppText.label.copyWith(
                              color: color, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(s.fullName,
                      style: AppText.bodyMd.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          // Role badge
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: s.titleDisplay.isNotEmpty ? s.titleDisplay : s.title,
                tone: roleTone,
              ),
            ),
          ),
          // Shares
          Expanded(
            flex: 2,
            child: Text(
              numberFormat.format(s.shareCount),
              style: AppText.bodyMd.copyWith(color: AppColors.textPrimary),
            ),
          ),
          // Percentage
          Expanded(
            flex: 2,
            child: Text('${s.sharePercentage}%',
                style: AppText.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
          ),
          // Action menu
          SizedBox(
            width: 48,
            child: PopupMenuButton<String>(
              icon: const Icon(Iconsax.more, size: 18),
              shape: const RoundedRectangleBorder(
                  borderRadius: AppRadii.brMd),
              onSelected: (value) async {
                switch (value) {
                  case 'view':
                    _showShareholderDetails(context, s);
                    break;
                  case 'edit':
                    showDialog(
                      context: context,
                      builder: (_) => AddEditShareholderDialog(shareholder: s),
                    );
                    break;
                  case 'delete':
                    final confirmed =
                        await showDeleteShareholderDialog(context, s.fullName);
                    if (confirmed == true && context.mounted) {
                      controller.deleteShareholder(context, s.id);
                    }
                    break;
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(children: [
                    Icon(Iconsax.eye,
                        size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Iconsax.edit,
                        size: 18, color: AppColors.textSecondary),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Iconsax.trash, size: 18, color: AppColors.danger),
                    SizedBox(width: 8),
                    Text('Delete',
                        style: TextStyle(color: AppColors.danger)),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showShareholderDetails(BuildContext context, Shareholder s) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brLg),
        backgroundColor: AppColors.surface,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Shareholder Details', style: AppText.h2),
                  IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    color: AppColors.textMuted,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Name', s.fullName),
              _buildDetailRow('Email', s.email),
              _buildDetailRow('Phone', s.phoneNumber),
              _buildDetailRow('Role', s.titleDisplay),
              _buildDetailRow('Shares', '${s.shareCount}'),
              _buildDetailRow('Percentage', '${s.sharePercentage}%'),
              _buildDetailRow('Board Member', s.isBoardMember ? 'Yes' : 'No'),
              _buildDetailRow('Status', s.isActive ? 'Active' : 'Inactive'),
              if (s.notes != null && s.notes!.isNotEmpty)
                _buildDetailRow('Notes', s.notes!),
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
            child: Text(label,
                style: AppText.bodySm
                    .copyWith(color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: AppText.bodyMd.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
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
        icon: const Icon(Iconsax.add,
            size: 18, color: AppColors.textOnPrimary),
        onTap: onAdd,
      ),
    );
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

  // --- HELPERS ---
  Widget _buildTabButton(String label, RxString currentTab) {
    final isActive = currentTab.value == label;
    return InkWell(
      onTap: () => currentTab.value = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: isActive ? AppColors.primary : Colors.transparent,
                    width: 2))),
        child: Text(label,
            style: AppText.bodyMd.copyWith(
                color:
                    isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: AppText.caption.copyWith(color: AppColors.textMuted)),
      const SizedBox(height: 4),
      Text(value,
          style: AppText.bodyMd.copyWith(
              fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
    ]);
  }

  Widget _buildColorField(String label, String hex, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: AppText.caption.copyWith(color: AppColors.textMuted)),
      const SizedBox(height: 6),
      Row(children: [
        Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
                color: color, borderRadius: AppRadii.brSm)),
        const SizedBox(width: 8),
        Text(hex,
            style: AppText.bodyMd.copyWith(
                fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      ])
    ]);
  }

  Widget _buildStaticPill(String text, bool active) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: StatusChip(
        label: text,
        tone: active ? StatusTone.primary : StatusTone.neutral,
      ),
    );
  }

  /// statistics row that behaves responsively across screen sizes
  Widget _buildStatsSection(CompanyController controller) {
    return Obx(() {
      final stats = controller.dashboardStats.value;
      final cards = <Widget>[
        DashboardStatCard(
          title: 'Total Employees',
          count: stats != null ? '${stats.totalEmployees}' : '–',
          borderColor: _accentGreen,
          countColor: _accentGreen,
        ),
        DashboardStatCard(
          title: 'Total Branches',
          count: stats != null ? '${stats.totalBranches}' : '–',
          borderColor: _accentBlue,
          countColor: _accentBlue,
        ),
        DashboardStatCard(
          title: 'Pending Approvals',
          count: stats != null ? '${stats.pendingApprovals}' : '–',
          borderColor: _accentAmber,
          countColor: _accentAmber,
        ),
        DashboardStatCard(
          title: 'Asset Inventory',
          count: stats != null ? '${stats.assetInventory}' : '–',
          borderColor: _accentIndigo,
          countColor: _accentIndigo,
        ),
      ];
      return ResponsiveStatRow(cards: cards);
    });
  }
}

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color borderColor;
  final Color countColor;

  // Legacy named params kept for backward compatibility during migration
  final String? label, value, subtext;
  final IconData? icon;
  final bool isPositive, isWarning;

  const DashboardStatCard({
    super.key,
    this.title = '',
    this.count = '',
    this.borderColor = Colors.blue,
    this.countColor = Colors.blue,
    // Legacy params
    this.label,
    this.value,
    this.subtext,
    this.icon,
    this.isPositive = true,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve display values (prefer new params, fallback to legacy)
    final displayTitle = title.isNotEmpty ? title : (label ?? '');
    final displayCount = count.isNotEmpty ? count : (value ?? '–');
    final displayBorderColor =
        title.isNotEmpty ? borderColor : _legacyBorderColor();
    final displayCountColor =
        count.isNotEmpty ? countColor : _legacyCountColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.brMd,
        border: Border.all(color: displayBorderColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(displayTitle,
              style: AppText.bodySm.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Text(displayCount,
              style: AppText.h1.copyWith(
                  fontWeight: FontWeight.w700,
                  color: displayCountColor)),
        ],
      ),
    );
  }

  Color _legacyBorderColor() {
    if (isWarning) return Colors.orange;
    return isPositive ? Colors.green : Colors.red;
  }

  Color _legacyCountColor() {
    if (isWarning) return Colors.orange;
    return isPositive ? Colors.green : Colors.red;
  }
}

/// Responsive stat card row — 4 columns on desktop, 2 on tablet, 1 on mobile.
class ResponsiveStatRow extends StatelessWidget {
  final List<Widget> cards;
  const ResponsiveStatRow({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;

      // Desktop: single row
      if (width >= 900) {
        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(child: cards[i]),
            ],
          ],
        );
      }

      // Tablet: 2 per row
      if (width >= 500) {
        final rows = <Widget>[];
        for (int i = 0; i < cards.length; i += 2) {
          final hasSecond = i + 1 < cards.length;
          rows.add(Row(
            children: [
              Expanded(child: cards[i]),
              const SizedBox(width: 16),
              Expanded(child: hasSecond ? cards[i + 1] : const SizedBox()),
            ],
          ));
          if (i + 2 < cards.length) rows.add(const SizedBox(height: 16));
        }
        return Column(children: rows);
      }

      // Mobile: stacked
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

/// Responsive subheader row — wraps search and button below title on small screens.
class ResponsiveSubheader extends StatelessWidget {
  final Widget title;
  final Widget? search;
  final Widget? action;
  const ResponsiveSubheader({
    super.key,
    required this.title,
    this.search,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isSmall = constraints.maxWidth < 700;

      if (isSmall) {
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

/// Wraps a table widget with horizontal scrolling on small screens.
/// Use [minWidth] to set the minimum width for the table content.
class ResponsiveTableWrapper extends StatelessWidget {
  final Widget child;
  final double breakpoint;
  final double minWidth;
  const ResponsiveTableWrapper({
    super.key,
    required this.child,
    this.breakpoint = 700,
    this.minWidth = 800,
  });

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
