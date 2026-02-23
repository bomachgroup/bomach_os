import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/pages/company/compliance.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/company_controller.dart';
import 'widget/edit_company_dialog.dart'; // Ensure this points to the file above
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:bms_front_end/components/section/responsive_widget.dart';

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
          _buildStatsSection(),

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
                return _buildBoardMembersTab(context, controller);
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
    // Renders the mock shareholder list from controller
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Ownership Records",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: controller.shareholders
              .map((s) => ListTile(
                    title: Text(s['name']),
                    subtitle: Text(s['role']),
                    trailing: Text(s['percent']),
                    leading: CircleAvatar(
                        backgroundColor: Color(s['bg']),
                        child: Text(s['name'][0],
                            style: TextStyle(color: Color(s['fg'])))),
                  ))
              .toList(),
        ),
      )
    ]);
  }

  Widget _buildBoardMembersTab(
      BuildContext context, CompanyController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Board Members",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      Container(
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: controller.boardMembers
              .map((s) => ListTile(
                    title: Text("${s['title']} ${s['name']}"),
                    subtitle: Text(s['role']),
                    leading: CircleAvatar(
                        backgroundColor: Color(s['bg']),
                        child: Icon(Icons.person, color: Color(s['fg']))),
                  ))
              .toList(),
        ),
      )
    ]);
  }

 

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
  Widget _buildStatsSection() {
    // each card is constrained to a max width so that wrap works nicely
    const cardWidth = 260.0;
    return const Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        SizedBox(
            width: cardWidth,
            child: DashboardStatCard(
                label: 'Total Employees',
                value: '452',
                subtext: '2 new employees added!',
                icon: Icons.people_outline,
                isPositive: true)),
        SizedBox(
            width: cardWidth,
            child: DashboardStatCard(
                label: 'Total Branches',
                value: '29',
                subtext: '2 Branches removed!',
                icon: Icons.domain,
                isPositive: false)),
        SizedBox(
            width: cardWidth,
            child: DashboardStatCard(
                label: 'Pending Approvals',
                value: '3',
                subtext: '2 overdue tasks',
                icon: Icons.pending_actions,
                isWarning: true)),
        SizedBox(
            width: cardWidth,
            child: DashboardStatCard(
                label: 'Asset Inventory',
                value: '29',
                subtext: '2 new projects added!',
                icon: Icons.inventory_2_outlined,
                isPositive: true)),
      ],
    );
  }
}

class DashboardStatCard extends StatelessWidget {
  final String label, value, subtext;
  final IconData icon;
  final bool isPositive, isWarning;
  const DashboardStatCard(
      {super.key,
      required this.label,
      required this.value,
      required this.subtext,
      required this.icon,
      this.isPositive = true,
      this.isWarning = false});

  @override
  Widget build(BuildContext context) {
    Color color =
        isWarning ? Colors.orange : (isPositive ? Colors.green : Colors.red);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Icon(icon, color: Colors.blue)
        ]),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Text(subtext, style: TextStyle(color: color, fontSize: 12))
      ]),
    );
  }
}
