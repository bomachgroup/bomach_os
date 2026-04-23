import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/cards/app_card.dart';
import 'package:bms_front_end/components/chip/status_chip.dart';
import 'package:bms_front_end/components/section/empty_state.dart';
import 'package:bms_front_end/components/section/loading_skeleton.dart';
import 'package:bms_front_end/components/section/page_header.dart';
import 'package:bms_front_end/components/section/page_scaffold.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/shadows.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/helper/responsive_breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../src/model/employees_model.dart';
import 'controller/employees_controller.dart';
import 'widget/add_employee_appraisal.dart';
import 'widget/add_employee_document.dart';
import 'widget/add_new_employee.dart';

class EmployeeProfile extends StatefulWidget {
  final Employee? e;
  const EmployeeProfile({super.key, this.e});

  @override
  State<EmployeeProfile> createState() => _EmployeeProfileState();
}

class _EmployeeProfileState extends State<EmployeeProfile> {
  int _selectedTab = 0;

  final EmployeeController controller = Get.isRegistered<EmployeeController>()
      ? Get.find<EmployeeController>()
      : Get.put(EmployeeController());

  @override
  void initState() {
    super.initState();
    final e = widget.e;
    if (e != null) {
      controller.selectedEmployee.value = e;
      controller.fetchEmployeeById(e.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final employee = controller.selectedEmployee.value ??
          widget.e ??
          ModalRoute.of(context)?.settings.arguments as Employee?;

      if (employee == null) {
        return const Scaffold(
          body: Center(child: Text('Employee not found')),
        );
      }

      return PageScaffold(
        maxContentWidth: 1440,
        header: PageHeader(
          title: employee.fullName,
          subtitle: employee.designation ?? employee.role,
          leading: _backButton(context),
          trailing: _buildHeaderActions(context, employee),
        ),
        children: [
          _buildSummaryCard(context, employee),
          _buildPillTabBar(),
          _buildBody(employee),
        ],
      );
    });
  }

  Widget _backButton(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadii.brMd,
      child: InkWell(
        borderRadius: AppRadii.brMd,
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderStrong),
            borderRadius: AppRadii.brMd,
          ),
          child: const Icon(Iconsax.arrow_left_2,
              size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget? _buildHeaderActions(BuildContext context, Employee employee) {
    if (context.isMobile) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          MyOutlinedButton(
            child: 'Edit',
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            textColor: AppColors.textPrimary,
            borderColor: AppColors.borderStrong,
            icon: const Icon(Iconsax.edit,
                size: 16, color: AppColors.textPrimary),
            onTap: () => showDialog(
              context: context,
              builder: (_) => AddEmployeeDialog(employee: employee),
            ),
          ),
          MyElevatedButton(
            child: 'Give Review',
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            icon: const Icon(Iconsax.star1,
                color: AppColors.textOnPrimary, size: 16),
            onTap: () => showDialog(
              context: context,
              builder: (_) => EmployeeAppraisalDialog(userId: employee.id),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyOutlinedButton(
          child: 'Export',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          textColor: AppColors.textPrimary,
          borderColor: AppColors.borderStrong,
          icon: const Icon(Iconsax.export_1,
              size: 16, color: AppColors.textPrimary),
          onTap: () {},
        ),
        const SizedBox(width: 12),
        MyOutlinedButton(
          child: 'Edit Profile',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          icon: const Icon(Iconsax.edit, size: 16, color: AppColors.primary),
          onTap: () => showDialog(
            context: context,
            builder: (_) => AddEmployeeDialog(employee: employee),
          ),
        ),
        const SizedBox(width: 12),
        MyElevatedButton(
          child: 'Give Review',
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          icon: const Icon(Iconsax.star1,
              color: AppColors.textOnPrimary, size: 16),
          onTap: () => showDialog(
            context: context,
            builder: (_) => EmployeeAppraisalDialog(userId: employee.id),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, Employee employee) {
    final bool isActive = employee.isActive;
    final bool hasPicture = employee.profilePicture != null &&
        employee.profilePicture != 'string' &&
        employee.profilePicture!.isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
              image: hasPicture
                  ? DecorationImage(
                      image: NetworkImage(employee.profilePicture!),
                      fit: BoxFit.cover,
                    )
                  : null,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: !hasPicture
                ? Center(
                    child: Text(
                      employee.firstName.isNotEmpty
                          ? employee.firstName[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.fullName, style: AppTextStyles.h2),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      employee.designation ?? employee.role,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    StatusChip(
                      label: isActive ? 'Active' : 'Inactive',
                      tone: isActive ? StatusTone.success : StatusTone.neutral,
                      dense: true,
                    ),
                    if ((employee.employmentType ?? '').isNotEmpty)
                      StatusChip(
                        label: employee.employmentType!,
                        tone: _employmentTypeTone(employee.employmentType),
                        dense: true,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${employee.employeeId ?? employee.id} • ${employee.email}',
                  style: AppTextStyles.bodySm,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  StatusTone _employmentTypeTone(String? type) {
    final t = (type ?? '').toLowerCase();
    if (t.contains('part')) return StatusTone.info;
    if (t.contains('contract')) return StatusTone.warning;
    if (t.contains('intern')) return StatusTone.neutral;
    return StatusTone.primary;
  }

  Widget _buildPillTabBar() {
    const tabs = ['Profile', 'Documents', 'Reviews', 'Benefits'];
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
          mainAxisSize: MainAxisSize.min,
          children: List.generate(tabs.length, (index) {
            final isActive = _selectedTab == index;
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadii.brMd,
                  onTap: () => setState(() => _selectedTab = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.surface : Colors.transparent,
                      borderRadius: AppRadii.brMd,
                      boxShadow: isActive ? AppShadows.sm : const <BoxShadow>[],
                    ),
                    child: Text(
                      tabs[index],
                      style: AppTextStyles.bodyMd.copyWith(
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBody(Employee employee) {
    switch (_selectedTab) {
      case 0:
        return _ProfileTab(employee: employee);
      case 1:
        return _DocumentsTab(controller: controller, userId: employee.id);
      case 2:
        return _ReviewsTab(controller: controller, employee: employee);
      case 3:
        return _BenefitsTab(employee: employee);
      default:
        return _ProfileTab(employee: employee);
    }
  }
}

// ==============================================================================
// TAB 1: PROFILE
// ==============================================================================
class _ProfileTab extends StatelessWidget {
  final Employee employee;
  const _ProfileTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.breakpoint.isDesktop;

    return LayoutBuilder(builder: (context, constraints) {
      final double maxWidth = constraints.maxWidth;
      const double twoColGap = 24.0;
      final leftWidth = isDesktop ? (maxWidth * 0.32) : maxWidth;
      final rightWidth =
          isDesktop ? (maxWidth - leftWidth - twoColGap) : maxWidth;

      return Wrap(
        spacing: twoColGap,
        runSpacing: 24,
        children: [
          SizedBox(
            width: leftWidth,
            child: _InfoCard(
              title: 'Contact Information',
              children: [
                _InfoRow(
                    icon: Iconsax.sms,
                    label: 'Email Address',
                    value: employee.email),
                _InfoRow(
                    icon: Iconsax.call,
                    label: 'Phone Number',
                    value: employee.phoneNumber ?? '—'),
                _InfoRow(
                    icon: Iconsax.location,
                    label: 'Location',
                    value: employee.location ?? employee.branchName ?? '—'),
              ],
            ),
          ),
          SizedBox(
            width: rightWidth,
            child: _InfoCard(
              title: 'Personal Information',
              isGrid: true,
              children: [
                _DataField(
                    label: 'Employee ID',
                    value: employee.employeeId ?? employee.id),
                _DataField(
                    label: 'Date of Birth',
                    value: employee.dateOfBirth != null
                        ? DateFormat('MMM dd, yyyy')
                            .format(employee.dateOfBirth!)
                        : '—'),
                _DataField(label: 'Gender', value: employee.gender ?? '—'),
                _DataField(
                    label: 'Marital Status',
                    value: employee.maritalStatus ?? '—'),
                _DataField(
                    label: 'Nationality', value: employee.nationality ?? '—'),
              ],
            ),
          ),
          SizedBox(
            width: leftWidth,
            child: _InfoCard(
              title: 'Manager',
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor:
                          AppColors.warning.withValues(alpha: 0.18),
                      radius: 22,
                      child: Text(
                        (employee.reportingToName ?? 'N').isNotEmpty
                            ? (employee.reportingToName ?? 'N')[0].toUpperCase()
                            : 'N',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.warning,
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
                            employee.reportingToName ?? 'Not Assigned',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Reporting Manager',
                            style: AppTextStyles.bodySm,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: rightWidth,
            child: _InfoCard(
              title: 'Contact Address',
              isGrid: true,
              children: [
                _DataField(label: 'Work Email', value: employee.email),
                _DataField(
                    label: 'Personal Email',
                    value: employee.personalEmail ?? '—'),
                _DataField(label: 'Phone', value: employee.phoneNumber ?? '—'),
                _DataField(
                    label: 'Other Phone',
                    value: employee.otherPhoneNumber ?? '—'),
                _DataField(
                    label: 'Street Address',
                    value: employee.streetAddress ?? employee.address ?? '—'),
                _DataField(label: 'City', value: employee.city ?? '—'),
                _DataField(label: 'State', value: employee.state ?? '—'),
                _DataField(label: 'Zip Code', value: employee.zipCode ?? '—'),
                _DataField(
                    label: 'Emergency Contact',
                    value: employee.emergencyContactName ?? '—'),
                _DataField(
                    label: 'Relationship',
                    value: employee.emergencyContactRelationship ?? '—'),
              ],
            ),
          ),
          SizedBox(
            width: maxWidth,
            child: _InfoCard(
              title: 'Employment',
              isGrid: true,
              children: [
                _DataField(
                    label: 'Designation',
                    value: employee.designation ?? employee.role),
                _DataField(
                    label: 'Department',
                    value: employee.departmentName ??
                        employee.departmentId?.toString() ??
                        '—'),
                _DataField(
                    label: 'Unit', value: employee.departmentUnitName ?? '—'),
                _DataField(
                    label: 'Branch',
                    value: employee.branchName ??
                        employee.branchId?.toString() ??
                        '—'),
                _DataField(label: 'Location', value: employee.location ?? '—'),
                _DataField(
                    label: 'Reporting To',
                    value: employee.reportingToName ?? '—'),
                _DataField(
                    label: 'Employment Type',
                    value: employee.employmentType ?? '—'),
                _DataField(
                  label: 'Status',
                  customValue: StatusChip(
                    label: employee.isActive ? 'Active' : 'Inactive',
                    tone: employee.isActive
                        ? StatusTone.success
                        : StatusTone.neutral,
                    dense: true,
                  ),
                ),
                _DataField(
                    label: 'Joining Date',
                    value: employee.startDate != null
                        ? DateFormat('MMM dd, yyyy').format(employee.startDate!)
                        : '—'),
                _DataField(
                    label: 'Probation Period',
                    value: employee.probationPeriod != null
                        ? '${employee.probationPeriod} Months'
                        : '—'),
              ],
            ),
          ),
          SizedBox(
            width: maxWidth,
            child: _InfoCard(
              title: 'Compensation',
              isGrid: true,
              children: [
                _DataField(
                    label: 'Basic Salary',
                    value: employee.grossSalary != null
                        ? '₦${employee.grossSalary}'
                        : '₦0.00'),
                _DataField(
                    label: 'Payment Frequency',
                    value: employee.salaryFrequency ?? '—'),
                _DataField(label: 'Bank Name', value: employee.bankName ?? '—'),
                _DataField(
                    label: 'Account Number',
                    value: employee.accountNumber ?? '—'),
                _DataField(label: 'Tax ID', value: employee.taxId ?? '—'),
                _DataField(
                    label: 'Pension Number',
                    value: employee.pensionNumber ?? '—'),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// ==============================================================================
// TAB 2: DOCUMENTS
// ==============================================================================
class _DocumentsTab extends StatefulWidget {
  final EmployeeController controller;
  final String userId;

  const _DocumentsTab({required this.controller, required this.userId});

  @override
  State<_DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<_DocumentsTab> {
  @override
  void initState() {
    super.initState();
    widget.controller.fetchDocuments(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
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
                      const Text('Digital Personnel File', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            '${widget.controller.documents.length} document${widget.controller.documents.length == 1 ? '' : 's'} on file',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )),
                    ],
                  ),
                ),
                MyElevatedButton(
                  child: 'Upload Document',
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  icon: const Icon(Iconsax.document_upload,
                      color: AppColors.textOnPrimary, size: 16),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => UploadDocumentDialog(userId: widget.userId),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Obx(() {
            if (widget.controller.isLoadingDocuments.value) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: LoadingSkeleton.listRows(count: 4),
              );
            }

            if (widget.controller.documents.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: EmptyState(
                  icon: Iconsax.document,
                  title: 'No documents found',
                  subtitle:
                      'Upload contracts, IDs, certificates, and other records for this employee.',
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: AppColors.surfaceMuted,
                  child: const Row(
                    children: [
                      Expanded(flex: 4, child: _HeaderCell('Document Title')),
                      Expanded(flex: 2, child: _HeaderCell('Type')),
                      Expanded(flex: 3, child: _HeaderCell('Uploaded By')),
                      SizedBox(width: 60, child: _HeaderCell('')),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                ...widget.controller.documents.map((doc) {
                  final title =
                      doc['name'] ?? doc['document_name'] ?? 'Untitled';
                  final type = doc['type'] ?? doc['document_type'] ?? '—';
                  final uploader = doc['uploaded_by'] ?? '—';
                  final docId = doc['id']?.toString() ?? '';

                  return _buildDocRow(title, type, uploader, docId);
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDocRow(
      String title, String type, String uploader, String docId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySubtle,
                    borderRadius: AppRadii.brSm,
                  ),
                  child: const Icon(Iconsax.document,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                label: type.toString(),
                tone: StatusTone.neutral,
                dense: true,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              uploader.toString(),
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 60,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                icon: const Icon(Iconsax.more,
                    size: 18, color: AppColors.textMuted),
                onSelected: (value) {
                  if (value == 'delete' && docId.isNotEmpty) {
                    widget.controller
                        .deleteDocument(context, widget.userId, docId);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// TAB 3: REVIEWS
// ==============================================================================
class _ReviewsTab extends StatefulWidget {
  final EmployeeController controller;
  final Employee employee;

  const _ReviewsTab({required this.controller, required this.employee});

  @override
  State<_ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<_ReviewsTab> {
  @override
  void initState() {
    super.initState();
    widget.controller.fetchReviews(widget.employee.id);
  }

  @override
  Widget build(BuildContext context) {
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
                      const Text('Performance Reviews', style: AppTextStyles.h3),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            '${widget.controller.reviews.length} review${widget.controller.reviews.length == 1 ? '' : 's'} recorded',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )),
                    ],
                  ),
                ),
                const StatusChip(
                  label: 'Performance log',
                  tone: StatusTone.primary,
                  icon: Iconsax.star1,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Obx(() {
            if (widget.controller.isLoadingReviews.value) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: LoadingSkeleton.listRows(count: 4),
              );
            }

            if (widget.controller.reviews.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: EmptyState(
                  icon: Iconsax.star,
                  title: 'No reviews found',
                  subtitle:
                      'Reviews appear here once managers submit performance feedback.',
                ),
              );
            }

            return Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: AppColors.surfaceMuted,
                  child: const Row(
                    children: [
                      Expanded(flex: 4, child: _HeaderCell('From')),
                      Expanded(flex: 3, child: _HeaderCell('Date')),
                      Expanded(flex: 3, child: _HeaderCell('Rating')),
                      SizedBox(width: 60, child: _HeaderCell('')),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderSubtle),
                ...widget.controller.reviews.map((review) {
                  final reviewerName =
                      review['reviewer_name'] ?? review['from'] ?? 'Unknown';
                  final date = review['created_at'] ?? review['date'] ?? '—';
                  final rating =
                      review['rating'] ?? review['overall_rating'] ?? 0;
                  final reviewId = review['id']?.toString() ?? '';

                  return _buildReviewRow(reviewerName, date, rating, reviewId);
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewRow(
      String reviewer, String date, dynamic rating, String reviewId) {
    final int ratingInt =
        rating is int ? rating : (int.tryParse(rating.toString()) ?? 0);
    final String formattedDate =
        date.length > 10 ? date.substring(0, 10) : date;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                  radius: 16,
                  backgroundColor: AppColors.primarySubtle,
                  child: Text(
                    reviewer.isNotEmpty ? reviewer[0].toUpperCase() : '?',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    reviewer,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              formattedDate,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < ratingInt ? Iconsax.star1 : Iconsax.star,
                  color: AppColors.warning,
                  size: 16,
                );
              }),
            ),
          ),
          SizedBox(
            width: 60,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                icon: const Icon(Iconsax.more,
                    size: 18, color: AppColors.textMuted),
                onSelected: (value) {
                  if (value == 'delete' && reviewId.isNotEmpty) {
                    widget.controller
                        .deleteReview(context, widget.employee.id, reviewId);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// TAB 4: BENEFITS
// ==============================================================================
class _BenefitsTab extends StatelessWidget {
  final Employee employee;
  const _BenefitsTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 700;
      final colWidth =
          isWide ? (constraints.maxWidth - 24) / 2 : constraints.maxWidth;

      return Wrap(
        spacing: 24,
        runSpacing: 24,
        children: [
          SizedBox(
            width: colWidth,
            child: _InfoCard(
              title: 'Health Insurance (HMO)',
              hasEdit: true,
              children: [
                _DataField(
                    label: 'Current Plan',
                    value: employee.hmoPlan ?? '—',
                    isBoldValue: true),
                _DataField(
                    label: 'HMO ID Number',
                    value: employee.hmoIdNumber ?? '—',
                    isBoldValue: true),
                _DataField(
                    label: 'Dependents Covered',
                    value: employee.hmoDependentsCovered?.toString() ?? '—',
                    isBoldValue: true),
              ],
            ),
          ),
          SizedBox(
            width: colWidth,
            child: _InfoCard(
              title: 'Pension Scheme',
              hasEdit: true,
              children: [
                _DataField(
                    label: 'PFA Provider',
                    value: employee.pfaProvider ?? '—',
                    isBoldValue: true),
                _DataField(
                    label: 'RSA Number',
                    value: employee.rsaNumber ?? '—',
                    isBoldValue: true),
                _DataField(
                    label: 'Employer Contribution',
                    value: employee.employerContribution != null
                        ? '${employee.employerContribution}%'
                        : '—',
                    isBoldValue: true),
              ],
            ),
          ),
          SizedBox(
            width: constraints.maxWidth,
            child: _InfoCard(
              title: 'Allowances & Perks',
              customAction: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadii.brSm,
                ),
                child: Text(
                  'Add',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              children: _buildAllowanceRows(),
            ),
          ),
        ],
      );
    });
  }

  List<Widget> _buildAllowanceRows() {
    final allowances = employee.allowances;
    if (allowances == null || allowances.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'No allowances configured.',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ];
    }

    return allowances.entries.map((entry) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.value}',
                    style: AppTextStyles.bodySm,
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.trash, color: AppColors.danger, size: 18),
          ],
        ),
      );
    }).toList();
  }
}

// ==============================================================================
// SHARED WIDGETS
// ==============================================================================

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.bodySm.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool isGrid;
  final bool hasEdit;
  final Widget? customAction;

  const _InfoCard({
    required this.title,
    required this.children,
    this.isGrid = false,
    this.hasEdit = false,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      elevation: AppCardElevation.sm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.h4),
              if (customAction != null)
                customAction!
              else if (hasEdit)
                Text(
                  'Edit',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (isGrid)
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 520;
              final colCount = isWide ? 2 : 1;
              const spacing = 20.0;
              final colWidth =
                  (constraints.maxWidth - (spacing * (colCount - 1))) /
                      colCount;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: children
                    .map((c) => SizedBox(width: colWidth, child: c))
                    .toList(),
              );
            })
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: AppRadii.brSm,
            ),
            child: const Icon(Iconsax.location,
                color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppTextStyles.bodySm),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).withIcon(icon);
  }
}

extension _IconOverride on Padding {
  Padding withIcon(IconData icon) {
    final row = child as Row;
    final children = List<Widget>.from(row.children);
    final iconBox = children[0] as Container;
    children[0] = Container(
      padding: iconBox.padding,
      decoration: iconBox.decoration,
      child: Icon(icon, color: AppColors.primary, size: 16),
    );
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: row.crossAxisAlignment,
        children: children,
      ),
    );
  }
}

class _DataField extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? customValue;
  final bool isBoldValue;

  const _DataField({
    required this.label,
    this.value,
    this.customValue,
    this.isBoldValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySm),
        const SizedBox(height: 4),
        if (customValue != null)
          customValue!
        else
          Text(
            value ?? '—',
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: isBoldValue ? FontWeight.w700 : FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
      ],
    );
  }
}
