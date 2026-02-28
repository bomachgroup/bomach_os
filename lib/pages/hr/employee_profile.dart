import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/button/my_outlined_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/helper/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../../src/model/employees_model.dart';
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
  // 0: Profile, 1: Documents, 2: Reviews, 3: Benefits
  int _selectedTab = 0;
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) token = token.replaceFirst("Bearer ", "");
    return token.replaceAll('"', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final employee =
        widget.e ?? ModalRoute.of(context)?.settings.arguments as Employee?;

    if (employee == null) {
      return const Scaffold(body: Center(child: Text("Employee not found")));
    }

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Section
          _buildHeader(context, employee),
          const SizedBox(height: 24),

          // 2. Tabs
          _buildTabs(),
          const SizedBox(height: 24),

          // 3. Dynamic Body
          _buildBody(employee),
        ],
      ),
    );
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
          // Back Button
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

          // Profile Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
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

              // Name & Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      '${employee.firstName} ${employee.lastName}',
                      size: 20,
                      weight: 700,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        MyText(
                          employee.role,
                          color: Colors.grey.shade600,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                              color: Colors.grey, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: MyText(
                            isActive ? 'Active' : 'Inactive',
                            color: isActive ? Colors.green : Colors.red,
                            size: 11,
                            weight: 600,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),

              // Actions Buttons
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
                      onTap: () async {
                        final token = await _getToken(context);
                        if (token != null && context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => AddEmployesScreen(
                                  token: token, employee: employee),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    MyElevatedButton(
                      child: 'Give Review',
                      bgColor: const Color(0xFFD500F9), // Purple
                      icon:
                          const Icon(Icons.star, color: Colors.white, size: 16),
                      height: 40,
                      // CONNECTED DIALOG HERE
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const EmployeeAppraisalDialog(),
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
                    height: 2,
                    width: 20,
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
        return _DocumentsTab();
      case 2:
        return _ReviewsTab(employee: employee);
      case 3:
        return _BenefitsTab();
      default:
        return _ProfileTab(employee: employee);
    }
  }
}

// ==============================================================================
// TAB 2: DOCUMENTS
// ==============================================================================
class _DocumentsTab extends StatelessWidget {
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
                  // CONNECTED DIALOG HERE
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const UploadDocumentDialog(),
                    );
                  },
                )
              ],
            ),
          ),
          const Divider(height: 1),
          // ... rest of the table implementation
          Container(
            color: Colors.grey.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                    flex: 3,
                    child: MyText("Document Title",
                        weight: 600, color: Colors.grey)),
                const Expanded(
                    flex: 2,
                    child: MyText("Type", weight: 600, color: Colors.grey)),
                const Expanded(
                    flex: 2,
                    child:
                        MyText("Uploaded By", weight: 600, color: Colors.grey)),
                Expanded(
                    flex: 1,
                    child: Container(
                        alignment: Alignment.centerRight,
                        child: const MyText("Action",
                            weight: 600, color: Colors.grey))),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Rows
          _buildDocRow("Employment Agreement", "Contract", "Lagos"),
          _buildDocRow("ID Card Scan", "ID", "Abuja"),
          _buildDocRow("Driving Certificate", "License", "Port Harcourt"),
          _buildDocRow("Training Certificate", "Training", "Port Harcourt"),
        ],
      ),
    );
  }

  Widget _buildDocRow(String title, String type, String uploader) {
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
              child: Container(
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.more_vert,
                      size: 18, color: Colors.grey))),
        ],
      ),
    );
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
            const _InfoRow(
                icon: Icons.location_on_outlined,
                label: "Location",
                value: "Abuja Branch"), // Mock or derive
          ],
        ),
        _InfoCard(
          title: "Personal Information",
          width: isDesktop ? 0.66 : 1.0,
          isGrid: true, // 2 Columns
          children: [
            _DataField(label: "Employee ID", value: employee.id),
            _DataField(
                label: "Date of Birth",
                value: employee.dateOfBirth != null
                    ? DateFormat('MMM dd, yyyy').format(employee.dateOfBirth!)
                    : '-'),
            _DataField(label: "Gender", value: employee.gender ?? '-'),
            _DataField(
                label: "Marital Status", value: employee.maritalStatus ?? '-'),
            const _DataField(label: "Nationality", value: "Nigeria"), // Mock
          ],
        ),

        // Row 2
        _InfoCard(
          title: "Manager",
          width: isDesktop ? 0.3 : 1.0,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.orange,
                  radius: 20,
                  child: Text("LS",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MyText("Engr. David", weight: 600, size: 14),
                    MyText("Hiring Manager",
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
            _DataField(label: "Personal Email", value: employee.email), // Mock
            _DataField(label: "Phone", value: employee.phoneNumber ?? '-'),
            _DataField(
                label: "Other Phone", value: employee.phoneNumber), // Mock
            _DataField(
                label: "Street Address",
                value: employee.address ?? "No 12 Street"),
            const _DataField(label: "City", value: "Ikeja"), // Mock
            const _DataField(label: "State", value: "Lagos"), // Mock
            const _DataField(label: "Zip Code", value: "100001"), // Mock
            const _DataField(
                label: "Emergency Contact", value: "Grace Mercy Ijoma"), // Mock
            const _DataField(label: "Relationship", value: "Sister"), // Mock
          ],
        ),

        // Row 3
        _InfoCard(
          title: "Employment",
          width: 1.0,
          isGrid: true,
          children: [
            _DataField(label: "Designation", value: employee.role),
            _DataField(
                label: "Department",
                value: employee.departmentId?.toString() ?? "IT"),
            const _DataField(label: "Unit", value: "Bomach"), // Mock
            _DataField(
                label: "Branch",
                value: employee.branchId?.toString() ?? "Lagos Branch"),
            const _DataField(label: "Location", value: "Ikeja"), // Mock
            _DataField(
                label: "Reporting To",
                customValue: Row(children: [
                  const CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.orange,
                      child: Text("L", style: TextStyle(fontSize: 10))),
                  const SizedBox(width: 8),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Luka Simon",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                        Text("Hiring Manager",
                            style: TextStyle(
                                fontSize: 10, color: Colors.grey.shade500))
                      ])
                ])),
            _DataField(
                label: "Employment Type",
                value: employee.employmentType ?? "Full-Time"),
            _DataField(
                label: "Status",
                customValue: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text("Active",
                      style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                )),
            _DataField(
                label: "Joining Date",
                value: employee.startDate != null
                    ? DateFormat('MMM dd, yyyy').format(employee.startDate!)
                    : '-'),
            const _DataField(
                label: "Probation Period", value: "3 Months"), // Mock
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
            const _DataField(label: "Payment Frequency", value: "Monthly"),
            const _DataField(label: "Bank Name", value: "Bomach Bank"), // Mock
            const _DataField(
                label: "Account Number", value: "0587654321"), // Mock
            const _DataField(label: "Tax ID", value: "AFD938935"), // Mock
            const _DataField(
                label: "Pension Number", value: "LDGS930003MM02"), // Mock
          ],
        ),
      ],
    );
  }
}

// ==============================================================================
// TAB 3: REVIEWS
// ==============================================================================
class _ReviewsTab extends StatelessWidget {
  final Employee employee;
  const _ReviewsTab({required this.employee});

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
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Expanded(
                    flex: 3,
                    child: MyText("From", weight: 600, color: Colors.grey)),
                const Expanded(
                    flex: 2,
                    child: MyText("Date", weight: 600, color: Colors.grey)),
                const Expanded(
                    flex: 2,
                    child: MyText("Rating", weight: 600, color: Colors.grey)),
                Expanded(
                    flex: 1,
                    child: Container(
                        alignment: Alignment.centerRight,
                        child: const MyText("Action",
                            weight: 600, color: Colors.grey))),
              ],
            ),
          ),
          const Divider(height: 1),
          // Rows
          _buildReviewRow(employee),
          _buildReviewRow(employee),
          _buildReviewRow(employee),
          // Footer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const MyText("Showing 03", color: Colors.grey),
                Row(
                  children: [
                    const Icon(Icons.chevron_left, color: Colors.grey),
                    const SizedBox(width: 8),
                    Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                            color: const Color(0xFF0055FF),
                            borderRadius: BorderRadius.circular(4)),
                        child: const Center(
                            child: Text("1",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12)))),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildReviewRow(Employee e) {
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
                  backgroundImage: (e.profilePicture?.isNotEmpty ?? false)
                      ? NetworkImage(e.profilePicture!)
                      : null,
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText("${e.firstName} ${e.lastName}",
                        weight: 600, size: 13),
                    MyText(e.departmentId?.toString() ?? "IT",
                        size: 11, color: Colors.grey),
                  ],
                )
              ],
            ),
          ),
          const Expanded(
              flex: 2, child: MyText("2024-03-20", color: Colors.grey)),
          const Expanded(
              flex: 2,
              child: Row(children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star, color: Colors.amber, size: 16),
                Icon(Icons.star_border, color: Colors.amber, size: 16)
              ])),
          Expanded(
              flex: 1,
              child: Container(
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.more_vert,
                      size: 18, color: Colors.grey))),
        ],
      ),
    );
  }
}

// ==============================================================================
// TAB 4: BENEFITS
// ==============================================================================
class _BenefitsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _InfoCard(
                title: "Health Insurance (HMO)",
                hasEdit: true, // "Edit" button
                children: [
                  _DataField(
                      label: "Current Plan",
                      value: "Reliance Platinum",
                      isBoldValue: true),
                  _DataField(
                      label: "HMO ID Number",
                      value: "REL-313548",
                      isBoldValue: true),
                  _DataField(
                      label: "Dependents Covered",
                      value: "2",
                      isBoldValue: true),
                ],
              ),
            ),
            SizedBox(width: 24),
            Expanded(
              child: _InfoCard(
                title: "Pension Scheme",
                hasEdit: true,
                children: [
                  _DataField(
                      label: "PFA Provider",
                      value: "Stanbic IBTC",
                      isBoldValue: true),
                  _DataField(
                      label: "RSA Number",
                      value: "PEN100028344",
                      isBoldValue: true),
                  _DataField(
                      label: "Employer Contribution",
                      value: "10%",
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
          children: [
            _AllowanceRow("Housing", "10%"),
            _AllowanceRow("Transport", "10%"),
            _AllowanceRow("Data", "10%"),
          ],
        )
      ],
    );
  }

  Widget _AllowanceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            MyText(label, weight: 600, size: 14),
            MyText(value, color: Colors.grey, size: 12),
          ]),
          const Icon(Icons.delete_outline, color: Colors.red, size: 18)
        ],
      ),
    );
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
                    color: Color(0xFF0055FF),
                    weight: 600,
                    size: 12), // Default Edit
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
                color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
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
