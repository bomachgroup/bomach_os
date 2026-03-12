import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/company/board_members.dart';
import 'package:bms_front_end/pages/company/compliance.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/model/company_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/company_controller.dart';
import 'widget/edit_company_dialog.dart';
import 'widget/shareholders_dialogs.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:bms_front_end/components/section/responsive_widget.dart';
import 'package:intl/intl.dart';

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
          const MyText('Company Profile', style: AppText.black_600_32),
          const SizedBox(height: 8),
          const Text('Manage Profile, Business, ownerships and Compliance',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          const SizedBox(height: 24),

          // Stats Row (wrap so cards flow on smaller widths)
          _buildStatsSection(controller),

          const SizedBox(height: 32),

          // Tabs
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
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
              return const Center(
                  child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator()));
            }
            if (controller.companySettings.value == null) {
              return Center(
                  child: Column(children: [
                const Text("No data"),
                TextButton(
                    onPressed: controller.fetchCompanyProfile,
                    child: const Text("Retry"))
              ]));
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
                return CompliancePage();
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
    return Card(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE2E8F0))),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Company Information",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              MyElevatedButton(
                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
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
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12)),
                child: Center(
                    child: data.companyLogo != null
                        ? Image.network(data.companyLogo!,
                            errorBuilder: (c, e, s) =>
                                const Icon(Icons.business))
                        : const Icon(Icons.business)),
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
                        "Company Addresses", data.companyAddresses)),
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
      ),
    );
  }

  Widget _buildGlobalBusinessTab(
      BuildContext context, CompanyController controller, dynamic data) {
    return Column(children: [
      Builder(builder: (layoutContext) {
        bool small = isSmallScreen(layoutContext);
        Widget title = const Text("Global Business Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
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
      Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E8F0))),
        child: Padding(
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
                      const Text("Approvals",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      _buildStaticPill(controller.approvalType.value, true),
                    ])),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      const Text("Notifications",
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
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
      )
    ]);
  }

  Widget _buildOwnershipTab(
      BuildContext context, CompanyController controller) {
    final numberFormat = NumberFormat('#,###');

    return Obx(() {
      if (controller.isShareholdersLoading.value &&
          controller.shareholders.isEmpty) {
        return const Center(
            child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator()));
      }

      final list = controller.shareholders;

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row with title and search + edit button
        Builder(builder: (layoutContext) {
          bool small = isSmallScreen(layoutContext);
          Widget title = const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ownership & Shareholders",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text("Bomach Group of Companies",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ],
          );
          Widget actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyElevatedButton(
                child: 'Edit Share Holders',
                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
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
        Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Equity",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    TextButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const EditEquityDialog(),
                      ),
                      icon: const Icon(Icons.edit, size: 14),
                      label: const Text("Update Shares",
                          style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text("Authorized Shares",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
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
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Shareholders table
        if (list.isEmpty)
          _buildEmptyState(
            context,
            icon: Icons.people_outline,
            title: "No shareholders yet",
            subtitle:
                "Add shareholders to track ownership and share distribution.",
            buttonLabel: "Add Shareholder",
            onAdd: () => showDialog(
              context: context,
              builder: (_) => const AddEditShareholderDialog(),
            ),
          )
        else
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                // Table header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 40),
                      const Expanded(
                          flex: 3,
                          child: Text("Name",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B)))),
                      const Expanded(
                          flex: 2,
                          child: Text("Role",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B)))),
                      const Expanded(
                          flex: 2,
                          child: Text("Shares",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B)))),
                      const Expanded(
                          flex: 2,
                          child: Text("Percentage",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B)))),
                      const SizedBox(
                          width: 48,
                          child: Text("Action",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: Color(0xFF64748B)))),
                    ],
                  ),
                ),
                const Divider(height: 1),
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

    Color roleColor;
    switch (s.titleDisplay.toLowerCase()) {
      case 'founder':
        roleColor = Colors.green;
        break;
      case 'co-founder':
        roleColor = Colors.blue;
        break;
      case 'investor':
        roleColor = Colors.orange;
        break;
      default:
        roleColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
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
              activeColor: AppColors.blue,
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
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold))))
                      : Text(
                          s.firstName.isNotEmpty
                              ? s.firstName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                              color: color, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(s.fullName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 14),
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
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  s.titleDisplay.isNotEmpty ? s.titleDisplay : s.title,
                  style: TextStyle(
                      color: roleColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          // Shares
          Expanded(
            flex: 2,
            child: Text(numberFormat.format(s.shareCount),
                style: const TextStyle(fontSize: 14)),
          ),
          // Percentage
          Expanded(
            flex: 2,
            child: Text('${s.sharePercentage}%',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          // Action menu
          SizedBox(
            width: 48,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                    Icon(Icons.visibility_outlined,
                        size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  const Text("Shareholder Details",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow("Name", s.fullName),
              _buildDetailRow("Email", s.email),
              _buildDetailRow("Phone", s.phoneNumber),
              _buildDetailRow("Role", s.titleDisplay),
              _buildDetailRow("Shares", '${s.shareCount}'),
              _buildDetailRow("Percentage", '${s.sharePercentage}%'),
              _buildDetailRow("Board Member", s.isBoardMember ? 'Yes' : 'No'),
              _buildDetailRow("Status", s.isActive ? 'Active' : 'Inactive'),
              if (s.notes != null && s.notes!.isNotEmpty)
                _buildDetailRow("Notes", s.notes!),
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
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 20),
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            MyElevatedButton(
              child: buttonLabel,
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              onTap: onAdd,
            ),
          ],
        ),
      ),
    );
  }

  static const _avatarColors = [
    Color(0xFFEA580C),
    Color(0xFFC026D3),
    Color(0xFF0284C7),
    Color(0xFF16A34A),
    Color(0xFFD97706),
    Color(0xFF7C3AED),
  ];

  Color _avatarColor(int index) => _avatarColors[index % _avatarColors.length];

  // --- HELPERS ---
  Widget _buildTabButton(String label, RxString currentTab) {
    return InkWell(
      onTap: () => currentTab.value = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: currentTab.value == label
                        ? const Color(0xFF005CE8)
                        : Colors.transparent,
                    width: 2))),
        child: Text(label,
            style: TextStyle(
                color: currentTab.value == label
                    ? const Color(0xFF005CE8)
                    : Colors.grey,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 4),
      Text(value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    ]);
  }

  Widget _buildColorField(String label, String hex, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 4),
      Row(children: [
        Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 8),
        Text(hex, style: const TextStyle(fontWeight: FontWeight.w500)),
      ])
    ]);
  }

  Widget _buildStaticPill(String text, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
          color: active ? const Color(0xFF005CE8) : Colors.white,
          borderRadius: BorderRadius.circular(4)),
      child: Text(text,
          style: TextStyle(
              color: active ? Colors.white : Colors.grey, fontSize: 12)),
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
          borderColor: Colors.green,
          countColor: Colors.green,
        ),
        DashboardStatCard(
          title: 'Total Branches',
          count: stats != null ? '${stats.totalBranches}' : '–',
          borderColor: const Color(0xFF1976D2),
          countColor: const Color(0xFF1976D2),
        ),
        DashboardStatCard(
          title: 'Pending Approvals',
          count: stats != null ? '${stats.pendingApprovals}' : '–',
          borderColor: const Color(0xFFC27803),
          countColor: const Color(0xFFC27803),
        ),
        DashboardStatCard(
          title: 'Asset Inventory',
          count: stats != null ? '${stats.assetInventory}' : '–',
          borderColor: Colors.green,
          countColor: Colors.green,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: displayBorderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(displayTitle,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87)),
          const SizedBox(height: 12),
          Text(displayCount,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
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
          if (search != null)
            SizedBox(width: 220, child: search!),
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
