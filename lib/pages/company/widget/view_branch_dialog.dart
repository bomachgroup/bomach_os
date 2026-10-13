import 'package:bomach_os/components/backend_capability_unavailable.dart';
import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/chip/status_chip.dart';
import 'package:bomach_os/components/section/page_header.dart';
import 'package:bomach_os/components/section/page_scaffold.dart';
import 'package:bomach_os/components/permission/permission_gate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/radii.dart';
import 'package:bomach_os/src/constants/shadows.dart';
import 'package:bomach_os/src/constants/textstyle.dart';
import 'package:bomach_os/src/model/branch_model.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bomach_os/src/helper/language_helper.dart';

import '../controllers/branch_controller.dart';
import 'add_branch_dialog.dart';

class BranchDetailPage extends StatefulWidget {
  const BranchDetailPage({super.key});

  @override
  State<BranchDetailPage> createState() => _BranchDetailPageState();
}

class _BranchDetailPageState extends State<BranchDetailPage>
    with SingleTickerProviderStateMixin {
  final BranchController controller = Get.find<BranchController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingDetail.value) {
        return const PageScaffold(
          header: PageHeader(title: 'Branch details'),
          children: [
            SizedBox(
              height: 280,
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        );
      }

      final branch = controller.currentBranch.value;
      if (branch == null) {
        return PageScaffold(
          header: PageHeader(
            title: 'Branch details',
            leading: _buildBackButton(context),
          ),
          children: const [
            SizedBox(
              height: 220,
              child: Center(child: Text('No branch data available')),
            ),
          ],
        );
      }

      return PageScaffold(
        maxContentWidth: 1280,
        header: PageHeader(
          title: branch.branchName,
          subtitle: '${branch.branchRoleDisplay} • ${_branchLocation(branch)}',
          leading: _buildBackButton(context),
          trailing: PermissionGate(
            require: Perms.branchesUpdate,
            child: MyElevatedButton(
              width: 128,
              height: 44,
              icon: const Icon(Iconsax.edit,
                  size: 16, color: AppColors.textOnPrimary),
              child: 'Edit Branch',
              onTap: () {
                controller.loadFilterResources();
                showDialog(
                  context: context,
                  builder: (_) => AddBranchDialog(branchToEdit: branch),
                );
              },
            ),
          ),
        ),
        children: [
          _buildSummaryBanner(branch),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.brLg,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: AppRadii.brMd,
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.textPrimary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicator: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.brMd,
                      boxShadow: AppShadows.sm,
                    ),
                    indicatorPadding: const EdgeInsets.symmetric(
                        horizontal: -12, vertical: -2),
                    dividerColor: Colors.transparent,
                    overlayColor:
                        WidgetStateProperty.all(AppColors.surfaceMuted),
                    labelStyle: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w600),
                    unselectedLabelStyle: AppTextStyles.bodyMd
                        .copyWith(fontWeight: FontWeight.w500),
                    padding: const EdgeInsets.all(6),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Departments'),
                      Tab(text: 'Projects'),
                      Tab(text: 'Financial'),
                      Tab(text: 'People'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height < 820 ? 520 : 620,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.brLg,
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOverviewTab(branch),
                        _buildDepartmentsTab(),
                        _buildProjectsTab(),
                        _buildFinancialTab(),
                        _buildPeopleTab(branch),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      tooltip: 'Back to branches',
      onPressed: () => Navigator.maybePop(context),
      icon: const Icon(Iconsax.arrow_left, color: AppColors.textPrimary),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.surface,
        side: const BorderSide(color: AppColors.borderSubtle),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
      ),
    );
  }

  Widget _buildSummaryBanner(Branch branch) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;

        final iconCard = Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: AppColors.primarySubtle,
            borderRadius: AppRadii.brLg,
          ),
          child: const Icon(Iconsax.building_4,
              color: AppColors.primary, size: 24),
        );

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(branch.branchName, style: AppTextStyles.h2),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                StatusChip.fromStatus(branch.operationalStatusDisplay),
                _buildMetaChip(
                  icon: Iconsax.tag,
                  label: branch.branchId.isNotEmpty
                      ? branch.branchId
                      : '#${branch.id}',
                ),
                _buildMetaChip(
                  icon: Iconsax.profile_circle,
                  label: branch.managerName.isNotEmpty
                      ? branch.managerName
                      : 'No manager assigned',
                ),
              ],
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: AppRadii.brLg,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconCard,
                    const SizedBox(height: 14),
                    content,
                  ],
                )
              : Row(
                  children: [
                    iconCard,
                    const SizedBox(width: 14),
                    Expanded(child: content),
                  ],
                ),
        );
      },
    );
  }

  String _branchLocation(Branch branch) {
    final parts = <String>[
      if (branch.city.isNotEmpty) branch.city,
      if (branch.state.isNotEmpty) branch.state,
      if (branch.country.isNotEmpty) branch.country,
    ];
    return parts.isEmpty ? 'No location added' : parts.join(' • ');
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─── OVERVIEW TAB ───
  Widget _buildOverviewTab(Branch branch) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Branch Details
          _buildSectionTitle("Branch Details"),
          const SizedBox(height: 12),
          _buildDetailGrid([
            _DetailItem("Branch Name", branch.branchName),
            _DetailItem("Branch Type", branch.branchRoleDisplay),
            _DetailItem("Branch ID",
                branch.branchId.isNotEmpty ? branch.branchId : "#${branch.id}"),
            _DetailItem(
                "Status",
                branch.operationalStatusDisplay.isNotEmpty
                    ? branch.operationalStatusDisplay
                    : (branch.isOperational
                        ? "Operational"
                        : "Non-Operational")),
            if (branch.createdAt.isNotEmpty)
              _DetailItem("Created", branch.createdAt.split('T').first),
            if (branch.updatedAt.isNotEmpty)
              _DetailItem("Updated", branch.updatedAt.split('T').first),
          ]),

          const SizedBox(height: 24),

          // Location & Contact
          _buildSectionTitle("Location & Contact"),
          const SizedBox(height: 12),
          _buildDetailGrid([
            _DetailItem("Address", branch.officeAddress),
            _DetailItem("City", branch.city),
            _DetailItem(
                "State",
                branch.stateCode.isNotEmpty
                    ? "${branch.state} (${branch.stateCode})"
                    : branch.state),
            _DetailItem(
                "Country",
                branch.countryCode.isNotEmpty
                    ? "${branch.country} (${branch.countryCode})"
                    : branch.country),
            if (branch.defaultCurrency.isNotEmpty)
              _DetailItem("Currency", branch.defaultCurrency),
            if (branch.languagePreference.isNotEmpty)
              _DetailItem("Language",
                  LanguageHelper.toDisplay(branch.languagePreference)),
            _DetailItem("Email", branch.contactEmail),
            _DetailItem("Phone", branch.contactPhone),
            _DetailItem("Active", branch.isActive ? "Yes" : "No"),
          ]),

          const SizedBox(height: 24),

          _buildSectionTitle("Attendance Geofence"),
          const SizedBox(height: 12),
          _buildDetailGrid([
            _DetailItem(
              "Attendance point",
              branch.latitude != null && branch.longitude != null
                  ? "${branch.latitude!.toStringAsFixed(6)}, ${branch.longitude!.toStringAsFixed(6)}"
                  : "Not configured",
            ),
            _DetailItem(
              "Allowed radius",
              branch.latitude != null && branch.longitude != null
                  ? "${branch.attendanceRadiusMeters} metres"
                  : "Configure a point first",
            ),
          ]),

          const SizedBox(height: 24),

          // Manager
          _buildSectionTitle("Management"),
          const SizedBox(height: 12),
          _buildManagerCard(branch),

          // Performance metrics
          if (controller.currentPerformance.value != null) ...[
            const SizedBox(height: 24),
            _buildSectionTitle("Performance Overview"),
            const SizedBox(height: 12),
            _buildPerformanceMetrics(controller.currentPerformance.value!),
          ],

          // Notes
          if (branch.notes.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionTitle("Notes"),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neutral200),
              ),
              child: Text(
                branch.notes,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.neutral600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // These branch sub-resources are not exposed by the published API yet.
  Widget _buildDepartmentsTab() => _buildUnavailableTab(
        'Departments',
        'Branch-specific department membership is not available from the current API.',
      );

  Widget _buildProjectsTab() => _buildUnavailableTab(
        'Projects',
        'Branch-specific project membership is not available from the current API.',
      );

  Widget _buildFinancialTab() => _buildUnavailableTab(
        'Financial summary',
        'Branch financial metrics and transactions require a published branch-finance contract.',
      );

  Widget _buildPeopleTab(Branch branch) => _buildUnavailableTab(
        'People',
        'Branch-specific people and role assignments are not available from the current API.',
      );

  Widget _buildUnavailableTab(String featureName, String explanation) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: BackendCapabilityUnavailable(
        featureName: featureName,
        explanation: explanation,
        contractRequirement:
            'Backend support is required before this tab can display live data.',
      ),
    );
  }

  // ─── SHARED WIDGETS ───

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.neutral800,
      ),
    );
  }

  Widget _buildDetailGrid(List<_DetailItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final itemWidth =
            compact ? constraints.maxWidth : (constraints.maxWidth - 24) / 2;

        return Wrap(
          spacing: 24,
          runSpacing: 12,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral500,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.value.isNotEmpty ? item.value : "-",
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral700,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            item.label,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.neutral500,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.value.isNotEmpty ? item.value : "-",
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.neutral700,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildManagerCard(Branch branch) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;

        final identity = Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.profile_circle,
                  color: Colors.blue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    branch.managerName.isNotEmpty
                        ? branch.managerName
                        : "Unassigned",
                    weight: 600,
                    size: 14,
                  ),
                  const MyText("Branch Manager", size: 12, color: Colors.grey),
                ],
              ),
            ),
          ],
        );

        final status = _buildStatusBadge(
            branch.managerName.isNotEmpty ? "Assigned" : "Unassigned");

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    identity,
                    const SizedBox(height: 12),
                    status,
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: identity),
                    const SizedBox(width: 12),
                    status,
                  ],
                ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status.toLowerCase().contains('active') ||
        status.toLowerCase().contains('operational') ||
        status.toLowerCase().contains('completed') ||
        status.toLowerCase().contains('assigned')) {
      color = Colors.green;
    } else if (status.toLowerCase().contains('inactive') ||
        status.toLowerCase().contains('closed') ||
        status.toLowerCase().contains('unassigned')) {
      color = Colors.red;
    } else if (status.toLowerCase().contains('progress') ||
        status.toLowerCase().contains('planning') ||
        status.toLowerCase().contains('maintenance')) {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BranchPerformance performance) {
    final metrics = performance.metrics;
    if (metrics.isEmpty) {
      return const Text("No metrics available",
          style: TextStyle(color: Colors.grey, fontSize: 13));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: metrics.entries.map((e) {
        return Container(
          padding: const EdgeInsets.all(12),
          width: 150,
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                e.key.replaceAll('_', ' ').toUpperCase(),
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                "${e.value}",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DetailItem {
  final String label;
  final String value;
  _DetailItem(this.label, this.value);
}
