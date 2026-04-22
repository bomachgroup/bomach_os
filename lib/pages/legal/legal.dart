import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bms_front_end/components/cards/module_shortcut_card.dart';
import 'package:bms_front_end/components/section/module_dashboard.dart';
import 'package:bms_front_end/pages/legal/audits.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/permissions.dart';
import 'package:bms_front_end/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/text/my_text.dart';
import 'cases.dart';
import 'compliance.dart';
import 'contract.dart';
import 'dialogs/new_contract.dart';
import 'widgets/summary_card.dart';
import 'widgets/tab_button.dart';

enum DashboardTab { contracts, compliance, cases, audits }

final Map<DashboardTab, List<SummaryItem>> dashboardSummaryData = {
  DashboardTab.contracts: [
    SummaryItem('Contracts', '2', Iconsax.document_text),
    SummaryItem('Compliance', '2', Iconsax.tick_circle),
    SummaryItem('Active', '2', Iconsax.ticket),
    SummaryItem(
      'Contract Value',
      '₦505,000.00',
      Iconsax.money_recive,
    ),
  ],
  DashboardTab.compliance: [
    SummaryItem('Total Policies', '2', Iconsax.judge),
    SummaryItem('Compliant', '2', Iconsax.shield_tick),
    SummaryItem('Review Due', '2', Iconsax.warning_2),
    SummaryItem(
      'Overdue',
      '2',
      Iconsax.calendar_1,
    ),
  ],
  DashboardTab.cases: [
    SummaryItem('Total Cases', '2', Iconsax.people),
    SummaryItem('Active Cases', '2', Iconsax.people),
    SummaryItem('Settled Cases', '2', Iconsax.people),
    SummaryItem(
      'Total Exposure',
      '₦505,000.00',
      Iconsax.empty_wallet,
    ),
  ],
  DashboardTab.audits: [
    SummaryItem('Total Audits', '2', Iconsax.people),
    SummaryItem('Completed', '2', Iconsax.people),
    SummaryItem('In Progress', '2', Iconsax.people),
    SummaryItem(
      'Scheduled',
      '₦505,000.00',
      Iconsax.empty_wallet,
    ),
  ],
};

class LegalsPage extends StatefulWidget {
  final int selectedIndex;
  const LegalsPage({super.key, this.selectedIndex = 0});

  @override
  State<LegalsPage> createState() => _LegalsPageState();
}

class _LegalsPageState extends State<LegalsPage> {
  final DashboardData _dashboardData = DashboardData();
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _dashboardData.setActiveTab(DashboardTab.values[_currentIndex]);
  }

  @override
  void didUpdateWidget(covariant LegalsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != _currentIndex) {
      _currentIndex = widget.selectedIndex;
      _pageController.jumpToPage(_currentIndex);
      _dashboardData.setActiveTab(DashboardTab.values[_currentIndex]);
    }
  }

  @override
  void dispose() {
    _dashboardData.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
      _dashboardData.setActiveTab(DashboardTab.values[index]);
      _pageController.jumpToPage(index);
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
      _dashboardData.setActiveTab(DashboardTab.values[index]);
    });
  }

  Widget _buildQuickNav() {
    final perms = Get.find<PermissionService>();
    ModuleShortcutCard card({
      required IconData icon,
      required String title,
      required String subtitle,
      required String route,
      required List<String> resources,
    }) =>
        ModuleShortcutCard(
          icon: icon,
          title: title,
          subtitle: subtitle,
          route: route,
          enabled: perms.canAccessRoute(route, resources),
        );

    return ModuleQuickNav(
      shortcuts: [
        card(
          icon: Iconsax.document_text,
          title: 'Contracts',
          subtitle: 'Agreements and documents',
          route: RouteConstants.legalContracts,
          resources: const [PermissionConstants.resContracts],
        ),
        card(
          icon: Iconsax.shield_tick,
          title: 'Compliance',
          subtitle: 'Policies and records',
          route: RouteConstants.legalCompliance,
          resources: const [PermissionConstants.resComplianceRecords],
        ),
        card(
          icon: Iconsax.judge,
          title: 'Cases',
          subtitle: 'Active legal matters',
          route: RouteConstants.legalCases,
          resources: const [PermissionConstants.resLegalCases],
        ),
        card(
          icon: Iconsax.task_square,
          title: 'Audits',
          subtitle: 'Compliance audits',
          route: RouteConstants.legalAudits,
          resources: const [PermissionConstants.resComplianceAudits],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet =
            constraints.maxWidth < 1000 && constraints.maxWidth >= 600;
        final double pageViewHeight = isMobile ? 600 : (isTablet ? 650 : 700);

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 12 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: isMobile
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText("Legal & Compliance",
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        MyText(
                            "Manage contracts, compliance requirements, and legal documentation",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                  ),
                  if (!isMobile)
                    MyElevatedButton(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const CreateNewContractDialog(),
                        );
                      },
                      icon: const Icon(Iconsax.add, color: Colors.white),
                      child: "New Contract",
                    ),
                ],
              ),
              if (isMobile)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 8),
                  child: MyElevatedButton(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const CreateNewContractDialog(),
                      );
                    },
                    icon: const Icon(Iconsax.add, color: Colors.white),
                    child: "New Contract",
                  ),
                ),
              const SizedBox(height: 24),
              _buildQuickNav(),
              const SizedBox(height: 24),
              DynamicSummaryRow(dashboardData: _dashboardData),
              const SizedBox(height: 24),
              isMobile
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          PageButton(
                            label: "Contracts",
                            index: 0,
                            isSelected: _currentIndex == 0,
                            onTap: () => _onTabSelected(0),
                          ),
                          PageButton(
                            label: "Compliance",
                            index: 1,
                            isSelected: _currentIndex == 1,
                            onTap: () => _onTabSelected(1),
                          ),
                          PageButton(
                            label: "Cases",
                            index: 2,
                            isSelected: _currentIndex == 2,
                            onTap: () => _onTabSelected(2),
                          ),
                          PageButton(
                            label: "Audits",
                            index: 3,
                            isSelected: _currentIndex == 3,
                            onTap: () => _onTabSelected(3),
                          ),
                        ],
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: PageButton(
                            label: "Contracts",
                            index: 0,
                            isSelected: _currentIndex == 0,
                            onTap: () => _onTabSelected(0),
                          ),
                        ),
                        Expanded(
                          child: PageButton(
                            label: "Compliance",
                            index: 1,
                            isSelected: _currentIndex == 1,
                            onTap: () => _onTabSelected(1),
                          ),
                        ),
                        Expanded(
                          child: PageButton(
                            label: "Cases",
                            index: 2,
                            isSelected: _currentIndex == 2,
                            onTap: () => _onTabSelected(2),
                          ),
                        ),
                        Expanded(
                          child: PageButton(
                            label: "Audits",
                            index: 3,
                            isSelected: _currentIndex == 3,
                            onTap: () => _onTabSelected(3),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 16),
              SizedBox(
                height: pageViewHeight,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: const [
                    ContractsPageView(),
                    CompliancePageView(),
                    CasesPageView(),
                    AuditsPageView()
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
