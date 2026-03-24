import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    // Set the initial employee and fetch fresh data
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
        return const Scaffold(body: Center(child: Text("Employee not found")));
      }

      return SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, employee),
            const SizedBox(height: 24),
            _buildTabs(),
            const SizedBox(height: 24),
            _buildBody(employee),
          ],
        ),
      );
    });
  }

  Widget _buildHeader(BuildContext context, Employee employee) {
    final bool isActive = employee.isActive;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Back to Directory',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                  image: (employee.profilePicture != null &&
                          employee.profilePicture != "string" &&
                          employee.profilePicture!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(employee.profilePicture!),
                          fit: BoxFit.cover)
                      : null,
                ),
                child: (employee.profilePicture == null ||
                        employee.profilePicture == "string" ||
                        employee.profilePicture!.isEmpty)
                    ? Center(
                        child: Text(
                          employee.firstName.isNotEmpty
                              ? employee.firstName[0]
                              : '?',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(employee.fullName, size: 20, weight: 700),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        MyText(employee.role,
                            color: Colors.grey.shade600, size: 14),
                        const SizedBox(width: 8),
                        Container(
                          width: 4, height: 4,
                          decoration: const BoxDecoration(
                              color: Colors.grey, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: MyText(
                            isActive ? 'Active' : 'Inactive',
                            color: isActive ? Colors.green : Colors.red,
                            size: 11, weight: 600,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              if (!isSmallScreen(context))
                Row(
                  children: [
                    MyOutlinedButton(
                      child: 'Export',
                      textColor: Colors.black,
                      onTap: () {},
                      height: 40,
                    ),
                    const SizedBox(width: 12),
                    MyElevatedButton(
                      child: 'Edit Profile',
                      bgColor: const Color(0xFF0055FF),
                      height: 40,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) =>
                              AddEmployeeDialog(employee: employee),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    MyElevatedButton(
                      child: 'Give Review',
                      bgColor: const Color(0xFFD500F9),
                      icon: const Icon(Icons.star, color: Colors.white, size: 16),
                      height: 40,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => EmployeeAppraisalDialog(
                            userId: employee.id,
                          ),
                        );
                      },
                    ),
                  ],
                )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ["Profile", "Documents", "Reviews", "Benefits"];
    return Row(
      children: List.generate(tabs.length, (index) {
        final isSelected = _selectedTab == index;
        return Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: InkWell(
            onTap: () => setState(() => _selectedTab = index),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tabs[index],
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF0055FF)
                        : Colors.grey.shade600,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                if (isSelected)
                  Container(
                    height: 2, width: 20,
                    color: const Color(0xFF0055FF),
                  )
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBody(Employee employee) {
    switch (_selectedTab) {
      case 0:
        return _ProfileTab(employee: employee);
      case 1:
        return _DocumentsTab(
            controller: controller, userId: employee.id);
      case 2:
        return _ReviewsTab(
            controller: controller, employee: employee);
      case 3:
        return _BenefitsTab(employee: employee);
      default:
        return _ProfileTab(employee: employee);
    }
  }
}

// ==============================================================================
// TAB 1: PROFILE (Grid of Cards)
// ==============================================================================
class _ProfileTab extends StatelessWidget {
  final Employee employee;
  const _ProfileTab({required this.employee});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        // Row 1
        _InfoCard(
          title: "Contact Information",
          width: isDesktop ? 0.3 : 1.0,
          children: [
            _InfoRow(
                icon: Icons.email_outlined,
                label: "Email Address",
                value: employee.email),
            _InfoRow(
                icon: Icons.phone_outlined,
                label: "Phone Number",
                value: employee.phoneNumber ?? "N/A"),
            _InfoRow(
                icon: Icons.location_on_outlined,
                label: "Location",
                value: employee.location ?? employee.branchName ?? "N/A"),
          ],
        ),
        _InfoCard(
          title: "Personal Information",
          width: isDesktop ? 0.66 : 1.0,
          isGrid: true,
          children: [
            _DataField(label: "Employee ID", value: employee.employeeId ?? employee.id),
            _DataField(
                label: "Date of Birth",
                value: employee.dateOfBirth != null
                    ? DateFormat('MMM dd, yyyy').format(employee.dateOfBirth!)
                    : '-'),
            _DataField(label: "Gender", value: employee.gender ?? '-'),
            _DataField(
                label: "Marital Status", value: employee.maritalStatus ?? '-'),
            _DataField(label: "Nationality", value: employee.nationality ?? '-'),
          ],
        ),

        // Row 2
        _InfoCard(
          title: "Manager",
          width: isDesktop ? 0.3 : 1.0,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 20,
                  child: Text(
                    (employee.reportingToName ?? 'N').isNotEmpty
                        ? (employee.reportingToName ?? 'N')[0]
                        : 'N',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(employee.reportingToName ?? "Not Assigned",
                        weight: 600, size: 14),
                    MyText("Manager",
                        size: 12, color: Colors.grey.shade600),
                  ],
                )
              ],
            )
          ],
        ),
        _InfoCard(
          title: "Contact Address",
          width: isDesktop ? 0.66 : 1.0,
          isGrid: true,
          children: [
            _DataField(label: "Work Email", value: employee.email),
            _DataField(label: "Personal Email", value: employee.personalEmail ?? '-'),
            _DataField(label: "Phone", value: employee.phoneNumber ?? '-'),
            _DataField(label: "Other Phone", value: employee.otherPhoneNumber ?? '-'),
            _DataField(
                label: "Street Address",
                value: employee.streetAddress ?? employee.address ?? '-'),
            _DataField(label: "City", value: employee.city ?? '-'),
            _DataField(label: "State", value: employee.state ?? '-'),
            _DataField(label: "Zip Code", value: employee.zipCode ?? '-'),
            _DataField(label: "Emergency Contact", value: employee.emergencyContactName ?? '-'),
            _DataField(label: "Relationship", value: employee.emergencyContactRelationship ?? '-'),
          ],
        ),

        // Row 3
        _InfoCard(
          title: "Employment",
          width: 1.0,
          isGrid: true,
          children: [
            _DataField(label: "Designation", value: employee.designation ?? employee.role),
            _DataField(
                label: "Department",
                value: employee.departmentName ?? employee.departmentId?.toString() ?? '-'),
            _DataField(label: "Unit", value: employee.departmentUnitName ?? '-'),
            _DataField(
                label: "Branch",
                value: employee.branchName ?? employee.branchId?.toString() ?? '-'),
            _DataField(label: "Location", value: employee.location ?? '-'),
            _DataField(
                label: "Reporting To",
                value: employee.reportingToName ?? '-'),
            _DataField(
                label: "Employment Type",
                value: employee.employmentType ?? '-'),
            _DataField(
                label: "Status",
                customValue: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: employee.isActive
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    employee.isActive ? "Active" : "Inactive",
                    style: TextStyle(
                        color: employee.isActive ? Colors.green : Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                )),
            _DataField(
                label: "Joining Date",
                value: employee.startDate != null
                    ? DateFormat('MMM dd, yyyy').format(employee.startDate!)
                    : '-'),
            _DataField(
                label: "Probation Period",
                value: employee.probationPeriod != null
                    ? "${employee.probationPeriod} Months"
                    : '-'),
          ],
        ),

        // Row 4
        _InfoCard(
          title: "Compensation",
          width: 1.0,
          isGrid: true,
          children: [
            _DataField(
                label: "Basic Salary",
                value: employee.grossSalary != null
                    ? "₦${employee.grossSalary}"
                    : "₦0.00"),
            _DataField(label: "Payment Frequency", value: employee.salaryFrequency ?? '-'),
            _DataField(label: "Bank Name", value: employee.bankName ?? '-'),
            _DataField(label: "Account Number", value: employee.accountNumber ?? '-'),
            _DataField(label: "Tax ID", value: employee.taxId ?? '-'),
            _DataField(label: "Pension Number", value: employee.pensionNumber ?? '-'),
          ],
        ),
      ],
    );
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const MyText("Digital Personnel File", weight: 600, size: 16),
                MyElevatedButton(
                  child: "Upload Document",
                  bgColor: const Color(0xFF0055FF),
                  height: 36,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          UploadDocumentDialog(userId: widget.userId),
                    );
                  },
                )
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Header
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: MyText("Document Title",
                        weight: 600, color: Colors.grey)),
                Expanded(
                    flex: 2,
                    child: MyText("Type", weight: 600, color: Colors.grey)),
                Expanded(
                    flex: 2,
                    child:
                        MyText("Uploaded By", weight: 600, color: Colors.grey)),
                Expanded(
                    flex: 1,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: MyText("Action",
                            weight: 600, color: Colors.grey))),
              ],
            ),
          ),
          const Divider(height: 1),
          // Dynamic rows from API
          Obx(() {
            if (widget.controller.isLoadingDocuments.value) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (widget.controller.documents.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: Text("No documents found.")),
              );
            }

            return Column(
              children: widget.controller.documents.map((doc) {
                final title = doc['name'] ?? doc['document_name'] ?? 'Untitled';
                final type = doc['type'] ?? doc['document_type'] ?? '-';
                final uploader = doc['uploaded_by'] ?? '-';
                final docId = doc['id']?.toString() ?? '';

                return _buildDocRow(title, type, uploader, docId);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDocRow(String title, String type, String uploader, String docId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: MyText(title, weight: 500)),
          Expanded(flex: 2, child: MyText(type, color: Colors.grey.shade700)),
          Expanded(
              flex: 2, child: MyText(uploader, color: Colors.grey.shade700)),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'delete' && docId.isNotEmpty) {
                    widget.controller.deleteDocument(
                        context, widget.userId, docId);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'delete', child: Text('Delete')),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: const Row(
              children: [
                Expanded(
                    flex: 3,
                    child: MyText("From", weight: 600, color: Colors.grey)),
                Expanded(
                    flex: 2,
                    child: MyText("Date", weight: 600, color: Colors.grey)),
                Expanded(
                    flex: 2,
                    child: MyText("Rating", weight: 600, color: Colors.grey)),
                Expanded(
                    flex: 1,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: MyText("Action",
                            weight: 600, color: Colors.grey))),
              ],
            ),
          ),
          const Divider(height: 1),
          Obx(() {
            if (widget.controller.isLoadingReviews.value) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (widget.controller.reviews.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: Text("No reviews found.")),
              );
            }

            return Column(
              children: widget.controller.reviews.map((review) {
                final reviewerName =
                    review['reviewer_name'] ?? review['from'] ?? 'Unknown';
                final date = review['created_at'] ?? review['date'] ?? '-';
                final rating = review['rating'] ?? review['overall_rating'] ?? 0;
                final reviewId = review['id']?.toString() ?? '';

                return _buildReviewRow(reviewerName, date, rating, reviewId);
              }).toList(),
            );
          }),
          Obx(() => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText(
                        "Showing ${widget.controller.reviews.length}",
                        color: Colors.grey),
                    const SizedBox(),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildReviewRow(
      String reviewer, String date, dynamic rating, String reviewId) {
    final int ratingInt =
        rating is int ? rating : (int.tryParse(rating.toString()) ?? 0);
    final String formattedDate = date.length > 10 ? date.substring(0, 10) : date;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    reviewer.isNotEmpty ? reviewer[0] : '?',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                MyText(reviewer, weight: 600, size: 13),
              ],
            ),
          ),
          Expanded(
              flex: 2,
              child: MyText(formattedDate, color: Colors.grey)),
          Expanded(
            flex: 2,
            child: Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < ratingInt ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'delete' && reviewId.isNotEmpty) {
                    widget.controller.deleteReview(
                        context, widget.employee.id, reviewId);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                      value: 'delete', child: Text('Delete')),
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
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoCard(
                title: "Health Insurance (HMO)",
                hasEdit: true,
                children: [
                  _DataField(
                      label: "Current Plan",
                      value: employee.hmoPlan ?? '-',
                      isBoldValue: true),
                  _DataField(
                      label: "HMO ID Number",
                      value: employee.hmoIdNumber ?? '-',
                      isBoldValue: true),
                  _DataField(
                      label: "Dependents Covered",
                      value: employee.hmoDependentsCovered?.toString() ?? '-',
                      isBoldValue: true),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _InfoCard(
                title: "Pension Scheme",
                hasEdit: true,
                children: [
                  _DataField(
                      label: "PFA Provider",
                      value: employee.pfaProvider ?? '-',
                      isBoldValue: true),
                  _DataField(
                      label: "RSA Number",
                      value: employee.rsaNumber ?? '-',
                      isBoldValue: true),
                  _DataField(
                      label: "Employer Contribution",
                      value: employee.employerContribution != null
                          ? "${employee.employerContribution}%"
                          : '-',
                      isBoldValue: true),
                ],
              ),
            ),
          ],
        ),
        _InfoCard(
          title: "Allowance & Perks",
          hasEdit: false,
          customAction: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFF0055FF),
                borderRadius: BorderRadius.circular(4)),
            child: const Text("Add",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
          children: _buildAllowanceRows(),
        )
      ],
    );
  }

  List<Widget> _buildAllowanceRows() {
    final allowances = employee.allowances;
    if (allowances == null || allowances.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16),
          child: MyText("No allowances configured", color: Colors.grey),
        )
      ];
    }

    return allowances.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              MyText(entry.key, weight: 600, size: 14),
              MyText("${entry.value}", color: Colors.grey, size: 12),
            ]),
            const Icon(Icons.delete_outline, color: Colors.red, size: 18)
          ],
        ),
      );
    }).toList();
  }
}

// ==============================================================================
// SHARED WIDGETS
// ==============================================================================

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final double width;
  final bool isGrid;
  final bool hasEdit;
  final Widget? customAction;

  const _InfoCard({
    required this.title,
    required this.children,
    this.width = 1.0,
    this.isGrid = false,
    this.hasEdit = false,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectiveWidth = (screenWidth * width) - 32;

    return Container(
      width: width == 1.0 ? double.infinity : effectiveWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(title, weight: 700, size: 16),
              if (hasEdit)
                const MyText("Edit",
                    color: Color(0xFF0055FF), weight: 600, size: 12)
              else if (customAction != null)
                customAction!
              else
                const MyText("Edit",
                    color: Color(0xFF0055FF), weight: 600, size: 12),
            ],
          ),
          const SizedBox(height: 20),
          if (isGrid)
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: children
                  .map((c) => SizedBox(
                      width: (width == 1.0
                          ? (screenWidth - 100) / 2
                          : (effectiveWidth - 40) / 2),
                      child: c))
                  .toList(),
            )
          else
            Column(children: children),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.green, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(label, size: 12, color: Colors.grey.shade600),
              const SizedBox(height: 2),
              MyText(value, size: 14, weight: 600),
            ],
          )
        ],
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
        MyText(label, size: 12, color: Colors.grey.shade600),
        const SizedBox(height: 4),
        if (customValue != null)
          customValue!
        else
          MyText(value ?? '-', weight: isBoldValue ? 700 : 600, size: 14),
      ],
    );
  }
}
